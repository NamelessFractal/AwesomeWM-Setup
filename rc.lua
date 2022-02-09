-- awesome_mode: api-level=4:screen=on
-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Declarative object management
local ruled = require("ruled")
local naughty = require("naughty")
local hotkeys_popup = require("awful.hotkeys_popup")

-- Error notifications

naughty.connect_signal("request::display_error", function(message, startup)
    naughty.notification {
        urgency = "critical",
        title   = "Oops, an error happened"..(startup and " during startup!" or "!"),
        message = message
    }
end)

beautiful.init(gears.filesystem.get_configuration_dir() .. "theme.lua")

-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

require("bar")
require("bindings")
require("notifications")

-- This is used later as the default terminal and editor to run.

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

mymainmenu = awful.menu { 
    items = { 
        { "awesome", myawesomemenu, beautiful.awesome_icon },
    }
}

-- {{{ Tag layout
-- Table of layouts to cover with awful.layout.inc, order matters.

-- TODO Remove magnifier layout
tag.connect_signal("request::default_layouts", function()
    awful.layout.append_default_layouts({
        awful.layout.suit.floating,
        awful.layout.suit.tile,
        awful.layout.suit.tile.left,
        awful.layout.suit.tile.bottom,
        awful.layout.suit.tile.top,
        awful.layout.suit.fair,
        awful.layout.suit.fair.horizontal,
        awful.layout.suit.spiral,
        awful.layout.suit.spiral.dwindle,
        awful.layout.suit.max,
        awful.layout.suit.max.fullscreen,
        awful.layout.suit.magnifier,
        awful.layout.suit.corner.nw,
    })
end)
-- }}}

-- {{{ Wallpaper
screen.connect_signal("request::wallpaper", function(s)
    awful.wallpaper {
        screen = s,
        widget = {
            {
                image     = beautiful.wallpaper,
                upscale   = true,
                downscale = true,
                widget    = wibox.widget.imagebox,
            },
            valign = "center",
            halign = "center",
            tiled  = false,
            widget = wibox.container.tile,
        }
    }
end)
-- }}}

client.connect_signal("request::manage", function(c)
    c.shape = function(cr, width, height)
        if not c.maximized and not c.fullscreen then
            gears.shape.rounded_rect(cr, width, height, 10)
        else
            gears.shape.rectangle(cr, width, height)
        end
    end
end)

-- {{{ Rules
-- Rules to apply to new clients.
ruled.client.connect_signal("request::rules", function()
    -- All clients will match this rule.
    ruled.client.append_rule {
        id         = "global",
        rule       = { },
        properties = {
            focus     = awful.client.focus.filter,
            raise     = true,
            screen    = awful.screen.preferred,
            placement = awful.placement.no_overlap+awful.placement.no_offscreen
        }
    }

    -- Floating clients.
    ruled.client.append_rule {
        id       = "floating",
        rule_any = {
            instance = { "copyq", "pinentry" },
            class    = {
                "Arandr", "Blueman-manager", "Gpick", "Kruler", "Sxiv",
                "Tor Browser", "Wpa_gui", "veromix", "xtightvncviewer"
            },
            -- Note that the name property shown in xprop might be set slightly after creation of the client
            -- and the name shown there might not match defined rules here.
            name    = {
                "Event Tester",  -- xev.
            },
            role    = {
                "AlarmWindow",    -- Thunderbird's calendar.
                "ConfigManager",  -- Thunderbird's about:config.
                "pop-up",         -- e.g. Google Chrome's (detached) Developer Tools.
            }
        },
        properties = { floating = true }
    }

    -- Add titlebars to normal clients and dialogs
    ruled.client.append_rule {
        id         = "titlebars",
        rule_any   = { type = { "normal", "dialog" } },
        properties = { titlebars_enabled = true      }
    }

    ruled.client.append_rule {
        id         = "notitlebars",
        rule       = { requests_no_titlebar = true },
        properties = { titlebars_enabled = false }
    }

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- ruled.client.append_rule {
    --     rule       = { class = "Firefox"     },
    --     properties = { screen = 1, tag = "2" }
    -- }
end)

awful.titlebar.enable_tooltip = false

-- {{{ Titlebars
-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)

    awful.titlebar(c, {size = 20}).widget = {
        { -- Left
            wibox.container.margin(awful.titlebar.widget.iconwidget (c), 5, 2, 2, 2),
            wibox.container.margin(awful.titlebar.widget.floatingbutton (c), 2, 2, 2, 2),
            wibox.container.margin(awful.titlebar.widget.stickybutton (c), 2, 2, 2, 2),
            wibox.container.margin(awful.titlebar.widget.ontopbutton (c), 2, 0, 2, 2),
            layout = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = {
                awful.button({ }, 1, function()
                    c:activate { context = "titlebar", action = "mouse_move"  }
                end),
                awful.button({ }, 3, function()
                    c:activate { context = "titlebar", action = "mouse_resize"}
                end),
            },
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            wibox.container.margin(awful.titlebar.widget.maximizedbutton (c), 0, 2, 2, 2),
            wibox.container.margin(awful.titlebar.widget.minimizebutton (c), 2, 2, 2, 2),
            wibox.container.margin(awful.titlebar.widget.closebutton (c), 2, 5, 2, 2),
            layout = wibox.layout.fixed.horizontal,
        },
        layout = wibox.layout.align.horizontal,
    }

end)

-- }}}

-- Additional programs to launch

awful.spawn.with_shell("ps -C picom || picom --experimental-backends &")
awful.spawn.with_shell("ps -C playerctld || playerctld daemon")
awful.spawn.with_shell("ps -C keepassxc || keepassxc")
