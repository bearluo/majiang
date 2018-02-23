--
-- Author: shineflag
-- Date: 2017-02-24 17:51:26
--
-- 游戏中的圆形头像

local CircleClip = class("CircleClip", function()
	return  cc.ClippingNode:create() 
end)

function CircleClip:ctor(sp, mask)

	self:setAlphaThreshold(0.05)  --不显示模板的透明区域
	self:setInverted( false ) --显示模板不透明的部分

	mask = mask or "dec/zhezhao.png" 

	local stencil = mask
	if type(mask) == "string" then
		stencil = display.newSprite(mask) 
	end
	self.mStencil = stencil
	self:setStencil( stencil )

	if type(sp) == "string" then
		sp = display.newSprite( sp )
	end
	self.mSp = sp
	self:addChild(sp)
end

function CircleClip:setCircleClipContentSize(w,h)
	self:setContentSize(w,h)
	local sprite = self.mSp
	local scalX=w/sprite:getContentSize().width--设置x轴方向的缩放系数
	local scalY=h/sprite:getContentSize().height--设置y轴方向的缩放系数
	printInfo("setCircleClipContentSize sprite %d %d",scalX,scalY)
	sprite:setAnchorPoint(cc.p(0, 0))
			:setScaleX(scalX)
			:setScaleY(scalY)
	local mask = self.mStencil
	local scalX=w/mask:getContentSize().width--设置x轴方向的缩放系数
	local scalY=h/mask:getContentSize().height--设置y轴方向的缩放系数
	printInfo("setCircleClipContentSize mask %d %d",scalX,scalY)
	mask:setAnchorPoint(cc.p(0, 0))
			:setScaleX(scalX)
			:setScaleY(scalY)
	return self
end

return CircleClip
