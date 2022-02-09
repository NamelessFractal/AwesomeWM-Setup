---------------------------
-- Default awesome theme --
---------------------------

local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local rnotification = require("ruled.notification")
local dpi = xresources.apply_dpi

local gears = { filesystem = require("gears.filesystem"), colors = require("gears.color") , shape = require("gears.shape") }
local themes_path = gears.filesystem.get_themes_dir()
local assets_folder = gears.filesystem.get_configuration_dir() .. "assets/"

local theme = {}

theme.font          = "Source Sans Pro 8"

theme.bg_normal     = "#2b2a2e"
theme.bg_focus      = "#535d6c"
theme.bg_urgent     = "#ff0000"
theme.bg_minimize   = "#444444"
theme.bg_systray    = theme.bg_normal

theme.fg_normal     = "#aaaaaa"
theme.fg_focus      = "#ffffff"
theme.fg_urgent     = "#ffffff"
theme.fg_minimize   = "#ffffff"

theme.useless_gap         = dpi(5)
theme.border_width        = dpi(1)
theme.border_color_normal = "#00000000"
theme.border_color_active = "#2b2a2e"
theme.border_color_marked = "#91231c"

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- taglist_[bg|fg]_[focus|urgent|occupied|empty|volatile]
-- tasklist_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- prompt_[fg|bg|fg_cursor|bg_cursor|font]
-- hotkeys_[bg|fg|border_width|border_color|shape|opacity|modifiers_fg|label_bg|label_fg|group_margin|font|description_font]
-- Example:
--theme.taglist_bg_focus = "#ff0000"

-- Generate taglist squares:
local taglist_square_size = dpi(4)
theme.taglist_squares_sel = theme_assets.taglist_squares_sel(
    taglist_square_size, theme.fg_normal
)
theme.taglist_squares_unsel = theme_assets.taglist_squares_unsel(
    taglist_square_size, theme.fg_normal
)

-- Variables set for theming notifications:
-- notification_font
-- notification_[bg|fg]
-- notification_[width|height|margin]
-- notification_[border_color|border_width|shape|opacity]

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = themes_path.."default/submenu.png"
theme.menu_height = dpi(15)
theme.menu_width  = dpi(100)

theme.menubar_bg_focus = "#14297d"

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = "#cc0000"

-- Define the image to load

-- Electric Blue
--theme.titlebar_bg_normal = "#0b3d8f"
--theme.titlebar_bg = "#0b3d8f"

-- Neon Purple
--theme.titlebar_bg_normal = "#6625e8"
--theme.titlebar_bg = "#6625e8"

-- Dark Blue
--theme.titlebar_bg_normal = "#0f3c70"
--theme.titlebar_bg = "#0f3c70"

--[[ theme.tasklist_disable_task_name = true
theme.tasklist_align = "center" ]]

theme.taglist_font = "Source Han Sans JP Medium"
theme.taglist_bg_focus = "#14297d"

theme.titlebar_bg_normal = "#2b2a2e"
theme.titlebar_bg = "#2b2a2e"

theme.titlebar_close_button_normal = assets_folder .. "titlebar/close_unfocused.svg"
theme.titlebar_close_button_focus = assets_folder .. "titlebar/close.svg"
theme.titlebar_close_button_focus_hover = assets_folder .. "titlebar/close_hover.svg"
theme.titlebar_close_button_focus_pressed = assets_folder .. "titlebar/close_pressed.svg"

theme.titlebar_minimize_button_normal = assets_folder .. "titlebar/minimize_unfocused.svg"
theme.titlebar_minimize_button_focus  = assets_folder .. "titlebar/minimize.svg"
theme.titlebar_minimize_button_focus_hover  = assets_folder .. "titlebar/minimize_hover.svg"
theme.titlebar_minimize_button_focus_pressed  = assets_folder .. "titlebar/minimize_pressed.svg"

theme.titlebar_maximized_button_normal_inactive = assets_folder .. "titlebar/maximize_unfocused.svg"
theme.titlebar_maximized_button_normal_active = assets_folder .. "titlebar/maximize_unfocused.svg"
theme.titlebar_maximized_button_focus_inactive  = assets_folder .. "titlebar/maximize.svg"
theme.titlebar_maximized_button_focus_active  = assets_folder .. "titlebar/maximize.svg"
theme.titlebar_maximized_button_focus_inactive_hover  = assets_folder .. "titlebar/maximize_hover.svg"
theme.titlebar_maximized_button_focus_active_hover  = assets_folder .. "titlebar/maximize_hover.svg"
theme.titlebar_maximized_button_focus_inactive_press  = assets_folder .. "titlebar/maximize_press.svg"
theme.titlebar_maximized_button_focus_active_press  = assets_folder .. "titlebar/maximize_press.svg"

theme.titlebar_ontop_button_normal_inactive = themes_path.."default/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive  = themes_path.."default/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = themes_path.."default/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active  = themes_path.."default/titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive = themes_path.."default/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive  = themes_path.."default/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = themes_path.."default/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active  = themes_path.."default/titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = themes_path.."default/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive  = themes_path.."default/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active = themes_path.."default/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active  = themes_path.."default/titlebar/floating_focus_active.png"

theme.wallpaper = "/home/dani/Wallpapers/winter.jpg"

theme.notification_font = "SF Pro Display Light"
theme.notification_shape = function (cr, width, height) gears.shape.rounded_rect(cr, width, height, 10) end
theme.notification_margin = 5

-- You can use your own layout icons like this:
theme.layout_fairh = themes_path.."default/layouts/fairhw.png"
theme.layout_fairv = themes_path.."default/layouts/fairvw.png"
theme.layout_floating  = themes_path.."default/layouts/floatingw.png"
theme.layout_magnifier = themes_path.."default/layouts/magnifierw.png"
theme.layout_max = themes_path.."default/layouts/maxw.png"
theme.layout_fullscreen = themes_path.."default/layouts/fullscreenw.png"
theme.layout_tilebottom = themes_path.."default/layouts/tilebottomw.png"
theme.layout_tileleft   = themes_path.."default/layouts/tileleftw.png"
theme.layout_tile = themes_path.."default/layouts/tilew.png"
theme.layout_tiletop = themes_path.."default/layouts/tiletopw.png"
theme.layout_spiral  = themes_path.."default/layouts/spiralw.png"
theme.layout_dwindle = themes_path.."default/layouts/dwindlew.png"
theme.layout_cornernw = themes_path.."default/layouts/cornernww.png"
theme.layout_cornerne = themes_path.."default/layouts/cornernew.png"
theme.layout_cornersw = themes_path.."default/layouts/cornersww.png"
theme.layout_cornerse = themes_path.."default/layouts/cornersew.png"

-- Generate Awesome icon:
theme.awesome_icon = theme_assets.awesome_icon(
    theme.menu_height, theme.bg_focus, theme.fg_focus
)

-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = nil

-- Set different colors for urgent notifications.
rnotification.connect_signal('request::rules', function()
    rnotification.append_rule {
        rule       = { urgency = 'critical' },
        properties = { bg = '#ff0000', fg = '#ffffff' }
    }
end)

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
