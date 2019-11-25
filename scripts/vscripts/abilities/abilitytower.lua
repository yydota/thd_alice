g_creeps_name={
	"npc_dota_goodguys_siege",
	"npc_dota_goodguys_siege_upgraded",
	"npc_dota_badguys_siege",
	"npc_dota_badguys_siege_upgraded",
	"npc_dota_creep_goodguys_melee",
	"npc_dota_creep_goodguys_melee_upgraded",
	"npc_dota_creep_goodguys_ranged",
	"npc_dota_creep_goodguys_ranged_upgraded",
	"npc_dota_creep_badguys_melee",
	"npc_dota_creep_badguys_melee_upgraded",
	"npc_dota_creep_badguys_ranged",
	"npc_dota_creep_badguys_ranged_upgraded",
}

function IsCreep(unit)
	if unit==nil or unit:IsNull() then
		return false
	end
	for _,name in pairs(g_creeps_name) do
		if name == unit:GetUnitName() then 
			return true 
		end
	end
end

function OnCheckNearby(keys)
	local caster=keys.caster
	local radius = keys.Radius
	if caster:GetClassname()=="npc_dota_fort" then
		radius = 1060
	end
	local units = FindUnitsInRadius(
				   caster:GetTeam(),						--caster team
				   caster:GetOrigin(),							--find position
				   nil,										--find entity
				   radius,						--find radius
				   DOTA_UNIT_TARGET_TEAM_ENEMY,
				   keys.ability:GetAbilityTargetType(),
				   0, FIND_CLOSEST,
				   false
			    )
	for _,v in pairs(units) do
		if IsCreep(v) and v:HasModifier("modifier_thdots_unit_anti_bd")==false then 
			keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_thdots_anti_bd_stop", {})
			break
		elseif caster:HasModifier("modifier_thdots_anti_bd_stop") and v:IsRealHero() then 
			keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_thdots_anti_bd_stop", {})
			break
		end
	end
end

function OnTowerAttacked(keys)
	local caster = keys.caster
	local Attacker = keys.attacker
	if (Attacker:GetTeam() == caster:GetTeam()) then 
		return
	elseif caster:HasModifier("modifier_thdots_anti_bd_stop") == false then
		caster:SetHealth(caster:GetHealth()+keys.DamageTaken+1)	
	end
end