local wezterm = require("wezterm")
-- プラグインはwezterm.luaで既に読み込まれているため、グローバル変数から取得
-- または、ここで再度読み込む（weztermはプラグインのキャッシュを管理するため問題なし）
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")

local M = {}

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
		-- Workspace全体を保存
		{
			key = "w",
			mods = "CTRL|ALT",
			action = wezterm.action_callback(function(win, pane)
				resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state())
			end),
		},
		-- 現在のウィンドウを保存
		{
			key = "W",
			mods = "CTRL|ALT|SHIFT",
			action = resurrect.window_state.save_window_action(),
		},
		-- 現在のタブを保存
		{
			key = "T",
			mods = "CTRL|ALT|SHIFT",
			action = resurrect.tab_state.save_tab_action(),
		},
		-- Workspace全体とウィンドウを保存
		-- ALT+sはLEADERキーとして使用されている可能性があるため、CTRL+ALT+sを使用
		{
			key = "s",
			mods = "CTRL|ALT",
			action = wezterm.action_callback(function(win, pane)
				resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state())
				resurrect.window_state.save_window_action()
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
					elseif type == "window" then
						local state = resurrect.state_manager.load_state(id, "window")
						resurrect.window_state.restore_window(pane:window(), state, opts)
					elseif type == "tab" then
						local state = resurrect.state_manager.load_state(id, "tab")
						resurrect.tab_state.restore_tab(pane:tab(), state, opts)
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
				end, {
					title = "Delete State",
					description = "Select State to Delete and press Enter = accept, Esc = cancel, / = filter",
					fuzzy_description = "Search State to Delete: ",
					is_fuzzy = true,
				})
			end),
		},
	}
end

return M
