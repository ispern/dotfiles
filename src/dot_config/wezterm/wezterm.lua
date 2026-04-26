local wezterm = require("wezterm")
local config = wezterm.config_builder()

local is_windows = wezterm.target_triple:find("windows") ~= nil

local resurrect_plugin = nil
if not is_windows then
	resurrect_plugin = require("plugins/resurrect")
end

if is_windows then
	config.default_domain = "WSL:Ubuntu-24.04"
	config.front_end = "WebGpu"
else
	-- macOS / Linux: launch Nix-provided fish directly so we don't depend on
	-- the login shell (which can drift after brew uninstall / chsh).
	config.default_prog = { "/run/current-system/sw/bin/fish", "-l" }
end

config.automatically_reload_config = true
config.font = wezterm.font("UDEV Gothic NF", {
	weight = "Medium",
})
config.font_size = 16.0
config.use_ime = true
config.window_background_opacity = 0.97
config.macos_window_background_blur = 20

----------------------------------------------------
-- Colors
----------------------------------------------------
-- TOMLファイルから色スキームを読み込む
print(wezterm.config_dir)
local colors = wezterm.color.load_scheme(wezterm.config_dir .. "/colors/kanagawa-paper-ink.toml")
config.color_scheme = "kanagawa-paper-ink"
config.window_frame = {
	inactive_titlebar_bg = "none",
	active_titlebar_bg = "none",
}
config.window_background_gradient = {
	colors = { colors.background },
}

----------------------------------------------------
-- Tab
----------------------------------------------------
-- macOS / Linux はタイトルバー非表示でリサイズのみ。
-- Windows はネイティブのタイトルバー (最小化 / 最大化 / 閉じるボタン) を表示。
config.window_decorations = is_windows and "TITLE | RESIZE" or "RESIZE"
-- タブバーの表示
config.show_tabs_in_tab_bar = true
-- タブが一つの時は非表示
config.hide_tab_bar_if_only_one_tab = true
-- falseにするとタブバーの透過が効かなくなる
-- config.use_fancy_tab_bar = false

-- タブバーの透過
config.window_frame = {
	inactive_titlebar_bg = "none",
	active_titlebar_bg = "none",
}

-- タブの追加ボタンを非表示
config.show_new_tab_button_in_tab_bar = false
-- nightlyのみ使用可能
-- タブの閉じるボタンを非表示
config.show_close_tab_button_in_tabs = false
-- タブの境界線を非表示
config.colors = {
	tab_bar = {
		inactive_tab_edge = "none",
	},
}

-- タブの形をカスタマイズ
-- タブの左側の装飾
local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_lower_right_triangle
-- タブの右側の装飾
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_upper_left_triangle
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	-- Kanagawa Wave color scheme colors
	local background = colors.background -- scrollbar_thumb color for inactive tabs
	local foreground = colors.foreground -- foreground color
	local edge_background = "none"
	if tab.is_active then
		background = colors.selection_bg -- selection_bg color for active tab
		foreground = colors.foreground -- cursor_bg color for active tab text
	end
	local edge_foreground = background
	local title = "   " .. wezterm.truncate_right(tab.active_pane.title, max_width - 1) .. "   "
	return {
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = edge_foreground } },
		{ Text = SOLID_LEFT_ARROW },
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = title },
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = edge_foreground } },
		{ Text = SOLID_RIGHT_ARROW },
	}
end)

----------------------------------------------------
-- keybinds
----------------------------------------------------
config.disable_default_key_bindings = true
-- 既存のキーバインドを読み込む
local base_keys = require("keybindings").keys
-- resurrectプラグインのキーバインドを追加（Windows以外）
if resurrect_plugin then
	local resurrect_keys = resurrect_plugin.keys()
	for _, key_binding in ipairs(resurrect_keys) do
		table.insert(base_keys, key_binding)
	end
end
config.keys = base_keys
config.key_tables = require("keybindings").key_tables
config.leader = { key = "g", mods = "CTRL", timeout_milliseconds = 2000 }

return config
