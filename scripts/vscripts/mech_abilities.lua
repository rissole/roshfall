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
	
		-- mode 1: teammates can control, but this user is not a teammate
		if (steal_mode == 1 and owner:GetTeam() ~= user:GetTeam()) then
			return false
		end
	end
		
	return true
end

-- Place the Summoned Mech (unit to animate, then item) into the world
-- This is a point target ability
function StartSummonMech(keys)
	local caster = keys.caster
	if (Roshfall:GetMechInfo(caster) ~= nil) then
		-- Player already has a mech
		print('Player ' .. caster:GetName() .. ' already has a summoned mech')
		return
	end
	local point = keys.target_points[1]
    -- Spawn animation entity which will summon item
    local mech = CreateUnitByName("npc_roshfall_mech_spawning", point, true, nil, nil, caster:GetTeam())
    -- To apply data driven modifiers to units from scripts you have to make an item. lol
    local summoning_modifier = CreateItem("item_roshfall_mech_summoning_modifier", nil, nil)
    summoning_modifier:ApplyDataDrivenModifier(caster, mech, "modifier_roshfall_mech_spawning", {})
    summoning_modifier:ApplyDataDrivenModifier(caster, mech, "modifier_roshfall_mech_falling", {})
end

-- Called once the mech summon animation is complete
function EndSummonMech(keys)
    local owner = keys.caster
    local point = keys.target:GetAbsOrigin()
    keys.target:ForceKill(false)
    SummonMechItem(owner, point)
end

-- Create the item that can be used by the owner
function SummonMechItem(owner, point)
    local item = CreateItemOnPositionSync(point, CreateItem("item_roshfall_summoned_mech", owner, owner))
    Roshfall:SetMechInfo(owner, {item=item})
end

-- This event fires when the Mech impacts the ground (during the summon animation)
function SummonImpactGround(keys)
    print("BOOM")
end

-- Hack to make hero invisible. Yes I know SetNoDraw exists
-- but that doesn't work for particles/effects like Abaddon's glowing bits.
function StartBanish(keys)
	local caster = keys.caster
	caster:SetAbsOrigin(Vector(-8000, -8000, 0))
end

-- Attempt to enter the mech
function EnterMech(keys)
	local user = keys.caster
	local item = keys.ability
	local owner = Roshfall:FindOwnerForItemAbility(item)

	if (not CanEnterMech(user, owner)) then
		-- If can't enter mech, we have to recreate the item exactly as we found it.
		local point = Roshfall:GetMechInfo(owner).item:GetAbsOrigin()
		Roshfall:SetMechInfo(owner, nil)
		SummonMechItem(owner, point)
	else
		local point = Roshfall:GetMechInfo(owner).item:GetAbsOrigin()
		Roshfall:SetMechInfo(owner, nil)
		local mech = CreateUnitByName("npc_roshfall_mech", point, true, user, user, user:GetTeam())
		mech:SetControllableByPlayer(user:GetPlayerID(), true)
		item:ApplyDataDrivenModifier(user, mech, "modifier_roshfall_mech_control", {})
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
	local target = keys.target
	local user = target:GetOwner()
	GameRules:GetGameModeEntity():SetOverrideSelectionEntity(nil)
	user:SetAbsOrigin(target:GetAbsOrigin())
	local angles = target:GetAngles()
	user:SetAngles(angles.x, angles.y, angles.z)
	user:RemoveModifierByName("modifier_roshfall_banish")
	if (target:IsAlive()) then
		target:ForceKill(false)
	end
end