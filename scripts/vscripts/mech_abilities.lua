function summonMech(keys)
	local caster = keys.caster
	local point = keys.target_points[1]
	CreateItemOnPositionSync(point, CreateItem("item_roshfall_summoned_mech", caster, caster))
end

function start_banish(keys)
	local caster = keys.caster
	caster:SetOrigin(Vector(0,0,-512))
end

function relocateOwner(keys)
	local target = keys.target
	target:GetOwner():SetAbsOrigin(target:GetAbsOrigin())
	local angles = target:GetAngles()
	target:GetOwner():SetAngles(angles.x, angles.y, angles.z)
end