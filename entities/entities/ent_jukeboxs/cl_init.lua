// BASS module used with permission from AzuisLeet in a cooperation between Pulsar Effect and GMod Tower in order to spread the availability of the BASS module.


--require("bass")


include('shared.lua')

local zerovec = Vector(0,0,0)

function ENT:Initialize()
	self.CurSong = "";
	
	if !BASS then
		LocalPlayer():PrintMessage(HUD_PRINTTALK, "Please download the bass module from the Pulsar Effect website.");
	end
end

function ENT:StopStream ( )
	if self.OurStream then
		self.OurStream:stop();
	end
	
	self.CurSong = "";
	
	self.OurStream = nil;
	self.CurPaused = nil;
end

function ENT:StartStream ( Path )
	if !Path then return false; end
	
	if self.OurStream then
		self:StopStream();
	end

	self.CurPaused = nil;
	self.CurSong = Path;
	
	
	/*
	BASS.StreamFileURL("http://www.di.fm/mp3/trance.pls", 0, function ( b, e ) if !b then	Msg(e) return end b:set3dposition(Vector(0, 0, 0), Vector(0, 0, 0), Vector(0, 0, 0)) b:play() end);
	BASS.StreamFileURL("http://www.javabeats.fm/javabeats.m3u", 0, function ( b, e ) if !b then	Msg(e) return end b:set3dposition(Vector(0, 0, 0), Vector(0, 0, 0), Vector(0, 0, 0)) b:play() end);
	*/
	
	BASS.StreamFileURL(Path, 0, function(basschannel, error)
		if !basschannel then			
			if error == 40 || error == 2 then
				LocalPlayer():PrintMessage(HUD_PRINTTALK, "Error initializing music stream. Your client timed out.");
			elseif error == 41 then
				if !AlreadyToldDisabled then
					LocalPlayer():PrintMessage(HUD_PRINTTALK, "Error initializing music stream. The Jukebox has probably been temporarily disabled by administration.");
					AlreadyToldDisabled = true;
				end
			elseif error == 8 then
				LocalPlayer():PrintMessage(HUD_PRINTTALK, "Error initializing music stream. BASS module initialization failure.");
			else
				LocalPlayer():PrintMessage(HUD_PRINTTALK, "Error initializing music stream. Unknown error " .. tostring(error) .. ".");
			end
			
			return
		end

		self.OurStream = basschannel
		self.OurStream:set3dposition(self:GetPos(), zerovec, zerovec)

		self.OurStream:play()
	end)
end

function ENT:Think()
	if BASS then
		if self.CurSong != GAMEMODE.StreamPath then
			self:StartStream(GAMEMODE.StreamPath);
		end
				
		if !self:CanHear() and self.OurStream and !self.CurPaused then
			self.CurPaused = true;
			self.OurStream:pause();
		elseif self:CanHear() and self.OurStream and self.CurPaused then
			self.CurPaused = nil;
			self.OurStream:play();
		end
	end
	
	self:NextThink(CurTime());
	return true;
end
	
function ENT:Draw()
	self:DrawModel();
end

function ENT:CanHear ( )
	if LocalPlayer():GetPos():Distance(self:GetPos()) < 5000 then return true; end
	
	return false;
end

/* Following function used from AzuisLeet */

local function BassThink()
	local ply = LocalPlayer()
	local eyepos = ply:EyePos()
	eyepos.z = -eyepos.z
	local vel = ply:GetVelocity()
	local eyeangles = ply:GetAimVector():Angle()
	
	// threshold, 89 exact is backwards accord to BASS
	eyeangles.p = math.Clamp(eyeangles.p, -89, 88.9)
	local forward = eyeangles:Forward()
	local up = eyeangles:Up() * -1
	
	BASS.SetPosition(eyepos, vel * 0.005, forward, up)
end

if BASS then
	hook.Add("Think", "UpdateBassPosition", BassThink )
end

/* End azuisleet code*/




local PathToSite = "http://www.pulsareffect.com/jukebox/fetch_redirect.php?id=";

function RecieveNewSong ( UMsg )
	local SongID = UMsg:ReadShort();
	local Len = UMsg:ReadLong();
	local Artist = UMsg:ReadString();
	local Title = UMsg:ReadString();

	GAMEMODE.StreamPath = PathToSite .. SongID;
end
usermessage.Hook('jukebox_newsong', RecieveNewSong);

function GetJukeCommand ( )
	if !BASS then
		LocalPlayer():PrintMessage(HUD_PRINTTALK, "Please download the bass module from the Pulsar Effect website to use this feature.");
	else
		JukeboxMenu = vgui.Create('con_jukebox');
	end
end
usermessage.Hook('jukebox_open', GetJukeCommand);




// vgui code
local PANEL = {}

function SecondsFormatted ( Time )
	if Time < 0 then return "0:00"; end

	local Minutes = math.floor(Time / 60);
	local Seconds = Time - (Minutes * 60);
	
	if Seconds < 10 then Seconds = "0" .. Seconds; end
	
	return Minutes .. ":" .. Seconds;
end

TimeBetweenSongRequests = 60;

local function FetchJukeboxList ( Callback )
	JukeboxMusicList = {};
	
	for _, Line in pairs(string.Explode("\n", Callback)) do
		if string.len(Line) > 5 then
			local Info = string.Explode("\t", Line);
			
			local NewTable = {};
			NewTable.ID = Info[1];
			NewTable.Artist = Info[2];
			NewTable.Title = Info[3];
			NewTable.Length = tonumber(Info[4]);
			
			table.insert(JukeboxMusicList, NewTable);
		end
	end

	if JukeboxMenu then
		JukeboxMenu:SetupJukeboxList();
	end
end

function PANEL:Init ( )
	self.Menu_Jukebox_List = vgui.Create("DListView", self);
	self.Menu_Jukebox_List:SetMultiSelect(false);
	self.Menu_Jukebox_List_Artist = self.Menu_Jukebox_List:AddColumn("Artist");
	self.Menu_Jukebox_List_Title = self.Menu_Jukebox_List:AddColumn("Title");
	self.Menu_Jukebox_List_Time = self.Menu_Jukebox_List:AddColumn("Length");
	self.Menu_Jukebox_List_Time:SetMinWidth(50);
	self.Menu_Jukebox_List_Time:SetMaxWidth(50);
	
	self.Menu_Jukebox_SearchBox = vgui.Create('DTextEntry', self);
	self.Menu_Jukebox_RequestButton = vgui.Create('DButton', self);
	self.Menu_Jukebox_RequestButton:SetText("Request Song");
	
	function self.Menu_Jukebox_RequestButton:DoClick ( )
		local What = JukeboxMenu.Menu_Jukebox_List:GetSelectedLine();
		
		if What and What != 0 then
			if !LastRequest or LastRequest + TimeBetweenSongRequests <= CurTime() or LocalPlayer():GetLevel() <= 1 then
				LastRequest = CurTime();
				RunConsoleCommand('gmp_jrs', JukeboxMenu.JukeboxIdentifiers[What]);
			else
				LocalPlayer():PrintMessage(HUD_PRINTTALK, "You must wait another " .. math.Round(LastRequest + TimeBetweenSongRequests - CurTime()) .. " seconds before requesting another song.");
			end
		else
			LocalPlayer():PrintMessage(HUD_PRINTTALK, "You must select a song in order to request it.");
		end
	end

	if !JukeboxMusicList then
		http.Get('http://www.pulsareffect.com/jukebox/list.html', '', FetchJukeboxList);
	else
		self:SetupJukeboxList();
	end
	
	self.LastSearch = "";
	self:SetTitle("Jukebox")
	self:MakePopup()
	self:SetDraggable(false);
end

function PANEL:PerformLayout ( )
	self:SetSize(400, 500);
	self:SetPos(ScrW() * .5 - 200, ScrH() * .5 - 250);
		
	self.BaseClass.PerformLayout(self);
	
	self.Menu_Jukebox_List:StretchToParent(5, 30, 5, 30);
	local Available = self.Menu_Jukebox_List:GetWide() - 5;
	self.Menu_Jukebox_SearchBox:SetSize(Available * .6, 20);
	self.Menu_Jukebox_RequestButton:SetSize(Available * .4, 20);
	self.Menu_Jukebox_SearchBox:SetPos(5, self.Menu_Jukebox_SearchBox:GetParent():GetTall() - 25);
	self.Menu_Jukebox_RequestButton:SetPos(self.Menu_Jukebox_RequestButton:GetParent():GetWide() - self.Menu_Jukebox_RequestButton:GetWide() - 5, self.Menu_Jukebox_SearchBox:GetParent():GetTall() - 25);
end

function PANEL:Think ( )
	local OurVal = self.Menu_Jukebox_SearchBox:GetValue();
	if OurVal != self.LastSearch then
		self.LastSearch = OurVal;
		self:SetupJukeboxList(OurVal);
	end
end

function PANEL:SetupJukeboxList ( SearchString )
	local SearchString = SearchString or "";
	local SearchString = string.lower(string.gsub(SearchString, " ", ""));
	
	self.Menu_Jukebox_List:Clear()

	self.JukeboxIdentifiers = {};
	
	for k, v in pairs(JukeboxMusicList) do
		if string.find(string.lower(string.gsub(v.Artist, " ", "")), SearchString) or string.find(string.lower(string.gsub(v.Title, " ", "")), SearchString) then
			self.JukeboxIdentifiers[tonumber(self.Menu_Jukebox_List:AddLine(v.Artist, v.Title, SecondsFormatted(v.Length)):GetID())] = v.ID;
		end
	end
	
	self.Menu_Jukebox_List:SortByColumn(1);
end

vgui.Register("con_jukebox", PANEL, "DFrame")



local function diag ( )
	Msg('gm_bass.ddl exists: ' .. tostring(file.Exists("../lua/includes/modules/gm_bass.dll")) .. '\n');
	Msg('bass.ddl exists: ' .. tostring(file.Exists("../../bass.dll")) .. '\n');
	Msg('tags.ddl exists: ' .. tostring(file.Exists("../../tags.dll")) .. '\n');
end
concommand.Add('bass_diag', diag);

