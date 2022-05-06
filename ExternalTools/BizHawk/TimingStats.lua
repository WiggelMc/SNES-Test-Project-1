--###################################################
--################################################### CONFIG

showMarkers = false;
showInstructionText = true;

markerSize = 8; --int value
drawScale = 3; --int value

--###################################################
--################################################### SETTINGS

function mt(size)
	showMarkers = true;
	showInstructionText = true;
	
	if (size ~= nil) then
		markerSize = size;
	end
end

function m(size)
	showMarkers = true;
	showInstructionText = false;
	
	if (size ~= nil) then
		markerSize = size;
	end
end

function n()
	showMarkers = false;
	showInstructionText = false;
end



--###################################################
--################################################### PREPARE

event.unregisterbyname("getRoutineEnds");
event.unregisterbyname("WAI_F");
event.unregisterbyname("RTI_F");
event.unregisterbyname("DRAW_F");

--###################################################
--################################################### INIT

maxX = 339;
maxY = 261;

frames = {
	last = {}, 
	this = {},
	next = {},
}

pos = {
	min = {
		x = 0,
		y = 0
	},
	max = {
		x = maxX,
		y = maxY
	}
}

regionColors = {
	NMI = 0xBBEC2526,
	RTI = 0xBB60C0DF,
	WAI = 0xBBD7C037
}

markerColors = {
	NMI = 0xAAFF0000,
	RTI = 0xAA3333EE,
	WAI = 0xAA11DD44
}

function shiftFrames() 
	frames.last = frames.this;
	frames.this = frames.next;
	frames.next = {};
end

function addToFrame(frame, type, x, y)
	table.insert(frame, {
		type = type,
		x = x,
		y = y
	})
end

function minusOne(inst)
	local x = inst.x - 1;
	local y = inst.y;
	if (x < 0) then
		x = maxX;
		y = y - 1;
	end
	return {
		type = inst.type,
		x = x,
		y = y
	}
end


insttable = {};

currentV = 0;
currentH = 0;

nmiLineV = 225;
nmiLineH = 0;

rtiPC = 0;
rtiRead = false;
waiPC = 0;
waiRead = false;

canvas = gui.createcanvas(maxX*drawScale,maxY*drawScale);
canvas.SetTitle("Timing Stats");

--################################################### GET PC

event.onmemoryexecuteany(
	function()
		local pc = emu.getregister("PC");
		local x = memory.readbyte(pc);
		table.insert(insttable,string.format("%x",x));
		if (x == 0x40) then
			rtiPC = pc;
			rtiRead = true;
		end
		if (x == 0xEA) then --// 0xEA is NOP // 0xCB is WAI //
			waiPC = pc;
			waiRead = true;
		end
	end,
	"getRoutineEnds"
);

while (not (waiRead and rtiRead)) do
	emu.frameadvance();
end

event.unregisterbyname("getRoutineEnds");

--################################################### ATTACH

event.onmemoryexecute(
	function()
		drawFrameIfNew();
		local x = emu.getregister("H");
		local y = emu.getregister("V");
		addToFrame(frames.this, "WAI", x, y);
		
		if (y < nmiLineV) then
			addToFrame(frames.this, "NMI", nmiLineH, nmiLineV);
		else
			addToFrame(frames.next, "NMI", nmiLineH, nmiLineV);
		end
		
	end,
	waiPC,
	"WAI_F"
)
event.onmemoryexecute(
	function()
		drawFrameIfNew();
		local x = emu.getregister("H");
		local y = emu.getregister("V");
		addToFrame(frames.this, "RTI", x, y);
	end,
	rtiPC,
	"RTI_F"
)
console.log("ATTACHED RTI to "..string.format("%x",rtiPC));
console.log("ATTACHED WAI to "..string.format("%x",waiPC));

--################################################### DRAW

event.onframeend(
	function()
		drawFrameIfNew();
	end,
	"DRAW_F"
)

function drawFrameIfNew()
	local h = emu.getregister("H");
	local v = emu.getregister("V");
	if (v > currentV or (v == currentV and h > currentH)) then
		currentH = h;
		currentV = v;
		return;
	end
	currentH = 0;
	currentV = 0;
	drawFrame();
end

function drawFrame()
	--frameCounter = frameCounter + 1;
	--if (frameCounter < updateFrequency) then
		--if (not enablePointShadow) then
			--return
		--end
		--drawMarker(waiLineH,waiLineV,0x2211DD44, "");
		--drawMarker(rtiLineH,rtiLineV,0x223333EE, "");
		--canvas.Refresh();
		--return
	--end
	--frameCounter = 0;
	drawReset();
	--console.log(dump(frames));
	
	if (#frames.last == 0) then
		shiftFrames();
		return;
	end
	
	local lastFinal = frames.last[#frames.last];
	
	if (#frames.this == 0) then
		--draw FULL Region
		drawRegion(pos.min, pos.max, lastFinal.type);
	else
		--draw Regions
		
		local thisFirst = frames.this[1];
		drawRegion(pos.min, minusOne(thisFirst), lastFinal.type);
		
		for i = 1, #frames.this - 1 do
			drawRegion(frames.this[i], minusOne(frames.this[i+1]), frames.this[i].type);
		end
		
		local thisFinal = frames.this[#frames.this];
		drawRegion(thisFinal, pos.max, thisFinal.type);
		
		--draw Markers
		
		if (showMarkers) then
			for i = 1, #frames.this do
				drawMarker(frames.this[i]);
			end
		end
		
		
		shiftFrames();
	end
	
	canvas.Refresh();
	-- last empty ? do not draw
	-- this empty ? do not shift >> draw lastFinal: (MIN : MAX)
	
	-- lastFinal: MIN . thisFirst
	-- for i to len-1 >> this i . this i+1 
	-- thisFinal . MAX
	
	--drawReset();
	--drawMarker(waiLineH,waiLineV,0xAA11DD44, ternary(showInstructionText,"WAI",""));
	--drawMarker(rtiLineH,rtiLineV,0xAA3333EE, ternary(showInstructionText,"RTI",""));
	--drawMarker(nmiLineH,nmiLineV,0xAAFF0000, ternary(showInstructionText,"NMI",""));
	
	--drawRegion(nmiLineH,nmiLineV,rtiLineH,rtiLineV,0xBBEC2526);
	--drawRegion(rtiLineH,rtiLineV,waiLineH,waiLineV,0xBB60C0DF);
	--drawRegion(waiLineH,waiLineV,nmiLineH,nmiLineV,0xBBD7C037);
	--canvas.Refresh();
end

function drawReset()
	canvas.Clear(0xFFFFFFFF);
	--canvas.DrawRectangle(0,0,maxX*drawScale,maxY*drawScale,0x00000000,0x00FFFFFF);
	canvas.DrawRectangle(22*drawScale,1*drawScale,255*drawScale,224*drawScale,0x00000000,0xFF888888);
end

function drawMarker(inst)
	canvas.DrawEllipse(inst.x*drawScale - markerSize, inst.y*drawScale - markerSize, markerSize*2, markerSize*2, markerColors[inst.type], markerColors[inst.type]);
	if (showInstructionText) then
		canvas.DrawText(inst.x*drawScale + markerSize + 2, inst.y*drawScale -8, inst.type, 0xFF000000, 0x00000000);
	end
end

function drawRegion(pos1,pos2,type)
	drawRegionX(pos1.x,pos1.y,pos2.x,pos2.y,regionColors[type]);
end

function drawRegionX(x1,y1,x2,y2,color)
	if (y1 == y2) then
		canvas.DrawRectangle(x1*drawScale,y1*drawScale,(x2-x1+1)*drawScale,1*drawScale,0x00000000,color);
	else
		drawRegionX(x1,y1,maxX,y1,color);
		
		if (y2 - y1 > 1) then
			canvas.DrawRectangle(0,(y1+1)*drawScale,maxX*drawScale,(y2-y1-1)*drawScale,0x00000000,color);
		end
		
		drawRegionX(0,y2,x2,y2,color);
	end
end


function ternary(cond, T, F)
    if cond then return T else return F end
end

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end
--PLANS


--run on any once to find position of RTI and WAI
--unregister
--event.unregisterbyname("getRoutineEnds")
--attach function onmemoryexecute to the 2 found addresses
--onframeEnd Draws graph on screen 