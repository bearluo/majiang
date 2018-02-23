
local LayoutUtil = LayoutUtil or {}

function LayoutUtil:layoutLeft(view, target, offsetX, offsetY)
    LayoutUtil:layout(view, 1, 0.5, target, 0, 0.5, false, offsetX, offsetY)
end

function LayoutUtil:layoutRight(view, target, offsetX, offsetY)
    LayoutUtil:layout(view, 0, 0.5, target, 1, 0.5, false, offsetX, offsetY)
end

function LayoutUtil:layoutTop(view, target, offsetX, offsetY)
    LayoutUtil:layout(view, 0.5, 0, target, 0.5, 1, false, offsetX, offsetY)
end

function LayoutUtil:layoutBottom(view, target, offsetX, offsetY)
    LayoutUtil:layout(view, 0.5, 1, target, 0.5, 0, false, offsetX, offsetY)
end

function LayoutUtil:layoutCenter(view, target, offsetX, offsetY)
    LayoutUtil:layout(view, 0.5, 0.5, target, 0.5, 0.5, false, offsetX, offsetY)
end

function LayoutUtil:layoutTopLeft(view, target, offsetX, offsetY)
    LayoutUtil:layout(view, 1, 1, target, 0, 1, false, offsetX, offsetY)
end

function LayoutUtil:layoutTopRight(view, target, offsetX, offsetY)
    LayoutUtil:layout(view, 0, 1, target, 1, 1, false, offsetX, offsetY)
end

function LayoutUtil:layoutBottomLeft(view, target, offsetX, offsetY)
    LayoutUtil:layout(view, 1, 0, target, 0, 0, false, offsetX, offsetY)
end

function LayoutUtil:layoutBottomRight(view, target, offsetX, offsetY)
    LayoutUtil:layout(view, 0, 0, target, 1, 0, false, offsetX, offsetY)
end

function LayoutUtil:layoutParentLeft(view, offsetX, offsetY)
    LayoutUtil:layout(view, 0, 0.5, view:getParent(), 0, 0.5, true, offsetX, offsetY)
end

function LayoutUtil:layoutParentRight(view, offsetX, offsetY)
    LayoutUtil:layout(view, 1, 0.5, view:getParent(), 1, 0.5, true, offsetX, offsetY)
end

function LayoutUtil:layoutParentTop(view, offsetX, offsetY)
    LayoutUtil:layout(view, 0.5, 1, view:getParent(), 0.5, 1, true, offsetX, offsetY)
end

function LayoutUtil:layoutParentBottom(view, offsetX, offsetY)
    LayoutUtil:layout(view, 0.5, 0, view:getParent(), 0.5, 0, true, offsetX, offsetY)
end

function LayoutUtil:layoutParentCenter(view, offsetX, offsetY)
    LayoutUtil:layout(view, 0.5, 0.5, view:getParent(), 0.5, 0.5, true, offsetX, offsetY)
end

function LayoutUtil:layoutParentTopLeft(view, offsetX, offsetY)
    LayoutUtil:layout(view, 0, 1,view:getParent(), 0, 1, true, offsetX, offsetY)
end

function LayoutUtil:layoutParentTopRight(view, offsetX, offsetY)
    LayoutUtil:layout(view, 1, 1, view:getParent(), 1, 1, true, offsetX, offsetY)
end

function LayoutUtil:layoutParentBottomLeft(view, offsetX, offsetY)
    LayoutUtil:layout(view, 0, 0, view:getParent(), 0, 0, true, offsetX, offsetY)
end

function LayoutUtil:layoutParentBottomRight(view, offsetX, offsetY)
    LayoutUtil:layout(view, 1, 0, view:getParent(), 1, 0, true, offsetX, offsetY)
end

function LayoutUtil:layout(src, srcAlignX, srcAlignY, target, targetAlignX, targetAlignY, targetIsParent, offsetX, offsetY)
	targetIsParent = targetIsParent or false
	offsetY = offsetY or 0
	offsetX = offsetX or 0
	local srcAnchorPoint = src:getAnchorPoint()
    local anchorPointDiff = cc.p(srcAlignX - srcAnchorPoint.x, srcAlignY - srcAnchorPoint.y)
    local targetAnchorPoint = target:getAnchorPoint()
    local targetAlignXPosition = 0
    local targetAlignYPosition = 0
    if targetIsParent then
        targetAlignXPosition = target:getContentSize().width * targetAlignX
        targetAlignYPosition = target:getContentSize().height * targetAlignY
    else
        targetAlignXPosition = target:getPositionX() + target:getBoundingBox().width * (targetAlignX - targetAnchorPoint.x)
        targetAlignYPosition = target:getPositionY() + target:getBoundingBox().height * (targetAlignY - targetAnchorPoint.y)
    end
    src:setPosition(cc.p(targetAlignXPosition - anchorPointDiff.x * src:getBoundingBox().width + offsetX,
                         targetAlignYPosition - anchorPointDiff.y * src:getBoundingBox().height + offsetY))
end

return LayoutUtil