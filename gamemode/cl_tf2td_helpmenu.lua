local sndButtonPress = "tf2ui/buttonclick.wav"
util.PrecacheSound( "sound/"..sndButtonPress )
local sndButtonRelease = "tf2ui/buttonclickrelease.wav"
util.PrecacheSound( "sound/"..sndButtonRelease )
local sndRollOver = "tf2ui/buttonrollover.wav"
util.PrecacheSound( "sound/"..sndRollOver )

include('cl_tf2td_info.lua');

TEAM_RED = 10;
TEAM_BLU = 11;

local texClasses = {}
	texClasses[ TEAM_RED ] = {}
	texClasses[ TEAM_BLU ] = {}
	
local classes = {
	"demo",
	"engi",
	"heavy",
	"medic",
	"pyro",
	"scout",
	"sniper",
	"soldier",
	"spy"
}

for _, class in pairs( classes ) do
	
	texClasses[ TEAM_RED ][ class ] = surface.GetTextureID( "HUD/class_"..class.."red" )
	texClasses[ TEAM_BLU ][ class ] = surface.GetTextureID( "HUD/class_"..class.."blue" )
	
end

local texPanelBlack = surface.GetTextureID( "HUD/score_panel_black_bg" )
local texPanelRed = surface.GetTextureID( "HUD/score_panel_red_bg" )
local texPanelBlu = surface.GetTextureID( "HUD/score_panel_blue_bg" )
local texSelectGlow = surface.GetTextureID( "gui/center_gradient" )
local HelpMenu

-- INITIALIZE
	
hook.Add( "Initialize", "HelpMenuCreate", function()
	
	HelpMenu = vgui.Create( "menu_help" )
	HelpMenu:SetVisible( false )
	
end )

-- TOGGLE

function GM.ToggleTF2TDHelp ( um )
	if( !(HelpMenu && HelpMenu:IsValid()) ) then return end
	
	if( HelpMenu:IsVisible() ) then
		
		HelpMenu:SetVisible( false )
		
	else
		
		HelpMenu:SetVisible( true )
		HelpMenu:MakePopup()
		
	end
	
end
usermessage.Hook("HelpMenu.toggle", GM.ToggleTF2TDHelp);

--[[----------------------------------------------
	
	
	MAIN MENU
	
	
-------------------------------------------------]]--

local function SplitTextLines ( Text, W, Font )
	local SplitText = string.Explode("\n", Text);
	local FinalText = {};
	
	if Font then
		surface.SetFont(Font);
	else
		surface.SetFont('Default');
	end

	local Comp = W - 30;
	local SComp = Comp - 50;
	local LComp = Comp - 40;
	for k, v in pairs(SplitText) do
		local TX, TY = surface.GetTextSize(v);
			
		if TX > Comp then
			local LastSplit = 1;
								
			for i = 1, string.len(v) do
				local LookingText = string.sub(v, LastSplit, i);
				local TEX, TEY = surface.GetTextSize(LookingText);
										
				if TEX >= Comp then
					LastSplit = i + 1;
					table.insert(FinalText, LookingText .. "-");
				elseif TEX >= SComp and string.sub(LookingText, -1) == " " and (!string.find(string.sub(v, i + 1, i + 6), " ") or TEX >= LComp) then
					LastSplit = i + 1;
					table.insert(FinalText, LookingText);
				elseif i == string.len(v) then
					table.insert(FinalText, LookingText);
				end
			end
		else
			table.insert(FinalText, v);
		end
	end
	
	return FinalText;
end

local PANEL = {}

function PANEL:Init()
	
	self:SetPos( 0, 0 )
	self:SetSize( ScrW(), ScrH() )
	self:SetMouseInputEnabled( true )
	self:SetKeyboardInputEnabled( false )
	
	self.Pages = {}
	self.Buttons = {}
	
	local x, y = 128, 128
	local wide, tall = ScrW() - x*2, ScrH() - y*2
	
	self.PageGeneral = vgui.Create( "menu_help_general", self )
	self.PageGeneral:SetPos( x, y )
	self.PageGeneral:SetSize( wide, tall )
	self.ButtonGeneral = vgui.Create( "menu_button", self )
	self.ButtonGeneral:SetTitle( "General" )
	self.ButtonGeneral:SetPage( self.PageGeneral )
	table.insert( self.Buttons, self.ButtonGeneral )
	table.insert( self.Pages, self.PageGeneral )
	
	self.PageClasses = vgui.Create( "menu_help_classes", self )
	self.PageClasses:SetVisible( false )
	self.PageClasses:SetPos( x, y )
	self.PageClasses:SetSize( wide, tall )
	self.ButtonTowers = vgui.Create( "menu_button", self )
	self.ButtonTowers:SetTitle( "Towers" )
	self.ButtonTowers:SetPage( self.PageClasses )
	self.ButtonTowers.page_type = "tower"
	self.ButtonEnemies = vgui.Create( "menu_button", self )
	self.ButtonEnemies:SetTitle( "Enemies" )
	self.ButtonEnemies:SetPage( self.PageClasses )
	self.ButtonEnemies.page_type = "enemy"
	table.insert( self.Buttons, self.ButtonTowers )
	table.insert( self.Buttons, self.ButtonEnemies )
	table.insert( self.Pages, self.PageClasses )
	self.selected = self.ButtonGeneral
	
	local buttonCount = #self.Buttons
	local buttonWidth = wide / buttonCount
	for i, btn in ipairs( self.Buttons ) do
		
		btn:SetSize( buttonWidth, ScrH() * 0.1 )
		btn:SetPos( x + i * buttonWidth - buttonWidth, y - btn:GetTall() )
		
	end
	
end

function PANEL:OnKeyCodePressed( keycode )
	
	if( keycode == KEY_ESCAPE || keycode == KEY_F3 ) then
		
		self:SetVisible( false )
		
	end
	
end

function PANEL:ChangePage( button )
	
	self.selected = button
	for _, page in pairs( self.Pages ) do
		
		page:SetVisible( false )
		
	end
	button.page:SetVisible( true )
	
	if( button.page.ButtonPanel && button.page_type ) then
		button.page.ButtonPanel.page_type = button.page_type
		button.page.ButtonPanel:ChangePage( button.page.ButtonPanel.selected )
	end
	
end

function PANEL:Paint()
	
	surface.SetTexture( texPanelBlack )
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawTexturedRect( 128, 128, self:GetWide() - 256, (self:GetTall() - 256) * 1.6 )
	
end

vgui.Register( "menu_help", PANEL, "Panel" )


--[[----------------------------------------------
	
	
	MENU BUTTON
	
	
-------------------------------------------------]]--

local PANEL = {}

AccessorFunc( PANEL, "s_Title", "Title", "No Title", FORCE_STRING )

function PANEL:Init()
	
	self:SetMouseInputEnabled( true )
	
end

function PANEL:SetPage( page )
	
	self.page = page
	
end

function PANEL:OnCursorEntered()
	
	self.hovered = true
	surface.PlaySound( sndRollOver )
	
end

function PANEL:OnCursorExited()
	
	self.hovered = false
	
end

function PANEL:OnMousePressed()
	
	surface.PlaySound( sndButtonPress )
	
end

function PANEL:OnMouseReleased()
	
	if( self:GetParent().selected != self ) then
		
		self:GetParent():ChangePage( self )
		surface.PlaySound( sndButtonRelease )
		
	end
	
end

function PANEL:Paint()
	
	local yoffset = 0
	
	if( self:GetParent().selected == self ) then
		surface.SetTexture( texPanelBlu )
		yoffset = 10
	else
		surface.SetTexture( texPanelRed )
		if(self.hovered) then
			yoffset = 5
		end
	end
	
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawTexturedRect( 0, yoffset, self:GetWide(), self:GetTall() )
	
	surface.SetFont( "TabLarge" )
	local w, h = surface.GetTextSize( self:GetTitle() )
	draw.SimpleText( self:GetTitle(), "TabLarge", self:GetWide()*0.5 - w*0.5, self:GetTall()*0.4 - h*0.5 + yoffset, color_white )
	
end

vgui.Register( "menu_button", PANEL, "Panel" )

--[[----------------------------------------------
	
	
	GENERAL HELP
	
	
-------------------------------------------------]]--

local PANEL = {}

function PANEL:Init()
	
	local x, y = 20, 30
	self.PageContainer = vgui.Create( "menu_help_page_container", self )
	self.PageContainer:SetPos( x, y )
	self.PageContainer:SetSize( self:GetWide() - 40, self:GetTall() - 30 )
	
end

function PANEL:PerformLayout()
end

function PANEL:Paint()
	surface.SetFont('Trebuchet18');
	local w, h = surface.GetTextSize( "Description:" )
	local sw, sh = w, h
	
	/* Runner description start */
	if !GAMEMODE.GeneralInformation then
		if GAMEMODE.Raw_GeneralInformation then
			GAMEMODE.GeneralInformation = SplitTextLines(GAMEMODE.Raw_GeneralInformation, self:GetWide(), 'Trebuchet18');
		else
			GAMEMODE.GeneralInformation = {"No information provided."};
		end
	end
	
	for k, v in pairs(GAMEMODE.GeneralInformation) do
		draw.SimpleText( v, "Trebuchet18", 25, 5 + sh * (k - 1), Color( 255, 255, 255, 255 ) )
	end
	/* Runner description end */
end

vgui.Register( "menu_help_general", PANEL, "Panel" )

--[[----------------------------------------------
	
	
	CLASSES HELP
	
	
-------------------------------------------------]]--

local PANEL = {}

function PANEL:Init()
	
	self.ButtonPanel = vgui.Create( "menu_class_buttons", self )
	
end

function PANEL:PerformLayout()
	
	local x, y = 20, 30
	self.ButtonPanel:SetPos( x, y )
	self.ButtonPanel:SetSize( self:GetWide() - 40, self:GetTall() * 0.2 )
	
	y = y + self.ButtonPanel:GetTall() + 10
	self.PageContainer = vgui.Create( "menu_help_page_container", self )
	self.PageContainer:SetPos( x, y )
	self.PageContainer:SetSize( self.ButtonPanel:GetWide(), self:GetTall() - y - 30 )
	
	self.ButtonPanel:SetupButtons()

end

function PANEL:Paint()
	
	if( self.ButtonPanel.page_type == "tower" ) then
		
		draw.SimpleText( "Select a class to get more info about that tower.", "Trebuchet18", 30, 10, Color( 230, 230, 128, 255 ) )
		
	elseif( self.ButtonPanel.page_type == "enemy" ) then
		
		draw.SimpleText( "Select a class to get more info about that enemy.", "Trebuchet18", 30, 10, Color( 230, 230, 128, 255 ) )
		
	end
	
	local x, y = self.ButtonPanel:GetPos()
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawLine( x, y + self.ButtonPanel:GetTall(), x + self.ButtonPanel:GetWide(), y + self.ButtonPanel:GetTall() )
	
end

vgui.Register( "menu_help_classes", PANEL, "Panel" )

--[[----------------------------------------------
	
	
	CLASS SELECTION
	
	
-------------------------------------------------]]--

local PANEL = {}

function PANEL:Init()
	
	self.page_type = "tower"
	
end

function PANEL:SetupButtons()
	
	if( self.Buttons ) then return end
	
	self.Buttons = {}
	self.towerPages = {}
	self.enemyPages = {}
	
	self.total = 0
	
	for index, class in pairs( classes ) do
		
		self.total = self.total + 1
		local btn = vgui.Create( "menu_class_button", self )
		btn.index = self.total
		btn.class = class
		btn.towerpage = vgui.Create( "menu_help_page_tower", self:GetParent().PageContainer )
		btn.towerpage:SetClass( class )
		btn.towerpage:SetVisible( false )
		btn.towerpage:SetEnabled( false )
		self.towerPages[ btn.index ] = btn.towerpage
		btn.enemypage = vgui.Create( "menu_help_page_enemy", self:GetParent().PageContainer )
		btn.enemypage:SetClass( class )
		btn.enemypage:SetVisible( false )
		btn.enemypage:SetEnabled( false )
		self.enemyPages[ btn.index ] = btn.enemypage
		table.insert( self.Buttons, btn )
		
	end
	
	if self.total == 0 then
		self:Remove()
		return
	end
	
	self.wide = math.floor( (self:GetWide() - (self.total-1)) / self.total )
	
end

function PANEL:OnCursorEntered()
	
	self.hovered = true
	
end

function PANEL:OnCursorExited()
	
	self.hovered = false
	self.hover = nil
	self.hovernum = nil
	
end

function PANEL:OnMousePressed()
	
	surface.PlaySound( sndButtonPress )
	
end

function PANEL:ChangePage( button )
	
	if( !button ) then return end
	
	for k, v in pairs( self[ "towerPages" ] ) do
		
		v:SetEnabled( false )
		v:SetVisible( false )
		
	end
	
	for k, v in pairs( self[ "enemyPages" ] ) do
		
		v:SetEnabled( false )
		v:SetVisible( false )
		
	end
	
	button[ self.page_type.."page" ]:SetVisible( true )
	self.selected = button
	
end

function PANEL:OnMouseReleased()
	
	if( self.selected != self.hover ) then
		
		self:ChangePage( self.hover )
		surface.PlaySound( sndButtonRelease )
		
	end
	
end

function PANEL:Think()
	
	if( self.hovered ) then
		local x, y = self:ScreenToLocal( gui.MousePos() )
		self:CalcButtonSlide( x )
	else
		for i, item in pairs( self.Buttons ) do
			if(self.selected != item) then
				item.idealsize = self.wide
				item:SetZPos( 10 )
			else
				item.idealsize = self:GetTall() * 1.25
				item:SetZPos( 100 )
			end
		end
	end
	
	self:PerformButtonSlide()
	
end

function PANEL:CalcButtonSlide( x )
	
	local width = self:GetWide()
	
	x = math.Clamp( x, 0, width )
	
	local itemnum = x/width*(self.total)
	local solidnum = math.floor( itemnum )
	local item = self.Buttons[ solidnum + 1 ]
	if !item then return end
	
	if(solidnum != self.hovernum) then
		
		surface.PlaySound( sndRollOver )
		
	end
	
	self.hover = item
	self.hovernum = solidnum
	
	item:SetZPos( 100 )
	item.idealsize = self:GetTall()
	if( self.selected == item ) then
		item.idealsize = item.idealsize * 1.25
	end
	
	if solidnum < self.total-1 then
		local prev = item
		for i=solidnum+1, self.total-1, 1 do
			prev = item
			item = self.Buttons[ i+1 ]
			item.idealsize = self.wide * 100 / math.min( (i-solidnum) * self:GetTall(), 150 )
			item:SetZPos( i )
			if( self.selected == item ) then
				item.idealsize = item.idealsize * 1.25
			end
		end
	end
	
	if solidnum > 0 and solidnum <= self.total-1 then
		local prev, item = item, item
		for i=solidnum, 1, -1 do
			prev = item
			item = self.Buttons[ i ]
			item.idealsize = self.wide * 100 / math.min( (solidnum-i+1) * self:GetTall(), 150 )
			item:SetZPos( i )
			if( self.selected == item ) then
				item.idealsize = item.idealsize * 1.25
			end
		end
	end
	
end

function PANEL:PerformButtonSlide()
	
	for _, item in pairs( self.Buttons ) do
		
		local size = item:GetSize()
		
		if item.idealsize then
			if size != item.idealsize then
				if math.abs(item.idealsize-size)<1 then
					size = item.idealsize
				elseif math.abs(item.idealsize-size)<=10 then
					size = math.Approach( size, item.idealsize, 1 )
				else
					size = Lerp( 50*FrameTime(), size, item.idealsize )
				end
			end
		end
		
		item:SetSize( size, size )
		item:SetPos( item.index * self.wide - self.wide*0.5 - item:GetWide() * 0.5, self:GetTall() - math.ceil(item:GetTall()) )
		
	end
	
end

function PANEL:Paint()
	
	surface.SetDrawColor( 0, 0, 0, 80 )
	surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
	
end

vgui.Register( "menu_class_buttons", PANEL, "Panel" )


--[[----------------------------------------------
	
	
	CLASS BUTTON
	
	
-------------------------------------------------]]--

local PANEL = {}

function PANEL:Init()
	
	self:SetMouseInputEnabled( false )
	
end

function PANEL:Paint()
	
	DisableClipping( true )
	
	if( self:GetParent().selected == self ) then
		
		surface.SetDrawColor( 255, 255, 255, 255 )
		
	else
		
		surface.SetDrawColor( 160, 160, 160, 255 )
		
	end
	
	if( self:GetParent().page_type == "tower" ) then
		
		surface.SetTexture( texClasses[ TEAM_BLU ][ self.class ] )
		
	else
		
		surface.SetTexture( texClasses[ TEAM_RED ][ self.class ] )
		
	end
	
	surface.DrawTexturedRect( 0, 0, self:GetWide(), self:GetTall() )
	
	DisableClipping( false )
	
end

vgui.Register( "menu_class_button", PANEL, "Panel" )


--[[----------------------------------------------
	
	
	PAGE CONTAINER
	
	
-------------------------------------------------]]--

local PANEL = {}

function PANEL:Init() end
function PANEL:PerformLayout() end

vgui.Register( "menu_help_page_container", PANEL, "Panel" )



--[[----------------------------------------------
	
	
	PAGES
	
	
-------------------------------------------------]]--



local PANEL = {}

function PANEL:Init()

end

function PANEL:PerformLayout()
	
	self:SetSize( self:GetParent():GetWide(), self:GetParent():GetTall() )
	
end

--[[----------------------------------------------
	
	TOWER PAGE
	
-------------------------------------------------]]--

function PANEL:SetClass( class )
	
	self.classname = class
	--TODO: set all the variables youll need for the paint function, like description, damage, delay, range
	
end

function PANEL:Paint()
	
	draw.SimpleText( "Tower | ", "HUDNumber5", 30, 10, Color( 255, 255, 180, 255 ) )
	surface.SetFont( "HUDNumber5" )
	local w, h = surface.GetTextSize( "Tower | " )
	local lastw, lasth = w, h
	
	surface.SetFont('Trebuchet18');
	local w, h = surface.GetTextSize( "Description:" )
	local sw, sh = w, h
	
	surface.SetFont( "HUDNumber3" )
	local w, h = surface.GetTextSize( self.classname )
	draw.SimpleText( self.classname, "HUDNumber3", 30+lastw, 10 + h - lasth, Color( 255, 255, 255, 255 ) )
	
	draw.SimpleText( "Description:", "Trebuchet18", 25, 20 + lasth, Color( 255, 255, 255, 255 ) )
	
	/* Tower description start */
	if !GAMEMODE.TowerDescriptions[self.classname] then
		if GAMEMODE.Raw_TowerDescriptions[self.classname] then
			GAMEMODE.TowerDescriptions[self.classname] = SplitTextLines(GAMEMODE.Raw_TowerDescriptions[self.classname], self:GetWide() * .5, 'Trebuchet18');
		else
			GAMEMODE.TowerDescriptions[self.classname] = {"No information provided."};
		end
	end
	
	for k, v in pairs(GAMEMODE.TowerDescriptions[self.classname]) do
		draw.SimpleText( v, "Trebuchet18", 25, 20 + lasth + sh * (k + 1), Color( 255, 255, 255, 255 ) )
	end
	/* Tower description end */
	
	surface.SetDrawColor( 0, 0, 0, 160 )
	surface.DrawRect( self:GetWide() * 0.5 - 3, 20 + lasth, 6, self:GetTall() - 20 - h )
	
	draw.SimpleText( "Stats:", "Trebuchet18", self:GetWide() * 0.5 + 20, 20 + lasth, Color( 255, 255, 255, 255 ) )
	
	/* Tower stats start */
	if !GAMEMODE.TowerStats[self.classname] then
		if GAMEMODE.Raw_TowerStats[self.classname] then
			GAMEMODE.TowerStats[self.classname] = SplitTextLines(GAMEMODE.Raw_TowerStats[self.classname], self:GetWide() * .5, 'Trebuchet18');
		else
			GAMEMODE.TowerStats[self.classname] = {"No information provided."};
		end
	end
	
	for k, v in pairs(GAMEMODE.TowerStats[self.classname]) do
		if k <= 6 then
			local WPlace = self:GetWide() * 0.5 + 20;
			if math.ceil(k / 2) == math.floor(k / 2) then WPlace = self:GetWide() * 0.7 + 20 end
		
			draw.SimpleText( v, "Trebuchet18", WPlace, 20 + lasth + sh * (math.ceil(k / 2) + 1), Color( 255, 255, 255, 255 ) )
		else
			draw.SimpleText( v, "Trebuchet18", self:GetWide() * 0.5 + 20, 20 + lasth + sh * (k - 2), Color( 255, 255, 255, 255 ) )
		end
	end
	/* Tower stats end */
	
end

vgui.Register( "menu_help_page_tower", PANEL, "Panel" )

--[[----------------------------------------------
	
	ENEMY PAGE
	
-------------------------------------------------]]--

local PANEL = table.Copy( PANEL )

function PANEL:SetClass( class )
	
	self.classname = class
	--TODO: set all the variables youll need for the paint function, like description, damage, delay, range
	
end

function PANEL:Paint()
	
	draw.SimpleText( "Runner | ", "HUDNumber5", 30, 10, Color( 255, 255, 180, 255 ) )
	surface.SetFont( "HUDNumber5" )
	local w, h = surface.GetTextSize( "Runner | " )
	local lastw, lasth = w, h
	
	surface.SetFont('Trebuchet18');
	local w, h = surface.GetTextSize( "Description:" )
	local sw, sh = w, h
	
	surface.SetFont( "HUDNumber3" )
	local w, h = surface.GetTextSize( self.classname )
	draw.SimpleText( self.classname, "HUDNumber3", 30+lastw, 10 + h - lasth, Color( 255, 255, 255, 255 ) )
	
	draw.SimpleText( "Description:", "Trebuchet18", 25, 20 + lasth, Color( 255, 255, 255, 255 ) )
	
	/* Runner description start */
	if !GAMEMODE.RunnerDescriptions[self.classname] then
		if GAMEMODE.Raw_RunnerDescriptions[self.classname] then
			GAMEMODE.RunnerDescriptions[self.classname] = SplitTextLines(GAMEMODE.Raw_RunnerDescriptions[self.classname], self:GetWide() * .5, 'Trebuchet18');
		else
			GAMEMODE.RunnerDescriptions[self.classname] = {"No information provided."};
		end
	end
	
	for k, v in pairs(GAMEMODE.RunnerDescriptions[self.classname]) do
		draw.SimpleText( v, "Trebuchet18", 25, 20 + lasth + sh * (k + 1), Color( 255, 255, 255, 255 ) )
	end
	/* Runner description end */
	
	surface.SetDrawColor( 0, 0, 0, 160 )
	surface.DrawRect( self:GetWide() * 0.5 - 3, 20 + lasth, 6, self:GetTall() - 20 - h )
	
	draw.SimpleText( "Stats:", "Trebuchet18", self:GetWide() * 0.5 + 20, 20 + lasth, Color( 255, 255, 255, 255 ) )
	
	/* Runner stats start */
	if !GAMEMODE.RunnerStats[self.classname] then
		if GAMEMODE.Raw_RunnerStats[self.classname] then
			GAMEMODE.RunnerStats[self.classname] = SplitTextLines(GAMEMODE.Raw_RunnerStats[self.classname], self:GetWide() * .5, 'Trebuchet18');
		else
			GAMEMODE.RunnerStats[self.classname] = {"No information provided."};
		end
	end
	
	for k, v in pairs(GAMEMODE.RunnerStats[self.classname]) do
		if k <= 6 then
			local WPlace = self:GetWide() * 0.5 + 20;
			if math.ceil(k / 2) == math.floor(k / 2) then WPlace = self:GetWide() * 0.7 + 20 end
		
			draw.SimpleText( v, "Trebuchet18", WPlace, 20 + lasth + sh * (math.ceil(k / 2) + 1), Color( 255, 255, 255, 255 ) )
		else
			draw.SimpleText( v, "Trebuchet18", self:GetWide() * 0.5 + 20, 20 + lasth + sh * (k - 2), Color( 255, 255, 255, 255 ) )
		end
	end
	/* Runner stats end */
	
end

vgui.Register( "menu_help_page_enemy", PANEL, "Panel" )



GM.RunnerDescriptions = {};
GM.RunnerStats = {};
GM.TowerDescriptions = {};
GM.TowerStats = {};

GM.Raw_RunnerDescriptions = {};
GM.Raw_RunnerStats = {};
GM.Raw_TowerDescriptions = {};
GM.Raw_TowerStats = {};

local FastestRunner, SlowestRunner, HealthiestRunner, HealthlessRunner = 0, 100000, 0, 100000;
for k, v in pairs(GM.RunnerConfig) do
	if v.Health > HealthiestRunner then
		HealthiestRunner = v.Health;
	end
	
	if v.Health < HealthlessRunner then
		HealthlessRunner = v.Health;
	end
	
	if v.Speed > FastestRunner then
		FastestRunner = v.Speed;
	end
	
	if v.Speed < SlowestRunner then
		SlowestRunner = v.Speed;
	end
end

local function BuildRunnerStatsRaw ( Class, Table, ExtraThreat, ExtraText )
	local HealthRating = math.ceil(((Table.Health - HealthlessRunner) / (HealthiestRunner - HealthlessRunner)) * 10);
	local SpeedRating = math.ceil(((Table.Speed - SlowestRunner) / (FastestRunner - SlowestRunner)) * 10);
	local ThreatRating = math.ceil((HealthRating + SpeedRating) / 2);
	local ExtraInfo = ExtraText or "No further information available.";
	
	GM.Raw_RunnerStats[Class] = 									"Health Rating:\n" .. math.Clamp(HealthRating, 1, 10) .. "/10\n";
	GM.Raw_RunnerStats[Class] = GM.Raw_RunnerStats[Class] .. 		"Speed Rating:\n" .. math.Clamp(SpeedRating, 1, 10) .. "/10\n";
	GM.Raw_RunnerStats[Class] = GM.Raw_RunnerStats[Class] .. 		"Threat Rating:\n" .. math.Clamp(ThreatRating + ExtraThreat, 1, 10) .. "/10\n\n";
	GM.Raw_RunnerStats[Class] = GM.Raw_RunnerStats[Class] ..		"Extra Information: " .. ExtraInfo;
end

// Runner stats
BuildRunnerStatsRaw('engi', GM.RunnerConfig.Engineer, 0);
BuildRunnerStatsRaw('demo', GM.RunnerConfig.Demoman, 0);
BuildRunnerStatsRaw('soldier', GM.RunnerConfig.Soldier, 0);
BuildRunnerStatsRaw('heavy', GM.RunnerConfig.Heavy, 2);
BuildRunnerStatsRaw('medic', GM.RunnerConfig.Medic, 4, "Immune to disease towers and heals nearby units.");
BuildRunnerStatsRaw('pyro', GM.RunnerConfig.Pyro, 2, "Immune to flame towers.");
BuildRunnerStatsRaw('scout', GM.RunnerConfig.Scout, 0);
BuildRunnerStatsRaw('sniper', GM.RunnerConfig.Sniper, 3, "Slows attacking towers with Jarate.");
BuildRunnerStatsRaw('spy', GM.RunnerConfig.Spy, 4, "Requires a sniper tower to uncloak.");

// Runer descriptions
GM.Raw_RunnerDescriptions['engi'] = "The third runner you will encounter in your defense of the point. He is equipped with only a small shotgun and is capable of running at faster speeds than experienced with either the demoman or soldier, as well as having slightly more hitpoints than the demoman. This guy can run you down if you aren't prepared.";
GM.Raw_RunnerDescriptions['soldier'] = "The brute force of the waves. This is the most common runner, as well as the first. It is a balance between all stats, and, in large numbers, can prove devistating to your defense. Splash towers are recommended to take out large clusters of them.";
GM.Raw_RunnerDescriptions['demo'] = "Faster and weaker than their soldier counterparts, these runners are the second you'll encounter. They do not sit in one place for long, as you'll probably need some longer ranged towers to deal with them effectively.";
GM.Raw_RunnerDescriptions['heavy'] = "Both the slowest and strongest of the runners. You'll have to toss everything you got at this big guy, or risk leaking him. He can, however, prove devistating if all your towers concentrate on him, leaving the rest of the runners to leak through your defense.";
GM.Raw_RunnerDescriptions['medic'] = "The last runner you will encounter. He is not only immune to disease, but also heals nearby runners. If he is not taken out quickly, you will have a hard time killing him.";
GM.Raw_RunnerDescriptions['pyro'] = "Although he lacks a great deal of health, he can still be a formidable opponent. He is immune to flame towers, so you'll need brute force to knock him down.";
GM.Raw_RunnerDescriptions['scout'] = "The fastest of the runners, as well as one of the weakest. He can run through any short-distance based defense with ease, although sniper towers usually knock him down easily enough.";
GM.Raw_RunnerDescriptions['sniper'] = "Encountered late in the game, this runner is unique in it's ability to affect your towers directly. He will occasionally toss Jarate up at your towers as he is targeted, causing the towers to slow their attacking.";
GM.Raw_RunnerDescriptions['spy'] = "Spies enter the wave cloaked, and will remain so unless they encounter a sniper tower. Sniper towers will throw Jarate down at the spies, removing their cloaks and allowing all towers to target them. Once revealed, spies prove to be rather weak and easy to dispatch.";

// Tower stats
GM.Raw_TowerStats['soldier'] = "Cost:\n" .. GM.Damages.Soldier.Price .. " Resources\nStarting Range:\n" .. GM.Damages.Soldier.Range .. " Units\nStarting Delay:\n" .. GM.Damages.Soldier.Delay_Level1 .. " Seconds\n\nUpgrade Benefits: Increased damage, attack speed, and splash radius.";
GM.Raw_TowerStats['heavy'] = "Cost:\n" .. GM.Damages.Heavy.Price .. " Resources\nStarting Range:\n" .. GM.Damages.Heavy.Range .. " Units\nStarting Delay:\n" .. GM.Damages.Heavy.Delay .. " Seconds\n\nUpgrade Benefits: Increased damage.";
GM.Raw_TowerStats['scout'] = "Cost:\n" .. GM.Damages.Scout.Price .. " Resources\nStarting Range:\n" .. GM.Damages.Scout.Range .. " Units\nStarting Delay:\n" .. GM.Damages.Scout.Delay_Level1 .. " Seconds\n\nUpgrade Benefits: Increased damage and attack speed.";
GM.Raw_TowerStats['demo'] = "Cost:\n" .. GM.Damages.Demoman.Price .. " Resources\nStarting Range:\n" .. GM.Damages.Demoman.Range_Level1 .. " Units\nStarting Delay:\n" .. GM.Damages.Demoman.Delay_Level1 .. " Seconds\n\nUpgrade Benefits: Increased damage, range, attack speed, and splash radius.";
GM.Raw_TowerStats['sniper'] = "Cost:\n" .. GM.Damages.Sniper.Price .. " Resources\nStarting Range:\n" .. GM.Damages.Sniper.Range .. " Units\nStarting Delay:\n" .. GM.Damages.Sniper.Delay_Level1 .. " Seconds\n\nUpgrade Benefits: Increased damage and attack speed.";
GM.Raw_TowerStats['medic'] = "Cost:\n" .. GM.Damages.Medic.Price .. " Resources\nStarting Range:\n" .. GM.Damages.Medic.Range .. " Units\nStarting Delay:\n" .. GM.Damages.Medic.Delay .. " Seconds\n\nUpgrade Benefits: Increased base damage, disease damage, and disease time.";
GM.Raw_TowerStats['pyro'] = "Cost:\n" .. GM.Damages.Pyro.Price .. " Resources\nStarting Range:\n" .. GM.Damages.Pyro.Range .. " Units\nStarting Delay:\n" .. GM.Damages.Pyro.Delay .. " Seconds\n\nUpgrade Benefits: Increased base damage and ignition time.";
GM.Raw_TowerStats['spy'] = "Cost:\n" .. GM.Damages.Spy.Price .. " Resources\nStarting Range:\n" .. GM.Damages.Spy.Range .. " Units\nStarting Delay:\n" .. GM.Damages.Spy.Delay_Level1 .. " Seconds\n\nUpgrade Benefits: Increased damage and attack speed.";

// Tower descriptions
GM.Raw_TowerDescriptions['engi'] = "As engineers are the only class capable of doing anything productive, they have been pushed into service instructing the other classes on where to go, what to do, and so forth. You are one of these engineers, and as such you are to command the rest of your company's soldiers to victory.";
GM.Raw_TowerDescriptions['soldier'] = "The backbone of any team. This guy costs only 100 resource and is quite powerful. What makes him effective are his rockets which are capable of hitting multiple runners at once ( hence the name splash tower ) so be sure to have this guy on your team or you will lose out!";
GM.Raw_TowerDescriptions['heavy'] = "A strong, fast hitting, spray machine! Using this guy will not hinder your chances of winning as he is a vital asset to the team. However, he is quite expensive to buy at 170 resource so you better choose where to place him wisely!";
GM.Raw_TowerDescriptions['scout'] = "Like the heavy, strong and quite fast. Use this guy effectively as he can pick off those few runners who make it through your first line of defence. Having him on your team is essential as this powerhouse really can alter the course of the game!";
GM.Raw_TowerDescriptions['demo'] = "Similar to the soldier in pretty much everyway, strong, hits multiple targets and pretty cheap ( 130 resources ). However, what makes him unique is his grenades. These grenades will either explode over a period of time or if the grenade hits a runner. This support class is essential as it can hit those few runners who seem to receive less damage than the rest.";
GM.Raw_TowerDescriptions['sniper'] = "Sniping is a good job, especially when this guy will, without fail, always hit your target and do a considerable amount of damage to the poor sap as well! Unfortunatly, he attacks slowly and is very expensive but this shouldn't stop you from using him as he can pick off those few runners who escape your clutches. He also spots spy runners, who are cloaked and not noticed by other towers, and uncloaks them with his Jarate!";
GM.Raw_TowerDescriptions['medic'] = "Ironically, he damages rather than heals, and he hits hard. However rather than giving the runner a powerful shot at first glance, he leaves them something to remember him by, by diseasing the runners doing tremendous amounts of damage over a period of time. He is costly, however, but he is worth having in any match.";
GM.Raw_TowerDescriptions['pyro'] = "Like the medic, he leaves the runners something to remember him by, by burning them alive for a period of time. He is much cheaper than the medic, but also deals less damage. Combining the pyro with the medic should be considered in any match as these two really do some damage together.";
GM.Raw_TowerDescriptions['spy'] = "This class may seem terrible at first and not really a credit to the team, but you will be badly mistaken. If the spy manages to see the runners' backs, he does critical damage to them. Having this guy on your team is definatly essential as he can really change the balance of the match.";

// General
GM.Raw_GeneralInformation = "Introduction:\n     Welcome to Team Fortress 2 Tower Defence. This gamemode combines the cartoon like elements of the popular game Team Fortress 2 with another popular internet classic, tower defence. This simple guide will help you get to grips with Team Fortress 2 Tower Defence and what the game's objectives are and so on.\n\nObjective:\n     Two teams, one capture point, and one objective. Stop runners from getting to the capture point! You must use your arsenal of towers which are represented by the various classes of TF2 to stop the runners ( TF2 characters who run through a trench-like area). Each match can have a max of four players per team and the most you can have get to the capture point is ten. If you let ten get there, you lose!\n\nHow to Play:\n     You should notice that the hud looks alot like the TF2 hud. On your right is the amount of resources you have - these are used to place towers. The more resources the better. Each wave lasts for thirty seconds and you earn a certain amount of resources depending on how many runners you and your team killed. If you press Q, you can change to your wrench. By left clicking on a tower you have created, you can upgrade your tower for the same cost as the tower's original cost. For example: it costs 100 resource to upgrade the Soldier tower because it originally cost 100 to build the tower. If you decide that the placement of a certain tower is not to your liking, right clicking on a tower you created with your wrench to destroy it and regain 75 percent of the resources spent on it. There are 150 waves in total, but as the waves progress, more and more runners come and it gets harder and harder as the runners receive more health and different classes.\n\nBasic Strategy:\n     Obviously, you will want to place your towers on the edges of the trench, so they can shoot at the runners. For the best results, you will want to place your pyro and medic at the start of the trench so they can do damage over time. They will soften up the runners so the rest of your defence will have a shot at them. Also, you will want to clump your demomen together as having plenty of grenades in one part of the trench can only mean mass destruction. However, you do not want to make one class of tower your only tower as this will not work due to the fact that each runner requires a different set of skills to defeat. Use a variety of towers and keep it mixed to give the best results. Also, be sure to not place too many level 1 towers down. Make sure you upgrade each tower to level three to get the best out of them. A good strategy is to place two soldiers, a heavy, three demomen and four scouts at one point and upgrade them all to level three to ensure maximum damage to all runners. By wave thirty, you will want to consider buying a sniper tower as the spy runners are only five waves away.\n\n\nPress F3 to close this help menu.";


