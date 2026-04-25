#! /usr/bin/env node

import { execFileSync } from "node:child_process";
import { existsSync, readFileSync } from "node:fs";
import os from "node:os";
import path from "node:path";

try {
    const input = JSON.parse(readFileSync(process.stdin.fd, 'utf8'));
    if (!input.transcript_path) {
        process.exit(0);
    }

    const homeDir = os.homedir();
    let transcriptPath = input.transcript_path;

    if (transcriptPath.startsWith('~/')) {
        transcriptPath = path.join(homeDir, transcriptPath.slice(2));
    }

    const allowedBase = path.join(homeDir, '.claude', 'projects');
    const resolvedPath = path.resolve(transcriptPath);

    if (!resolvedPath.startsWith(allowedBase)) {
        process.exit(1);
    }

    if (!existsSync(resolvedPath)) {
        process.exit(0);
    }

    const lines = readFileSync(resolvedPath, "utf-8").split("\n").filter(line => line.trim());
    if (lines.length === 0) {
        process.exit(0);
    }

    // 末尾からテキストコンテンツを持つアシスタントメッセージを探す
    let lastMessageContent = null;
    for (let i = lines.length - 1; i >= Math.max(0, lines.length - 20); i--) {
        const entry = JSON.parse(lines[i]);
        const textBlock = entry?.message?.content?.find(c => c.type === 'text');
        if (textBlock?.text) {
            lastMessageContent = textBlock.text;
            break;
        }
    }

    if (!lastMessageContent) {
        process.exit(0);
    }

    // イベント種別に応じたタイトル設定
    const hookEventName = input.hook_event_name || 'Notification';
    const title = hookEventName === 'Stop'
        ? 'Claude Code - 完了'
        : 'Claude Code - 入力待ち';

    // メッセージの長さを制限（通知には長すぎる場合があるため）
    const maxLength = 200;
    const notificationMessage = lastMessageContent.length > maxLength
        ? lastMessageContent.substring(0, maxLength) + '...'
        : lastMessageContent;

    const isMacOS = process.platform === 'darwin';
    const isWindows = process.platform === 'win32';

    if (isMacOS) {
        // macOS: terminal-notifier + WezTermペインフォーカス
        const weztermPaneId = process.env.WEZTERM_PANE;
        let hasTerminalNotifier = false;
        try {
            execFileSync('/usr/bin/which', ['terminal-notifier'], { stdio: 'ignore' });
            hasTerminalNotifier = true;
        } catch {}

        if (hasTerminalNotifier) {
            const args = [
                '-title', title,
                '-message', notificationMessage,
                '-sound', 'default',
                '-group', `claude-code-${hookEventName}`,
            ];

            // WezTermペインIDが利用可能ならクリック時にペインをアクティベート
            if (weztermPaneId) {
                args.push(
                    '-execute',
                    `osascript -e 'tell application "WezTerm" to activate' ; wezterm cli activate-pane --pane-id ${weztermPaneId}`,
                );
            }

            execFileSync('terminal-notifier', args, { stdio: 'ignore' });
        } else {
            // フォールバック: osascript（クリック時アクションなし）
            const script = `
              on run {notificationTitle, notificationMessage}
                try
                  display notification notificationMessage with title notificationTitle
                end try
              end run
            `;
            execFileSync('osascript', ['-e', script, title, notificationMessage], {
                stdio: 'ignore'
            });
        }

    } else if (isWindows) {
        // Windows PowerShell通知
        const psScript = `
            try {
                if (Get-Module -ListAvailable -Name BurntToast) {
                    Import-Module BurntToast -ErrorAction Stop
                    New-BurntToastNotification -Text '${title}', '${notificationMessage.replace(/'/g, "''")}'
                } else {
                    Add-Type -AssemblyName System.Windows.Forms
                    [System.Windows.Forms.MessageBox]::Show('${notificationMessage.replace(/'/g, "''")}', '${title}', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
                }
            } catch {
                Write-Host '${title}' -ForegroundColor Cyan
                Write-Host '${notificationMessage.replace(/'/g, "''")}' -ForegroundColor White
            }
        `;

        execFileSync('powershell.exe', ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-Command', psScript], {
            stdio: 'ignore'
        });

    } else {
        // Linux/WSL2
        try {
            const psScript = `
                try {
                    if (Get-Module -ListAvailable -Name BurntToast) {
                        Import-Module BurntToast -ErrorAction Stop
                        New-BurntToastNotification -Text '${title}', '${notificationMessage.replace(/'/g, "''")}'
                    } else {
                        Add-Type -AssemblyName System.Windows.Forms
                        [System.Windows.Forms.MessageBox]::Show('${notificationMessage.replace(/'/g, "''")}', '${title}', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
                    }
                } catch {
                    Write-Host '${title}' -ForegroundColor Cyan
                    Write-Host '${notificationMessage.replace(/'/g, "''")}' -ForegroundColor White
                }
            `;
            execFileSync('powershell.exe', ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-Command', psScript], {
                stdio: 'ignore'
            });
        } catch {
            try {
                execFileSync('notify-send', [title, notificationMessage], {
                    stdio: 'ignore'
                });
            } catch {
                console.log(title);
                console.log(notificationMessage);
            }
        }
    }
} catch (error) {
    process.exit(1);
}
