--[[
 .____                  ________ ___.    _____                           __                
 |    |    __ _______   \_____  \\_ |___/ ____\_ __  ______ ____ _____ _/  |_  ___________ 
 |    |   |  |  \__  \   /   |   \| __ \   __\  |  \/  ___// ___\\__  \\   __\/  _ \_  __ \
 |    |___|  |  // __ \_/    |    \ \_\ \  | |  |  /\___ \\  \___ / __ \|  | (  <_> )  | \/
 |_______ \____/(____  /\_______  /___  /__| |____//____  >\___  >____  /__|  \____/|__|   
         \/          \/         \/    \/                \/     \/     \/                   
          \_Welcome to LuaObfuscator.com   (Alpha 0.10.6) ~  Much Love, Ferib 

]]--

local StrToNumber = tonumber;
local Byte = string.byte;
local Char = string.char;
local Sub = string.sub;
local Subg = string.gsub;
local Rep = string.rep;
local Concat = table.concat;
local Insert = table.insert;
local LDExp = math.ldexp;
local GetFEnv = getfenv or function()
	return _ENV;
end;
local Setmetatable = setmetatable;
local PCall = pcall;
local Select = select;
local Unpack = unpack or table.unpack;
local ToNumber = tonumber;
local function VMCall(ByteString, vmenv, ...)
	local DIP = 1;
	local repeatNext;
	ByteString = Subg(Sub(ByteString, 5), "..", function(byte)
		if (Byte(byte, 2) == 79) then
			repeatNext = StrToNumber(Sub(byte, 1, 1));
			return "";
		else
			local FlatIdent_12703 = 0;
			local a;
			while true do
				if (FlatIdent_12703 == 0) then
					a = Char(StrToNumber(byte, 16));
					if repeatNext then
						local FlatIdent_2BD95 = 0;
						local b;
						while true do
							if (FlatIdent_2BD95 == 1) then
								return b;
							end
							if (FlatIdent_2BD95 == 0) then
								b = Rep(a, repeatNext);
								repeatNext = nil;
								FlatIdent_2BD95 = 1;
							end
						end
					else
						return a;
					end
					break;
				end
			end
		end
	end);
	local function gBit(Bit, Start, End)
		if End then
			local FlatIdent_60EA1 = 0;
			local Res;
			while true do
				if (FlatIdent_60EA1 == 0) then
					Res = (Bit / (2 ^ (Start - 1))) % (2 ^ (((End - 1) - (Start - 1)) + 1));
					return Res - (Res % 1);
				end
			end
		else
			local FlatIdent_31A5A = 0;
			local Plc;
			while true do
				if (FlatIdent_31A5A == 0) then
					Plc = 2 ^ (Start - 1);
					return (((Bit % (Plc + Plc)) >= Plc) and 1) or 0;
				end
			end
		end
	end
	local function gBits8()
		local a = Byte(ByteString, DIP, DIP);
		DIP = DIP + 1;
		return a;
	end
	local function gBits16()
		local FlatIdent_24439 = 0;
		local a;
		local b;
		while true do
			if (FlatIdent_24439 == 1) then
				return (b * 256) + a;
			end
			if (FlatIdent_24439 == 0) then
				a, b = Byte(ByteString, DIP, DIP + 2);
				DIP = DIP + 2;
				FlatIdent_24439 = 1;
			end
		end
	end
	local function gBits32()
		local a, b, c, d = Byte(ByteString, DIP, DIP + 3);
		DIP = DIP + 4;
		return (d * 16777216) + (c * 65536) + (b * 256) + a;
	end
	local function gFloat()
		local Left = gBits32();
		local Right = gBits32();
		local IsNormal = 1;
		local Mantissa = (gBit(Right, 1, 20) * (2 ^ 32)) + Left;
		local Exponent = gBit(Right, 21, 31);
		local Sign = ((gBit(Right, 32) == 1) and -1) or 1;
		if (Exponent == 0) then
			if (Mantissa == 0) then
				return Sign * 0;
			else
				local FlatIdent_5ED46 = 0;
				while true do
					if (FlatIdent_5ED46 == 0) then
						Exponent = 1;
						IsNormal = 0;
						break;
					end
				end
			end
		elseif (Exponent == 2047) then
			return ((Mantissa == 0) and (Sign * (1 / 0))) or (Sign * NaN);
		end
		return LDExp(Sign, Exponent - 1023) * (IsNormal + (Mantissa / (2 ^ 52)));
	end
	local function gString(Len)
		local Str;
		if not Len then
			local FlatIdent_61585 = 0;
			while true do
				if (0 == FlatIdent_61585) then
					Len = gBits32();
					if (Len == 0) then
						return "";
					end
					break;
				end
			end
		end
		Str = Sub(ByteString, DIP, (DIP + Len) - 1);
		DIP = DIP + Len;
		local FStr = {};
		for Idx = 1, #Str do
			FStr[Idx] = Char(Byte(Sub(Str, Idx, Idx)));
		end
		return Concat(FStr);
	end
	local gInt = gBits32;
	local function _R(...)
		return {...}, Select("#", ...);
	end
	local function Deserialize()
		local Instrs = {};
		local Functions = {};
		local Lines = {};
		local Chunk = {Instrs,Functions,nil,Lines};
		local ConstCount = gBits32();
		local Consts = {};
		for Idx = 1, ConstCount do
			local FlatIdent_A36C = 0;
			local Type;
			local Cons;
			while true do
				if (FlatIdent_A36C == 0) then
					Type = gBits8();
					Cons = nil;
					FlatIdent_A36C = 1;
				end
				if (FlatIdent_A36C == 1) then
					if (Type == 1) then
						Cons = gBits8() ~= 0;
					elseif (Type == 2) then
						Cons = gFloat();
					elseif (Type == 3) then
						Cons = gString();
					end
					Consts[Idx] = Cons;
					break;
				end
			end
		end
		Chunk[3] = gBits8();
		for Idx = 1, gBits32() do
			local Descriptor = gBits8();
			if (gBit(Descriptor, 1, 1) == 0) then
				local FlatIdent_7FAC9 = 0;
				local Type;
				local Mask;
				local Inst;
				while true do
					if (0 == FlatIdent_7FAC9) then
						Type = gBit(Descriptor, 2, 3);
						Mask = gBit(Descriptor, 4, 6);
						FlatIdent_7FAC9 = 1;
					end
					if (FlatIdent_7FAC9 == 3) then
						if (gBit(Mask, 3, 3) == 1) then
							Inst[4] = Consts[Inst[4]];
						end
						Instrs[Idx] = Inst;
						break;
					end
					if (FlatIdent_7FAC9 == 2) then
						if (gBit(Mask, 1, 1) == 1) then
							Inst[2] = Consts[Inst[2]];
						end
						if (gBit(Mask, 2, 2) == 1) then
							Inst[3] = Consts[Inst[3]];
						end
						FlatIdent_7FAC9 = 3;
					end
					if (FlatIdent_7FAC9 == 1) then
						Inst = {gBits16(),gBits16(),nil,nil};
						if (Type == 0) then
							local FlatIdent_99389 = 0;
							while true do
								if (FlatIdent_99389 == 0) then
									Inst[3] = gBits16();
									Inst[4] = gBits16();
									break;
								end
							end
						elseif (Type == 1) then
							Inst[3] = gBits32();
						elseif (Type == 2) then
							Inst[3] = gBits32() - (2 ^ 16);
						elseif (Type == 3) then
							Inst[3] = gBits32() - (2 ^ 16);
							Inst[4] = gBits16();
						end
						FlatIdent_7FAC9 = 2;
					end
				end
			end
		end
		for Idx = 1, gBits32() do
			Functions[Idx - 1] = Deserialize();
		end
		return Chunk;
	end
	local function Wrap(Chunk, Upvalues, Env)
		local Instr = Chunk[1];
		local Proto = Chunk[2];
		local Params = Chunk[3];
		return function(...)
			local Instr = Instr;
			local Proto = Proto;
			local Params = Params;
			local _R = _R;
			local VIP = 1;
			local Top = -1;
			local Vararg = {};
			local Args = {...};
			local PCount = Select("#", ...) - 1;
			local Lupvals = {};
			local Stk = {};
			for Idx = 0, PCount do
				if (Idx >= Params) then
					Vararg[Idx - Params] = Args[Idx + 1];
				else
					Stk[Idx] = Args[Idx + 1];
				end
			end
			local Varargsz = (PCount - Params) + 1;
			local Inst;
			local Enum;
			while true do
				local FlatIdent_8CEDF = 0;
				while true do
					if (FlatIdent_8CEDF == 1) then
						if (Enum <= 60) then
							if (Enum <= 29) then
								if (Enum <= 14) then
									if (Enum <= 6) then
										if (Enum <= 2) then
											if (Enum <= 0) then
												local FlatIdent_1B1BA = 0;
												local B;
												local A;
												while true do
													if (FlatIdent_1B1BA == 0) then
														B = nil;
														A = nil;
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														FlatIdent_1B1BA = 1;
													end
													if (FlatIdent_1B1BA == 2) then
														A = Inst[2];
														Stk[A] = Stk[A](Stk[A + 1]);
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_1B1BA = 3;
													end
													if (FlatIdent_1B1BA == 7) then
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														if not Stk[Inst[2]] then
															VIP = VIP + 1;
														else
															VIP = Inst[3];
														end
														break;
													end
													if (6 == FlatIdent_1B1BA) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_1B1BA = 7;
													end
													if (FlatIdent_1B1BA == 1) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_1B1BA = 2;
													end
													if (FlatIdent_1B1BA == 4) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														B = Stk[Inst[3]];
														FlatIdent_1B1BA = 5;
													end
													if (FlatIdent_1B1BA == 5) then
														Stk[A + 1] = B;
														Stk[A] = B[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_1B1BA = 6;
													end
													if (FlatIdent_1B1BA == 3) then
														Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														FlatIdent_1B1BA = 4;
													end
												end
											elseif (Enum > 1) then
												local FlatIdent_57893 = 0;
												local A;
												while true do
													if (FlatIdent_57893 == 7) then
														Inst = Instr[VIP];
														if not Stk[Inst[2]] then
															VIP = VIP + 1;
														else
															VIP = Inst[3];
														end
														break;
													end
													if (6 == FlatIdent_57893) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														FlatIdent_57893 = 7;
													end
													if (FlatIdent_57893 == 2) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_57893 = 3;
													end
													if (FlatIdent_57893 == 5) then
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														FlatIdent_57893 = 6;
													end
													if (FlatIdent_57893 == 4) then
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_57893 = 5;
													end
													if (FlatIdent_57893 == 1) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_57893 = 2;
													end
													if (FlatIdent_57893 == 3) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_57893 = 4;
													end
													if (FlatIdent_57893 == 0) then
														A = nil;
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_57893 = 1;
													end
												end
											else
												local FlatIdent_9622C = 0;
												local Edx;
												local Results;
												local Limit;
												local B;
												local A;
												while true do
													if (FlatIdent_9622C == 19) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														FlatIdent_9622C = 20;
													end
													if (FlatIdent_9622C == 0) then
														Edx = nil;
														Results, Limit = nil;
														B = nil;
														A = nil;
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														FlatIdent_9622C = 1;
													end
													if (9 == FlatIdent_9622C) then
														Stk[A + 1] = B;
														Stk[A] = B[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_9622C = 10;
													end
													if (16 == FlatIdent_9622C) then
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Inst[4];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Inst[4];
														VIP = VIP + 1;
														FlatIdent_9622C = 17;
													end
													if (FlatIdent_9622C == 3) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A]();
														FlatIdent_9622C = 4;
													end
													if (FlatIdent_9622C == 27) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_9622C = 28;
													end
													if (FlatIdent_9622C == 30) then
														Stk[A] = B[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														FlatIdent_9622C = 31;
													end
													if (FlatIdent_9622C == 29) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														B = Stk[Inst[3]];
														Stk[A + 1] = B;
														FlatIdent_9622C = 30;
													end
													if (FlatIdent_9622C == 12) then
														Stk[A + 1] = B;
														Stk[A] = B[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = {};
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Inst[4];
														FlatIdent_9622C = 13;
													end
													if (FlatIdent_9622C == 11) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A]();
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														B = Stk[Inst[3]];
														FlatIdent_9622C = 12;
													end
													if (FlatIdent_9622C == 26) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Stk[A + 1]);
														FlatIdent_9622C = 27;
													end
													if (25 == FlatIdent_9622C) then
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Stk[A + 1]);
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_9622C = 26;
													end
													if (FlatIdent_9622C == 15) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_9622C = 16;
													end
													if (FlatIdent_9622C == 31) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														if Stk[Inst[2]] then
															VIP = VIP + 1;
														else
															VIP = Inst[3];
														end
														break;
													end
													if (FlatIdent_9622C == 13) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Inst[4];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Inst[4];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_9622C = 14;
													end
													if (FlatIdent_9622C == 24) then
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_9622C = 25;
													end
													if (FlatIdent_9622C == 1) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														B = Stk[Inst[3]];
														Stk[A + 1] = B;
														Stk[A] = B[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_9622C = 2;
													end
													if (FlatIdent_9622C == 23) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Stk[A + 1]);
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_9622C = 24;
													end
													if (FlatIdent_9622C == 21) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_9622C = 22;
													end
													if (FlatIdent_9622C == 28) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Stk[A + 1]);
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														FlatIdent_9622C = 29;
													end
													if (8 == FlatIdent_9622C) then
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														B = Stk[Inst[3]];
														FlatIdent_9622C = 9;
													end
													if (FlatIdent_9622C == 22) then
														Stk[A] = Stk[A](Stk[A + 1]);
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														FlatIdent_9622C = 23;
													end
													if (FlatIdent_9622C == 4) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_9622C = 5;
													end
													if (FlatIdent_9622C == 10) then
														Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
														Top = (Limit + A) - 1;
														Edx = 0;
														for Idx = A, Top do
															local FlatIdent_77FC3 = 0;
															while true do
																if (FlatIdent_77FC3 == 0) then
																	Edx = Edx + 1;
																	Stk[Idx] = Results[Edx];
																	break;
																end
															end
														end
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
														FlatIdent_9622C = 11;
													end
													if (FlatIdent_9622C == 17) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														FlatIdent_9622C = 18;
													end
													if (FlatIdent_9622C == 14) then
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_9622C = 15;
													end
													if (18 == FlatIdent_9622C) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														FlatIdent_9622C = 19;
													end
													if (FlatIdent_9622C == 20) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Stk[A + 1]);
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														FlatIdent_9622C = 21;
													end
													if (FlatIdent_9622C == 5) then
														A = Inst[2];
														B = Stk[Inst[3]];
														Stk[A + 1] = B;
														Stk[A] = B[Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_9622C = 6;
													end
													if (FlatIdent_9622C == 2) then
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
														Top = (Limit + A) - 1;
														Edx = 0;
														for Idx = A, Top do
															local FlatIdent_91B54 = 0;
															while true do
																if (FlatIdent_91B54 == 0) then
																	Edx = Edx + 1;
																	Stk[Idx] = Results[Edx];
																	break;
																end
															end
														end
														FlatIdent_9622C = 3;
													end
													if (6 == FlatIdent_9622C) then
														Inst = Instr[VIP];
														A = Inst[2];
														Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
														Top = (Limit + A) - 1;
														Edx = 0;
														for Idx = A, Top do
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
														end
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_9622C = 7;
													end
													if (7 == FlatIdent_9622C) then
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A]();
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_9622C = 8;
													end
												end
											end
										elseif (Enum <= 4) then
											if (Enum > 3) then
												local FlatIdent_4E54D = 0;
												local Results;
												local Edx;
												local Limit;
												local B;
												local A;
												while true do
													if (FlatIdent_4E54D == 3) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														Results, Limit = _R(Stk[A](Stk[A + 1]));
														FlatIdent_4E54D = 4;
													end
													if (FlatIdent_4E54D == 4) then
														Top = (Limit + A) - 1;
														Edx = 0;
														for Idx = A, Top do
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
														end
														VIP = VIP + 1;
														FlatIdent_4E54D = 5;
													end
													if (FlatIdent_4E54D == 2) then
														A = Inst[2];
														B = Stk[Inst[3]];
														Stk[A + 1] = B;
														Stk[A] = B[Inst[4]];
														FlatIdent_4E54D = 3;
													end
													if (FlatIdent_4E54D == 1) then
														A = nil;
														Stk[Inst[2]] = Env[Inst[3]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_4E54D = 2;
													end
													if (FlatIdent_4E54D == 6) then
														for Idx = A, Inst[4] do
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
														end
														VIP = VIP + 1;
														Inst = Instr[VIP];
														VIP = Inst[3];
														break;
													end
													if (FlatIdent_4E54D == 0) then
														Results = nil;
														Edx = nil;
														Results, Limit = nil;
														B = nil;
														FlatIdent_4E54D = 1;
													end
													if (FlatIdent_4E54D == 5) then
														Inst = Instr[VIP];
														A = Inst[2];
														Results = {Stk[A](Unpack(Stk, A + 1, Top))};
														Edx = 0;
														FlatIdent_4E54D = 6;
													end
												end
											else
												Stk[Inst[2]] = Stk[Inst[3]];
											end
										elseif (Enum == 5) then
											local B;
											local A;
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											if Stk[Inst[2]] then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
										else
											local B;
											local A;
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											if Stk[Inst[2]] then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
										end
									elseif (Enum <= 10) then
										if (Enum <= 8) then
											if (Enum > 7) then
												local FlatIdent_7CF06 = 0;
												local B;
												local A;
												while true do
													if (2 == FlatIdent_7CF06) then
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
														FlatIdent_7CF06 = 3;
													end
													if (FlatIdent_7CF06 == 6) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Inst[3];
														VIP = VIP + 1;
														FlatIdent_7CF06 = 7;
													end
													if (FlatIdent_7CF06 == 3) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														FlatIdent_7CF06 = 4;
													end
													if (FlatIdent_7CF06 == 4) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_7CF06 = 5;
													end
													if (FlatIdent_7CF06 == 0) then
														B = nil;
														A = nil;
														Stk[Inst[2]] = Upvalues[Inst[3]];
														VIP = VIP + 1;
														FlatIdent_7CF06 = 1;
													end
													if (7 == FlatIdent_7CF06) then
														Inst = Instr[VIP];
														A = Inst[2];
														Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
														VIP = VIP + 1;
														FlatIdent_7CF06 = 8;
													end
													if (FlatIdent_7CF06 == 1) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_7CF06 = 2;
													end
													if (FlatIdent_7CF06 == 8) then
														Inst = Instr[VIP];
														if not Stk[Inst[2]] then
															VIP = VIP + 1;
														else
															VIP = Inst[3];
														end
														break;
													end
													if (FlatIdent_7CF06 == 5) then
														A = Inst[2];
														B = Stk[Inst[3]];
														Stk[A + 1] = B;
														Stk[A] = B[Inst[4]];
														FlatIdent_7CF06 = 6;
													end
												end
											else
												local FlatIdent_8849F = 0;
												local A;
												while true do
													if (FlatIdent_8849F == 2) then
														Inst = Instr[VIP];
														A = Inst[2];
														do
															return Stk[A](Unpack(Stk, A + 1, Inst[3]));
														end
														FlatIdent_8849F = 3;
													end
													if (FlatIdent_8849F == 0) then
														A = nil;
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														FlatIdent_8849F = 1;
													end
													if (FlatIdent_8849F == 1) then
														Inst = Instr[VIP];
														Stk[Inst[2]] = Stk[Inst[3]];
														VIP = VIP + 1;
														FlatIdent_8849F = 2;
													end
													if (FlatIdent_8849F == 4) then
														do
															return Unpack(Stk, A, Top);
														end
														VIP = VIP + 1;
														Inst = Instr[VIP];
														FlatIdent_8849F = 5;
													end
													if (FlatIdent_8849F == 5) then
														VIP = Inst[3];
														break;
													end
													if (FlatIdent_8849F == 3) then
														VIP = VIP + 1;
														Inst = Instr[VIP];
														A = Inst[2];
														FlatIdent_8849F = 4;
													end
												end
											end
										elseif (Enum == 9) then
											local FlatIdent_7FF98 = 0;
											local A;
											while true do
												if (FlatIdent_7FF98 == 0) then
													A = Inst[2];
													Stk[A](Stk[A + 1]);
													break;
												end
											end
										else
											local A;
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A]();
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											if Stk[Inst[2]] then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
										end
									elseif (Enum <= 12) then
										if (Enum > 11) then
											local B;
											local A;
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
										else
											local FlatIdent_4FF01 = 0;
											local B;
											local A;
											while true do
												if (0 == FlatIdent_4FF01) then
													B = nil;
													A = nil;
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													FlatIdent_4FF01 = 1;
												end
												if (FlatIdent_4FF01 == 5) then
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													break;
												end
												if (FlatIdent_4FF01 == 2) then
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_4FF01 = 3;
												end
												if (FlatIdent_4FF01 == 3) then
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_4FF01 = 4;
												end
												if (FlatIdent_4FF01 == 1) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_4FF01 = 2;
												end
												if (FlatIdent_4FF01 == 4) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = {};
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_4FF01 = 5;
												end
											end
										end
									elseif (Enum > 13) then
										local FlatIdent_6679B = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_6679B == 0) then
												B = nil;
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_6679B = 1;
											end
											if (FlatIdent_6679B == 5) then
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_6679B = 6;
											end
											if (FlatIdent_6679B == 1) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_6679B = 2;
											end
											if (FlatIdent_6679B == 6) then
												if Stk[Inst[2]] then
													VIP = VIP + 1;
												else
													VIP = Inst[3];
												end
												break;
											end
											if (FlatIdent_6679B == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_6679B = 4;
											end
											if (FlatIdent_6679B == 2) then
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												FlatIdent_6679B = 3;
											end
											if (FlatIdent_6679B == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_6679B = 5;
											end
										end
									elseif not Stk[Inst[2]] then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								elseif (Enum <= 21) then
									if (Enum <= 17) then
										if (Enum <= 15) then
											local A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										elseif (Enum == 16) then
											local FlatIdent_854BA = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_854BA == 4) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													if not Stk[Inst[2]] then
														VIP = VIP + 1;
													else
														VIP = Inst[3];
													end
													break;
												end
												if (FlatIdent_854BA == 0) then
													B = nil;
													A = nil;
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_854BA = 1;
												end
												if (FlatIdent_854BA == 2) then
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_854BA = 3;
												end
												if (3 == FlatIdent_854BA) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													FlatIdent_854BA = 4;
												end
												if (1 == FlatIdent_854BA) then
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													FlatIdent_854BA = 2;
												end
											end
										else
											local FlatIdent_125A6 = 0;
											local Edx;
											local Results;
											local Limit;
											local B;
											local A;
											while true do
												if (FlatIdent_125A6 == 8) then
													Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													break;
												end
												if (7 == FlatIdent_125A6) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_125A6 = 8;
												end
												if (1 == FlatIdent_125A6) then
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_125A6 = 2;
												end
												if (0 == FlatIdent_125A6) then
													Edx = nil;
													Results, Limit = nil;
													B = nil;
													A = nil;
													A = Inst[2];
													FlatIdent_125A6 = 1;
												end
												if (FlatIdent_125A6 == 4) then
													for Idx = A, Top do
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
													end
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A](Unpack(Stk, A + 1, Top));
													FlatIdent_125A6 = 5;
												end
												if (FlatIdent_125A6 == 2) then
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_125A6 = 3;
												end
												if (FlatIdent_125A6 == 6) then
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_125A6 = 7;
												end
												if (FlatIdent_125A6 == 3) then
													Inst = Instr[VIP];
													A = Inst[2];
													Results, Limit = _R(Stk[A]());
													Top = (Limit + A) - 1;
													Edx = 0;
													FlatIdent_125A6 = 4;
												end
												if (FlatIdent_125A6 == 5) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_125A6 = 6;
												end
											end
										end
									elseif (Enum <= 19) then
										if (Enum > 18) then
											local FlatIdent_957A4 = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_957A4 == 5) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													FlatIdent_957A4 = 6;
												end
												if (FlatIdent_957A4 == 1) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_957A4 = 2;
												end
												if (FlatIdent_957A4 == 4) then
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													FlatIdent_957A4 = 5;
												end
												if (FlatIdent_957A4 == 2) then
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_957A4 = 3;
												end
												if (FlatIdent_957A4 == 6) then
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													break;
												end
												if (FlatIdent_957A4 == 0) then
													B = nil;
													A = nil;
													A = Inst[2];
													Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													FlatIdent_957A4 = 1;
												end
												if (3 == FlatIdent_957A4) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = {};
													VIP = VIP + 1;
													FlatIdent_957A4 = 4;
												end
											end
										else
											local B;
											local A;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											B = Stk[Inst[4]];
											if not B then
												VIP = VIP + 1;
											else
												Stk[Inst[2]] = B;
												VIP = Inst[3];
											end
										end
									elseif (Enum > 20) then
										local FlatIdent_F26C = 0;
										local A;
										while true do
											if (FlatIdent_F26C == 24) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												break;
											end
											if (16 == FlatIdent_F26C) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												FlatIdent_F26C = 17;
											end
											if (FlatIdent_F26C == 1) then
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												FlatIdent_F26C = 2;
											end
											if (5 == FlatIdent_F26C) then
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_F26C = 6;
											end
											if (FlatIdent_F26C == 23) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_F26C = 24;
											end
											if (FlatIdent_F26C == 17) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_F26C = 18;
											end
											if (FlatIdent_F26C == 10) then
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_F26C = 11;
											end
											if (FlatIdent_F26C == 22) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_F26C = 23;
											end
											if (FlatIdent_F26C == 3) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_F26C = 4;
											end
											if (FlatIdent_F26C == 21) then
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_F26C = 22;
											end
											if (FlatIdent_F26C == 7) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_F26C = 8;
											end
											if (9 == FlatIdent_F26C) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_F26C = 10;
											end
											if (FlatIdent_F26C == 18) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_F26C = 19;
											end
											if (FlatIdent_F26C == 8) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												FlatIdent_F26C = 9;
											end
											if (FlatIdent_F26C == 6) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												FlatIdent_F26C = 7;
											end
											if (15 == FlatIdent_F26C) then
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_F26C = 16;
											end
											if (FlatIdent_F26C == 13) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_F26C = 14;
											end
											if (FlatIdent_F26C == 12) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_F26C = 13;
											end
											if (FlatIdent_F26C == 11) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												FlatIdent_F26C = 12;
											end
											if (FlatIdent_F26C == 19) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_F26C = 20;
											end
											if (FlatIdent_F26C == 20) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_F26C = 21;
											end
											if (FlatIdent_F26C == 0) then
												A = nil;
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_F26C = 1;
											end
											if (FlatIdent_F26C == 14) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_F26C = 15;
											end
											if (FlatIdent_F26C == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												FlatIdent_F26C = 3;
											end
											if (4 == FlatIdent_F26C) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_F26C = 5;
											end
										end
									else
										local A;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
									end
								elseif (Enum <= 25) then
									if (Enum <= 23) then
										if (Enum == 22) then
											local FlatIdent_9F31 = 0;
											local A;
											while true do
												if (1 == FlatIdent_9F31) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													FlatIdent_9F31 = 2;
												end
												if (FlatIdent_9F31 == 0) then
													A = nil;
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													FlatIdent_9F31 = 1;
												end
												if (FlatIdent_9F31 == 4) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													FlatIdent_9F31 = 5;
												end
												if (2 == FlatIdent_9F31) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													for Idx = Inst[2], Inst[3] do
														Stk[Idx] = nil;
													end
													FlatIdent_9F31 = 3;
												end
												if (FlatIdent_9F31 == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													FlatIdent_9F31 = 4;
												end
												if (FlatIdent_9F31 == 5) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													break;
												end
											end
										else
											local FlatIdent_48494 = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_48494 == 1) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													FlatIdent_48494 = 2;
												end
												if (FlatIdent_48494 == 5) then
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_48494 = 6;
												end
												if (3 == FlatIdent_48494) then
													A = Inst[2];
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													FlatIdent_48494 = 4;
												end
												if (4 == FlatIdent_48494) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = {};
													VIP = VIP + 1;
													FlatIdent_48494 = 5;
												end
												if (FlatIdent_48494 == 6) then
													Stk[Inst[2]][Inst[3]] = Inst[4];
													break;
												end
												if (FlatIdent_48494 == 2) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_48494 = 3;
												end
												if (FlatIdent_48494 == 0) then
													B = nil;
													A = nil;
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_48494 = 1;
												end
											end
										end
									elseif (Enum > 24) then
										local Results;
										local Edx;
										local Results, Limit;
										local B;
										local A;
										A = Inst[2];
										Stk[A] = Stk[A]();
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Results, Limit = _R(Stk[A](Stk[A + 1]));
										Top = (Limit + A) - 1;
										Edx = 0;
										for Idx = A, Top do
											local FlatIdent_7C0B1 = 0;
											while true do
												if (FlatIdent_7C0B1 == 0) then
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
													break;
												end
											end
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Results = {Stk[A](Unpack(Stk, A + 1, Top))};
										Edx = 0;
										for Idx = A, Inst[4] do
											local FlatIdent_71493 = 0;
											while true do
												if (FlatIdent_71493 == 0) then
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
													break;
												end
											end
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
									elseif (Stk[Inst[2]] ~= Stk[Inst[4]]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								elseif (Enum <= 27) then
									if (Enum == 26) then
										local FlatIdent_1691A = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_1691A == 1) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]]();
												VIP = VIP + 1;
												FlatIdent_1691A = 2;
											end
											if (FlatIdent_1691A == 3) then
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												FlatIdent_1691A = 4;
											end
											if (FlatIdent_1691A == 6) then
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												FlatIdent_1691A = 7;
											end
											if (FlatIdent_1691A == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_1691A = 3;
											end
											if (FlatIdent_1691A == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_1691A = 5;
											end
											if (FlatIdent_1691A == 0) then
												B = nil;
												A = nil;
												A = Inst[2];
												Stk[A] = Stk[A](Stk[A + 1]);
												FlatIdent_1691A = 1;
											end
											if (5 == FlatIdent_1691A) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = {};
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_1691A = 6;
											end
											if (FlatIdent_1691A == 7) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												break;
											end
										end
									else
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									end
								elseif (Enum > 28) then
									local FlatIdent_64501 = 0;
									local A;
									local Results;
									local Edx;
									while true do
										if (FlatIdent_64501 == 0) then
											A = Inst[2];
											Results = {Stk[A](Stk[A + 1])};
											FlatIdent_64501 = 1;
										end
										if (FlatIdent_64501 == 1) then
											Edx = 0;
											for Idx = A, Inst[4] do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											break;
										end
									end
								else
									local B;
									local A;
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									if Stk[Inst[2]] then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								end
							elseif (Enum <= 44) then
								if (Enum <= 36) then
									if (Enum <= 32) then
										if (Enum <= 30) then
											local A;
											Env[Inst[3]] = Stk[Inst[2]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											for Idx = Inst[2], Inst[3] do
												Stk[Idx] = nil;
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A]();
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A]();
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
										elseif (Enum > 31) then
											Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
										elseif (Inst[2] == Stk[Inst[4]]) then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									elseif (Enum <= 34) then
										if (Enum > 33) then
											local A = Inst[2];
											local T = Stk[A];
											local B = Inst[3];
											for Idx = 1, B do
												T[Idx] = Stk[A + Idx];
											end
										else
											local B;
											local A;
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
										end
									elseif (Enum > 35) then
										local B;
										local A;
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
									else
										local FlatIdent_15034 = 0;
										local A;
										while true do
											if (1 == FlatIdent_15034) then
												A = Inst[2];
												Stk[A] = Stk[A]();
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_15034 = 2;
											end
											if (FlatIdent_15034 == 6) then
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												do
													return;
												end
												break;
											end
											if (0 == FlatIdent_15034) then
												A = nil;
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_15034 = 1;
											end
											if (FlatIdent_15034 == 2) then
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												FlatIdent_15034 = 3;
											end
											if (3 == FlatIdent_15034) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Stk[A + 1]);
												FlatIdent_15034 = 4;
											end
											if (4 == FlatIdent_15034) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_15034 = 5;
											end
											if (FlatIdent_15034 == 5) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_15034 = 6;
											end
										end
									end
								elseif (Enum <= 40) then
									if (Enum <= 38) then
										if (Enum > 37) then
											Stk[Inst[2]] = Inst[3] ~= 0;
										else
											Stk[Inst[2]] = Wrap(Proto[Inst[3]], nil, Env);
										end
									elseif (Enum == 39) then
										local A;
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										do
											return Stk[A](Unpack(Stk, A + 1, Inst[3]));
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										do
											return Unpack(Stk, A, Top);
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
									else
										Stk[Inst[2]]();
									end
								elseif (Enum <= 42) then
									if (Enum > 41) then
										local FlatIdent_8A06A = 0;
										local Results;
										local Edx;
										local Limit;
										local B;
										local A;
										while true do
											if (FlatIdent_8A06A == 0) then
												Results = nil;
												Edx = nil;
												Results, Limit = nil;
												B = nil;
												FlatIdent_8A06A = 1;
											end
											if (FlatIdent_8A06A == 5) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_8A06A = 6;
											end
											if (FlatIdent_8A06A == 4) then
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_8A06A = 5;
											end
											if (FlatIdent_8A06A == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												FlatIdent_8A06A = 4;
											end
											if (8 == FlatIdent_8A06A) then
												Top = (Limit + A) - 1;
												Edx = 0;
												for Idx = A, Top do
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
												end
												VIP = VIP + 1;
												FlatIdent_8A06A = 9;
											end
											if (FlatIdent_8A06A == 7) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Results, Limit = _R(Stk[A](Stk[A + 1]));
												FlatIdent_8A06A = 8;
											end
											if (FlatIdent_8A06A == 2) then
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												FlatIdent_8A06A = 3;
											end
											if (1 == FlatIdent_8A06A) then
												A = nil;
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_8A06A = 2;
											end
											if (FlatIdent_8A06A == 6) then
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_8A06A = 7;
											end
											if (FlatIdent_8A06A == 10) then
												for Idx = A, Inst[4] do
													local FlatIdent_9157 = 0;
													while true do
														if (FlatIdent_9157 == 0) then
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
															break;
														end
													end
												end
												VIP = VIP + 1;
												Inst = Instr[VIP];
												VIP = Inst[3];
												break;
											end
											if (FlatIdent_8A06A == 9) then
												Inst = Instr[VIP];
												A = Inst[2];
												Results = {Stk[A](Unpack(Stk, A + 1, Top))};
												Edx = 0;
												FlatIdent_8A06A = 10;
											end
										end
									else
										local B;
										local A;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
									end
								elseif (Enum == 43) then
									local NewProto = Proto[Inst[3]];
									local NewUvals;
									local Indexes = {};
									NewUvals = Setmetatable({}, {__index=function(_, Key)
										local Val = Indexes[Key];
										return Val[1][Val[2]];
									end,__newindex=function(_, Key, Value)
										local FlatIdent_74B46 = 0;
										local Val;
										while true do
											if (FlatIdent_74B46 == 0) then
												Val = Indexes[Key];
												Val[1][Val[2]] = Value;
												break;
											end
										end
									end});
									for Idx = 1, Inst[4] do
										local FlatIdent_60C77 = 0;
										local Mvm;
										while true do
											if (FlatIdent_60C77 == 0) then
												VIP = VIP + 1;
												Mvm = Instr[VIP];
												FlatIdent_60C77 = 1;
											end
											if (FlatIdent_60C77 == 1) then
												if (Mvm[1] == 3) then
													Indexes[Idx - 1] = {Stk,Mvm[3]};
												else
													Indexes[Idx - 1] = {Upvalues,Mvm[3]};
												end
												Lupvals[#Lupvals + 1] = Indexes;
												break;
											end
										end
									end
									Stk[Inst[2]] = Wrap(NewProto, NewUvals, Env);
								else
									local FlatIdent_30B1F = 0;
									local Results;
									local Edx;
									local Limit;
									local B;
									local A;
									while true do
										if (FlatIdent_30B1F == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Results, Limit = _R(Stk[A](Stk[A + 1]));
											Top = (Limit + A) - 1;
											FlatIdent_30B1F = 4;
										end
										if (FlatIdent_30B1F == 0) then
											Results = nil;
											Edx = nil;
											Results, Limit = nil;
											B = nil;
											A = nil;
											FlatIdent_30B1F = 1;
										end
										if (FlatIdent_30B1F == 1) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_30B1F = 2;
										end
										if (FlatIdent_30B1F == 5) then
											Results = {Stk[A](Unpack(Stk, A + 1, Top))};
											Edx = 0;
											for Idx = A, Inst[4] do
												local FlatIdent_6E23 = 0;
												while true do
													if (FlatIdent_6E23 == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_30B1F = 6;
										end
										if (FlatIdent_30B1F == 6) then
											VIP = Inst[3];
											break;
										end
										if (4 == FlatIdent_30B1F) then
											Edx = 0;
											for Idx = A, Top do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_30B1F = 5;
										end
										if (FlatIdent_30B1F == 2) then
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											FlatIdent_30B1F = 3;
										end
									end
								end
							elseif (Enum <= 52) then
								if (Enum <= 48) then
									if (Enum <= 46) then
										if (Enum > 45) then
											local A = Inst[2];
											local B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
										else
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										end
									elseif (Enum == 47) then
										local Results;
										local Edx;
										local Results, Limit;
										local B;
										local A;
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Results, Limit = _R(Stk[A](Stk[A + 1]));
										Top = (Limit + A) - 1;
										Edx = 0;
										for Idx = A, Top do
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Results = {Stk[A](Unpack(Stk, A + 1, Top))};
										Edx = 0;
										for Idx = A, Inst[4] do
											local FlatIdent_43E8E = 0;
											while true do
												if (FlatIdent_43E8E == 0) then
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
													break;
												end
											end
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
									else
										local FlatIdent_12E4E = 0;
										local A;
										while true do
											if (0 == FlatIdent_12E4E) then
												A = Inst[2];
												do
													return Unpack(Stk, A, A + Inst[3]);
												end
												break;
											end
										end
									end
								elseif (Enum <= 50) then
									if (Enum == 49) then
										local B;
										local A;
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
									else
										Stk[Inst[2]] = Upvalues[Inst[3]];
									end
								elseif (Enum > 51) then
									local FlatIdent_89126 = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_89126 == 6) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											FlatIdent_89126 = 7;
										end
										if (FlatIdent_89126 == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_89126 = 5;
										end
										if (FlatIdent_89126 == 0) then
											B = nil;
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_89126 = 1;
										end
										if (FlatIdent_89126 == 5) then
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											FlatIdent_89126 = 6;
										end
										if (FlatIdent_89126 == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_89126 = 4;
										end
										if (FlatIdent_89126 == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_89126 = 3;
										end
										if (FlatIdent_89126 == 8) then
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											break;
										end
										if (FlatIdent_89126 == 7) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_89126 = 8;
										end
										if (FlatIdent_89126 == 1) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_89126 = 2;
										end
									end
								else
									local B;
									local A;
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
								end
							elseif (Enum <= 56) then
								if (Enum <= 54) then
									if (Enum == 53) then
										local A;
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
									else
										local A;
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A]();
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Env[Inst[3]] = Stk[Inst[2]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
									end
								elseif (Enum == 55) then
									local A;
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									if not Stk[Inst[2]] then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								else
									local B;
									local A;
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									do
										return;
									end
								end
							elseif (Enum <= 58) then
								if (Enum == 57) then
									VIP = Inst[3];
								else
									Stk[Inst[2]] = Env[Inst[3]];
								end
							elseif (Enum == 59) then
								local B;
								local A;
								A = Inst[2];
								Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
							else
								Stk[Inst[2]] = {};
							end
						elseif (Enum <= 91) then
							if (Enum <= 75) then
								if (Enum <= 67) then
									if (Enum <= 63) then
										if (Enum <= 61) then
											local DIP;
											local NStk;
											local Upv;
											local List;
											local Cls;
											local B;
											local A;
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Cls = {};
											for Idx = 1, #Lupvals do
												List = Lupvals[Idx];
												for Idz = 0, #List do
													Upv = List[Idz];
													NStk = Upv[1];
													DIP = Upv[2];
													if ((NStk == Stk) and (DIP >= A)) then
														local FlatIdent_1CF13 = 0;
														while true do
															if (FlatIdent_1CF13 == 0) then
																Cls[DIP] = NStk[DIP];
																Upv[1] = Cls;
																break;
															end
														end
													end
												end
											end
										elseif (Enum == 62) then
											if (Stk[Inst[2]] == Inst[4]) then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
										else
											local A;
											A = Inst[2];
											Stk[A] = Stk[A]();
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											VIP = Inst[3];
										end
									elseif (Enum <= 65) then
										if (Enum > 64) then
											local A = Inst[2];
											local Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
											Top = (Limit + A) - 1;
											local Edx = 0;
											for Idx = A, Top do
												local FlatIdent_95405 = 0;
												while true do
													if (FlatIdent_95405 == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
										else
											local A;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											VIP = Inst[3];
										end
									elseif (Enum > 66) then
										local FlatIdent_2444E = 0;
										local A;
										local T;
										while true do
											if (FlatIdent_2444E == 0) then
												A = Inst[2];
												T = Stk[A];
												FlatIdent_2444E = 1;
											end
											if (1 == FlatIdent_2444E) then
												for Idx = A + 1, Inst[3] do
													Insert(T, Stk[Idx]);
												end
												break;
											end
										end
									else
										Env[Inst[3]] = Stk[Inst[2]];
									end
								elseif (Enum <= 71) then
									if (Enum <= 69) then
										if (Enum == 68) then
											local FlatIdent_1AD5 = 0;
											local B;
											local T;
											local A;
											while true do
												if (FlatIdent_1AD5 == 0) then
													B = nil;
													T = nil;
													A = nil;
													Stk[Inst[2]] = Inst[3] ~= 0;
													FlatIdent_1AD5 = 1;
												end
												if (FlatIdent_1AD5 == 5) then
													Inst = Instr[VIP];
													A = Inst[2];
													T = Stk[A];
													B = Inst[3];
													FlatIdent_1AD5 = 6;
												end
												if (FlatIdent_1AD5 == 3) then
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_1AD5 = 4;
												end
												if (FlatIdent_1AD5 == 4) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													VIP = VIP + 1;
													FlatIdent_1AD5 = 5;
												end
												if (2 == FlatIdent_1AD5) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = {};
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_1AD5 = 3;
												end
												if (FlatIdent_1AD5 == 6) then
													for Idx = 1, B do
														T[Idx] = Stk[A + Idx];
													end
													break;
												end
												if (1 == FlatIdent_1AD5) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = {};
													VIP = VIP + 1;
													FlatIdent_1AD5 = 2;
												end
											end
										else
											local FlatIdent_78DE1 = 0;
											local Results;
											local Edx;
											local Limit;
											local B;
											local A;
											while true do
												if (FlatIdent_78DE1 == 5) then
													Edx = 0;
													for Idx = A, Top do
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
													end
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_78DE1 = 6;
												end
												if (FlatIdent_78DE1 == 7) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													VIP = Inst[3];
													break;
												end
												if (FlatIdent_78DE1 == 2) then
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_78DE1 = 3;
												end
												if (1 == FlatIdent_78DE1) then
													A = nil;
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_78DE1 = 2;
												end
												if (FlatIdent_78DE1 == 0) then
													Results = nil;
													Edx = nil;
													Results, Limit = nil;
													B = nil;
													FlatIdent_78DE1 = 1;
												end
												if (FlatIdent_78DE1 == 3) then
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													FlatIdent_78DE1 = 4;
												end
												if (FlatIdent_78DE1 == 4) then
													Inst = Instr[VIP];
													A = Inst[2];
													Results, Limit = _R(Stk[A](Stk[A + 1]));
													Top = (Limit + A) - 1;
													FlatIdent_78DE1 = 5;
												end
												if (FlatIdent_78DE1 == 6) then
													A = Inst[2];
													Results = {Stk[A](Unpack(Stk, A + 1, Top))};
													Edx = 0;
													for Idx = A, Inst[4] do
														local FlatIdent_765F0 = 0;
														while true do
															if (FlatIdent_765F0 == 0) then
																Edx = Edx + 1;
																Stk[Idx] = Results[Edx];
																break;
															end
														end
													end
													FlatIdent_78DE1 = 7;
												end
											end
										end
									elseif (Enum == 70) then
										if (Stk[Inst[2]] ~= Inst[4]) then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									else
										local T;
										local B;
										local A;
										A = Inst[2];
										Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										T = Stk[A];
										B = Inst[3];
										for Idx = 1, B do
											T[Idx] = Stk[A + Idx];
										end
									end
								elseif (Enum <= 73) then
									if (Enum == 72) then
										do
											return Stk[Inst[2]];
										end
									else
										local FlatIdent_40A1E = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_40A1E == 9) then
												VIP = Inst[3];
												break;
											end
											if (FlatIdent_40A1E == 7) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_40A1E = 8;
											end
											if (FlatIdent_40A1E == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_40A1E = 5;
											end
											if (FlatIdent_40A1E == 0) then
												B = nil;
												A = nil;
												Stk[Inst[2]] = Upvalues[Inst[3]];
												FlatIdent_40A1E = 1;
											end
											if (3 == FlatIdent_40A1E) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												FlatIdent_40A1E = 4;
											end
											if (6 == FlatIdent_40A1E) then
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												FlatIdent_40A1E = 7;
											end
											if (FlatIdent_40A1E == 5) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_40A1E = 6;
											end
											if (FlatIdent_40A1E == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												FlatIdent_40A1E = 3;
											end
											if (FlatIdent_40A1E == 1) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_40A1E = 2;
											end
											if (FlatIdent_40A1E == 8) then
												Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_40A1E = 9;
											end
										end
									end
								elseif (Enum == 74) then
									local FlatIdent_8BF78 = 0;
									local A;
									local Results;
									local Limit;
									local Edx;
									while true do
										if (FlatIdent_8BF78 == 2) then
											for Idx = A, Top do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											break;
										end
										if (FlatIdent_8BF78 == 1) then
											Top = (Limit + A) - 1;
											Edx = 0;
											FlatIdent_8BF78 = 2;
										end
										if (0 == FlatIdent_8BF78) then
											A = Inst[2];
											Results, Limit = _R(Stk[A](Stk[A + 1]));
											FlatIdent_8BF78 = 1;
										end
									end
								else
									local FlatIdent_851CE = 0;
									local A;
									local Results;
									local Limit;
									local Edx;
									while true do
										if (FlatIdent_851CE == 0) then
											A = Inst[2];
											Results, Limit = _R(Stk[A]());
											FlatIdent_851CE = 1;
										end
										if (FlatIdent_851CE == 1) then
											Top = (Limit + A) - 1;
											Edx = 0;
											FlatIdent_851CE = 2;
										end
										if (FlatIdent_851CE == 2) then
											for Idx = A, Top do
												local FlatIdent_11EF5 = 0;
												while true do
													if (FlatIdent_11EF5 == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
											break;
										end
									end
								end
							elseif (Enum <= 83) then
								if (Enum <= 79) then
									if (Enum <= 77) then
										if (Enum == 76) then
											local FlatIdent_58A9D = 0;
											local A;
											while true do
												if (0 == FlatIdent_58A9D) then
													A = nil;
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_58A9D = 1;
												end
												if (2 == FlatIdent_58A9D) then
													Stk[A] = Stk[A](Stk[A + 1]);
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]];
													FlatIdent_58A9D = 3;
												end
												if (FlatIdent_58A9D == 1) then
													Stk[Inst[2]] = Stk[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_58A9D = 2;
												end
												if (FlatIdent_58A9D == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A](Stk[A + 1]);
													break;
												end
											end
										else
											local FlatIdent_511F5 = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_511F5 == 2) then
													Stk[Inst[2]]();
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_511F5 = 3;
												end
												if (FlatIdent_511F5 == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													FlatIdent_511F5 = 4;
												end
												if (FlatIdent_511F5 == 6) then
													Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													for Idx = Inst[2], Inst[3] do
														Stk[Idx] = nil;
													end
													FlatIdent_511F5 = 7;
												end
												if (FlatIdent_511F5 == 0) then
													B = nil;
													A = nil;
													Env[Inst[3]] = Stk[Inst[2]];
													VIP = VIP + 1;
													FlatIdent_511F5 = 1;
												end
												if (FlatIdent_511F5 == 5) then
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_511F5 = 6;
												end
												if (FlatIdent_511F5 == 8) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													break;
												end
												if (FlatIdent_511F5 == 1) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_511F5 = 2;
												end
												if (FlatIdent_511F5 == 7) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_511F5 = 8;
												end
												if (FlatIdent_511F5 == 4) then
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_511F5 = 5;
												end
											end
										end
									elseif (Enum == 78) then
										local FlatIdent_696E1 = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_696E1 == 1) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												FlatIdent_696E1 = 2;
											end
											if (FlatIdent_696E1 == 5) then
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												break;
											end
											if (FlatIdent_696E1 == 0) then
												B = nil;
												A = nil;
												A = Inst[2];
												Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_696E1 = 1;
											end
											if (FlatIdent_696E1 == 2) then
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_696E1 = 3;
											end
											if (3 == FlatIdent_696E1) then
												Stk[Inst[2]] = {};
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_696E1 = 4;
											end
											if (FlatIdent_696E1 == 4) then
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												FlatIdent_696E1 = 5;
											end
										end
									else
										local A = Inst[2];
										local C = Inst[4];
										local CB = A + 2;
										local Result = {Stk[A](Stk[A + 1], Stk[CB])};
										for Idx = 1, C do
											Stk[CB + Idx] = Result[Idx];
										end
										local R = Result[1];
										if R then
											Stk[CB] = R;
											VIP = Inst[3];
										else
											VIP = VIP + 1;
										end
									end
								elseif (Enum <= 81) then
									if (Enum > 80) then
										local A = Inst[2];
										do
											return Unpack(Stk, A, Top);
										end
									else
										local B;
										local A;
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = {};
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
									end
								elseif (Enum == 82) then
									local FlatIdent_14AB1 = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_14AB1 == 3) then
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_14AB1 = 4;
										end
										if (FlatIdent_14AB1 == 7) then
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_14AB1 = 8;
										end
										if (FlatIdent_14AB1 == 8) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_14AB1 = 9;
										end
										if (FlatIdent_14AB1 == 2) then
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											FlatIdent_14AB1 = 3;
										end
										if (FlatIdent_14AB1 == 11) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_14AB1 = 12;
										end
										if (FlatIdent_14AB1 == 5) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											FlatIdent_14AB1 = 6;
										end
										if (FlatIdent_14AB1 == 6) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											FlatIdent_14AB1 = 7;
										end
										if (FlatIdent_14AB1 == 4) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_14AB1 = 5;
										end
										if (FlatIdent_14AB1 == 10) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											FlatIdent_14AB1 = 11;
										end
										if (FlatIdent_14AB1 == 1) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_14AB1 = 2;
										end
										if (FlatIdent_14AB1 == 12) then
											Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											VIP = Inst[3];
											break;
										end
										if (FlatIdent_14AB1 == 0) then
											B = nil;
											A = nil;
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											FlatIdent_14AB1 = 1;
										end
										if (FlatIdent_14AB1 == 9) then
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											FlatIdent_14AB1 = 10;
										end
									end
								else
									local FlatIdent_13092 = 0;
									local Results;
									local Edx;
									local Limit;
									local B;
									local A;
									while true do
										if (FlatIdent_13092 == 0) then
											Results = nil;
											Edx = nil;
											Results, Limit = nil;
											FlatIdent_13092 = 1;
										end
										if (FlatIdent_13092 == 5) then
											Results, Limit = _R(Stk[A](Stk[A + 1]));
											Top = (Limit + A) - 1;
											Edx = 0;
											FlatIdent_13092 = 6;
										end
										if (FlatIdent_13092 == 1) then
											B = nil;
											A = nil;
											Stk[Inst[2]] = Upvalues[Inst[3]];
											FlatIdent_13092 = 2;
										end
										if (FlatIdent_13092 == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_13092 = 5;
										end
										if (FlatIdent_13092 == 7) then
											A = Inst[2];
											Results = {Stk[A](Unpack(Stk, A + 1, Top))};
											Edx = 0;
											FlatIdent_13092 = 8;
										end
										if (3 == FlatIdent_13092) then
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											FlatIdent_13092 = 4;
										end
										if (FlatIdent_13092 == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_13092 = 3;
										end
										if (9 == FlatIdent_13092) then
											VIP = Inst[3];
											break;
										end
										if (6 == FlatIdent_13092) then
											for Idx = A, Top do
												local FlatIdent_61F8A = 0;
												while true do
													if (FlatIdent_61F8A == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_13092 = 7;
										end
										if (FlatIdent_13092 == 8) then
											for Idx = A, Inst[4] do
												local FlatIdent_59859 = 0;
												while true do
													if (FlatIdent_59859 == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_13092 = 9;
										end
									end
								end
							elseif (Enum <= 87) then
								if (Enum <= 85) then
									if (Enum > 84) then
										local FlatIdent_4E115 = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_4E115 == 6) then
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												FlatIdent_4E115 = 7;
											end
											if (FlatIdent_4E115 == 2) then
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												FlatIdent_4E115 = 3;
											end
											if (FlatIdent_4E115 == 3) then
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_4E115 = 4;
											end
											if (FlatIdent_4E115 == 0) then
												B = nil;
												A = nil;
												A = Inst[2];
												Stk[A](Unpack(Stk, A + 1, Inst[3]));
												FlatIdent_4E115 = 1;
											end
											if (4 == FlatIdent_4E115) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												FlatIdent_4E115 = 5;
											end
											if (5 == FlatIdent_4E115) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_4E115 = 6;
											end
											if (FlatIdent_4E115 == 9) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												break;
											end
											if (FlatIdent_4E115 == 7) then
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_4E115 = 8;
											end
											if (FlatIdent_4E115 == 1) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_4E115 = 2;
											end
											if (FlatIdent_4E115 == 8) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = {};
												VIP = VIP + 1;
												FlatIdent_4E115 = 9;
											end
										end
									else
										local FlatIdent_5C19E = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_5C19E == 16) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5C19E = 17;
											end
											if (FlatIdent_5C19E == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5C19E = 5;
											end
											if (21 == FlatIdent_5C19E) then
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_5C19E = 22;
											end
											if (FlatIdent_5C19E == 13) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5C19E = 14;
											end
											if (FlatIdent_5C19E == 27) then
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												break;
											end
											if (FlatIdent_5C19E == 25) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5C19E = 26;
											end
											if (FlatIdent_5C19E == 7) then
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												FlatIdent_5C19E = 8;
											end
											if (19 == FlatIdent_5C19E) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_5C19E = 20;
											end
											if (18 == FlatIdent_5C19E) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5C19E = 19;
											end
											if (0 == FlatIdent_5C19E) then
												B = nil;
												A = nil;
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_5C19E = 1;
											end
											if (FlatIdent_5C19E == 12) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_5C19E = 13;
											end
											if (FlatIdent_5C19E == 22) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												FlatIdent_5C19E = 23;
											end
											if (FlatIdent_5C19E == 10) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												FlatIdent_5C19E = 11;
											end
											if (FlatIdent_5C19E == 24) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_5C19E = 25;
											end
											if (FlatIdent_5C19E == 26) then
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												FlatIdent_5C19E = 27;
											end
											if (FlatIdent_5C19E == 20) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5C19E = 21;
											end
											if (FlatIdent_5C19E == 23) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5C19E = 24;
											end
											if (5 == FlatIdent_5C19E) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_5C19E = 6;
											end
											if (FlatIdent_5C19E == 17) then
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												FlatIdent_5C19E = 18;
											end
											if (FlatIdent_5C19E == 14) then
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_5C19E = 15;
											end
											if (FlatIdent_5C19E == 6) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_5C19E = 7;
											end
											if (FlatIdent_5C19E == 1) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_5C19E = 2;
											end
											if (FlatIdent_5C19E == 15) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_5C19E = 16;
											end
											if (FlatIdent_5C19E == 9) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5C19E = 10;
											end
											if (8 == FlatIdent_5C19E) then
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_5C19E = 9;
											end
											if (FlatIdent_5C19E == 3) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												FlatIdent_5C19E = 4;
											end
											if (FlatIdent_5C19E == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5C19E = 3;
											end
											if (FlatIdent_5C19E == 11) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_5C19E = 12;
											end
										end
									end
								elseif (Enum == 86) then
									local FlatIdent_7308B = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_7308B == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_7308B = 4;
										end
										if (FlatIdent_7308B == 8) then
											if not Stk[Inst[2]] then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
											break;
										end
										if (FlatIdent_7308B == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											FlatIdent_7308B = 3;
										end
										if (FlatIdent_7308B == 7) then
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_7308B = 8;
										end
										if (FlatIdent_7308B == 4) then
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											FlatIdent_7308B = 5;
										end
										if (FlatIdent_7308B == 0) then
											B = nil;
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_7308B = 1;
										end
										if (1 == FlatIdent_7308B) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Upvalues[Inst[3]] = Stk[Inst[2]];
											FlatIdent_7308B = 2;
										end
										if (FlatIdent_7308B == 6) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_7308B = 7;
										end
										if (FlatIdent_7308B == 5) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_7308B = 6;
										end
									end
								else
									local A;
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
								end
							elseif (Enum <= 89) then
								if (Enum > 88) then
									Upvalues[Inst[3]] = Stk[Inst[2]];
								else
									local FlatIdent_69531 = 0;
									local A;
									while true do
										if (FlatIdent_69531 == 6) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											FlatIdent_69531 = 7;
										end
										if (FlatIdent_69531 == 4) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_69531 = 5;
										end
										if (5 == FlatIdent_69531) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_69531 = 6;
										end
										if (FlatIdent_69531 == 3) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_69531 = 4;
										end
										if (FlatIdent_69531 == 1) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_69531 = 2;
										end
										if (FlatIdent_69531 == 2) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_69531 = 3;
										end
										if (FlatIdent_69531 == 7) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
											FlatIdent_69531 = 8;
										end
										if (8 == FlatIdent_69531) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											break;
										end
										if (FlatIdent_69531 == 0) then
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_69531 = 1;
										end
									end
								end
							elseif (Enum > 90) then
								local A = Inst[2];
								Stk[A] = Stk[A]();
							else
								local FlatIdent_4EF63 = 0;
								local A;
								while true do
									if (0 == FlatIdent_4EF63) then
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
										break;
									end
								end
							end
						elseif (Enum <= 106) then
							if (Enum <= 98) then
								if (Enum <= 94) then
									if (Enum <= 92) then
										local FlatIdent_81F6A = 0;
										local A;
										while true do
											if (FlatIdent_81F6A == 0) then
												A = nil;
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_81F6A = 1;
											end
											if (2 == FlatIdent_81F6A) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Stk[A + 1]);
												FlatIdent_81F6A = 3;
											end
											if (1 == FlatIdent_81F6A) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_81F6A = 2;
											end
											if (FlatIdent_81F6A == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												FlatIdent_81F6A = 4;
											end
											if (FlatIdent_81F6A == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												if Stk[Inst[2]] then
													VIP = VIP + 1;
												else
													VIP = Inst[3];
												end
												break;
											end
										end
									elseif (Enum > 93) then
										local FlatIdent_5C3A6 = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_5C3A6 == 0) then
												B = nil;
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_5C3A6 = 1;
											end
											if (FlatIdent_5C3A6 == 1) then
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												FlatIdent_5C3A6 = 2;
											end
											if (2 == FlatIdent_5C3A6) then
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_5C3A6 = 3;
											end
											if (FlatIdent_5C3A6 == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												break;
											end
											if (FlatIdent_5C3A6 == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												FlatIdent_5C3A6 = 4;
											end
										end
									else
										local FlatIdent_674F6 = 0;
										while true do
											if (FlatIdent_674F6 == 1) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_674F6 = 2;
											end
											if (FlatIdent_674F6 == 2) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_674F6 = 3;
											end
											if (FlatIdent_674F6 == 4) then
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_674F6 = 5;
											end
											if (FlatIdent_674F6 == 0) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_674F6 = 1;
											end
											if (FlatIdent_674F6 == 5) then
												VIP = Inst[3];
												break;
											end
											if (FlatIdent_674F6 == 3) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_674F6 = 4;
											end
										end
									end
								elseif (Enum <= 96) then
									if (Enum > 95) then
										local FlatIdent_4B897 = 0;
										local A;
										while true do
											if (FlatIdent_4B897 == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
												FlatIdent_4B897 = 4;
											end
											if (FlatIdent_4B897 == 2) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Stk[A + 1]);
												FlatIdent_4B897 = 3;
											end
											if (FlatIdent_4B897 == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												if Stk[Inst[2]] then
													VIP = VIP + 1;
												else
													VIP = Inst[3];
												end
												break;
											end
											if (FlatIdent_4B897 == 1) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_4B897 = 2;
											end
											if (FlatIdent_4B897 == 0) then
												A = nil;
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_4B897 = 1;
											end
										end
									else
										local Results;
										local Edx;
										local Results, Limit;
										local B;
										local A;
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Results, Limit = _R(Stk[A](Stk[A + 1]));
										Top = (Limit + A) - 1;
										Edx = 0;
										for Idx = A, Top do
											local FlatIdent_945DF = 0;
											while true do
												if (FlatIdent_945DF == 0) then
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
													break;
												end
											end
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Results = {Stk[A](Unpack(Stk, A + 1, Top))};
										Edx = 0;
										for Idx = A, Inst[4] do
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
										end
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
									end
								elseif (Enum > 97) then
									local FlatIdent_8DA9B = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_8DA9B == 6) then
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_8DA9B = 7;
										end
										if (FlatIdent_8DA9B == 0) then
											B = nil;
											A = nil;
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											FlatIdent_8DA9B = 1;
										end
										if (FlatIdent_8DA9B == 3) then
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											VIP = VIP + 1;
											FlatIdent_8DA9B = 4;
										end
										if (FlatIdent_8DA9B == 4) then
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											FlatIdent_8DA9B = 5;
										end
										if (FlatIdent_8DA9B == 1) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = {};
											FlatIdent_8DA9B = 2;
										end
										if (FlatIdent_8DA9B == 7) then
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											break;
										end
										if (FlatIdent_8DA9B == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											FlatIdent_8DA9B = 3;
										end
										if (FlatIdent_8DA9B == 5) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											FlatIdent_8DA9B = 6;
										end
									end
								else
									local B;
									local A;
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									if Stk[Inst[2]] then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								end
							elseif (Enum <= 102) then
								if (Enum <= 100) then
									if (Enum == 99) then
										local FlatIdent_6DE1D = 0;
										local A;
										while true do
											if (0 == FlatIdent_6DE1D) then
												A = Inst[2];
												do
													return Stk[A](Unpack(Stk, A + 1, Inst[3]));
												end
												break;
											end
										end
									else
										local FlatIdent_6FC5B = 0;
										local Edx;
										local Results;
										local B;
										local A;
										while true do
											if (FlatIdent_6FC5B == 11) then
												A = Inst[2];
												Results = {Stk[A](Stk[A + 1])};
												Edx = 0;
												for Idx = A, Inst[4] do
													local FlatIdent_7E46E = 0;
													while true do
														if (0 == FlatIdent_7E46E) then
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
															break;
														end
													end
												end
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_6FC5B = 12;
											end
											if (FlatIdent_6FC5B == 7) then
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_6FC5B = 8;
											end
											if (FlatIdent_6FC5B == 5) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_6FC5B = 6;
											end
											if (FlatIdent_6FC5B == 8) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_6FC5B = 9;
											end
											if (FlatIdent_6FC5B == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_6FC5B = 3;
											end
											if (FlatIdent_6FC5B == 10) then
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_6FC5B = 11;
											end
											if (FlatIdent_6FC5B == 0) then
												Edx = nil;
												Results = nil;
												B = nil;
												A = nil;
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												FlatIdent_6FC5B = 1;
											end
											if (9 == FlatIdent_6FC5B) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_6FC5B = 10;
											end
											if (FlatIdent_6FC5B == 12) then
												VIP = Inst[3];
												break;
											end
											if (FlatIdent_6FC5B == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												FlatIdent_6FC5B = 5;
											end
											if (FlatIdent_6FC5B == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_6FC5B = 4;
											end
											if (6 == FlatIdent_6FC5B) then
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_6FC5B = 7;
											end
											if (FlatIdent_6FC5B == 1) then
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												FlatIdent_6FC5B = 2;
											end
										end
									end
								elseif (Enum == 101) then
									local B = Stk[Inst[4]];
									if not B then
										VIP = VIP + 1;
									else
										Stk[Inst[2]] = B;
										VIP = Inst[3];
									end
								else
									local A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Top));
								end
							elseif (Enum <= 104) then
								if (Enum == 103) then
									local A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
								else
									Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
								end
							elseif (Enum > 105) then
								if Stk[Inst[2]] then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							else
								local Edx;
								local Results;
								local B;
								local A;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = {};
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Results = {Stk[A](Stk[A + 1])};
								Edx = 0;
								for Idx = A, Inst[4] do
									local FlatIdent_94E30 = 0;
									while true do
										if (FlatIdent_94E30 == 0) then
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
											break;
										end
									end
								end
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
							end
						elseif (Enum <= 114) then
							if (Enum <= 110) then
								if (Enum <= 108) then
									if (Enum == 107) then
										local FlatIdent_3BCFD = 0;
										local Results;
										local Edx;
										local Limit;
										local B;
										local A;
										while true do
											if (3 == FlatIdent_3BCFD) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_3BCFD = 4;
											end
											if (FlatIdent_3BCFD == 8) then
												Inst = Instr[VIP];
												A = Inst[2];
												Results = {Stk[A](Unpack(Stk, A + 1, Top))};
												Edx = 0;
												FlatIdent_3BCFD = 9;
											end
											if (FlatIdent_3BCFD == 7) then
												Top = (Limit + A) - 1;
												Edx = 0;
												for Idx = A, Top do
													Edx = Edx + 1;
													Stk[Idx] = Results[Edx];
												end
												VIP = VIP + 1;
												FlatIdent_3BCFD = 8;
											end
											if (FlatIdent_3BCFD == 9) then
												for Idx = A, Inst[4] do
													local FlatIdent_7F2A4 = 0;
													while true do
														if (FlatIdent_7F2A4 == 0) then
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
															break;
														end
													end
												end
												VIP = VIP + 1;
												Inst = Instr[VIP];
												VIP = Inst[3];
												break;
											end
											if (6 == FlatIdent_3BCFD) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Results, Limit = _R(Stk[A](Stk[A + 1]));
												FlatIdent_3BCFD = 7;
											end
											if (FlatIdent_3BCFD == 5) then
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												FlatIdent_3BCFD = 6;
											end
											if (FlatIdent_3BCFD == 1) then
												A = nil;
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_3BCFD = 2;
											end
											if (FlatIdent_3BCFD == 2) then
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_3BCFD = 3;
											end
											if (FlatIdent_3BCFD == 0) then
												Results = nil;
												Edx = nil;
												Results, Limit = nil;
												B = nil;
												FlatIdent_3BCFD = 1;
											end
											if (FlatIdent_3BCFD == 4) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_3BCFD = 5;
											end
										end
									else
										local A;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A]();
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										if not Stk[Inst[2]] then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									end
								elseif (Enum > 109) then
									local FlatIdent_47DDA = 0;
									local A;
									while true do
										if (0 == FlatIdent_47DDA) then
											A = Inst[2];
											Stk[A] = Stk[A](Stk[A + 1]);
											break;
										end
									end
								else
									for Idx = Inst[2], Inst[3] do
										Stk[Idx] = nil;
									end
								end
							elseif (Enum <= 112) then
								if (Enum == 111) then
									local FlatIdent_4087C = 0;
									local A;
									local Results;
									local Edx;
									while true do
										if (FlatIdent_4087C == 0) then
											A = Inst[2];
											Results = {Stk[A](Unpack(Stk, A + 1, Top))};
											FlatIdent_4087C = 1;
										end
										if (FlatIdent_4087C == 1) then
											Edx = 0;
											for Idx = A, Inst[4] do
												local FlatIdent_212D3 = 0;
												while true do
													if (FlatIdent_212D3 == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
											break;
										end
									end
								else
									local FlatIdent_2AB7E = 0;
									local Edx;
									local Results;
									local Limit;
									local B;
									local A;
									while true do
										if (FlatIdent_2AB7E == 3) then
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											FlatIdent_2AB7E = 4;
										end
										if (FlatIdent_2AB7E == 6) then
											Top = (Limit + A) - 1;
											Edx = 0;
											for Idx = A, Top do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											FlatIdent_2AB7E = 7;
										end
										if (FlatIdent_2AB7E == 5) then
											Inst = Instr[VIP];
											A = Inst[2];
											Results, Limit = _R(Stk[A](Stk[A + 1]));
											FlatIdent_2AB7E = 6;
										end
										if (FlatIdent_2AB7E == 8) then
											Stk[A](Unpack(Stk, A + 1, Top));
											break;
										end
										if (FlatIdent_2AB7E == 2) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_2AB7E = 3;
										end
										if (FlatIdent_2AB7E == 0) then
											Edx = nil;
											Results, Limit = nil;
											B = nil;
											FlatIdent_2AB7E = 1;
										end
										if (FlatIdent_2AB7E == 4) then
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_2AB7E = 5;
										end
										if (FlatIdent_2AB7E == 1) then
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_2AB7E = 2;
										end
										if (FlatIdent_2AB7E == 7) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_2AB7E = 8;
										end
									end
								end
							elseif (Enum > 113) then
								local FlatIdent_84D9 = 0;
								local A;
								while true do
									if (FlatIdent_84D9 == 0) then
										A = nil;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										FlatIdent_84D9 = 1;
									end
									if (FlatIdent_84D9 == 6) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_84D9 = 7;
									end
									if (FlatIdent_84D9 == 7) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										FlatIdent_84D9 = 8;
									end
									if (FlatIdent_84D9 == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_84D9 = 4;
									end
									if (FlatIdent_84D9 == 2) then
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]];
										FlatIdent_84D9 = 3;
									end
									if (FlatIdent_84D9 == 8) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_84D9 = 9;
									end
									if (FlatIdent_84D9 == 5) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_84D9 = 6;
									end
									if (FlatIdent_84D9 == 1) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_84D9 = 2;
									end
									if (FlatIdent_84D9 == 4) then
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										FlatIdent_84D9 = 5;
									end
									if (FlatIdent_84D9 == 9) then
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
										break;
									end
								end
							else
								Stk[Inst[2]] = Inst[3];
							end
						elseif (Enum <= 118) then
							if (Enum <= 116) then
								if (Enum > 115) then
									local FlatIdent_92670 = 0;
									while true do
										if (FlatIdent_92670 == 4) then
											if Stk[Inst[2]] then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
											break;
										end
										if (FlatIdent_92670 == 2) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_92670 = 3;
										end
										if (FlatIdent_92670 == 1) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_92670 = 2;
										end
										if (FlatIdent_92670 == 0) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_92670 = 1;
										end
										if (FlatIdent_92670 == 3) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_92670 = 4;
										end
									end
								else
									do
										return;
									end
								end
							elseif (Enum == 117) then
								local FlatIdent_6128B = 0;
								local B;
								local A;
								while true do
									if (FlatIdent_6128B == 5) then
										Stk[Inst[2]] = Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										break;
									end
									if (FlatIdent_6128B == 4) then
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_6128B = 5;
									end
									if (FlatIdent_6128B == 1) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										FlatIdent_6128B = 2;
									end
									if (FlatIdent_6128B == 2) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_6128B = 3;
									end
									if (FlatIdent_6128B == 0) then
										B = nil;
										A = nil;
										Env[Inst[3]] = Stk[Inst[2]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										FlatIdent_6128B = 1;
									end
									if (FlatIdent_6128B == 3) then
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_6128B = 4;
									end
								end
							else
								local B;
								local A;
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								if not Stk[Inst[2]] then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							end
						elseif (Enum <= 120) then
							if (Enum == 119) then
								local FlatIdent_2595D = 0;
								local A;
								local Cls;
								while true do
									if (FlatIdent_2595D == 0) then
										A = Inst[2];
										Cls = {};
										FlatIdent_2595D = 1;
									end
									if (FlatIdent_2595D == 1) then
										for Idx = 1, #Lupvals do
											local List = Lupvals[Idx];
											for Idz = 0, #List do
												local FlatIdent_73868 = 0;
												local Upv;
												local NStk;
												local DIP;
												while true do
													if (FlatIdent_73868 == 0) then
														Upv = List[Idz];
														NStk = Upv[1];
														FlatIdent_73868 = 1;
													end
													if (FlatIdent_73868 == 1) then
														DIP = Upv[2];
														if ((NStk == Stk) and (DIP >= A)) then
															Cls[DIP] = NStk[DIP];
															Upv[1] = Cls;
														end
														break;
													end
												end
											end
										end
										break;
									end
								end
							else
								local FlatIdent_65844 = 0;
								local A;
								while true do
									if (FlatIdent_65844 == 2) then
										Stk[A] = Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
										FlatIdent_65844 = 3;
									end
									if (FlatIdent_65844 == 0) then
										A = nil;
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_65844 = 1;
									end
									if (FlatIdent_65844 == 1) then
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_65844 = 2;
									end
									if (FlatIdent_65844 == 3) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										if Stk[Inst[2]] then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
										break;
									end
								end
							end
						elseif (Enum > 121) then
							local FlatIdent_197AE = 0;
							local A;
							while true do
								if (3 == FlatIdent_197AE) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A]();
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_197AE = 4;
								end
								if (5 == FlatIdent_197AE) then
									VIP = Inst[3];
									break;
								end
								if (FlatIdent_197AE == 1) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									FlatIdent_197AE = 2;
								end
								if (FlatIdent_197AE == 4) then
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_197AE = 5;
								end
								if (FlatIdent_197AE == 0) then
									A = nil;
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A]();
									FlatIdent_197AE = 1;
								end
								if (FlatIdent_197AE == 2) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									FlatIdent_197AE = 3;
								end
							end
						else
							Stk[Inst[2]][Inst[3]] = Inst[4];
						end
						VIP = VIP + 1;
						break;
					end
					if (FlatIdent_8CEDF == 0) then
						Inst = Instr[VIP];
						Enum = Inst[1];
						FlatIdent_8CEDF = 1;
					end
				end
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!CA3O00030A3O006C6F6164737472696E6703043O0067616D6503073O00482O747047657403493O00682O7470733A2O2F6769746875622E636F6D2F64617769642D736372697074732F466C75656E742F72656C65617365732F6C61746573742F646F776E6C6F61642F6D61696E2E6C756103543O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F64617769642D736372697074732F466C75656E742F6D61737465722F412O646F6E732F536176654D616E616765722E6C756103593O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F64617769642D736372697074732F466C75656E742F6D61737465722F412O646F6E732F496E746572666163654D616E616765722E6C7561030C3O0043726561746557696E646F7703053O005469746C65030B3O004D612O646965204875622003083O005375625469746C65030B3O006279204D696E6B4465763703083O005461625769647468026O00644003043O0053697A6503053O005544696D32030A3O0066726F6D4F2O66736574025O00207C40025O00C0724003073O00416372796C69632O0103053O005468656D6503083O00416D657468797374030B3O004D696E696D697A654B657903043O00456E756D03073O004B6579436F6465030B3O004C656674436F6E74726F6C03083O00496E7374616E63652O033O006E657703093O005363722O656E47756903053O004672616D65030A3O00496D6167654C6162656C030A3O005465787442752O746F6E03083O005549436F726E657203073O00436F7265477569030E3O0046696E6446697273744368696C64030B3O00436C69636B42752O746F6E03073O0044657374726F7903043O004E616D6503063O00506172656E74030E3O005A496E6465784265686176696F7203073O005369626C696E6703093O004D61696E4672616D6503063O00416374697665030B3O00416E63686F72506F696E7403073O00566563746F7232026O00E03F03103O004261636B67726F756E64436F6C6F723303063O00436F6C6F7233026O00F03F030C3O00426F72646572436F6C6F7233028O00030F3O00426F7264657253697A65506978656C030C3O005472616E73706172656E637903083O00506F736974696F6E02AF27992013FEC73F02F73361A01086DE3F025O00804640030C3O00436F726E657252616469757303043O005544696D026O005940021E607BA0F449DF3F03053O00496D61676503183O00726278612O73657469643A2O2F313836323134393033373203163O004261636B67726F756E645472616E73706172656E6379023O00206CC1963E030F3O004175746F42752O746F6E436F6C6F72010003043O00466F6E74030A3O00536F7572636553616E7303043O0054657874034O00030A3O0054657874436F6C6F7233025O00E06F4003083O005465787453697A65026O002E4003113O004D6F75736542752O746F6E31436C69636B03073O00436F2O6E65637403053O007063612O6C030A3O004765745365727669636503093O00576F726B737061636503113O005265706C69636174656453746F7261676503073O00506C6179657273030B3O004C6F63616C506C61796572030A3O0052756E5365727669636503083O004C69676874696E6703103O0055736572496E7075745365727669636503053O005465616D73030D3O00536372697074436F6E74657874030D3O0043752O72656E7443616D65726103083O004765744D6F75736503073O0054652O7261696E030B3O005669727475616C5573657203073O004D6F64756C6573030B3O00456D6F74654D6F64756C6503093O00506C6179657247756903073O004D61696E47554903043O0047616D6503063O00456D6F74657303083O00686561646C652O7303063O007A6F6D6269652O033O007A656E03053O006E696E6A6103053O00666C6F2O732O033O00646162027O0040027O00C0026O00F0BF03093O00486967686C6967687403153O0053706865726548616E646C6541646F726E6D656E7403093O0046692O6C436F6C6F7203073O0066726F6D524742026O006F40025O00206E40025O00C0654003073O0041646F726E2O6503073O0047756E44726F7003133O004F75746C696E655472616E73706172656E637903093O0044657074684D6F646503123O00486967686C6967687444657074684D6F6465030B3O00416C776179734F6E546F70030C3O00526F626C6F784C6F636B6564029A5O99C93F03103O0041646F726E43752O6C696E674D6F646503053O004E6576657203053O004C6F2O627903073O00566563746F7233022C2O0080E5475EC002212O0020C448614002162O00C01A7943402O033O004D6170023O00A020FA5AC0023O0040324B6140023O00A0B33E25C003053O00706169727303053O007461626C6503063O00696E73657274030B3O004765744D75726465726572030A3O0047657453686572692O6603073O0067657467656E7603023O005753026O00304003023O004A50026O004940030B3O005365744368617256617273030E3O00436861726163746572412O646564030E3O00682O6F6B6D6574616D6574686F6403073O002O5F696E64657803043O004D61696E03063O00412O6454616203043O0049636F6E03043O00686F6D6503053O004661726D732O033O00626F7803093O00412O64546F2O676C65030D3O00546F2O676C654B692O6C412O6C03083O004B692O6C20412O6C03073O0044656661756C7403093O004F6E4368616E676564030A3O00412O6453656374696F6E03063O0042617369637303093O00412O64536C6964657203093O0057616C6B53702O6564030B3O004465736372697074696F6E2O033O004D696E2O033O004D6178026O00694003083O00526F756E64696E6703083O0043612O6C6261636B03093O004A756D70506F77657203093O00412O6442752O746F6E03083O00476F64204D6F646503073O00476F644D6F646503053O00576F726C6403063O00466F6C646572030A3O0045535020486F6C646572030A3O00476574506C617965727303093O00636F726F7574696E6503043O0077726170030B3O00506C61796572412O646564030E3O00506C6179657252656D6F76696E6703103O00546F2O676C6545532O506C6179657273030B3O0045535020506C6179657273030F3O00546F2O676C654553504D7572646572030A3O00455350204D757264657203103O00546F2O676C6545535053686572692O66030B3O004553502053686572692O662O033O0047756E030C3O00546F2O676C6545535047756E03073O004553502047756E030A3O00412O644B657962696E6403073O004765742047756E03043O004D6F646503063O00546F2O676C6503013O005903063O004E6F7469667903073O0053752O63652O7303073O00436F6E74656E74030A3O004D612O64696520487562030A3O00537562436F6E74656E7403213O005468652053637269707420576173204C6F6164696E6720436F6D706C6574656C7903083O004475726174696F6E026O002040007B022O0012013O00013O00122O000100023O00202O00010001000300122O000300046O000100039O0000026O0001000200122O000100013O00122O000200023O00202O00020002000300122O000400056O000200046O00013O00024O00010001000200122O000200013O00122O000300023O00202O00030003000300122O000500066O000300056O00023O00024O00020001000200202O00033O00074O00053O000700302O00050008000900302O0005000A000B00302O0005000C000D00122O0006000F3O00202O00060006001000122O000700113O00122O000800126O00060008000200102O0005000E000600302O00050013001400302O00050015001600122O000600183O00202O00060006001900202O00060006001A00102O0005001700064O00030005000200122O0004001B3O00202O00040004001C00122O0005001D6O00040002000200122O0005001B3O00202O00050005001C00122O0006001E6O00050002000200122O0006001B3O00202O00060006001C00122O0007001F6O00060002000200122O0007001B3O00202O00070007001C00122O000800206O00070002000200122O0008001B3O00202O00080008001C00122O000900216O00080002000200122O0009001B3O00202O00090009001C00122O000A00216O00090002000200122O000A00023O00202O000A000A002200202O000A000A002300122O000C00246O000A000C000200062O000A004D00013O0004393O004D000100123A000A00023O002033000A000A002200202O000A000A002300122O000C00246O000A000C000200202O000A000A00254O000A00020001003079000400260024001215000A00023O00202O000A000A002200102O00040027000A00122O000A00183O00202O000A000A002800202O000A000A002900102O00040028000A00302O00050026002A00102O00050027000400302O0005002B001400122O000A002D3O00202O000A000A001C00122O000B002E3O00122O000C002E6O000A000C000200102O0005002C000A00122O000A00303O00202O000A000A001C00122O000B00313O00122O000C00313O00122O000D00316O000A000D000200102O0005002F000A00122O000A00303O00202O000A000A001C00122O000B00333O00122O000C00333O00122O000D00336O000A000D000200102O00050032000A00302O00050034003300302O00050035003100122O000A000F3O00202O000A000A001C00122O000B00373O00122O000C00333O00122O000D00383O00122O000E00336O000A000E000200102O00050036000A00122O000A000F3O00202O000A000A001C00122O000B00333O00122O000C00393O00122O000D00333O00122O000E00396O000A000E000200102O0005000E000A00122O000A003B3O00202O000A000A001C00122O000B00333O00122O000C003C6O000A000C000200102O0008003A000A00102O00080027000500122O000A003B3O00202O000A000A001C00122O000B00333O00122O000C003C6O000A000C000200102O0009003A000A00102O00090027000600102O00060027000500122O000A002D3O00202O000A000A001C00122O000B002E3O00122O000C002E6O000A000C000200102O0006002C000A00122O000A00303O00202O000A000A001C00122O000B00333O00122O000C00333O00122O000D00336O000A000D000200102O0006002F000A00122O000A00303O00202O000A000A001C00122O000B00333O00122O000C00333O001271000D00334O0054000A000D000200102O00060032000A00302O00060034003300122O000A000F3O00202O000A000A001C00122O000B003D3O00122O000C00333O00122O000D003D3O00122O000E00336O000A000E000200102O00060036000A00122O000A000F3O00202O000A000A001C00122O000B00333O00122O000C00393O00122O000D00333O00122O000E00396O000A000E000200102O0006000E000A00302O0006003E003F00102O00070027000500122O000A00303O00202O000A000A001C00122O000B00313O00122O000C00313O00122O000D00316O000A000D000200102O0007002F000A00302O00070040003100122O000A00303O00202O000A000A001C00122O000B00333O00122O000C00333O00122O000D00336O000A000D000200102O00070032000A00302O00070034003300122O000A000F3O00202O000A000A001C00122O000B00413O00122O000C00333O00122O000D00333O00122O000E00336O000A000E000200102O00070036000A00122O000A000F3O00202O000A000A001C00122O000B00333O00122O000C00393O00122O000D00333O00122O000E00396O000A000E000200102O0007000E000A00302O00070042004300122O000A00183O00202O000A000A004400202O000A000A004500102O00070044000A00302O00070046004700122O000A00303O00202O000A000A001C00122O000B00493O00122O000C00493O00122O000D00496O000A000D000200102O00070048000A00302O0007004A004B00202O000A0007004C00202O000A000A004D000225000C6O0067000A000C000100123A000A004E3O000225000B00014O0047000A0002000100122O000A00023O00202O000A000A004F00122O000C00506O000A000C000200122O000B00023O00202O000B000B004F00122O000D00516O000B000D000200122O000C00023O00202O000C000C004F00122O000E00526O000C000E000200202O000D000C005300122O000E00023O00202O000E000E004F00122O001000546O000E0010000200122O000F00023O00202O000F000F004F00122O001100506O000F0011000200122O001000023O00202O00100010004F00122O001200556O00100012000200122O001100023O00202O00110011004F00122O001300566O00110013000200122O001200023O00202O00120012004F00122O001400576O00120014000200122O001300023O00202O00130013004F00122O001500586O00130015000200122O001400023O00202O00140014004F00122O001600226O00140016000200202O0015000F005900202O0016000D005A4O00160002000200202O0017000F005B00122O001800023O00202O00180018004F00122O001A005C6O0018001A000200202O0019000B005D00202O001A0019005E00202O001B000D005F00202O001B001B006000202O001B001B006100202O001B001B002300122O001D00626O001B001D00024O001C00063O00122O001D00633O00122O001E00643O00122O001F00653O00122O002000663O00122O002100673O00122O002200686O001C000600012O006D001D001D4O0044001D8O001E00066O001F00033O00122O002000693O00122O002100333O00122O002200336O001F000300012O003C002000033O0012710021006A3O001271002200333O001271002300334O00220020000300012O003C002100033O001271002200333O001271002300693O001271002400334O00220021000300012O003C002200033O001271002300333O0012710024006A3O001271002500334O00220022000300012O003C002300033O001271002400333O001271002500333O001271002600314O00220023000300012O003C002400033O001271002500333O001271002600333O0012710027006B4O00220024000300012O0022001E0006000100123A001F001B3O002069001F001F001C00122O0020006C6O001F0002000200122O0020001B3O00202O00200020001C00122O0021006D6O00200002000200122O002100303O00202O00210021006F00122O002200703O00122O002300713O00122O002400726O00210024000200102O001F006E002100202O0021000F002300122O002300746O00210023000200102O001F0073002100302O001F0075003100122O002100183O00202O00210021007700202O00210021007800102O001F0076002100302O001F0079001400122O002100303O00202O00210021006F00122O002200703O00122O002300713O00122O002400726O00210024000200102O00200030002100302O00200035007A00202O0021000F002300122O002300746O00210023000200102O00200073002100302O00200078001400122O002100183O00202O00210021007B00202O00210021007C00102O0020007B002100302O00200079001400102O001F0027001400102O0020002700144O00213O000200122O0022007E3O00202O00220022001C00122O0023007F3O00122O002400803O00122O002500816O00220025000200102O0021007D002200122O0022007E3O00202O00220022001C00122O002300833O00122O002400843O00122O002500856O00220025000200102O0021008200224O00225O00122O002300866O002400216O00230002002500044O00922O0100123A002800873O00202D0028002800882O0003002900224O0003002A00264O00670028002A000100064F0023008D2O0100020004393O008D2O012O006D002300243O00062B00250002000100012O00033O000C3O001242002500893O00062B00250003000100012O00033O000C3O00121E0025008A6O002500273O00122O0028008B6O00280001000200302O0028008C008D00122O0028008B6O00280001000200302O0028008E008F00062B00280004000100042O00033O00254O00033O000D4O00033O00274O00033O00263O00124D002800903O00122O002800906O00280001000100202O0028000D009100202O00280028004D00122O002A00906O0028002A00014O002800283O00122O002900923O00122O002A00023O001271002B00933O00062B002C0005000100012O00033O00284O00160029002C00024O002800296O002900293O00122O002A00923O00122O002B00023O00122O002C00933O00062B002D0006000100012O00033O00294O0062002A002D00024O0029002A6O002A3O000200202O002B000300954O002D3O000200302O002D0008009400302O002D009600974O002B002D000200102O002A0094002B00202O002B000300952O003C002D3O000200300B002D0008009800302O002D009600994O002B002D000200102O002A0098002B00202O002B002A009400202O002B002B009A00122O002D009B6O002E3O000200302O002E0008009C00302O002E009D00432O000F002B002E000200202E002C002B009E00062B002E0007000100042O00033O000C4O00033O000D4O00033O00184O00033O00274O000C002C002E000100202O002C002A009400202O002C002C009F00122O002E00A06O002C002E000200202O002D002A009400202O002D002D00A100122O002F008C6O00303O000700302O0030000800A2003079003000A300470030790030009D008D003079003000A4008D003079003000A500A6003079003000A7003100062B00310008000100012O00033O00273O001050003000A800314O002D0030000200202O002E002A009400202O002E002E00A100122O0030008E6O00313O000700302O0031000800A900302O003100A3004700302O0031009D008F00302O003100A4008F003079003100A500A6003079003100A7003100062B00320009000100012O00033O00273O001017003100A800324O002E0031000200202O002F002A009400202O002F002F00AA4O00313O000300302O0031000800AB00302O003100A300470002250032000A3O00101B003100A800322O0067002F003100012O003C002F5O00062B0030000B000100012O00033O002F3O001275003000AC3O00202O0030002A009400202O00300030009F00122O003200AD6O00300032000200122O0031001B3O00202O00310031001C00122O003200AE6O003300146O0031003300020030790031002600AF00062B0032000C000100012O00033O00313O001204003300863O00202O0034000C00B04O003400356O00333O003500044O001E02010006180037001E0201000D0004393O001E020100123A003800B13O00204C0038003800B24O003900326O0038000200024O003900376O00380002000100064F00330016020100020004393O0016020100202D0033000C00B300202400330033004D4O003500326O00330035000100202O0033000C00B400202O00330033004D00062B0035000D000100012O00033O00314O004E00330035000100202O0033002A009400202O00330033009A00122O003500B56O00363O000200302O0036000800B600302O0036009D00434O00330036000200202O00340033009E00062B0036000E000100022O00033O00314O00033O000C4O004E00340036000100202O0034002A009400202O00340034009A00122O003600B76O00373O000200302O0037000800B800302O0037009D00434O00340037000200202O00350034009E00062B0037000F000100022O00033O00314O00033O000C4O004E00350037000100202O0035002A009400202O00350035009A00122O003700B96O00383O000200302O0038000800BA00302O0038009D00434O00350038000200202O00360035009E00062B00380010000100022O00033O00314O00033O000C4O000C00360038000100202O0036002A009800202O00360036009F00122O003800BB6O00360038000200202O0037002A009800202O00370037009A00122O003900BC6O003A3O000200302O003A000800BD003079003A009D00432O000F0037003A000200202E00380037009E000225003A00114O00670038003A000100123A003800B13O00202D0038003800B200062B00390012000100042O00033O000E4O00033O001F4O00033O00204O00033O000F4O001A0038000200024O00380001000100202O0038002A009800202O0038003800BE00122O003A00BF6O003B3O000400302O003B000800BF00302O003B00C000C100302O003B009D00C200062B003C0013000100042O00033O00264O00033O000E4O00033O000F4O00033O001D3O00103D003B00A8003C4O0038003B000200202O00393O00C34O003B3O000400302O003B000800C400302O003B00C500C600302O003B00C700C800302O003B00C900CA4O0039003B00019O002O00733O00013O00143O00063O00028O0003043O0067616D65030A3O004765745365727669636503133O005669727475616C496E7075744D616E61676572030C3O0053656E644B65794576656E74030B3O004C656674436F6E74726F6C00203O0012713O00014O006D000100013O000E1F0001000200013O0004393O00020001001271000100013O00263E00010005000100010004393O0005000100123A000200023O00205200020002000300122O000400046O00020004000200202O0002000200054O000400013O00122O000500066O00065O00122O000700026O00020007000100122O000200023O00202O00020002000300122O000400046O00020004000200202O0002000200054O00045O00122O000500066O00065O00122O000700026O00020007000100044O001F00010004393O000500010004393O001F00010004393O000200012O00733O00017O00073O0003053O007061697273030E3O00676574636F2O6E656374696F6E7303043O0067616D65030A3O0047657453657276696365030D3O00536372697074436F6E7465787403053O00452O726F7203073O0044697361626C65000F3O00122A3O00013O00122O000100023O00122O000200033O00202O00020002000400122O000400056O00020004000200202O0002000200064O000100029O00000200044O000C000100202E0005000400072O000900050002000100064F3O000A000100020004393O000A00012O00733O00017O00093O00028O0003053O007061697273030B3O004765744368696C6472656E03083O004261636B7061636B030E3O0046696E6446697273744368696C6403053O004B6E69666503093O0043686172616374657203043O004E616D6503043O00542O6F6C002A3O0012713O00014O006D000100013O00263E3O0002000100010004393O00020001001271000100013O00263E00010005000100010004393O00050001001271000200013O00263E00020008000100010004393O0008000100123A000300024O002F00045O00202O0004000400034O000400056O00033O000500044O0021000100202D00080007000400202E000800080005001271000A00064O000F0008000A000200060D0008001F000100010004393O001F000100202D00080007000700202E000800080005001271000A00064O000F0008000A000200066A0008002100013O0004393O0021000100202D00080007000800263E00080021000100090004393O0021000100202D0008000700082O0048000800023O00064F00030010000100020004393O001000012O006D000300034O0048000300023O0004393O000800010004393O000500010004393O002900010004393O000200012O00733O00017O00093O0003053O007061697273030B3O004765744368696C6472656E028O0003083O004261636B7061636B030E3O0046696E6446697273744368696C642O033O0047756E03093O0043686172616374657203043O004E616D6503043O00542O6F6C00263O0012453O00016O00015O00202O0001000100024O000100029O00000200044O00230001001271000500034O006D000600063O00263E00050008000100030004393O00080001001271000600033O000E1F0003000B000100060004393O000B000100202D00070004000400202E000700070005001271000900064O000F00070009000200060D0007001C000100010004393O001C000100202D00070004000700202E000700070005001271000900064O000F00070009000200066A0007001E00013O0004393O001E000100202D00070004000800263E0007001E000100090004393O001E000100202D0007000400082O0048000700024O006D000700074O0048000700023O0004393O000B00010004393O002300010004393O0008000100064F3O0006000100020004393O000600012O00733O00017O00113O00028O0003093O00436861726163746572030E3O0046696E6446697273744368696C6403083O0048756D616E6F6964030C3O0057616974466F724368696C64026O00F03F027O004003183O0047657450726F70657274794368616E6765645369676E616C03093O0057616C6B53702O656403073O00436F2O6E65637403073O0067657467656E7603043O004A756D7003023O004A50026O00084003103O0048756D616E6F6964522O6F745061727403053O0053702O656403023O005753004C3O0012713O00013O00263E3O0012000100010004393O001200012O0032000100013O0020560001000100024O00018O00015O00202O00010001000300122O000300046O00010003000200062O00010010000100010004393O001000012O003200015O00202E000100010005001271000300044O000F0001000300022O0059000100023O0012713O00063O00263E3O0027000100070004393O002700012O0032000100023O00202E000100010008001271000300094O000F00010003000200202E00010001000A00062B00033O000100012O00323O00024O000A00010003000100122O0001000B6O00010001000200202O00010001000C00062O0001002600013O0004393O002600012O0032000100023O00123A0002000B4O005B00020001000200202D00020002000D00101B0001000900020012713O000E3O00263E3O00320001000E0004393O003200012O0032000100023O00202E000100010008001271000300094O000F00010003000200202E00010001000A00062B00030001000100012O00323O00024O00670001000300010004393O004B000100263E3O0001000100060004393O000100012O003200015O00202E0001000100030012710003000F4O000F00010003000200060D0001003E000100010004393O003E00012O003200015O00202E0001000100050012710003000F4O000F0001000300022O0059000100033O00123A0001000B4O005B00010001000200202D00010001001000066A0001004900013O0004393O004900012O0032000100023O00123A0002000B4O005B00020001000200202D00020002001100101B0001000900020012713O00073O0004393O000100012O00733O00013O00023O00043O0003073O0067657467656E7603053O0053702O656403093O0057616C6B53702O656403023O005753000B3O00123A3O00014O005B3O0001000200202D5O000200066A3O000A00013O0004393O000A00012O00327O00123A000100014O005B00010001000200202D00010001000400101B3O000300012O00733O00017O00043O0003073O0067657467656E7603043O004A756D7003093O0057616C6B53702O656403023O004A50000B3O00123A3O00014O005B3O0001000200202D5O000200066A3O000A00013O0004393O000A00012O00327O00123A000100014O005B00010001000200202D00010001000400101B3O000300012O00733O00017O00053O00028O0003083O00746F737472696E6703083O0048756D616E6F696403093O0057616C6B53702O6564026O00304002163O001271000200013O000E1F00010001000100020004393O0001000100123A000300024O000300046O006E00030002000200263E0003000F000100030004393O000F000100123A000300024O0003000400014O006E00030002000200263E0003000F000100040004393O000F0001001271000300054O0048000300024O003200036O002700048O000500016O000300056O00035O00044O000100012O00733O00017O00053O00028O0003083O00746F737472696E6703083O0048756D616E6F696403093O0057616C6B53702O6564026O003040021A3O001271000200013O00263E00020001000100010004393O00010001001271000300013O00263E00030004000100010004393O0004000100123A000400024O000300056O006E00040002000200263E00040012000100030004393O0012000100123A000400024O0003000500014O006E00040002000200263E00040012000100040004393O00120001001271000400054O0048000400024O003200046O002700058O000600016O000400066O00045O00044O000400010004393O000100012O00733O00017O00013O0003053O007063612O6C01083O00123A000100013O00062B00023O000100042O00328O00323O00014O00323O00024O00323O00034O00090001000200012O00733O00013O00013O001C3O00028O00026O00F03F2O033O0049734103043O00542O6F6C03063O00697061697273030A3O00476574506C617965727303093O004368617261637465720003053O007461626C6503043O0066696E6403073O0067657467656E76030B3O0057686974656C697374656403043O004E616D65030C3O00436C69636B42752O746F6E3103073O00566563746F72322O033O006E657703113O0066697265746F756368696E74657265737403063O0048616E646C65027O004003103O0048756D616E6F6964522O6F745061727403083O00506F736974696F6E030A3O006C617374412O7461636B03043O007469636B03083O004261636B7061636B030E3O0046696E6446697273744368696C6403053O004B6E69666503063O00506172656E7403093O004571756970542O6F6C00793O0012713O00014O006D000100013O000E1F0002005700013O0004393O0057000100066A0001007800013O0004393O0078000100202E000200010003001271000400044O000F00020004000200066A0002007800013O0004393O0078000100123A000200054O002F00035O00202O0003000300064O000300046O00023O000400044O005400012O0032000700013O00061800060054000100070004393O0054000100202D00070006000700264600070054000100080004393O0054000100123A000700093O00206C00070007000A00122O0008000B6O00080001000200202O00080008000C00202O00090006000D4O00070009000200062O00070054000100010004393O00540001001271000700014O006D0008000A3O000E1F0002004E000100070004393O004E00012O006D000A000A3O00263E00080033000100020004393O003300012O0032000B00023O002011000B000B000E00122O000D000F3O00202O000D000D00104O000D00016O000B3O000100122O000B00116O000C00093O00202O000D0001001200122O000E00026O000B000E000100122O000800133O000E1F00010041000100080004393O00410001001271000B00013O00263E000B003C000100010004393O003C000100202D000C0006000700202D0009000C001400202D000A00090015001271000B00023O00263E000B0036000100020004393O00360001001271000800023O0004393O004100010004393O0036000100263E00080025000100130004393O0025000100123A000B00114O0036000C00093O00202O000D0001001200122O000E00016O000B000E000100122O000B00176O000B0001000200122O000B00163O00044O005400010004393O002500010004393O0054000100263E00070022000100010004393O00220001001271000800014O006D000900093O001271000700023O0004393O0022000100064F00020011000100020004393O001100010004393O0078000100263E3O0002000100010004393O00020001001271000200013O00263E0002005E000100020004393O005E00010012713O00023O0004393O00020001000E1F0001005A000100020004393O005A00012O0032000300013O00201200030003001800202O00030003001900122O0005001A6O00030005000200062O0001006D000100030004393O006D00012O0032000300013O00205E00030003000700202O00030003001900122O0005001A6O0003000500024O000100033O00202D00030001001B00202D00030003000D00263E00030075000100180004393O007500012O0032000300033O00202E00030003001C2O0003000500014O0067000300050001001271000200023O0004393O005A00010004393O000200012O00733O00017O00043O0003073O0067657467656E7603023O00575303083O00746F6E756D62657203093O0057616C6B53702O656401093O001223000100016O00010001000200122O000200036O00038O00020002000200102O0001000200024O00015O00102O000100048O00017O00053O00028O0003073O0067657467656E7603023O004A5003083O00746F6E756D62657203093O004A756D70506F776572010E3O001271000100013O00263E00010001000100010004393O0001000100123A000200024O003F00020001000200122O000300046O00048O00030002000200102O0002000300034O00025O00102O000200053O00044O000D00010004393O000100012O00733O00017O00013O0003073O00476F644D6F646500033O00123A3O00014O00283O000100012O00733O00017O001C3O0003043O0067616D6503073O00506C6179657273030B3O004C6F63616C506C6179657203093O00436861726163746572028O00030E3O0046696E6446697273744368696C6403083O0048756D616E6F696403053O007061697273030E3O00476574412O63652O736F7269657303053O007461626C6503063O00696E7365727403053O00436C6F6E6503043O004E616D6503043O00622O6F7003063O00506172656E74026O00F03F027O004003073O00416E696D61746503083O0044697361626C65642O0103043O0077616974029A5O99B93F010003073O0044657374726F7903093O00776F726B7370616365030D3O0043752O72656E7443616D657261030D3O0043616D6572615375626A656374030C3O00412O64412O63652O736F7279007C3O0012743O00013O00206O000200206O000300206O000400064O007B00013O0004393O007B00010012713O00054O006D000100013O00263E3O0045000100050004393O0045000100123A000200013O00206100020002000200202O00020002000300202O00020002000400202O00020002000600122O000400076O00020004000200062O0002003600013O0004393O00360001001271000200054O006D000300033O00263E00020015000100050004393O00150001001271000300053O000E1F00050018000100030004393O0018000100123A000400083O00126B000500013O00202O00050005000200202O00050005000300202O00050005000400202O00050005000700202O0005000500094O000500066O00043O000600044O002A000100123A0009000A3O00207000090009000B4O000A5O00202O000B0008000C4O000B000C6O00093O000100064F00040024000100020004393O0024000100123A000400013O00205D00040004000200202O00040004000300202O00040004000400202O00040004000700302O0004000D000E00044O003600010004393O001800010004393O003600010004393O0015000100123A000200013O00202900020002000200202O00020002000300202O00020002000400202O00020002000E00202O00020002000C4O0002000200024O000100023O00122O000200013O00202O00020002000200202O00020002000300202O00020002000400102O0001000F000200302O0001000D000700124O00103O00263E3O0057000100110004393O0057000100123A000200013O00204000020002000200202O00020002000300202O00020002000400202O00020002001200302O00020013001400122O000200153O00122O000300166O00020002000100122O000200013O00202O00020002000200202O00020002000300202O00020002000400202O00020002001200302O00020013001700044O007B000100263E3O0008000100100004393O0008000100123A000200153O001264000300166O00020002000100122O000200013O00202O00020002000200202O00020002000300202O00020002000400202O00020002000E00202O0002000200184O00020002000100122O000200193O00202O00020002001A00122O000300013O00202O00030003000200202O00030003000300202O00030003000400202O00030003000700102O0002001B000300122O000200086O00038O00020002000400044O0077000100123A000700013O00203400070007000200202O00070007000300202O00070007000400202O00070007000700202O00070007001C4O000900066O00070009000100064F0002006F000100020004393O006F00010012713O00113O0004393O000800012O00733O00017O00213O00028O00026O00F03F030D3O00457874656E74734F2O6673657403073O00566563746F72332O033O006E6577026O00084003073O00456E61626C6564010003083O00496E7374616E636503093O00546578744C6162656C03083O005465787453697A65026O003440027O004003043O005465787403043O004E616D6503043O00466F6E7403043O00456E756D030A3O00536F7572636553616E7303163O004261636B67726F756E645472616E73706172656E637903043O0053697A6503053O005544696D3203093O0066726F6D5363616C6503073O0067657467656E7603063O00412O6C4573702O0103043O007761697403053O007063612O6C03063O00506172656E74030C3O0042692O6C626F617264477569030B3O00416C776179734F6E546F70030A3O0066726F6D4F2O66736574026O006940026O00494001513O001271000100014O006D000200033O00263E00010014000100020004393O0014000100123A000400043O00201400040004000500122O000500013O00122O000600063O00122O000700016O00040007000200102O00020003000400302O00020007000800122O000400093O00202O00040004000500122O0005000A6O000600026O0004000600024O000300043O00302O0003000B000C00122O0001000D3O000E1F000D0024000100010004393O0024000100202D00043O000F0010350003000E000400122O000400113O00202O00040004001000202O00040004001200102O00030010000400302O00030013000200122O000400153O00202O00040004001600122O000500023O00122O000600026O00040006000200102O00030014000400122O000100063O000E1F0006003D000100010004393O003D000100123A000400174O005B00040001000200202D00040004001800066A0004002C00013O0004393O002C0001003079000200070019001271000400013O00263E0004002D000100010004393O002D000100123A0005001A4O002800050001000100123A0005001B3O00062B00063O000100032O00033O00024O00038O00033O00034O00090005000200010004393O003900010004393O002D000100202D00053O001C00060D0005002C000100010004393O002C00010004393O0050000100263E00010002000100010004393O0002000100123A000400093O00207200040004000500122O0005001D6O00068O0004000600024O000200043O00202O00043O000F00102O0002000F000400302O0002001E001900122O000400153O00202O00040004001F00122O000500203O00122O000600216O00040006000200102O00020014000400122O000100023O00044O000200012O00733O00013O00013O00113O00028O0003073O0041646F726E2O6503093O0043686172616374657203043O0048656164030E3O0046696E6446697273744368696C6403053O004B6E69666503083O004261636B7061636B030A3O0054657874436F6C6F723303063O00436F6C6F72332O033O006E6577026O00F03F03073O00456E61626C656403073O0067657467656E7603093O004D75726465724573702O012O033O0047756E030A3O0053686572692O66457370006D3O0012713O00013O00263E3O0001000100010004393O000100012O003200016O0008000200013O00202O00020002000300202O00020002000400102O0001000200024O000100013O00202O00010001000300202O00010001000500122O000300066O00010003000200062O00010016000100010004393O001600012O0032000100013O00200E00010001000700202O00010001000500122O000300066O00010003000200062O0001003500013O0004393O00350001001271000100014O006D000200023O00263E00010018000100010004393O00180001001271000200013O00263E0002001B000100010004393O001B00012O0032000300023O001202000400093O00202O00040004000A00122O0005000B3O00122O000600013O00122O000700016O00040007000200102O0003000800044O00035O00202O00030003000C00062O0003006C000100010004393O006C000100123A0003000D4O005B00030001000200202D00030003000E00066A0003006C00013O0004393O006C00012O003200035O0030790003000C000F0004393O006C00010004393O001B00010004393O006C00010004393O001800010004393O006C00012O0032000100013O00201000010001000300202O00010001000500122O000300106O00010003000200062O00010043000100010004393O004300012O0032000100013O00200E00010001000700202O00010001000500122O000300106O00010003000200062O0001006200013O0004393O00620001001271000100014O006D000200023O00263E00010045000100010004393O00450001001271000200013O00263E00020048000100010004393O004800012O0032000300023O001202000400093O00202O00040004000A00122O000500013O00122O000600013O00122O0007000B6O00040007000200102O0003000800044O00035O00202O00030003000C00062O0003006C000100010004393O006C000100123A0003000D4O005B00030001000200202D00030003001100066A0003006C00013O0004393O006C00012O003200035O0030790003000C000F0004393O006C00010004393O004800010004393O006C00010004393O004500010004393O006C00012O0032000100023O001257000200093O00202O00020002000A00122O000300013O00122O0004000B3O00122O000500016O00020005000200102O00010008000200044O006C00010004393O000100012O00733O00017O00023O0003043O004E616D6503073O0044657374726F7901064O003800015O00202O00023O00014O00010001000200202O0001000100024O0001000200016O00017O000C3O00028O0003073O0067657467656E7603063O00412O6C45737003053O007061697273030B3O004765744368696C6472656E2O033O00497341030C3O0042692O6C626F61726447756903083O00746F737472696E6703043O004E616D6503073O00456E61626C65643O0100012B3O001271000100014O006D000200023O00263E00010002000100010004393O00020001001271000200013O00263E00020005000100010004393O0005000100123A000300024O001900030001000200102O000300033O00122O000300046O00045O00202O0004000400054O000400056O00033O000500044O0024000100202E000800070006001271000A00074O000F0008000A000200066A0008002400013O0004393O002400012O0032000800013O00125C000900083O00202O000A000700094O0009000200024O00080008000900062O0008002400013O0004393O0024000100123A000800024O005B00080001000200202D00080008000300066A0008002300013O0004393O002300010030790007000A000B0004393O002400010030790007000A000C00064F00030010000100020004393O001000010004393O002A00010004393O000500010004393O002A00010004393O000200012O00733O00017O00053O00028O0003073O0067657467656E7603093O004D757264657245737003043O007761697403053O007063612O6C01273O001271000100014O006D000200023O00263E00010002000100010004393O00020001001271000200013O00263E00020005000100010004393O0005000100123A000300024O005B00030001000200101B000300033O00123A000300024O005B00030001000200202D00030003000300066A0003002600013O0004393O00260001001271000300014O006D000400043O00263E00030011000100010004393O00110001001271000400013O00263E00040014000100010004393O0014000100123A000500044O002800050001000100123A000500053O00062B00063O000100022O00328O00323O00014O00090005000200010004393O000A00010004393O001400010004393O000A00010004393O001100010004393O000A00010004393O002600010004393O000500010004393O002600010004393O000200012O00733O00013O00013O000F3O0003053O007061697273030B3O004765744368696C6472656E2O033O00497341030C3O0042692O6C626F61726447756903083O00746F737472696E6703043O004E616D6503093O00436861726163746572030E3O0046696E6446697273744368696C6403053O004B6E69666503083O004261636B7061636B03073O0067657467656E7603093O004D757264657245737003073O00456E61626C65643O012O00333O0012453O00016O00015O00202O0001000100024O000100029O00000200044O0030000100202E000500040003001271000700044O000F00050007000200066A0005003000013O0004393O003000012O0032000500013O00125C000600053O00202O0007000400064O0006000200024O00050005000600062O0005003000013O0004393O003000012O0032000500013O001276000600053O00202O0007000400064O0006000200024O00050005000600202O00050005000700202O00050005000800122O000700096O00050007000200062O00050028000100010004393O002800012O0032000500013O001205000600053O00202O0007000400064O0006000200024O00050005000600202O00050005000A00202O00050005000800122O000700096O00050007000200062O0005003000013O0004393O0030000100123A0005000B4O005B00050001000200202D00050005000C00066A0005002F00013O0004393O002F00010030790004000D000E0004393O003000010030790004000D000F00064F3O0006000100020004393O000600012O00733O00017O00053O00028O0003073O0067657467656E76030A3O0053686572692O6645737003043O007761697403053O007063612O6C01273O001271000100014O006D000200023O00263E00010002000100010004393O00020001001271000200013O00263E00020005000100010004393O0005000100123A000300024O005B00030001000200101B000300033O00123A000300024O005B00030001000200202D00030003000300066A0003002600013O0004393O00260001001271000300014O006D000400043O00263E00030011000100010004393O00110001001271000400013O00263E00040014000100010004393O0014000100123A000500044O002800050001000100123A000500053O00062B00063O000100022O00328O00323O00014O00090005000200010004393O000A00010004393O001400010004393O000A00010004393O001100010004393O000A00010004393O002600010004393O000500010004393O002600010004393O000200012O00733O00013O00013O000F3O0003053O007061697273030B3O004765744368696C6472656E2O033O00497341030C3O0042692O6C626F61726447756903083O00746F737472696E6703043O004E616D6503093O00436861726163746572030E3O0046696E6446697273744368696C642O033O0047756E03083O004261636B7061636B03073O0067657467656E76030A3O0053686572692O6645737003073O00456E61626C65643O012O00333O0012453O00016O00015O00202O0001000100024O000100029O00000200044O0030000100202E000500040003001271000700044O000F00050007000200066A0005003000013O0004393O003000012O0032000500013O00125C000600053O00202O0007000400064O0006000200024O00050005000600062O0005003000013O0004393O003000012O0032000500013O001276000600053O00202O0007000400064O0006000200024O00050005000600202O00050005000700202O00050005000800122O000700096O00050007000200062O00050028000100010004393O002800012O0032000500013O001205000600053O00202O0007000400064O0006000200024O00050005000600202O00050005000A00202O00050005000800122O000700096O00050007000200062O0005003000013O0004393O0030000100123A0005000B4O005B00050001000200202D00050005000C00066A0005002F00013O0004393O002F00010030790004000D000E0004393O003000010030790004000D000F00064F3O0006000100020004393O000600012O00733O00017O00023O0003073O0067657467656E7603063O0047756E45535001043O00123A000100014O005B00010001000200101B000100024O00733O00017O00023O00030D3O0052656E6465725374652O70656403073O00436F2O6E65637400094O00327O00202D5O000100202E5O000200062B00023O000100032O00323O00014O00323O00024O00323O00034O00673O000200012O00733O00013O00013O00013O0003053O007063612O6C00073O00123A3O00013O00062B00013O000100032O00328O00323O00014O00323O00024O00093O000200012O00733O00013O00013O000E3O0003073O0067657467656E7603063O0047756E455350028O00027O004003073O00456E61626C656403073O0056697369626C65030E3O0046696E6446697273744368696C6403073O0047756E44726F7003073O0041646F726E2O65026O00F03F03043O0053697A6503073O00566563746F72332O033O006E6577029A5O99A93F00313O00123A3O00014O005B3O0001000200202D5O000200066A3O003000013O0004393O003000010012713O00034O006D000100013O00263E3O0014000100040004393O001400012O003200025O00127A000300016O00030001000200202O00030003000200102O0002000500034O000200013O00122O000300016O00030001000200202O00030003000200102O00020006000300044O0030000100263E3O001E000100030004393O001E00012O0032000200023O00202100020002000700122O000400086O0002000400024O000100026O00025O00102O00020009000100124O000A3O00263E3O00070001000A0004393O000700012O0032000200013O00101B00020009000100066A0001002E00013O0004393O002E00012O0032000200013O00205800030001000B00122O0004000C3O00202O00040004000D00122O0005000E3O00122O0006000E3O00122O0007000E6O0004000700024O00030003000400102O0002000B00030012713O00043O0004393O000700012O00733O00017O00073O00028O00026O00F03F030A3O006C617374434672616D6503063O00434672616D6503053O007063612O6C030E3O0046696E6446697273744368696C6403073O0047756E44726F70012D3O001271000100014O006D000200023O000E1F0002001F000100010004393O001F000100066A0002002C00013O0004393O002C000100123A000300033O00060D0003002C000100010004393O002C0001001271000300014O006D000400043O00263E0003000B000100010004393O000B0001001271000400013O00263E0004000E000100010004393O000E00012O003200055O00202D000500050004001242000500033O00123A000500053O00062B00063O000100042O00328O00033O00024O00323O00014O00323O00024O00090005000200010004393O002C00010004393O000E00010004393O002C00010004393O000B00010004393O002C000100263E00010002000100010004393O000200012O0032000300033O00060D00030025000100010004393O002500012O00733O00014O0032000300023O00203100030003000600122O000500076O0003000500024O000200033O00122O000100023O00044O000200012O00733O00013O00013O00073O00028O00026O00F03F030A3O006C617374434672616D6503063O00434672616D6503073O005374652O70656403043O0057616974030E3O00497344657363656E64616E744F6600213O0012713O00013O00263E3O0006000100020004393O000600012O002600015O001242000100033O0004393O0020000100263E3O0001000100010004393O00010001001271000100013O000E1F00010009000100010004393O000900012O003200026O0049000300013O00202O00030003000400102O0002000400034O000200023O00202O00020002000500202O0002000200064O00020002000100044O001500010004393O000900012O0032000200013O00202E0002000200072O0032000400034O000F00020004000200060D00020008000100010004393O000800012O003200015O00123A000200033O00101B0001000400020012713O00023O0004393O000100012O00733O00017O00", GetFEnv(), ...);