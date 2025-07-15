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
        console.log('Hook execution failed: Transcript file does not exist');
        process.exit(0);
    }

    const lines = readFileSync(resolvedPath, "utf-8").split("\n").filter(line => line.trim());
    if (lines.length === 0) {
        console.log('Hook execution failed: Transcript file is empty');
        process.exit(0);
    }

    const lastLine = lines[lines.length - 1];
    const transcript = JSON.parse(lastLine);
    const lastMessageContent = transcript?.message?.content?.[0]?.text;

    if (lastMessageContent) {
        // OS判定
        const isWindows = process.platform === 'win32';
        const isMacOS = process.platform === 'darwin';
        
        // メッセージの長さを制限（通知には長すぎる場合があるため）
        const maxLength = 200;
        const notificationMessage = lastMessageContent.length > maxLength 
            ? lastMessageContent.substring(0, maxLength) + '...'
            : lastMessageContent;

        if (isWindows) {
            // Windows PowerShell通知
            const psScript = `
                try {
                    # BurntToastモジュールの使用を試行
                    if (Get-Module -ListAvailable -Name BurntToast) {
                        Import-Module BurntToast -ErrorAction Stop
                        New-BurntToastNotification -Text 'Claude Code', '${notificationMessage.replace(/'/g, "''")}'
                    } else {
                        # フォールバック: 標準メッセージボックス
                        Add-Type -AssemblyName System.Windows.Forms
                        [System.Windows.Forms.MessageBox]::Show('${notificationMessage.replace(/'/g, "''")}', 'Claude Code', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
                    }
                } catch {
                    # 最終フォールバック: コンソール出力
                    Write-Host '🔔 Claude Code Notification 🔔' -ForegroundColor Cyan
                    Write-Host '${notificationMessage.replace(/'/g, "''")}' -ForegroundColor White
                }
            `;

            execFileSync('powershell.exe', ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-Command', psScript], {
                stdio: 'ignore'
            });

        } else if (isMacOS) {
            // macOS AppleScript通知
            const script = `
              on run {notificationTitle, notificationMessage}
                try
                  display notification notificationMessage with title notificationTitle
                end try
              end run
            `;
            execFileSync('osascript', ['-e', script, "Claude Code", notificationMessage], {
                stdio: 'ignore'
            });

        } else {
            // Linux/WSL2 - PowerShell経由でWindows通知を試行
            try {
                // WSL2の場合、Windows側のPowerShellで通知
                const psScript = `
                    try {
                        # BurntToastモジュールの使用を試行
                        if (Get-Module -ListAvailable -Name BurntToast) {
                            Import-Module BurntToast -ErrorAction Stop
                            New-BurntToastNotification -Text 'Claude Code', '${notificationMessage.replace(/'/g, "''")}'
                        } else {
                            # フォールバック: 標準メッセージボックス
                            Add-Type -AssemblyName System.Windows.Forms
                            [System.Windows.Forms.MessageBox]::Show('${notificationMessage.replace(/'/g, "''")}', 'Claude Code', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
                        }
                    } catch {
                        # 最終フォールバック: コンソール出力
                        Write-Host '🔔 Claude Code Notification 🔔' -ForegroundColor Cyan
                        Write-Host '${notificationMessage.replace(/'/g, "''")}' -ForegroundColor White
                    }
                `;
                
                execFileSync('powershell.exe', ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-Command', psScript], {
                    stdio: 'ignore'
                });
            } catch (error) {
                // powershell.exeが利用できない場合は、notify-sendを試行
                try {
                    execFileSync('notify-send', ['Claude Code', notificationMessage], {
                        stdio: 'ignore'
                    });
                } catch {
                    // 最終フォールバック: コンソール出力
                    console.log('🔔 Claude Code Notification 🔔');
                    console.log(notificationMessage);
                }
            }
        }
    }
} catch (error) {
    console.log('Hook execution failed:', error.message);
    process.exit(1);
}