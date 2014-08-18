local Roshfall = GameRules.Roshfall

-- Returns true if the user can enter the summoned mech owned by owner
function CanEnterMech(user, owner)
	local mi = Roshfall:GetMechInfo(owner)
	
	-- isn't a hero
	if (not user:IsRealHero() and Convars:GetBool("roshfall_mech_nonhero_control") == false) then return false end
	
	local steal_mode = Convars:GetInt("roshfall_mech_steal_mode")
	-- not my mech
	if (user:entindex() ~= owner:entindex()) then
		-- mode 0: you can't control a mech that's not yours!
		if (steal_mode == 0) then
			return false
		end
	
		-- mode 1: team mates can control, but this user is not a teammate
		if (steal_mode == 1 and owner:GetTeam() ~= user:GetTeam()) then
			return false
		end
	end
		
	return true
end

-- Place the Summoned Mech (item) into the world (point target ability)
function SummonMechItem(keys)
	local caster = keys.caster
	if (Roshfall:GetMechInfo(caster) ~= nil) then
		-- Player already has a mech
		print('Player ' .. caster:GetName() .. ' already has a summoned mech')
		return
	end
	local point = keys.target_points[1]
	local item = CreateItemOnPositionSync(point, CreateItem("item_roshfall_summoned_mech", caster, caster))
	if (not keys.skip_animation) then
		-- TODO do entrance animation
	end
	Roshfall:SetMechInfo(caster, {item=item})
end

-- Hack to make hero invisible. Yes I know SetNoDraw exists
-- but that doesn't work for particles/effects like Abaddon's glowing bits.
function StartBanish(keys)
	local caster = keys.caster
	caster:SetAbsOrigin(Vector(-8000,-8000,0))
end

-- Attempt to enter the mech
function EnterMech(keys)
	local user = keys.caster
	local item = keys.ability
	local owner = Roshfall:FindOwnerForItemAbility(item)

	if (not CanEnterMech(user, owner)) then
		-- If can't enter mech, we have to recreate the item exactly as we found it.
		Roshfall:SetMechInfo(owner, nil)
		local point = Roshfall:GetMechInfo(owner).item:GetAbsOrigin()
		SummonMechItem({caster=owner, target_points={point}, skip_animation=true})
	else
		print(user:GetName() .. ' entered their mech.')
		Roshfall:SetMechInfo(owner, nil)
	end
end

-- Set control of the player to the mech
function StartMechControl(keys)
	local user = keys.caster
	local target = keys.target
	local item = keys.ability
	-- I think this is bad and makes everyone on the server select it... TODO investigate
	GameRules:GetGameModeEntity():SetOverrideSelectionEntity(target)
	item:ApplyDataDrivenModifier(user, user, "modifier_roshfall_banish", {})
end

-- This is called when the Mech dies/expires.
function EndMechControl(keys)
	GameRules:GetGameModeEntity():SetOverrideSelectionEntity(nil)
	local target = keys.target
	target:GetOwner():SetAbsOrigin(target:GetAbsOrigin())
	local angles = target:GetAngles()
	target:GetOwner():SetAngles(angles.x, angles.y, angles.z)
	target:GetOwner():RemoveModifierByName("modifier_roshfall_banish")
end