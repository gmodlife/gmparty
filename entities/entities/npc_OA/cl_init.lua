-- Copyright Macendo 2009
include('shared.lua')
local TheListToContainAllElse
local TheWindowOfSavin


local function introWindow(um)
	TheWindowOfSavin = vgui.Create("DFrame")
	TheWindowOfSavin:SetSize(300,300)
	TheWindowOfSavin:SetPos(ScrW()/2-150,ScrH()/2-150)
	TheWindowOfSavin:SetTitle("Bill Says: ")
	TheWindowOfSavin:SetVisible(true)
	TheWindowOfSavin:SetDraggable(true)
	TheWindowOfSavin:ShowCloseButton(true)
	TheWindowOfSavin:SetSkin("")
	TheWindowOfSavin:MakePopup()
	
	TheListToContainAllElse = vgui.Create("DPanelList", TheWindowOfSavin)
	TheListToContainAllElse:SetSize(300,278)
	TheListToContainAllElse:SetPos(0,22)
	TheListToContainAllElse:SetSpacing(5)
	TheListToContainAllElse:SetPadding(5)
	TheListToContainAllElse:EnableHorizontal(false)
	TheListToContainAllElse:EnableVerticalScrollbar(false)
	TheListToContainAllElse:SetSkin("")
	
	local Intro = vgui.Create("DLabel")
	Intro:SetText("What Server Would you like to connect to?")
	Intro:SizeToContents()
	TheListToContainAllElse:AddItem(Intro)
	
	local GetDaFood = vgui.Create("DButton")
	GetDaFood:SetText("[LW-2] Half-Life 2")
	GetDaFood:SetSkin("")
	GetDaFood.DoClick = function()
	LocalPlayer():ConCommand("connect 74.91.120.38:27015")
	--RunConsoleCommand("connect 74.91.120.38:27015");
	end
	TheListToContainAllElse:AddItem(GetDaFood)
	
	local cv = vgui.Create("DButton")
	cv:SetText("[LW-2] Civilizations 2")
	cv:SetSkin("")
	cv.DoClick = function()
	LocalPlayer():ConCommand("connect 74.91.120.17:27015");	
	end
	TheListToContainAllElse:AddItem(cv)
	
	local gmr = vgui.Create("DButton")
	gmr:SetText("GMod Racer 1.5")
	gmr:SetSkin("")
	gmr.DoClick = function()
	LocalPlayer():ConCommand("connect 66.151.244.36:27015")
	end
	TheListToContainAllElse:AddItem(gmr)
	
	local perp = vgui.Create("DButton")
	perp:SetText("Pulsar Effect Role Play 4.6")
	perp:SetSkin("")
	perp.DoClick = function()
	LocalPlayer():ConCommand("connect 74.91.120.43:27015");	
	end
	TheListToContainAllElse:AddItem(perp)
end
usermessage.Hook("GetFood", introWindow)