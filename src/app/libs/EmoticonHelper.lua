EmoticonHelper = {}

EmoticonHelper.factory = {}

function EmoticonHelper.createEmoticonById(emoticon_id)
	if EmoticonHelper.factory[emoticon_id] then return EmoticonHelper.factory[emoticon_id]() end
end


local configs = {
	{8,2},
	{6,3},
	{35,1},
	{15,1},
	{40,1},
	{35,1},
	{15,1},
	{3,5},
	{45,1},
	{30,1},
	{30,1},
	{10,1},
	{21,1},
	{10,1},
	{19,1},
	{28,1},
	{10,2},
	{34,1},
	{24,1},
	{20,1},
	{16,1},
	{17,1},
	{25,1},
	{26,1},
	{37,1},
	{18,1},
	{25,1},
	{15,1},
	{30,1},
	{28,1},
	{22,1},
	{6,3},
}
EmoticonHelper.configs=configs

local delayPerUnit = 1/10
for i,config in ipairs(configs) do
	local frameNum = configs[i][1]
	local loops = configs[i][2]
	EmoticonHelper.factory[i] = function()
		local frameSprite = display.newSprite(string.format("emoticon/%d/1.png",i))
		local frameAnim = cc.Animation:create()
		frameAnim:setDelayPerUnit(delayPerUnit)
		for j=1,frameNum do
			frameAnim:addSpriteFrameWithFile( string.format("emoticon/%d/%d.png",i,j))
		end
		frameAnim:setLoops(loops)
		local animate = cc.Animate:create(frameAnim)

		local emoticon = {}
		emoticon.frameSprite = frameSprite
		emoticon.play = function()
			frameSprite:runAction(animate)
			return frameNum*delayPerUnit*loops
		end
		return emoticon
	end
end

return EmoticonHelper