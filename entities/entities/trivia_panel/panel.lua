---------------------
-- TriviaPanel
---------------------

local texCenterGradient = surface.GetTextureID( "gui/center_gradient" )
local texGradientUp = surface.GetTextureID( "gui/gradient_up" )
local texSolid = Material(  "debug/debugtranslucentvertexcolor" )
texSolid:SetString( "$basetexture", "color/white" )

surface.CreateFont('trivia_font_large', {size=ScreenScale( 48 ), weight=600, antialias=true, font="Tahoma"});
surface.CreateFont('trivia_font_medium', {size=ScreenScale( 30 ), weight=600, antialias=true, font="Tahoma"});
surface.CreateFont('trivia_font_small', {size=ScreenScale( 20 ), weight=400, antialias=true, font="Tahoma"});

--Question Types
local QT_MULTICHOICE = 1
local QT_TEXTENTRY = 2

usermessage.Hook( "trivia.Start", function()
	
	TRIVIAPANEL:SetVisible( true )
	gui.EnableScreenClicker( true )
	
end )

usermessage.Hook( "trivia.NewQuestion", function( um )
	
	if( !TRIVIAPANEL ) then return end
	
	local question = um:ReadString()
	local qt = tonumber(um:ReadChar())
	local anwers
	
	if( qt == QT_MULTICHOICE ) then
		
		answers =  {}
		for i=1, 4 do
			anwers[ i ] = um:ReadString()
		end
		
	end
	
	TRIVIAPANEL:SetQuestionType( qt )
	TRIVIAPANEL:NewQuestion( question, answers )
	
end )

usermessage.Hook( "trivia.TimeLeft", function( um )
	
	if( !TRIVIAPANEL ) then return end
	
	local timeleft = um:ReadLong()
	TRIVIAPANEL:SetTimeLeft( timeleft )
	
end )

usermessage.Hook( "trivia.Leave", function()
	
	TRIVIAPANEL:SetVisible( false )
	gui.EnableScreenClicker( false )
	
end )

local GradientPos = Vector()
	
	local function GradVert( x, y )
		local vert = {}
		vert.x = x
		vert.y = y
		vert.u = (vert.x - GradientPos.x) / ScrW()
		vert.v = (vert.y - GradientPos.y) / ScrW()
		return vert
	end

local PANEL = {}

AccessorFunc( PANEL, "i_QuestionType", "QuestionType", QT_MULTICHOICE, FORCE_NUMBER )
AccessorFunc( PANEL, "i_TimeLeft", "TimeLeft", 0, FORCE_NUMBER )
AccessorFunc( PANEL, "i_State", "State" )

function PANEL:Init()
	
	self:SetMouseInputEnabled(true)
 	self:SetKeyboardInputEnabled(true)
	self:SetPaintedManually(true)
	
	self.Question = vgui.Create( "trivia_question", self )
	self.Question:SetTall( 120 )
	self.Question:SetWide( self:GetWide() * 0.8 )
	self.GradientPos = Vector()
	
	self.EntryPanel = vgui.Create( "trivia_textentry_answer", self )
	
	self.AnswerPanels = {
		vgui.Create( "trivia_multichoice_answer", self ),
		vgui.Create( "trivia_multichoice_answer", self ),
		vgui.Create( "trivia_multichoice_answer", self ),
		vgui.Create( "trivia_multichoice_answer", self )
	}
	
	for i, choice in ipairs{"A","B","C","D"} do
		
		self.AnswerPanels[ i ]:SetChoice( choice )
		
	end
	
	self:HideQuestion()
	self:SetQuestionType( QT_MULTICHOICE )
	
	--self:ChangeState( STATE_TOOFAR )
	
end

function PANEL:SetMousePos( x, y )
	
	self.mousex = x
	self.mousey = y
	
	self:OnCursorMoved( x, y, (x == -1 && y == -1) )
	
end

function PANEL:GetMousePos()
	
	local x = self.mousex or -1
	local y = self.mousey or -1
	
	if( x < 0 ) then return end
	if( y < 0 ) then return end
	if( x > self:GetWide() ) then return end
	if( y > self:GetTall() ) then return end
	
	return x, y
	
end

function PANEL:PerformLayout()	
	self.Question:SetWide( self:GetWide() * 0.8 )
end


function PANEL:ChangeState( s )
	
	ErrorNoHalt( "changing state: ", s, "\n" )
	self:SetState( s )
	
	if( s == STATE_TOOFAR ) then
		
		self.Question:SetVisible( false )
		for i, pnl in ipairs( self.AnswerPanels ) do
			pnl:SetVisible( false )
		end
		
	elseif( s == STATE_DEFAULT ) then
		
		self:Think()
		
		self.Question:SetVisible( true )
		for i, pnl in ipairs( self.AnswerPanels ) do
			local x, y = pnl:GetPos()
			pnl:SetVisible( true )
			pnl:SetPos( pnl.targetx or x, y )
		end
		
	elseif( s == STATE_DISABLED ) then
		
		self:SetVisible( false )
		
	end
	
end


function PANEL:EndQuestion( correct_answer )
end

function PANEL:HideQuestion()
	
	if( self.hidden ) then return end
	self.Question:Clear()
	self.hidden = CurTime()
	
	for i, pnl in ipairs( self.AnswerPanels ) do
		
		pnl:SetAnswer( "" )
		
	end
	
end

local function WrapString( str, wide )
	
	local lines = {}
	local tline = "";
	
	local words = string.Explode( " ", str );
	for _, word in pairs( words ) do
		
		local w, _ = surface.GetTextSize( tline .. word );
		if ( w > wide ) then
			
			table.insert( lines, tline )
			tline = word .. " "
			
		else
			
			tline = tline .. word .. " "
			
		end
		
	end
	
	if ( tline != "" ) then
		
		table.insert( lines, tline )
		
	end
	
	return lines
	
end

function PANEL:NewQuestion( question, answers )
	
	self.hidden = false
	self.Question:SetQuestion( question )
	self.Question.lines = {}
	local smallwrap, mediumwrap, largewrap = {}, {}, {}
	
	self.Question.lineFont = "trivia_font_small"
	surface.SetFont( self.Question.lineFont )
	smallwrap = WrapString( question, self.Question:GetWide() )
	
	if( #smallwrap == 1 ) then --check if a larger font fits in 1 line
		
		self.Question.lineFont = "trivia_font_medium"
		surface.SetFont( self.Question.lineFont )
		mediumwrap = WrapString( question, self.Question:GetWide() )
		
		if( #mediumwrap == 1 ) then --check if a larger font fits in 1 line
			
			self.Question.lineFont = "trivia_font_large"
			surface.SetFont( "trivia_font_large" )
			largewrap = WrapString( question, self.Question:GetWide() )
			
			if( #largewrap > 1 ) then
				self.Question.lineFont = "trivia_font_medium"
				self.Question.lines = mediumwrap
			else
				self.Question.lines = largewrap
			end
		else
			self.Question.lineFont = "trivia_font_small"
			self.Question.lines = smallwrap
		end
	else
		self.Question.lines = smallwrap
	end
	
	if( !answers ) then return end
	
	for i, answer in ipairs( answers ) do
		
		self.AnswerPanels[ i ]:SetAnswer( answer )
		
	end
	
end

function PANEL:Think()
	
	local w, h = self:GetWide(), self:GetTall()
	local x, y = self.Question:GetPos()
	local mx, my = self:GetMousePos()
	
	self.Question.YPos = h * 0.66
	
	local targetx, targety = w*0.5 - self.Question:GetWide()*0.5, self.Question.YPos - self.Question:GetTall() * 0.5
	
	self.Question:SetPos( Lerp( 20*FrameTime(), x, targetx ), targety )
	
	self.AnswerRowHeight = (h - targety - self.Question:GetTall() - 80) * 0.5
	self.AnswerRowYPos = {}
	self.AnswerRowYPos[1] = math.floor(y + self.Question:GetTall() + 20)
	self.AnswerRowYPos[2] = math.floor(y + self.Question:GetTall() + 20 + self.AnswerRowHeight + 20)
	
	local spacing = w * 0.05 * 3
	local answer_wide = (self.Question:GetWide() - spacing) * 0.5
	
	for i=1, #self.AnswerPanels, 2 do
		
		local panels = {self.AnswerPanels[ i ],self.AnswerPanels[ i+1 ]}
		local row = math.ceil(i/2)
		for _, pnl in pairs( panels ) do
			
			local x, y = pnl:GetPos()
			if( _%2 == 1 ) then
				if( self.hidden && CurTime() > self.hidden + (row-1)*0.1 ) then
					pnl.targetx = -answer_wide*2 - 10
				else
					pnl.targetx = targetx
				end
			else
				if( self.hidden && CurTime() > self.hidden + (row-1)*0.1 ) then
					pnl.targetx = w + answer_wide + 10
				else
					pnl.targetx = targetx + self.Question:GetWide() - answer_wide
				end
			end
			pnl:SetSize( answer_wide, self.AnswerRowHeight )
			pnl:SetPos( Lerp( 10*FrameTime(), x, pnl.targetx ), self.AnswerRowYPos[ row ] )
			self:HookOperationOverride( pnl, mx, my )
			
		end
		
	end
	
end

function PANEL:Paint()
	
	local w, h = self:GetWide(), self:GetTall()
	
	surface.SetDrawColor( 20, 30, 80, 255 )
	surface.DrawRect( 0, 0, w, h )
	
	GradientPos = Vector( w*0.5 + math.cos( RealTime() * 2 ) * w*0.5, math.sin( RealTime() * 2 ) * h*0.3 )
	
	surface.SetDrawColor( 10, 10, 10, 200 )
	surface.DrawRect( 0, self.Question.YPos, w, h - self.Question.YPos )
	
	surface.SetTexture( texGradientUp )
	surface.DrawTexturedRect( 0, self.Question.YPos, w, h - self.Question.YPos )
	
	--surface.SetDrawColor( 255, 255, 255, 255 )
	--surface.DrawLine( self.GradientPos.x - 10, self.GradientPos.y, self.GradientPos.x + 10, self.GradientPos.y )
	--surface.DrawLine( self.GradientPos.x, self.GradientPos.y - 10, self.GradientPos.x, self.GradientPos.y + 10 )
	
	local borderSize = 3
	local x, y = self.Question:GetPos()
	
	local poly = {
		GradVert(0,y+self.Question:GetTall()*0.5-borderSize*0.5),
		GradVert(w,y+self.Question:GetTall()*0.5-borderSize*0.5),
		GradVert(w,y+self.Question:GetTall()*0.5+borderSize*0.5),
		GradVert(0,y+self.Question:GetTall()*0.5+borderSize*0.5)
	}
	
	surface.SetDrawColor( 86, 109, 189, 255 )
	surface.SetMaterial( texSolid )
	surface.DrawPoly( poly )
	
	surface.SetDrawColor( 184, 231, 251, 255 )
	surface.SetTexture( texCenterGradient )
	surface.DrawPoly( poly )
	
	for _, yPos in pairs( self.AnswerRowYPos ) do
		local poly = {
			GradVert(0,math.floor(yPos+self.AnswerRowHeight*0.5-borderSize*0.5)),
			GradVert(w,math.floor(yPos+self.AnswerRowHeight*0.5-borderSize*0.5)),
			GradVert(w,math.floor(yPos+self.AnswerRowHeight*0.5+borderSize*0.5)),
			GradVert(0,math.floor(yPos+self.AnswerRowHeight*0.5+borderSize*0.5))
		}
		
		surface.SetDrawColor( 86, 109, 189, 255 )
		surface.SetMaterial( texSolid )
		surface.DrawPoly( poly )
		
		surface.SetDrawColor( 184, 231, 251, 255 )
		surface.SetTexture( texCenterGradient )
		surface.DrawPoly( poly )
	end
	
end

function PANEL:PaintOver()
	
	local screen = self.Screen
	if( !screen ) then return end
	
	if( !screen.Active ) then
		surface.SetDrawColor( 20, 30, 80, 255 )
		surface.DrawRect( 0, 0, screen.Width, screen.Height )
	end
	
	if( screen.InTime ) then
		local diff = (screen.InTime + 2 - RealTime()) / 2
		if( diff >= 0 ) then
			surface.SetDrawColor( 0, 0, 0, diff*255 )
			surface.DrawRect( 0, 0, screen.Width, screen.Height)
		else
			screen.InTime = nil
		end
	end
	
	self:PaintCursor()
	
end

local function intersectRayPlane( S1, S2, P, N ) --( startpoint, endpoinst, point on plane, plane's normal )
	
	local u = S2 - S1
	local w = S1 - P
	
	local d = N:Dot( u )
	local n = N:Dot( w )*-1
	
	if (math.abs( d ) < 0) then
		if (n == 0) then return end	--segment is in the plane
		return				--no intersection
	end
	
	local sI = n/d
	if (sI < 0 || sI > 1) then return end	--no intersection
	return S1 + sI * u
	
end

function PANEL:WorldToLocal( w )
	
	local p = self.Screen:WorldToLocal( w )
	
	local wide, tall = self:GetSize()
	
	local x = (p.y - self.Screen.LocalPos.y)/(-self.Screen.Width*self.Screen.CamScale)*self:GetWide()
	local y = (p.z - self.Screen.LocalPos.z)/(self.Screen.Height*self.Screen.CamScale)*self:GetTall()
	
	if(	x > wide || x < 0	||
		y > tall || y < 0	) then
		return
	end
	
	return x, y
	
end

function PANEL:UpdateCursor()
	
	local screen = self.Screen
	if( !screen ) then return end
	local pl = LocalPlayer()
	if( !IsValid( pl ) ) then return end
	
	local p1 = EyePos()
	local p2 = p1 + pl:GetAimVector()*2048
	local wpos = intersectRayPlane( p1, p2, screen.Pos, screen.Normal )
	if( !wpos ) then return end
	
	local x, y = self:WorldToLocal( wpos )
	if( !x ) then
		
		self:SetMousePos( -1, -1 )
		screen.mousex = -1
		screen.mousey = -1
		return
		
	end
	
	screen.mousex = x
	screen.mousey = y
	self:SetMousePos( x, y )
	
end

function PANEL:RestoreCursor()
	
	self:SetMousePos( self.Screen.mousex or -1, self.Screen.mousey or -1 )
	
end

function PANEL:HookOperationOverride( pnl, x, y, bOff )
	
	local nx, ny = pnl:ScreenToLocal( self:LocalToScreen( x, y ) )
	local w, t = pnl:GetWide(), pnl:GetTall()
	
	if( pnl:IsVisible() ) then
		
		if( nx >= 0	&&
			nx <= w	&&
			ny >= 0	&&
			ny <= t	&&
			!bOff	) then
			
			if( !pnl.pho_hover ) then
				pnl:OnCursorEntered()
			end
			pnl:OnCursorMoved( nx, ny )
			pnl.pho_hover = true
			
		else
			
			if( pnl.pho_hover ) then
				pnl:OnCursorExited()
			end
			pnl.pho_hover = false
			
		end
		
		if( input.IsMouseDown( MOUSE_LEFT ) ) then
			
			if( !pnl.pho_pressed ) then
				
				if( pnl.pho_hover ) then
					pnl:OnMousePressed( MOUSE_LEFT )
				end
				
			end
			pnl.pho_pressed = true
			
		else
			
			if( pnl.pho_pressed ) then
				
				if( pnl.pho_hover ) then
					pnl:OnMouseReleased( MOUSE_LEFT )
				end
				
			end
			pnl.pho_pressed = false
			
		end
			
	else
		
		if( pnl.pho_hover ) then
			pnl:OnCursorExited()
		end
		pnl.pho_hoved = false
		
	end
	
end

function PANEL:OnCursorMoved( x, y, bOff )
	
	for _, pnl in pairs( self.AnswerPanels ) do
		self:HookOperationOverride( pnl, x, y, bOff )
	end
	
end

function PANEL:PaintCursor()
	
	local x, y = self:GetMousePos()
	if( !x ) then return end
	
	draw.RoundedBox( 1, x-2, y-2, 4, 4, color_white )
	
end

vgui.Register( "trivia_main", PANEL, "Panel" )

local function GetPanelBackgroundPoly( pnl, twineWidth, borderSize )
	
	local wide, tall = pnl:GetWide(), pnl:GetTall()
	local twineHeight = tall * 0.5
	
	local detail = 12
	local poly = {}
	
	table.insert( poly, GradVert(wide*0.5,tall*0.5) )
	
	for i=0, detail do
		
		local vert = GradVert(
					-twineWidth + i/detail*twineWidth - borderSize,
					twineHeight * 0.5 - math.sin( i/detail*math.pi - math.pi*0.5 ) * twineHeight * 0.5 - borderSize * 0.5
				)
		table.insert( poly, vert )
		
	end
	
	for i=0, detail do
		
		local vert = GradVert(
					wide + i/detail*twineWidth + borderSize,
					twineHeight * 0.5 - math.sin( i/detail*math.pi + math.pi*0.5 ) * twineHeight * 0.5 - borderSize * 0.5
				)
		table.insert( poly, vert )
		
	end
	
	for i=detail, 0, -1 do
		
		local vert = GradVert(
					wide + i/detail*twineWidth + borderSize,
					tall - twineHeight * 0.5 - math.sin( i/detail*math.pi - math.pi*0.5 ) * twineHeight * 0.5 + borderSize * 0.5
				)
		table.insert( poly, vert )
		
	end
	
	for i=detail, 0, -1 do
		
		local vert = GradVert(
					-twineWidth + i/detail*twineWidth - borderSize,
					tall - twineHeight * 0.5 - math.sin( i/detail*math.pi + math.pi*0.5 ) * twineHeight * 0.5 + borderSize * 0.5
				)
		table.insert( poly, vert )
		
	end
	
	table.insert( poly, GradVert(-twineWidth,tall*0.5-borderSize*0.5) )
	
	return poly
	
end

local function UpdateGradientUV( pnl, poly )
	
	local x, y = pnl:ScreenToLocal( GradientPos.x, GradientPos.y )
	local w = ScrW()
	for _, vert in pairs( poly ) do
		vert.u = (vert.x - x) / w
		vert.v = (vert.y - y) / w
	end
	
end

local PANEL = {}

AccessorFunc( PANEL, "s_Question", "Question" )

function PANEL:Init()
	
	self:SetQuestion( "" )
	self.lineFont = "trivia_font_small"
	
end

function PANEL:PerformLayout()
	
	local twineWidth = ScrW() * 0.075
	local borderSize = 3
	
	self.BorderPoly = GetPanelBackgroundPoly( self, twineWidth, borderSize )
	self.ContentPoly = GetPanelBackgroundPoly( self, twineWidth, -1 )
	
end

function PANEL:Clear()
	
	self:SetQuestion( "" )
	
end

function PANEL:Think()
	
	if( self:GetQuestion() == "" ) then
		
		--Shrink the panel's height to 0
		
	end
	
end

function PANEL:Paint()
	
	UpdateGradientUV( self, self.BorderPoly )
	
	DisableClipping( true )
		surface.SetDrawColor( 86, 109, 189, 255 )
		surface.SetMaterial( texSolid )
		surface.DrawPoly( self.BorderPoly )
		
		surface.SetDrawColor( 184, 231, 251, 255 )
		surface.SetTexture( texCenterGradient )
		surface.DrawPoly( self.BorderPoly )
		
		surface.SetDrawColor( 0, 0, 0, 255 )
		surface.SetMaterial( texSolid )
		surface.DrawPoly( self.ContentPoly )
	DisableClipping( false )
	
end

function PANEL:PaintOver()
	
	if( !self.lines ) then return end
	
	surface.SetFont( self.lineFont )
	local spacing = self:GetTall() * 0.01
	local lineCount = #self.lines
	local lineHeight = (self:GetTall() - spacing*lineCount) / (lineCount+1)
	for i=1, lineCount do
		local w, h = surface.GetTextSize( self.lines[ i ] )
		draw.SimpleText( self.lines[ i ], self.lineFont, self:GetWide() * 0.5, lineHeight * i + spacing * i - h*0.5, color_white, TEXT_ALIGN_CENTER )
	end
	
end

vgui.Register( "trivia_question", PANEL, "Panel" )

local PANEL = {}

AccessorFunc( PANEL, "s_Answer", "Answer" )
AccessorFunc( PANEL, "s_Choice", "Choice" )

function PANEL:Init()
	
	self:SetAnswer( "None of the above" )
	
end

function PANEL:PerformLayout()
	
	local twineWidth = ScrW() * 0.04
	local borderSize = 3
	
	self.BorderPoly = GetPanelBackgroundPoly( self, twineWidth, borderSize )
	self.ContentPoly = GetPanelBackgroundPoly( self, twineWidth, -1 )
	
end

function PANEL:OnMousePressed( mc )
	
	ErrorNoHalt( "You pressed ", mc, " on Answer Choice: ", self:GetChoice(), "\n" )
	
end

function PANEL:OnMouseReleased( mc )
	
	ErrorNoHalt( "You released ", mc, " on Answer Choice: ", self:GetChoice(), "\n" )
	
end

function PANEL:OnCursorMoved( x, y )
end

function PANEL:OnCursorEntered()
	
	self.hovered = true
	
end

function PANEL:OnCursorExited()
	
	self.hovered = false
	
end

function PANEL:Paint()
	
	UpdateGradientUV( self, self.BorderPoly )
	
	DisableClipping( true )
		surface.SetDrawColor( 86, 109, 189, 255 )
		surface.SetMaterial( texSolid )
		surface.DrawPoly( self.BorderPoly )
		
		surface.SetDrawColor( 184, 231, 251, 255 )
		surface.SetTexture( texCenterGradient )
		surface.DrawPoly( self.BorderPoly )
		
		if( self.hovered ) then
			surface.SetDrawColor( 255, 140, 0, 255 )
		else
			surface.SetDrawColor( 0, 0, 0, 255 )
		end
		surface.SetMaterial( texSolid )
		surface.DrawPoly( self.ContentPoly )
	DisableClipping( false )
	
end

function PANEL:PaintOver()
	
	local x, y = ScrW() * -0.01, self:GetTall() * 0.5
	local size = self:GetTall() * 0.18
	
	DisableClipping( true )
		if( self.hovered ) then
			surface.SetDrawColor( 255, 255, 255, 255 )
		else
			surface.SetDrawColor( 255, 140, 0, 255 )
		end
		surface.SetMaterial( texSolid )
		surface.DrawTexturedRectRotated( x, y, size, size, 45 )
	DisableClipping( false )
	
	surface.SetFont( "trivia_font_medium" )
	local w, h = surface.GetTextSize( self:GetChoice()..": " )
	
	draw.SimpleText( self:GetChoice()..": ", "trivia_font_medium", 0, self:GetTall()*0.5-h*0.5, self.hovered and color_white or Color( 255, 140, 0, 255 ) )
	
	surface.SetFont( "trivia_font_small" )
	local _, h = surface.GetTextSize( self:GetChoice()..": " )
	draw.SimpleText( self:GetAnswer(), "trivia_font_small", w, self:GetTall()*0.5-h*0.5, self.hovered and color_black or color_white )
	
end

vgui.Register( "trivia_multichoice_answer", PANEL, "Panel" )