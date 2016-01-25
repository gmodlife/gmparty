function GM.ChooseRandomLocation ( Type, Limit )
	local PossibleLocations = {};
	
	for k, v in pairs(ents.FindByClass('ent_gmp_item_spawn')) do
		--print(v:GetTable().SpawnType,'==',Type)
		if v:GetTable().SpawnType == Type and (!v:GetTable().NextSpawnTime or v:GetTable().NextSpawnTime < CurTime()) then
			local NearbyPlayer = false;
			
			if Limit then
				local NearbyEnts = ents.FindInSphere(v:GetPos(), 32)
				
				local NearbyPlayer = false;
				for k, ent in pairs(NearbyEnts) do
					if ent:IsPlayer() then
						NearbyPlayer = true;
					end
				end
			end
			
			if !NearbyPlayer then
				table.insert(PossibleLocations, v);
			end
		end
	end
	
	if #PossibleLocations == 0 then
		Msg('No locations of type ' .. Type .. '\n');
		return Vector(0, 0, 0), Angle(0, 0, 0);
	else
		local SendLocation = PossibleLocations[math.random(1, #PossibleLocations)];
		SendLocation:GetTable().NextSpawnTime = CurTime() + 1;
		return SendLocation:GetPos(), SendLocation:GetAngles();
	end
end


function GM.ChooseRandomLocation_Trigger ( Type, Trace )
	local PossibleLocations = {};
	
	for k, v in pairs(ents.FindByClass('ent_gmp_trigger_spawn')) do
		if v:GetTable().SpawnType == Type then
			local OBBMax = v:LocalToWorld(v:OBBMaxs());
			local OBBMin = v:LocalToWorld(v:OBBMins())
			local RandomPosIn = Vector(math.random(OBBMin.x, OBBMax.x), math.random(OBBMin.y, OBBMax.y), math.random(OBBMin.z, OBBMax.z));
			
			if Trace then
				if Trace == TRACE_DOWN then
					local Trace = {};
					Trace.start = RandomPosIn;
					Trace.endpos = RandomPosIn - Vector(0, 0, 500);
					Trace.mask = MASK_SOLID_BRUSHONLY;
					
					local TraceRes = util.TraceLine(Trace);
				
					RandomPosIn = TraceRes.HitPos;
				elseif Trace == TRACE_UP then
					local Trace = {};
					Trace.start = RandomPosIn;
					Trace.endpos = RandomPosIn + Vector(0, 0, 500);
					Trace.mask = MASK_SOLID_BRUSHONLY;
					
					local TraceRes = util.TraceLine(Trace);
				
					RandomPosIn = TraceRes.HitPos;
				end
			end
			
			return RandomPosIn;
		end
	end
end
