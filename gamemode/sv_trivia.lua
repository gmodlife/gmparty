local TriviaTable = {};

local ReadTriviaFile = file.Read("trivia.txt");

for K, line in pairs(string.Explode("\n", ReadTriviaFile)) do
	local Exp = string.Explode("|", line)
	
	if #Exp > 1 and #Exp != 5 then
		Msg('Got odd number of exploded trivia args - Line ' .. K .. '\n');
	elseif #Exp == 5 then
		local NewTable = {};
		NewTable.Question = Exp[1];
		NewTable.RealAnswer = Exp[2];
		NewTable.FakeAnswers = {Exp[3], Exp[4], Exp[5]};
		
		table.insert(TriviaTable, NewTable);
	end
end

Msg("Loaded " .. table.Count(TriviaTable) .. " trivia questions successfully.\n");

function GM.MonitorTrivia_Think ( )

end
hook.Add('Think', 'GM.MonitorTrivia_Think', GM.MonitorTrivia_Think);

function GM.StartTrivia ( Player )
	umsg.Start("trivia.Start", Player); umsg.End();
	Player:GetTable().InTrivia = true;

	Player:SetEyeAngles(((ents.FindByName('trivia_director')[1]:GetPos() + Vector(0, 0, 64)) - Player:GetShootPos()):Angle());
	
	Player:CrosshairDisable();
end

concommand.Add('trivia_leave', function( pl, cmd, args )
	
	if( !pl.InTrivia ) then return end
	
	umsg.Start("trivia.Leave", pl)
	umsg.End()
	
	pl:ChatPrint( "You exited trivia" )
	pl.InTrivia = nil
	
	for k, v in pairs(ents.FindByClass('trivia_stand')) do
		if v.CurrentOccupant == pl then
			v.CurrentOccupant = nil;
		end
	end
	
end )

hook.Add("Move", "trivia.Freeze", function ( pl ) 
										if pl:GetTable().InTrivia then 
											return true 
										end 
									end);