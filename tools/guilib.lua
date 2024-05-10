local guilib = {}

function guilib.create_titlebar(parent, title)
    -- creates a draggable titlebar and returns the draggable flow of the titlebar
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
        caption = title
    }
    local widget = flow.add
    {
        type = 'empty_widget',
        style = 'draggable_space_header',
        ignored_by_interaction = true
    }
    widget.style.horizontally_stretchable = true
    widget.style.height = 24
    widget.style.right_margin = 4

    flow.drag_target = parent

    return flow
end

function guilib.create_content_frame(parent, direction)
    -- creates a content frame with a flow container inside and returns the flow container 
    local frame = parent.add
    {
        type = 'frame',
        style = 'inside_shallow_frame_with_padding'
    }
    return frame.add
    {
        type = 'flow',
        direction = direction
    }
end


function guilib.create_window(parent, direction, title)
    -- creates a window consisting of a titlebar and a content frame and returns the flow inside the content frame
    local frame = parent.add
    {
        type = 'frame'
    }
    guilib.create_titlebar(frame, title)
    return guilib.create_content_frame(parent, direction)
end