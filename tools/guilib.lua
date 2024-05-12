local guilib = {}

local function create_titlebar(parent, title)
    -- creates a draggable titlebar using a flow containing
    -- a label and an empty widget to pad the bar width
    -- returns:
    -- LuaGuiElement :: the flow element containing the title and the padding widget
    local flow = parent.add
    {
        type = 'flow'
    }
    flow.style.vertical_align = 'center'

    local label = flow.add
    {
        type = 'label',
        style = 'frame_title',
        ignored_by_interaction = true,
        caption = title or 'TD'
    }
    local widget = flow.add
    {
        type = 'empty-widget',
        style = 'draggable_space_header',
        ignored_by_interaction = true
    }
    widget.style.horizontally_stretchable = true
    widget.style.height = 24
    widget.style.right_margin = 4

    flow.drag_target = parent.parent

    return flow
end

function guilib.create_content_frame(parent, direction)
    -- creates a frame containing a flow, with some paddings
    -- returns:
    -- LuaGuiElement :: the flow element to add content to
    local frame = parent.add
    {
        type = 'frame',
        style = 'inside_shallow_frame_with_padding'
    }
    return frame.add
    {
        type = 'flow',
        direction = direction or 'horizontal'
    }
end

function guilib.create_window(parent, direction, title)
    -- creates a window consisting of a titlebar and a content frame
    -- returns 2 values:
    -- (1): LuaGuiElement :: the frame (so you can close the window)
    -- (2): LuaGuiElement :: the flow inside the content frame (so you can add content)
    -- usage:
    -- local my_frame, my_flow = guilib.create_window(player.gui.center, 'vertical', 'Title')
    local frame = parent.add
    {
        type = 'frame',
    }
    local flow = frame.add
    {
        type = 'flow',
        direction = 'vertical'
    }
    frame.force_auto_center()
    create_titlebar(flow, title)
    return frame, guilib.create_content_frame(flow, direction)
end

return guilib