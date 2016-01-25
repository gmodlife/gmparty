
function GM:ScoreboardShow()
	ShowSB = true
end

function GM:ScoreboardHide()
	ShowSB = false
end

// TODO: CLEAN THIS CODE

local namecolor = {
   default = COLOR_WHITE,
   admin = Color(178, 34, 34, 255),
   dev = Color(100, 240, 105, 255)
};

function GM:GetScoreboardColor(ply)
   if not IsValid(ply) then return namecolor.default end

   local pgroup = ply:GetNWInt('PGroup',0)
   if ply:SteamID() == "STEAM_0:0:11123796" then
		return Color(166, 122, 238, 255)
	elseif (pgroup == 3 or ply:IsSuperAdmin()) then
      return namecolor.admin
   elseif (pgroup == 2) then
      return Color(255, 215, 0, 255)
	elseif (pgroup == 22) then
      return Color(100, 149, 200, 255)
	elseif (pgroup == 23) then
      return Color(100, 149, 237, 255)
	elseif (pgroup == 1) then
		return Color(100, 230, 105, 255)
	elseif (pgroup == 12) then
		return Color(152, 118, 54, 255)
	elseif (pgroup == 13) then
		return Color(249, 132, 229, 255)
	elseif (pgroup == 15) then
		return Color(230, 150, 229, 255)
	elseif (pgroup == 14) then
		return Color(226, 80, 155, 255)
	elseif (pgroup == 16) then
		return Color(246, 83, 166, 255)
   end
   return namecolor.default
end

function GM:GetTeamScoreInfo()

	local TeamInfo = {}
	
	for id, pl in pairs( player.GetAll() ) do
	
		local _team = pl:Team()
		local _ping = pl:Ping()
		local _cash = pl:GetNWInt('gmp_stars',0)
		local _deaths = pl:GetNWInt('gmp_losses',0)
		
		if (not TeamInfo[_team]) then
			TeamInfo[_team] = {}
			TeamInfo[_team].TeamName = team.GetName( _team )
			TeamInfo[_team].Color = team.GetColor( _team )
			TeamInfo[_team].Players = {}
			--if _raids[_team] then TeamInfo[_team].Raiding = team.GetName( _raids[_team][2] ) end
		end
		
		local PlayerInfo = {}
		PlayerInfo.Deaths = _deaths
		PlayerInfo.Ping = _ping
		PlayerInfo.Name = pl:Nick()
		PlayerInfo.PlayerObj = pl
		PlayerInfo.cash = _cash
		PlayerInfo.tier = 1--pl:GetTier()
		local rank = pl:GetUserGroup()
		if rank == 'user' then rank = ''
		elseif rank == 'superadmin' and pl:SteamID() == "STEAM_0:0:11123796" then rank = 'owner' end
		PlayerInfo.rank = rank
		PlayerInfo.rankc = GAMEMODE:GetScoreboardColor(pl)
		
		local insertPos = #TeamInfo[_team].Players + 1
		for idx, info in pairs(TeamInfo[_team].Players) do
			if (PlayerInfo.Deaths < info.Deaths) then
				insertPos = idx
				break
			elseif (PlayerInfo.Deaths == info.Deaths) then
				if (PlayerInfo.Name < info.Name) then
					insertPos = idx
					break
				end
			end
		end
		
		table.insert(TeamInfo[_team].Players, insertPos, PlayerInfo)
	end
	
	return TeamInfo
end

function GM:HUDDrawScoreBoard()

	if (!ShowSB) then return end
	
	if (ScoreDesign == nil) then
	
		ScoreDesign = {}
		ScoreDesign.HeaderY = 0
		ScoreDesign.Height = ScrH() / 2
	
	end
	
	local alpha = 255

	local ScoreboardInfo = self:GetTeamScoreInfo()
	
	local xOffset = ScrW() / 10
	local yOffset = 32
	local scrWidth = ScrW()
	local scrHeight = ScrH() - 64
	local boardWidth = scrWidth - (2* xOffset)
	local boardHeight = scrHeight
	local colWidth = 75
	
	boardWidth = math.Clamp( boardWidth, 400, 600 )
	boardHeight = ScoreDesign.Height
	
	xOffset = (ScrW() - boardWidth) / 2.0
	yOffset = (ScrH() - boardHeight) / 2.0
	yOffset = yOffset - ScrH() / 4.0
	yOffset = math.Clamp( yOffset, 32, ScrH() )
	
	// Background
	surface.SetDrawColor( 52, 46, 50, 180 )
	surface.DrawRect( xOffset, yOffset, boardWidth, ScoreDesign.HeaderY)
	
	surface.SetDrawColor( 150, 150, 150, 200 )
	surface.DrawRect( xOffset, yOffset+ScoreDesign.HeaderY, boardWidth, boardHeight-ScoreDesign.HeaderY)
	
	// Outline
	surface.SetDrawColor( 0, 0, 0, 150 )
	surface.DrawOutlinedRect( xOffset, yOffset, boardWidth, boardHeight )
	surface.SetDrawColor( 0, 0, 0, 120 )
	surface.DrawOutlinedRect( xOffset-1, yOffset-1, boardWidth+2, boardHeight+2 )
	
	local hostname = GetGlobalString( "ServerName" )
	local gamemodeName = 'GMod Party'
	
	surface.SetTextColor( 255, 255, 255, 255 )
	
	if ( string.len(hostname) > 32 ) then
		surface.SetFont( "Trebuchet18" )
	else
		surface.SetFont( "Trebuchet18" )
	end
	
	local txWidth, txHeight = surface.GetTextSize( hostname )
	local y = yOffset + 15
	surface.SetTextPos(xOffset + (boardWidth / 2) - (txWidth/2), y)
	surface.DrawText( hostname )
	
	y = y + txHeight + 2
	
	surface.SetTextColor( 255, 255, 255, 255 )
	surface.SetFont( "Trebuchet18" )
	local txWidth, txHeight = surface.GetTextSize( gamemodeName )
	surface.SetTextPos(xOffset + (boardWidth / 2) - (txWidth/2), y)
	surface.DrawText( gamemodeName )
	
	y = y + txHeight + 4
	ScoreDesign.HeaderY = y - yOffset
	
	surface.SetDrawColor( 0, 0, 0, 100 )
	surface.DrawRect( xOffset, y-1, boardWidth, 1)
	
	surface.SetDrawColor( 255, 255, 255, 20 )
	surface.DrawRect( xOffset + boardWidth - (colWidth*1), y, colWidth, boardHeight-y+yOffset )
	
	surface.SetDrawColor( 255, 255, 255, 20 )
	surface.DrawRect( xOffset + boardWidth - (colWidth*3), y, colWidth, boardHeight-y+yOffset )	
	
	--surface.SetDrawColor( 255, 255, 255, 20 )
	--surface.DrawRect( xOffset + boardWidth - (colWidth*5.5), y, colWidth, boardHeight-y+yOffset )
	
	
	surface.SetFont( "Trebuchet18" )
	local txWidth, txHeight = surface.GetTextSize( "W" )
	
	surface.SetDrawColor( 0, 0, 0, 100 )
	surface.DrawRect( xOffset, y, boardWidth, txHeight + 6 )

	y = y + 2
	
	surface.SetTextPos( xOffset + 16,								y)	surface.DrawText("Name")
	surface.SetTextPos( xOffset + boardWidth - (colWidth*5.5) + 8,	y)	surface.DrawText("Rank")
	--surface.SetTextPos( xOffset + boardWidth - (colWidth*3.5) + 8,	y)	surface.DrawText("Tier")
	surface.SetTextPos( xOffset + boardWidth - (colWidth*3) + 8,	y)	surface.DrawText("Stars")
	surface.SetTextPos( xOffset + boardWidth - (colWidth*2) + 8,	y)	surface.DrawText("Plays")
	surface.SetTextPos( xOffset + boardWidth - (colWidth*1) + 8,	y)	surface.DrawText("Ping")
	
	y = y + txHeight + 4

	local yPosition = y
	for team,info in pairs(ScoreboardInfo) do
		
		local teamText = info.TeamName .. "  (" .. #info.Players .. " Players)"
		if info.Raiding then teamText = teamText..'   -   Raiding: '..info.Raiding end
		
		surface.SetFont( "Trebuchet18" )
		surface.SetTextColor( 0, 0, 0, 255 )
		
		txWidth, txHeight = surface.GetTextSize( teamText )
		surface.SetDrawColor( info.Color.r, info.Color.g, info.Color.b, 255 )
		surface.DrawRect( xOffset+1, yPosition, boardWidth-2, txHeight + 4)
		yPosition = yPosition + 2
		surface.SetTextPos( xOffset + boardWidth/2 - txWidth/2, yPosition )
		surface.DrawText( teamText )
		yPosition = yPosition + 2
						

		
		yPosition = yPosition + txHeight + 2
		
		for index,plinfo in pairs(info.Players) do
		
			surface.SetFont( "Trebuchet18" )
			surface.SetTextColor( info.Color.r, info.Color.g, info.Color.b, 200 )
			surface.SetTextPos( xOffset + 16, yPosition )
			txWidth, txHeight = surface.GetTextSize( plinfo.Name )
			
			if (plinfo.PlayerObj == LocalPlayer()) then
				surface.SetDrawColor( info.Color.r, info.Color.g, info.Color.b, 50 )
				surface.DrawRect( xOffset+1, yPosition, boardWidth - 2, txHeight + 2)
				surface.SetTextColor( info.Color.r, info.Color.g, info.Color.b, 255 )
			end
			
			
			local px, py = xOffset + 16, yPosition
			local textcolor = Color( info.Color.r, info.Color.g, info.Color.b, alpha )
			local shadowcolor = Color( 0, 0, 0, alpha * 0.8 )
			
			draw.SimpleText( plinfo.Name, "Trebuchet18", px+1, py+1, shadowcolor )
			draw.SimpleText( plinfo.Name, "Trebuchet18", px, py, textcolor )

			px = xOffset + boardWidth - (colWidth*5.5) + 8	
			draw.SimpleText( "" .. plinfo.rank, "Trebuchet18", px+1, py+1, shadowcolor )
			draw.SimpleText( "" .. plinfo.rank, "Trebuchet18", px, py, plinfo.rankc )
			
			px = xOffset + boardWidth - (colWidth*3.5) + 8	
			--draw.SimpleText( "" .. plinfo.tier, "Trebuchet18", px+1, py+1, shadowcolor )
			--draw.SimpleText( "" .. plinfo.tier, "Trebuchet18", px, py, textcolor )
			
			px = xOffset + boardWidth - (colWidth*3) + 8	
			draw.SimpleText( "" .. plinfo.cash, "Trebuchet18", px+1, py+1, shadowcolor )
			draw.SimpleText( "" .. plinfo.cash, "Trebuchet18", px, py, textcolor )
			
			px = xOffset + boardWidth - (colWidth*2) + 8			
			draw.SimpleText( plinfo.Deaths, "Trebuchet18", px+1, py+1, shadowcolor )
			draw.SimpleText( plinfo.Deaths, "Trebuchet18", px, py, textcolor )
			
			px = xOffset + boardWidth - (colWidth*1) + 8			
			draw.SimpleText( plinfo.Ping, "Trebuchet18", px+1, py+1, shadowcolor )
			draw.SimpleText( plinfo.Ping, "Trebuchet18", px, py, textcolor )
			
			//surface.DrawText( plinfo.Name )
			//surface.SetTextPos( xOffset + 16 + 2, yPosition + 2 )
			//surface.SetTextColor( 0, 0, 0, 200 )
			//surface.DrawText( plinfo.Name )

			//surface.SetTextPos( xOffset + boardWidth - (colWidth*3) + 8, yPosition )
			//surface.DrawText( plinfo.Frags )

			//surface.SetTextPos( xOffset + boardWidth - (colWidth*2) + 8, yPosition )
			//surface.DrawText( plinfo.Deaths )

			//surface.SetTextPos( xOffset + boardWidth - (colWidth*1) + 8, yPosition )
			//surface.DrawText( plinfo.Ping )

			yPosition = yPosition + txHeight + 3
		end
	end
	
	yPosition = yPosition + 8
	
	ScoreDesign.Height = (ScoreDesign.Height * 2) + (yPosition-yOffset)
	ScoreDesign.Height = ScoreDesign.Height / 3
	
end