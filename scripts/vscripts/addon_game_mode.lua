if (CRoshfallGameMode == nil) then
	CRoshfallGameMode = class({})
end

function Precache(context)
end

-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = CRoshfallGameMode()
	GameRules.AddonTemplate:InitGameMode()
end

function CRoshfallGameMode:InitGameMode()
	print("We have Roshfall.")
end