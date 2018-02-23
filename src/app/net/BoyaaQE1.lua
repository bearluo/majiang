

--[[
#pragma pack(1)
struct TPkgHeader
{    
    int length;
    char  flag[2];
    short  cVersion;
    int   cmd;
    short gameid;
    short regionid;
    char deviceid;
    unsigned char code;
};
#pragma pack()
--]]

local sendmap = {
	[0] = 	0x80,0x98,0xF7,0x19,0x65,0x14,0x3D,0x52,0xD7,0xB2,0xD1,0x8F,0x72,0x26,0xE2,0x53,
			0x25,0xA4,0x12,0x7B,0xD5,0xF4,0x40,0xCE,0x82,0x3F,0xAE,0xDC,0x92,0xA0,0x16,0x43,
			0xBB,0x48,0xF5,0x62,0x73,0x23,0xA8,0xB9,0x7A,0xCF,0xCD,0xBA,0x86,0x5D,0x57,0x5A,
			0x2C,0x7F,0x47,0x2D,0xE3,0xE0,0xBD,0x15,0xF3,0x9B,0x0D,0xE6,0x7C,0x4B,0x2B,0x6E,
			0xC2,0x75,0x6B,0xC5,0xAF,0xFB,0x21,0x96,0x67,0xA5,0xEC,0x79,0x9D,0x7D,0xB6,0x0C,
			0xF9,0x17,0xFC,0xBE,0x6A,0xC7,0x4E,0x4F,0x94,0x56,0x0A,0x46,0x3E,0xC3,0x9C,0x51,
			0xFE,0xC6,0xF2,0x20,0x54,0xB1,0xDD,0x03,0x42,0xA3,0xE1,0x06,0x88,0x74,0xFD,0x05,
			0x2F,0x5C,0x85,0xEF,0x34,0x4D,0xF8,0xDA,0x45,0xA6,0x29,0x59,0xED,0x1D,0xA9,0x61,
			0x81,0xB3,0x02,0xAB,0xC4,0x32,0x07,0x1F,0x8A,0x8D,0xDE,0x64,0x1C,0x49,0x37,0xCB,
			0x50,0x58,0x41,0xB5,0x76,0xE8,0x71,0x87,0xEA,0x1B,0xE5,0x91,0x24,0xD8,0x6F,0x5B,
			0xD6,0x5F,0xB0,0xCA,0xE7,0x90,0xFF,0x00,0x93,0x97,0xEE,0x9A,0xC1,0xB8,0xDF,0xF0,
			0x18,0x8B,0x8C,0x89,0x69,0xB7,0x09,0xCC,0xC9,0x78,0x70,0x35,0x13,0x9E,0x8E,0x08,
			0x39,0xAA,0xC0,0x0E,0x31,0x84,0xF1,0xBF,0x83,0x01,0x66,0x1E,0x36,0xBC,0x99,0x63,
			0x3A,0x7E,0x33,0x95,0x3B,0xA2,0xA7,0xDB,0x77,0x27,0xE9,0xAC,0x4C,0xEB,0x04,0xAD,
			0x2A,0x4A,0x3C,0x0B,0xFA,0xD3,0x6D,0x28,0xF6,0xD0,0xD9,0xE4,0xC8,0x68,0x22,0x30,
			0x44,0x11,0x2E,0xA1,0x0F,0x1A,0xB4,0x10,0x60,0x9F,0xD2,0x38,0x55,0x5E,0x6C,0xD4
}			



local recvmap = {
	[0] = 	0xA7,0xC9,0x82,0x67,0xDE,0x6F,0x6B,0x86,0xBF,0xB6,0x5A,0xE3,0x4F,0x3A,0xC3,0xF4,
			0xF7,0xF1,0x12,0xBC,0x05,0x37,0x1E,0x51,0xB0,0x03,0xF5,0x99,0x8C,0x7D,0xCB,0x87,
			0x63,0x46,0xEE,0x25,0x9C,0x10,0x0D,0xD9,0xE7,0x7A,0xE0,0x3E,0x30,0x33,0xF2,0x70,
			0xEF,0xC4,0x85,0xD2,0x74,0xBB,0xCC,0x8E,0xFB,0xC0,0xD0,0xD4,0xE2,0x06,0x5C,0x19,
			0x16,0x92,0x68,0x1F,0xF0,0x78,0x5B,0x32,0x21,0x8D,0xE1,0x3D,0xDC,0x75,0x56,0x57,
			0x90,0x5F,0x07,0x0F,0x64,0xFC,0x59,0x2E,0x91,0x7B,0x2F,0x9F,0x71,0x2D,0xFD,0xA1,
			0xF8,0x7F,0x23,0xCF,0x8B,0x04,0xCA,0x48,0xED,0xB4,0x54,0x42,0xFE,0xE6,0x3F,0x9E,
			0xBA,0x96,0x0C,0x24,0x6D,0x41,0x94,0xD8,0xB9,0x4B,0x28,0x13,0x3C,0x4D,0xD1,0x31,
			0x00,0x80,0x18,0xC8,0xC5,0x72,0x2C,0x97,0x6C,0xB3,0x88,0xB1,0xB2,0x89,0xBE,0x0B,
			0xA5,0x9B,0x1C,0xA8,0x58,0xD3,0x47,0xA9,0x01,0xCE,0xAB,0x39,0x5E,0x4C,0xBD,0xF9,
			0x1D,0xF3,0xD5,0x69,0x11,0x49,0x79,0xD6,0x26,0x7E,0xC1,0x83,0xDB,0xDF,0x1A,0x44,
			0xA2,0x65,0x09,0x81,0xF6,0x93,0x4E,0xB5,0xAD,0x27,0x2B,0x20,0xCD,0x36,0x53,0xC7,
			0xC2,0xAC,0x40,0x5D,0x84,0x43,0x61,0x55,0xEC,0xB8,0xA3,0x8F,0xB7,0x2A,0x17,0x29,
			0xE9,0x0A,0xFA,0xE5,0xFF,0x14,0xA0,0x08,0x9D,0xEA,0x77,0xD7,0x1B,0x66,0x8A,0xAE,
			0x35,0x6A,0x0E,0x34,0xEB,0x9A,0x3B,0xA4,0x95,0xDA,0x98,0xDD,0x4A,0x7C,0xAA,0x73,
			0xAF,0xC6,0x62,0x38,0x15,0x22,0xE8,0x02,0x76,0x50,0xE4,0x45,0x52,0x6E,0x60,0xA6
}


local utils = require("framework.cc.utils.init")
require("framework.cc.utils.bit")
local ByteArray = utils.ByteArray
local BODY_BEGIN = 11+1

local BoyaaQE1 = class("BoyaaQE1")

function BoyaaQE1:ctor()
	self.data_ = ByteArray.new(ByteArray.ENDIAN_BIG)
end


function BoyaaQE1:pack()
	return self.data_:getPack()
end

function BoyaaQE1:unpack( data )
	self.data_:writeBuf(data)
	self.data_:setPos(1)
	local len = self.data_:readUInt()
	local flag = self.data_:readStringBytes(2)
	local cmd = self.data_:readInt()
	local code = self.data_:readByte()
	--print(len,flag, string.format("0x%x",cmd))

	self.cmd_ = cmd

end

	--加密
	--writeEnd()之后 pack() 之前调用
function BoyaaQE1:encrypt( )
		--打包的时候，在buffer前加个4个字节的长度
	local buffer = self.data_:getPack()
	local t = {}
	local checkcode = 0
	for k,v in pairs({string.byte(buffer,BODY_BEGIN,-1) }) do
		checkcode = checkcode + v
		t[k] = sendmap[v]

	end
	local encrypt_body = string.char(unpack(t))

	local checkcode = bit.band( (bit.bnot(checkcode)+1), 0xff)
	self.data_:setPos(BODY_BEGIN - 1)
	self.data_:writeByte(checkcode)
	self.data_:writeBuf(encrypt_body)

end

	--解密
	--在upack 之后
function BoyaaQE1:decrypt()
	local buffer = self.data_:getPack()
	local checkcode = buffer:byte(BODY_BEGIN-1)
	local t = {}
	for k,v in pairs( { string.byte(buffer,BODY_BEGIN,-1)} ) do
		t[k] = recvmap[v]
		checkcode = checkcode + t[k]
	end
	local decrypt_body = string.char(unpack(t))
	self.data_:writeBuf(decrypt_body)
	self.data_:setPos(BODY_BEGIN)
	return checkcode
end



function BoyaaQE1:writeBegin( cmd )

	local len = 0
	local flag = "HZ"
	local code = 0
	self.data_:writeUInt(len)
	self.data_:writeStringBytes(flag)
	self.data_:writeInt(cmd)
	self.data_:writeByte(code)

	self.cmd_ = cmd
end

function BoyaaQE1:writeEnd()
	local len = self.data_:getLen()
	self.data_:setPos(1)
	self.data_:writeUInt(len)
end

function BoyaaQE1:writeByte( val )
	if type(val) == "number" then
		self.data_:writeByte(val)
	else
		self.data_:writeChar(val)
	end
end

function BoyaaQE1:writeShort( val )
	self.data_:writeShort( tonumber(val) or 0 )
end

function BoyaaQE1:writeInt( val )
	self.data_:writeInt(tonumber(val) or 0)
end

function BoyaaQE1:writeInt64( val )
    val = tonumber(val) or 0
    local low = val % 2^32
    local high = val / 2^32
    self.data_:writeInt(high)
    self.data_:writeUInt(low)
end

function BoyaaQE1:writeString( val )
    val = tostring(val) or ""
    self.data_:writeUInt(#val + 1)
    self.data_:writeStringBytes(val)
    self.data_:writeByte(0)
end

function BoyaaQE1:writeBinary( val )
	-- body
end


function BoyaaQE1:readByte()
    local ret = self.data_:readByte()
    if ret > 2^7 -1 then
        ret = ret - 2^8
    end
    return ret
end

function BoyaaQE1:readShort()
	return self.data_:readShort()
end

function BoyaaQE1:readInt( ... )
	return self.data_:readInt()
end

function BoyaaQE1:readInt64( ... )
    local high = self.data_:readInt()
    local low = self.data_:readUInt()
    print("readint 64 high low", high,low)
    return  high * 2^32 + low
end

function BoyaaQE1:readString(  )
    local len = self.data_:readUInt()
    local str = self.data_:readStringBytes(len - 1)
    self.data_:readByte() 
    return str
end

function BoyaaQE1:getCmd()
	return self.cmd_
end

return BoyaaQE1
