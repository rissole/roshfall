if (CRoshfallGameMode == nil) then
	CRoshfallGameMode = class({})
end

function Precache(context)
end

-- Create the game mode when we activate
function Activate()
	GameRules.Roshfall = CRoshfallGameMode()
	GameRules.Roshfall:InitGameMode()
end

function CRoshfallGameMode:InitGameMode()
	Convars:RegisterConvar("roshfall_mech_nonhero_control", "0", "Can non-hero units control mechs?", FCVAR_CHEAT)
	Convars:RegisterConvar("roshfall_mech_steal_mode", "0", "Who can take summoned mechs: 0 - player only, 1 - team mates, 2 - anyone", FCVAR_CHEAT)
	self.mech_info = {}
	print("We have Roshfall.")
end

function CRoshfallGameMode:GetMechInfo(player)
	return self.mech_info[player:entindex()]
end

function CRoshfallGameMode:SetMechInfo(player, t)
	self.mech_info[player:entindex()] = t
end

-- Finds summoned mech for ITEM AFTER IT ACTIVATES man this engine is weird
-- the PHYSICAL ITEM is stored in mech_info, but the 'contained' item is what
-- is passed to OnSpellStart (the 'ability' argument intuitively enough),
-- We need this finder to map from OnSpellStart -> physical item.
function CRoshfallGameMode:FindOwnerForItemAbility(ability)
	for owner, t in pairs(self.mech_info) do
		if t.item ~= nil and t.item:GetContainedItem():entindex() == ability:entindex() then
			return EntIndexToHScript(owner)
		end
	end
	return nil
end