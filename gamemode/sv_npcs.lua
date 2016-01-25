local ShopNameConv = {};
ShopNameConv['shop_gmr'] = 1;
ShopNameConv['shop_perp'] = 2;

function GM:KeyPress ( Player, Key )
	if Key == IN_USE then
		local TTable = {}
		TTable.start = Player:GetShootPos();
		TTable.endpos = TTable.start + Player:GetAimVector() * 100;
		TTable.filter = Player;
		TTable.mask = MASK_OPAQUE_AND_NPCS;
		
		local Tr = util.TraceLine(TTable);
				
		if Tr.Entity and Tr.Entity:IsValid() and Tr.Entity:IsNPC() and ShopNameConv[Tr.Entity:GetName()] then
			umsg.Start('gmr_npc_interact', Player);
				umsg.Short(ShopNameConv[Tr.Entity:GetName()]);
			umsg.End();
		end
	end
end

RunConsoleCommand('ai_disabled', '0');