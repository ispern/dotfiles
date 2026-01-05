local wezterm = require("wezterm")
-- プラグインはwezterm.luaで既に読み込まれているため、グローバル変数から取得
-- または、ここで再度読み込む（weztermはプラグインのキャッシュを管理するため問題なし）
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")

local M = {}

-- 通知を表示するヘルパー関数
local function notify(win, title, message)
	win:toast_notification("Resurrect", title .. ": " .. message, nil, 3000)
end

-- プラグインの設定を返す
function M.setup()
	return {
		resurrect = resurrect,
	}
end

-- キーバインドを返す
-- 既存のキーバインドとの競合を避けるため、CTRL+ALTを使用
function M.keys()
	return {
		-- Workspace全体を保存（名前入力付き）
		{
			key = "w",
			mods = "CTRL|ALT",
			action = wezterm.action_callback(function(win, pane)
				win:perform_action(
					wezterm.action.PromptInputLine({
						description = "Enter workspace name:",
						action = wezterm.action_callback(function(inner_win, inner_pane, line)
							if line and line ~= "" then
								local state = resurrect.workspace_state.get_workspace_state()
								resurrect.state_manager.save_state(state, line)
								notify(inner_win, "Workspace saved", line)
							else
								notify(inner_win, "Cancelled", "No name provided")
							end
						end),
					}),
					pane
				)
			end),
		},
		-- 現在のウィンドウを保存（名前入力付き）
		{
			key = "W",
			mods = "CTRL|ALT|SHIFT",
			action = wezterm.action_callback(function(win, pane)
				win:perform_action(
					wezterm.action.PromptInputLine({
						description = "Enter window name:",
						action = wezterm.action_callback(function(inner_win, inner_pane, line)
							if line and line ~= "" then
								local state = resurrect.window_state.get_window_state(inner_win:mux_window())
								resurrect.state_manager.save_state(state, line)
								notify(inner_win, "Window saved", line)
							else
								notify(inner_win, "Cancelled", "No name provided")
							end
						end),
					}),
					pane
				)
			end),
		},
		-- 現在のタブを保存（名前入力付き）
		{
			key = "T",
			mods = "CTRL|ALT|SHIFT",
			action = wezterm.action_callback(function(win, pane)
				win:perform_action(
					wezterm.action.PromptInputLine({
						description = "Enter tab name:",
						action = wezterm.action_callback(function(inner_win, inner_pane, line)
							if line and line ~= "" then
								local state = resurrect.tab_state.get_tab_state(inner_pane:tab())
								resurrect.state_manager.save_state(state, line)
								notify(inner_win, "Tab saved", line)
							else
								notify(inner_win, "Cancelled", "No name provided")
							end
						end),
					}),
					pane
				)
			end),
		},
		-- Workspace全体とウィンドウを保存（名前入力付き）
		-- ALT+sはLEADERキーとして使用されている可能性があるため、CTRL+ALT+sを使用
		{
			key = "s",
			mods = "CTRL|ALT",
			action = wezterm.action_callback(function(win, pane)
				win:perform_action(
					wezterm.action.PromptInputLine({
						description = "Enter name (saves both workspace and window):",
						action = wezterm.action_callback(function(inner_win, inner_pane, line)
							if line and line ~= "" then
								local ws_state = resurrect.workspace_state.get_workspace_state()
								resurrect.state_manager.save_state(ws_state, line)
								local win_state = resurrect.window_state.get_window_state(inner_win:mux_window())
								resurrect.state_manager.save_state(win_state, line .. "_window")
								notify(inner_win, "Saved", line .. " (workspace & window)")
							else
								notify(inner_win, "Cancelled", "No name provided")
							end
						end),
					}),
					pane
				)
			end),
		},
		-- 保存された状態を復元（ファジーファインダー）
		-- ALT+rは設定再読み込みとして使用されているため、CTRL+ALT+rを使用
		{
			key = "r",
			mods = "CTRL|ALT",
			action = wezterm.action_callback(function(win, pane)
				resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id, label)
					local type = string.match(id, "^([^/]+)") -- match before '/'
					id = string.match(id, "([^/]+)$") -- match after '/'
					id = string.match(id, "(.+)%..+$") -- remove file extention
					local opts = {
						relative = true,
						restore_text = true,
						on_pane_restore = resurrect.tab_state.default_on_pane_restore,
					}
					if type == "workspace" then
						local state = resurrect.state_manager.load_state(id, "workspace")
						resurrect.workspace_state.restore_workspace(state, opts)
						notify(win, "Workspace restored", id)
					elseif type == "window" then
						local state = resurrect.state_manager.load_state(id, "window")
						resurrect.window_state.restore_window(pane:window(), state, opts)
						notify(win, "Window restored", id)
					elseif type == "tab" then
						local state = resurrect.state_manager.load_state(id, "tab")
						resurrect.tab_state.restore_tab(pane:tab(), state, opts)
						notify(win, "Tab restored", id)
					end
				end)
			end),
		},
		{
			key = "d",
			mods = "CTRL|ALT",
			action = wezterm.action_callback(function(win, pane)
				resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id)
					resurrect.state_manager.delete_state(id)
					notify(win, "Deleted", id)
				end, {
					title = "Delete State",
					description = "Select State to Delete and press Enter = accept, Esc = cancel, / = filter",
					fuzzy_description = "Search State to Delete: ",
					is_fuzzy = true,
				})
			end),
		},
		-- 新規ウィンドウに保存された状態を復元
		{
			key = "n",
			mods = "CTRL|ALT",
			action = wezterm.action_callback(function(win, pane)
				resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id, label)
					local type = string.match(id, "^([^/]+)") -- match before '/'
					id = string.match(id, "([^/]+)$") -- match after '/'
					id = string.match(id, "(.+)%..+$") -- remove file extension
					local opts = {
						relative = true,
						restore_text = true,
						on_pane_restore = resurrect.tab_state.default_on_pane_restore,
					}
					if type == "window" then
						-- 新しいウィンドウを作成して復元
						local new_tab, new_pane, new_window = wezterm.mux.spawn_window({})
						local state = resurrect.state_manager.load_state(id, "window")
						resurrect.window_state.restore_window(new_window:gui_window(), state, opts)
						notify(win, "Window restored to new window", id)
					elseif type == "tab" then
						-- 新しいウィンドウを作成してタブを復元
						local new_tab, new_pane, new_window = wezterm.mux.spawn_window({})
						local state = resurrect.state_manager.load_state(id, "tab")
						resurrect.tab_state.restore_tab(new_tab, state, opts)
						notify(win, "Tab restored to new window", id)
					elseif type == "workspace" then
						-- workspaceは新規ウィンドウではなく通常の復元を行う
						local state = resurrect.state_manager.load_state(id, "workspace")
						resurrect.workspace_state.restore_workspace(state, opts)
						notify(win, "Workspace restored", id)
					end
				end, {
					title = "Restore to New Window",
					description = "Select state to restore in new window (Enter = accept, Esc = cancel)",
					fuzzy_description = "Search: ",
					is_fuzzy = true,
				})
			end),
		},
	}
end

return M
