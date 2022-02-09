
local awful = require("awful")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
local utilities = require("utilities")

local terminal = "alacritty"

local modkey = "Mod4"


-- Mouse

client.connect_signal("request::default_mousebindings", function()
    awful.mouse.append_client_mousebindings({
        awful.button({ }, 1, function (c)
            c:activate { context = "mouse_click" }
        end),
        awful.button({ modkey }, 1, function (c)
            c:activate { context = "mouse_click", action = "mouse_move"  }
        end),
        awful.button({ modkey }, 3, function (c)
            c:activate { context = "mouse_click", action = "mouse_resize"}
        end),
    })
end)

client.connect_signal("mouse::enter", function(c)
    c:activate { context = "mouse_enter", raise = false }
end)

awful.mouse.append_global_mousebindings({
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewprev),
    awful.button({ }, 5, awful.tag.viewnext),
})

awful.mouse.snap.edge_enabled = false
awful.mouse.snap.client_enabled = true


-- Keyboard

client.connect_signal("request::default_keybindings", function()
    awful.keyboard.append_client_keybindings({
        awful.key({ modkey }, "f", function(c) c.fullscreen = not c.fullscreen; c:raise() end,
                {description = "toggle fullscreen", group = "client"}),

        awful.key({ modkey, "Shift" }, "c", function(c) c:kill() end,
                {description = "close", group = "client"}),

        awful.key({ modkey, "Control" }, "space", awful.client.floating.toggle,
                {description = "toggle floating", group = "client"}),

        awful.key({ modkey, "Control" }, "Return", function(c) c:swap(awful.client.getmaster()) end,
                {description = "move to master", group = "client"}),

        awful.key({ modkey }, "o", function(c) c:move_to_screen() end,
                {description = "move to screen", group = "client"}),

        awful.key({ modkey }, "t", function(c) c.ontop = not c.ontop end,
                {description = "toggle keep on top", group = "client"}),

        awful.key({ modkey }, "n", function(c) c.minimized = true end,
                {description = "minimize", group = "client"}),

        awful.key({ modkey }, "m", function(c) c.maximized = not c.maximized; c:raise() end,
                {description = "(un)maximize", group = "client"})
    })
end)

awful.keyboard.append_global_keybindings({
    -- General Awesome keys
    awful.key({ modkey }, "s", hotkeys_popup.show_help,
            {description="show help", group="awesome"}),

    awful.key({ modkey }, "w", function() mymainmenu:show() end,
            {description = "show main menu", group = "awesome"}),

    awful.key({ modkey, "Control" }, "r", awesome.restart,
            {description = "reload awesome", group = "awesome"}),

    awful.key({ modkey, "Shift" }, "q", awesome.quit,
            {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey }, "x", function() utilities.toggle_lua_widget(awful.screen.focused()) end,
            {description = "lua execute prompt", group = "awesome"}),

    awful.key({ modkey }, "Return", function() awful.spawn(terminal) end,
            {description = "open a terminal", group = "launcher"}),

    awful.key({ modkey }, "r", function() utilities.toggle_prompt_widget(awful.screen.focused()) end,
            {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "p", function() menubar.show() end,
            {description = "show the menubar", group = "launcher"}),

    -- Tags related keybindings
    awful.key({ modkey }, "Escape", awful.tag.history.restore,
            {description = "go back", group = "tag"}),

    -- Focus related keybindings
    awful.key({ modkey }, "j", function() awful.client.focus.byidx( 1) end,
            {description = "focus next by index", group = "client"}),

    awful.key({ modkey }, "k", function() awful.client.focus.byidx(-1) end,
            {description = "focus previous by index", group = "client"}),

    awful.key({ modkey }, "Tab",
            function()
                awful.client.focus.history.previous()
                if client.focus then
                    client.focus:raise()
                end
            end,
            {description = "go back", group = "client"}),

    awful.key({ modkey, "Control" }, "n",
            function()
                local c = awful.client.restore()
                -- Focus restored client
                if c then
                c:activate { raise = true, context = "key.unminimize" }
                end
            end,
            {description = "restore minimized", group = "client"}),

    -- Layout related keybindings
    awful.key({ modkey, "Shift" }, "j", function() awful.client.swap.byidx(1) end,
            {description = "swap with next client by index", group = "client"}),

    awful.key({ modkey, "Shift" }, "k", function() awful.client.swap.byidx(-1) end,
            {description = "swap with previous client by index", group = "client"}),

    awful.key({ modkey }, "u", awful.client.urgent.jumpto,
            {description = "jump to urgent client", group = "client"}),

    awful.key({ modkey }, "l", function() awful.tag.incmwfact( 0.05) end,
            {description = "increase master width factor", group = "layout"}),

    awful.key({ modkey }, "h", function() awful.tag.incmwfact(-0.05) end,
            {description = "decrease master width factor", group = "layout"}),

    awful.key({ modkey, "Shift" }, "h", function() awful.tag.incnmaster( 1, nil, true) end,
            {description = "increase the number of master clients", group = "layout"}),

    awful.key({ modkey, "Shift" }, "l", function() awful.tag.incnmaster(-1, nil, true) end,
            {description = "decrease the number of master clients", group = "layout"}),

    awful.key({ modkey, "Control" }, "h", function() awful.tag.incncol( 1, nil, true) end,
            {description = "increase the number of columns", group = "layout"}),

    awful.key({ modkey, "Control" }, "l", function() awful.tag.incncol(-1, nil, true) end,
            {description = "decrease the number of columns", group = "layout"}),

    awful.key({ modkey }, "space", function() awful.layout.inc(1) end,
            {description = "select next", group = "layout"}),

    awful.key({ modkey, "Shift" }, "space", function() awful.layout.inc(-1) end,
            {description = "select previous", group = "layout"}),

    -- Alt + Tab behavior
    awful.key({ "Mod1" }, "Tab", function() utilities.focus_next_client() end,
            {description = "Focus next client", group = "Focus"}),

    -- Number keys related bindings
    awful.key {
        modifiers   = { modkey },
        keygroup    = "numrow",
        description = "only view tag",
        group       = "tag",
        on_press    = function (index)
            local screen = awful.screen.focused()
            local tag = screen.tags[index]
            if tag then
                tag:view_only()
            end
        end,
    },
    awful.key {
        modifiers   = { modkey, "Control" },
        keygroup    = "numrow",
        description = "toggle tag",
        group       = "tag",
        on_press    = function (index)
            local screen = awful.screen.focused()
            local tag = screen.tags[index]
            if tag then
                awful.tag.viewtoggle(tag)
            end
        end,
    },
    awful.key {
        modifiers = { modkey, "Shift" },
        keygroup    = "numrow",
        description = "move focused client to tag",
        group       = "tag",
        on_press    = function (index)
            if client.focus then
                local tag = client.focus.screen.tags[index]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end,
    },
    awful.key {
        modifiers   = { modkey, "Control", "Shift" },
        keygroup    = "numrow",
        description = "toggle focused client on tag",
        group       = "tag",
        on_press    = function (index)
            if client.focus then
                local tag = client.focus.screen.tags[index]
                if tag then
                    client.focus:toggle_tag(tag)
                end
            end
        end,
    },
    awful.key {
        modifiers   = { modkey },
        keygroup    = "numpad",
        description = "select layout directly",
        group       = "layout",
        on_press    = function (index)
            local t = awful.screen.focused().selected_tag
            if t then
                t.layout = t.layouts[index] or t.layout
            end
        end,
    },


    -- Brightness control

    awful.key({}, "XF86MonBrightnessUp", function() utilities.raise_brightness() end,
    		{description = "Raise brightness", group = "Brightness"}),

    awful.key({}, "XF86MonBrightnessDown", function() utilities.lower_brightness() end,
    		{description = "Lower brightness", group = "Brightness"}),

    -- Volume control

    awful.key({}, "XF86AudioRaiseVolume", function() utilities.raise_volume() end,
            {description = "Raise volume", group = "Volume"}),
    
    awful.key({}, "XF86AudioLowerVolume", function() utilities.lower_volume() end,
            {description = "Lower volume", group = "Volume"}),

    awful.key({}, "XF86AudioMute", function() utilities.mute_volume() end,
            {description = "Toggle mute", group = "Volume"}),

    -- Media keys

    awful.key({}, "XF86AudioPlay", function() utilities.media_play_pause() end,
            {description = "Play/pause track", group = "Media"}),

    awful.key({}, "XF86AudioPrev", function() utilities.media_prev() end,
            {description = "Previous track", group = "Media"}),

    awful.key({}, "XF86AudioNext", function() utilities.media_next() end,
            {description = "Next track", group = "Media"}),

    -- Screenshot key
    
    awful.key({}, "Print", function() utilities.take_screenshot() end,
            {description = "Take screenshot", group = "Screenshot"})
})
