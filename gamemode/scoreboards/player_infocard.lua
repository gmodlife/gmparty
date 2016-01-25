///////////////////////////////
// © 2009-2010 Pulsar Effect //
//    All rights reserved    //
///////////////////////////////
// This material may not be  //
//   reproduced, displayed,  //
//  modified or distributed  //
// without the express prior //
// written permission of the //
//   the copyright holder.   //
///////////////////////////////
// This content was derived  //
// from original garry's mod //
//         content.          //
///////////////////////////////

 


local PANEL = {}

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:Init()

	self.InfoLabels = {}
	self.InfoLabels[ 1 ] = {}
	self.InfoLabels[ 2 ] = {}
	
	//self.btnKick = vgui.Create( "PlayerKickButton", self )
	//self.btnBan = vgui.Create( "PlayerBanButton", self )
	//self.btnPBan = vgui.Create( "PlayerPermBanButton", self )
	//self.btnSlay = vgui.Create( "PlayerSlayButton", self )
	
	//self.btnBlacklistFromSerious 	= vgui.Create( "PlayerBlacklistFromSeriousButton", self )
	
	//self.scrollerTime = vgui.Create( "DNumSlider", self )
	//self.scrollerTime:SetDecimals(0);
	//self.scrollerTime:SetValue(24);
	//self.scrollerTime:SetMin(1);
	//self.scrollerTime:SetMax(720);
	//self.scrollerTime:SetText("Punishment Time ( Hours )");
end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:SetInfo( column, k, v )

	if ( !v || v == "" ) then v = "N/A" end

	if ( !self.InfoLabels[ column ][ k ] ) then
	
		self.InfoLabels[ column ][ k ] = {}
		self.InfoLabels[ column ][ k ].Key 	= vgui.Create( "Label", self )
		self.InfoLabels[ column ][ k ].Value 	= vgui.Create( "Label", self )
		self.InfoLabels[ column ][ k ].Key:SetText( k )
		self:InvalidateLayout()
	
	end
	
	self.InfoLabels[ column ][ k ].Value:SetText( v )
	return true

end


/*---------------------------------------------------------
   Name: UpdatePlayerData
---------------------------------------------------------*/
function PANEL:SetPlayer( ply )

	self.Player = ply
	self:UpdatePlayerData()

end

/*---------------------------------------------------------
   Name: UpdatePlayerData
---------------------------------------------------------*/
local titles = {};
titles[2] = "Super Administrator [Gold Member]";
titles[1] = "Owner [Gold Member]";
titles[3] = "Administrator";
titles[4] = "Administrator [Gold Member]";
titles[996] = "VIP";
titles[997] = "VIP [Gold Member]";
titles[998] = "Regular [Gold Member]";
titles[999] = "Regular";

function PANEL:UpdatePlayerData()

	if (!self.Player) then return end
	if ( !self.Player:IsValid() ) then return end
	
	self:SetInfo( 1, "SteamID:", self.Player:SteamID())
	self:SetInfo( 1, "UniqueID:", self.Player:UniqueID() )
	self:SetInfo( 1, "Steam Name:", self.Player:Nick() )
	
	if (titles[self.Player:GetAccessLevel()]) then
		self:SetInfo(1, "Position: ", titles[self.Player:GetAccessLevel()]);
	else
		self:SetInfo(1, "Position: ", "Unknown Access");
	end
	
	self:InvalidateLayout()

end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:ApplySchemeSettings()

	for _k, column in pairs( self.InfoLabels ) do

		for k, v in pairs( column ) do
		
			v.Key:SetFGColor( 0, 0, 0, 100 )
			v.Value:SetFGColor( 0, 70, 0, 200 )
		
		end
	
	end

end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:Think()

	if ( self.PlayerUpdate && self.PlayerUpdate > CurTime() ) then return end
	self.PlayerUpdate = CurTime() + 0.25
	
	self:UpdatePlayerData()
	
	self.scrollerTime:SetText("Punishment Time ( Hours ) - " .. (self.scrollerTime:GetValue() / 24) .. " Days");

end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()	

	local x = 5

	for colnum, column in pairs( self.InfoLabels ) do
	
		local y = 0
		local RightMost = 0
	
		for k, v in pairs( column ) do
	
			v.Key:SetPos( x, y )
			v.Key:SizeToContents()
			
			v.Value:SetPos( x + 70 , y )
			v.Value:SizeToContents()
			
			y = y + v.Key:GetTall() + 2
			
			RightMost = math.max( RightMost, v.Value.x + v.Value:GetWide() )
		
		end
		
		//x = RightMost + 10
		x = x + 300
	
	end
	
	if ( !self.Player || !LocalPlayer():IsAdmin() ) then 
	
		self.btnKick:SetVisible( false )
		self.btnBan:SetVisible( false )
		self.btnPBan:SetVisible( false )
	
	else
	
		self.btnKick:SetVisible( true )
		self.btnBan:SetVisible( true )
	
		local sizeOButton = 60;
	
		self.btnKick:SetPos( self:GetWide() - (sizeOButton + 4) * 2, 80 )
		self.btnKick:SetSize( sizeOButton, 20 )

		self.btnBan:SetPos( self:GetWide() - (sizeOButton + 4) * 1, 80 )
		self.btnBan:SetSize( sizeOButton, 20 )
		
		self.btnSlay:SetPos( self:GetWide() - (sizeOButton + 4) * 3, 80 )
		self.btnSlay:SetSize( sizeOButton, 20 )
		
		if (LocalPlayer():IsSuperAdmin()) then
			self.btnPBan:SetPos( self:GetWide() - (sizeOButton + 4) * 4, 80 )
			self.btnPBan:SetSize( sizeOButton, 20 )
			self.btnPBan:SetVisible( true )
		else
			self.btnPBan:SetVisible( false )
		end
	
	end
	
	self.scrollerTime:SetPos(self:GetWide() - 305, 5);
	self.scrollerTime:SetSize(300, 30);
end

function PANEL:Paint()
	return true
end


vgui.Register( "ScorePlayerInfoCard", PANEL, "Panel" )