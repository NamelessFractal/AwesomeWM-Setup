
local gears = require("gears")

local animations = {
    slide = function(widget, fx, fy, animation_time, start_callback, end_callback)
        if not widget.locked then
            widget.locked = true
            start_callback()
            local frame_counter = 0
            local frame_number = math.ceil(animation_time * 60)     -- 60 FPS or more
            local frame_step_x = math.floor((fx - widget.x) / frame_number)
            local frame_step_y = math.floor((fy - widget.y) / frame_number)
            local extra_steps_x = (fx - widget.x) % frame_number
            local extra_steps_y = (fy - widget.y) % frame_number
            gears.timer.start_new(animation_time/frame_number, function()
                widget.x = frame_counter < extra_steps_x and widget.x + frame_step_x + 1 or widget.x + frame_step_x
                widget.y = frame_counter < extra_steps_y and widget.y + frame_step_y + 1 or widget.y + frame_step_y
                frame_counter = frame_counter + 1
                if frame_counter == frame_number then
                    widget.locked = false
                    end_callback()
                end
                return widget.locked
            end)
        end
    end
}

return animations