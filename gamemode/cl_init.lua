// Include all required files
include('sh_init.lua');
include('cl_sounds.lua');
include('cl_hooks.lua');
include('cl_networking.lua');
include('cl_notifications.lua');
include('cl_td_network.lua');
include('cl_chat.lua');
include('cl_scoreboards.lua');

for k, v in pairs(file.Find('gmparty/gamemode/vgui/*.lua','LUA')) do
	include('vgui/' .. v);
end

// Setup fonts
surface.CreateFont('GMP', {size=ScreenScale(14), weight=700, antialias=true, font="Super Mario Bros."});
surface.CreateFont('GMP_Large', {size=ScreenScale(25), weight=700, antialias=true, font="Super Mario Bros."});
surface.CreateFont('GMP_Large_2', {size=ScreenScale(75 * .5), weight=400, antialias=true, font="Chlorinap"});
surface.CreateFont('ScoreboardHead', {size=ScreenScale(24), weight=500, antialias=true, font="coolvetica"});
surface.CreateFont('NewsHeader', {size=36, weight=500, antialias=true, font="coolvetica"});
surface.CreateFont('NewsFont', {size=36, weight=500, antialias=true, font="coolvetica"});
surface.CreateFont('ScoreboardSub', {size=ScreenScale(12), weight=500, antialias=true, font="coolvetica"});
surface.CreateFont('ScoreboardText', {size=ScreenScale(8), weight=1000, antialias=true, font="Tahoma"});
surface.CreateFont("ScoreboardSub", { font = "coolvetica", size = 22, weight = 200 } )
surface.CreateFont("SprayFont", {font = "Trebuchet19", size = 24, weight = 700})

// Variable Initialation
GM.GamePlaying = true;
GM.NextGameStart = 0;
GM.WaitingForPlayers = false;

function GM:HUDPaintBackground ( )
	local ply = LocalPlayer()
	local mpos = ply:GetPos()
	for k, v in pairs(player.GetAll()) do
		if v and IsValid(v) and v:Alive() then
			
			local TraceDat = {};
			local tpos = v:GetPos()
			TraceDat.start = tpos + Vector(0, 0, 64);
			TraceDat.endpos = mpos + Vector(0, 0, 64);
			TraceDat.filter = {v, ply};
			
			if ply:InVehicle() then table.insert(TraceDat.filter, ply:GetVehicle()); end
			local TraceDat = {};
			local tpos = v:GetPos()
			TraceDat.start = tpos + Vector(0, 0, 64);
			TraceDat.endpos = mpos + Vector(0, 0, 64);
			TraceDat.filter = {v, ply};
			
			if v:InVehicle() then table.insert(TraceDat.filter, v:GetVehicle()); end
			if ply:InVehicle() then table.insert(TraceDat.filter, ply:GetVehicle()); end
			
			local Trace = util.TraceLine(TraceDat);
			
			local pos = (v:GetPos() + Vector(0, 0, 90)):ToScreen()
			local dist = tpos:Distance(mpos)
			--local steam = (v:Team()>4 and v:Team() == ply:Team())
			if (!Trace.Hit and dist < 512) then
				local alpha = 255
				if dist > 384 then
					alpha = (512-dist)*2
				end
				local col = team.GetColor(v:Team())
				if v:Team()<4 then col = Color(255,255,255) end
				col.a = alpha
				draw.SimpleText(v:GetName(), "ScoreboardSub", pos.x, pos.y, col, 1, 1);
			end
		end
	end
end

SPRAY_LIST   = {}

hook.Add("HUDPaint", "SPRAY_LIST", function()
	local tr = util.TraceLine(util.GetPlayerTrace(LocalPlayer()))
	for k,v in pairs(SPRAY_LIST) do
		--if LocalPlayer():GetDTInt(10) > v.tc then return end
		if v.vec:Distance(tr.HitPos) < 80 and LocalPlayer():GetPos():Distance(v.vec) < 430 then
			local pos = v.vec:ToScreen()
			local alpha = 255-((LocalPlayer():GetPos():Distance(v.vec)/255)*430)+100
			draw.SimpleText(v.name.."'s Spray", "SprayFont", pos.x, pos.y, Color(255,255,255,alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText("("..v.steam..")", "SprayFont", pos.x, pos.y+25, Color(255,255,255,alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
end)

usermessage.Hook("AddSpray", function(um)
	local PlayerEnt = um:ReadEntity()
	local SVector = um:ReadVector()
	table.foreach(SPRAY_LIST, function(k,v)
		if v.name==PlayerEnt:Nick() then
			table.remove(SPRAY_LIST, k)
		end
	end)
	table.insert(SPRAY_LIST, {name=PlayerEnt:Nick(), steam=PlayerEnt:SteamID(), vec=SVector, tc=math.ceil(SysTime())})
end)
