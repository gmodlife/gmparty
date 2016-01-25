local PANEL = {}

function PANEL:Init ( ) 
	self:MakePopup()
	self:SetDraggable(false);

	self.List = vgui.Create("DPanelList", self)
	self.List:EnableVerticalScrollbar()
	self.List:SetPadding(5)
	self.List:SetSpacing(2)
end

function PANEL:PerformLayout ( ) 
	local W, H = 300, 200;
	
	self:SetPos(ScrW() * .5 - W * .5, ScrH() * .5 - H * .5);
	self:SetSize(W, H);
	
	self.List:StretchToParent(5, 30, 5, 5);
	
	self.BaseClass.PerformLayout(self);
end

function PANEL:SetCashType ( ID ) 
	self.CashID = ID;

	if ID == 1 then
		self:SetTitle("GMod Racer Cash Rewards")
		
		self.PerStarConv = GAMEMODE.GMRConversionRate;
		self.RegRate = GAMEMODE.GMRConversionRate;
		self.VIPRate = math.Round(GAMEMODE.GMRConversionRate * GAMEMODE.VIPConversionRateMod);
		
		self.CurCashLabel = vgui.Create('DLabel', self);
		self.CurCashLabel:SetText("Current GMR Cash: $" .. (GAMEMODE.GMRCash or 0));
		self.List:AddItem(self.CurCashLabel);
	elseif ID == 2 then
		self:SetTitle("Pulsar Effect RP 3.5 Cash Rewards")
		
		self.PerStarConv = GAMEMODE.PERPConversionRate;
		self.RegRate = GAMEMODE.PERPConversionRate;
		self.VIPRate = math.Round(GAMEMODE.PERPConversionRate * GAMEMODE.VIPConversionRateMod);
		
		self.CurCashLabel = vgui.Create('DLabel', self);
		self.CurCashLabel:SetText("Current PERP Cash: $" .. (GAMEMODE.PERPCash or 0));
		self.List:AddItem(self.CurCashLabel);
	end
	
	if LocalPlayer():GetLevel() <= 4 then
		self.PerStarConv = self.VIPRate;
	end
	
	self.CurConvLabel = vgui.Create('DLabel', self);
	self.CurConvLabel:SetText("Non-Vip Conversion Rate: $" .. self.RegRate .. " per star.");
	self.List:AddItem(self.CurConvLabel);
		
	self.CurConvLabel = vgui.Create('DLabel', self);
	self.CurConvLabel:SetText("VIP Conversion Rate: $" .. self.VIPRate .. " per star.");
	self.CurConvLabel:SetColor(Color(150, 150, 255, 255));
	self.List:AddItem(self.CurConvLabel);
	
	self.StarSlider = vgui.Create('DNumSlider', self);
	self.StarSlider:SetText("Number of stars to cash in:");
	self.StarSlider:SetMin(0);
	self.StarSlider:SetMax(LocalPlayer():GetNetworkedInt('gmp_stars', 0));
	self.StarSlider:SetValue(0);
	self.StarSlider:SetDecimals(0);
	self.List:AddItem(self.StarSlider);
	
	self.PayoutLabel = vgui.Create('DLabel', self);
	self.PayoutLabel:SetText("Prospective Payout: $0.");
	self.List:AddItem(self.PayoutLabel);
	
	function self.StarSlider.OnValueChanged ( Slider )
		local Val = Slider:GetValue();
		
		self.PayoutLabel:SetText("Prospective Payout: $" .. Val * self.PerStarConv);
	end
	
	self.FinishButton = vgui.Create('DButton', self);
	self.FinishButton:SetText("Confirm Conversion");
	self.List:AddItem(self.FinishButton);
	
	function self.FinishButton.DoClick ( Button )
		local Val = tonumber(self.StarSlider:GetValue() or 0);

		if Val < 1 then 
			LocalPlayer():PrintMessage(HUD_PRINTTALK, "You cannot convert a negative number of stars."); 
			
			return false; 
		end
		
		if Val > LocalPlayer():GetNetworkedInt('gmp_stars', 0) then 
			LocalPlayer():PrintMessage(HUD_PRINTTALK, "You don't have that many stars."); 
			
			return false; 
		end

		local CashPayout = Val * self.PerStarConv;
		
		RunConsoleCommand('gmp_conv', ID, Val);
		
		if ID == 1 then
			GAMEMODE.GMRCash = (GAMEMODE.GMRCash or 0) + CashPayout;
			self.CurCashLabel:SetText("Current GMR Cash: $" .. GAMEMODE.GMRCash);
			LocalPlayer():PrintMessage(HUD_PRINTTALK, "Converted " .. Val .. " stars to $" .. CashPayout .. " GMR cash.");
		elseif ID == 2 then
			GAMEMODE.PERPCash = (GAMEMODE.PERPCash or 0) + CashPayout;
			self.CurCashLabel:SetText("Current PERP Cash: $" .. GAMEMODE.PERPCash);
			LocalPlayer():PrintMessage(HUD_PRINTTALK, "Converted " .. Val .. " stars to $" .. CashPayout .. " PERP cash.");
		end
		
		local NewStars = LocalPlayer():GetNetworkedInt('gmp_stars', 0) - Val;
		
		if NewStars	!= 0 then
			self.StarSlider:SetText("Number of stars to cash in:");
			self.StarSlider:SetMin(0);
			self.StarSlider:SetMax(NewStars);
			self.StarSlider:SetValue(0);
		else
			LocalPlayer():PrintMessage(HUD_PRINTTALK, "You have no more stars to convert.");
			self:Remove();
			return false;
		end
	end
end

vgui.Register('shop_cash', PANEL, 'DFrame');