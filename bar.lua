
local awful = require("awful")
local gears = require("gears")
local menubar = require("menubar")
local wibox = require("wibox")

menubar.utils.terminal = "alacritty" -- Set the terminal for applications that require it
menubar.cache_entries = false

local utilities = require("utilities")
local script_folder = gears.filesystem.get_configuration_dir() .. "scripts/"
local assets_folder = gears.filesystem.get_configuration_dir() .. "assets/"
local modkey = "Mod4"

local function triangle(cr, width, height)
    cr:move_to(height, 0)
    cr:line_to(height, width)
    cr:line_to(0, width)
    cr:close_path()
end

local function double_separator_container(widget) 
    return {
        layout = wibox.layout.fixed.horizontal,
        {
            widget = wibox.widget.separator,
            shape = triangle,
            forced_width = 26,
            forced_height = 26,
            color = widget.bg,
        },
        widget,
        {
            widget = wibox.widget.separator,
            shape = gears.shape.transform(triangle):rotate_at(13, 13, math.pi),
            forced_width = 26,
            forced_height = 26,
            color = widget.bg,
        }
    }
end

-- TODO Refactor

local battery_widget = {
    {
        {
            {
                image = assets_folder .. "systembar/battery.svg",
                stylesheet = "* { color: #FFFFFF; }",
                downscale = true,
                valign = "center",
                halign = "center",
                forced_height = 18,
                forced_width = 18,
                widget = wibox.widget.imagebox
            },
            awful.widget.watch(script_folder .. "batteryPercentage.sh", 15, utilities.set_trimmed_output),
            spacing = 5,
            layout = wibox.layout.fixed.horizontal
        },
        left = 2,
        right = 2,
        widget = wibox.container.margin
    },
    bg = "#14297d",
    widget = wibox.container.background
}
        

local hour_widget = {
    {
        {
            image = assets_folder .. "systembar/clock.svg",
            stylesheet = "* { color: #FFFFFF; }",
            downscale = true,
            valign = "center",
            halign = "center",
            forced_height = 14,
            forced_width = 14,
            widget = wibox.widget.imagebox
        },
        awful.widget.watch("date +%H:%M", 1, utilities.set_trimmed_output),
        spacing = 5,
        layout = wibox.layout.fixed.horizontal
    },
    left = 2,
    widget = wibox.container.margin
}

wibox.widget.dock_icon = function (params)
    local t = wibox.widget {
        widget = wibox.widget.imagebox,
        docked = params.docked,
        image = params.image,
        class = params.class,
        name = params.name,
        exec = params.exec,
        opacity = 0.5,
        instances = {},
        -- TODO: Fix unnecesary instances being stored in a table
        -- TODO: Fix tags becoming urgent on warp
        menu = awful.menu(),
        add_instance = function (self, c)
            local n = #self.instances + 1
            self.instances[n] = c
            self.opacity = 1
        end,
        remove_instance = function(self, c)
            local found = false
            local i = 1
            while not found and i <= #self.instances do
                if(self.instances[i] == c) then
                    table.remove(self.instances, i)
                    found = true
                else
                    i = i + 1
                end
            end
            if #self.instances == 0 then
                self.opacity = 0.5
            end
        end,
        manage_instance = function(self, number)
            if self.instances[number] == client.focus then
                self.instances[number].minimized = true
            else
                self.instances[number]:activate({ switch_to_tag = true })
            end
        end,
        toggle_menu = function(self)
            awful.menu.client_list({}, {}, function(c) return self.class == c.class end)
        end
    }

    -- Add buttons
    t:connect_signal("button::press", function(self, lx, ly, button)
        if button == awful.button.names.LEFT then
            if #self.instances == 0 and self.exec ~= nil then
                awful.spawn(self.exec)
            elseif #self.instances == 1 then
                self:manage_instance(1)
            else
                self:toggle_menu()
            end
        elseif button == awful.button.names.RIGHT and self.exec ~= nil then
            awful.spawn(self.exec)
        end
    end)

    return t
end

local dock = wibox.widget {
    initialized = false,
    client_buffer = {},
    directory = gears.filesystem.get_configuration_dir() .. "dock/",
    layout = wibox.layout.fixed.horizontal,
    spacing = 3,
    load_icons = function(self)
        menubar.utils.parse_dir(self.directory, function(programs) 
            for _, i in pairs(programs) do
                self.children[#self.children + 1] = wibox.widget.dock_icon {
                    docked = true,
                    name = i["Name"],
                    exec = i["Exec"],
                    class = i["StartupWMClass"],
                    image = menubar.utils.lookup_icon(i["Icon"])
                }
            end
            table.sort(self.children, function (a, b) return a.name < b.name end)
            self:emit_signal_recursive("widget::layout_changed")
            self:emit_signal_recursive("widget::redraw_needed")
            for _, i in pairs(self.client_buffer) do
                self:add_client(i)
            end
            self.initialized = true
            self.client_buffer = {}
        end)
    end,
    add_client = function(self, c)
        local found = false
        local i = 1
        while not found and i <= #self.children do
            if self.children[i].class:lower() == c.class:lower() then   -- Comparison ignores upper/lowercase
                self.children[i]:add_instance(c)
                found = true
            else
                i = i + 1
            end
        end
        if not found then
            self.children[#self.children + 1] = wibox.widget.dock_icon {
                docked = false,
                name = c.class,
                class = c.class,
                exec = nil,
                image = c.icon
            }
            self.children[#self.children]:add_instance(c)
        end
        self:emit_signal_recursive("widget::layout_changed")
        self:emit_signal_recursive("widget::redraw_needed")
    end,
    remove_client = function(self, c)
        local found = false
        local i = 1
        while not found and i <= #self.children do
            if self.children[i].class:lower() == c.class:lower() then
                self.children[i]:remove_instance(c)
                if self.children[i].docked == false and #self.children[i].instances == 0 then
                    table.remove(self.children, i)
                    self:emit_signal_recursive("widget::layout_changed")
                    self:emit_signal_recursive("widget::redraw_needed")
                end
                found = true
            else
                i = i + 1
            end
        end
    end
}

client.connect_signal("request::manage", function(c)
    for s in screen do
        if s.dock ~= nil and c.class ~= nil then
            if s.dock.initialized then
                s.dock:add_client(c)
            else
                s.dock.client_buffer[#s.dock.client_buffer + 1] = c
            end
        end
    end
end)

client.connect_signal("request::unmanage", function(c)
    for s in screen do
        if s.dock ~= nil then
            s.dock:remove_client(c)
        end
    end
end)

client.connect_signal("property::class", function(c)    -- Workaround to get Spotify WM_CLASS
    if c.class:lower() == "spotify" and not awesome.startup then
        c:emit_signal("request::manage")
    end
end)

awesome.connect_signal("startup", function()
    for s in screen do
        if s.dock ~= nil then
            s.dock:load_icons()
        end
    end
end)

screen.connect_signal("request::desktop_decoration", function(s)

    awful.tag({ "一", "二", "三", "四", "五", "六", "七", "八", "九" }, s, awful.layout.layouts[1])

    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox {
        screen  = s,
        buttons = {
            awful.button({ }, 1, function () awful.layout.inc( 1) end),
            awful.button({ }, 3, function () awful.layout.inc(-1) end),
            awful.button({ }, 4, function () awful.layout.inc(-1) end),
            awful.button({ }, 5, function () awful.layout.inc( 1) end),
        }
    }

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = {
            awful.button({ }, 1, function(t) t:view_only() end),
            awful.button({ modkey }, 1, function(t)
                                            if client.focus then
                                                client.focus:move_to_tag(t)
                                            end
                                        end),
            awful.button({ }, 3, awful.tag.viewtoggle),
            awful.button({ modkey }, 3, function(t)
                                            if client.focus then
                                                client.focus:toggle_tag(t)
                                            end
                                        end),
            awful.button({ }, 4, function(t) awful.tag.viewprev(t.screen) end),
            awful.button({ }, 5, function(t) awful.tag.viewnext(t.screen) end),
        }
    }

    s.left_bar = wibox {
        x = 0,
        y = 1054,
        visible = true,
        width = 426,
        height = 26,
        shape = function(cr, width, height)
            cr:move_to(0, 0)
            cr:line_to(width, 0)
            cr:line_to(width - height, height)
            cr:line_to(0, height)
            cr:close_path()
        end,
        screen   = s,
        widget   = {
            layout = wibox.layout.align.horizontal,
            { -- Left widgets
                layout = wibox.layout.fixed.horizontal,
                {
                    s.mylayoutbox,
                    margins = 4,
                    widget = wibox.container.margin
                },
                s.mytaglist,
            },
            nil,
            nil
        }
    }
    
    s.left_bar:struts({ bottom = s.left_bar.height })

    s.dock = dock

    s.middle_bar = wibox {
        x = 426,
        y = 1054,
        visible = true,
        width = 1068,
        shape = function(cr, width, height)
            cr:move_to(height, 0)
            cr:line_to(width, 0)
            cr:line_to(width - height, height)
            cr:line_to(0, height)
            cr:close_path()
        end,
        height = s.left_bar.height,
        screen = s,
        widget = {
            layout = wibox.layout.align.horizontal,
            expand = "none",
            nil,
            wibox.container.margin(s.dock, 0, 0, 3, 3),
            nil,
        }
    }

    s.middle_bar:struts({ bottom = s.middle_bar.height })

    s.right_bar = wibox {
        x = 1496,
        y = 1054,
        visible = true,
        width = 426,
        height = s.left_bar.height,
        shape = function(cr, width, height)
            cr:move_to(0, height)
            cr:line_to(width, height)
            cr:line_to(width, 0)
            cr:line_to(height, 0)
            cr:close_path()
        end,
        screen   = s,
        widget = {
            layout = wibox.layout.align.horizontal,
            nil,
            nil,
            { -- Right widgets
                layout = wibox.layout.fixed.horizontal,
                wibox.widget.systray(),
                double_separator_container(battery_widget),
                wibox.container.margin(hour_widget, 0, 10, 0, 0),
            }
        }
    }

    s.right_bar:struts({ bottom = s.right_bar.height })

    s.prompt = wibox.widget {
        icon = assets_folder .. "systembar/command.svg",
        prompt = "Run: ",
        -- TODO Fix exe_callback not running
        exe_callback = function(command)
            awful.spawn.easy_async_with_shell('command -v "' .. command .. '"', function(stdout, stderr, exitreason, exitcode)
                if exitcode == 0 then awful.spawn(command) end
            end)
        end,
        done_callback = function()
            utilities.toggle_prompt_widget(s)
        end,
        widget = awful.widget.prompt
    }

    s.lua_prompt = {
        icon = assets_folder .. "systembar/lua.svg",
        run = function()
            awful.prompt.run {
                prompt = "Lua: ",
                textbox = s.prompt.children[1],
                exe_callback = function(command)
                    local f = load(command)
                    if f ~= nil then f() end
                end,
                done_callback = function() utilities.toggle_lua_widget(s) end,
                history_path = awful.util.get_cache_dir() .. "/history_eval",
                widget = awful.widget.prompt
            }
        end
    }

    s.prompt_icon = wibox.widget {
        image = s.prompt.icon,
        stylesheet = "* { color: #FFFFFF }",
        forced_height = 28,
        forced_width = 28,
        valign = "center",
        halign = "center",
        widget = wibox.widget.imagebox
    }

    s.prompt_widget = wibox {
        widget = {
            layout = wibox.layout.fixed.horizontal,
            margins = 20,
            {
                s.prompt_icon,
                left = 10,
                right = 10,
                widget = wibox.container.margin
            },
            s.prompt,
        },
        ontop = true,
        visible = true,
        locked = false,
        opacity = 1,
        type = "notification",
        shape = function(cr, width, height)
            cr:move_to(0, 0)
            cr:line_to(3/4 * width, 0)
            cr:line_to(width, height)
            cr:line_to(0, height)
            cr:close_path()
        end,
        x = -290,                -- Hidden by default
        y = 1080 - 60 - s.left_bar.height,
        width = 290,
        height = 50,
    }

end)

