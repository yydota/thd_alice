if AbilityTensi == nil then
	AbilityTensi = class({})
end

function OnTensi02SpellStart(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	if(keys.ability:GetContext("ability_tensi_02_reset")==nil)then
		keys.ability:SetContextNum("ability_tensi_02_reset",TRUE,0)
	end
	if(keys.ability:GetContext("ability_tensi_02_reset")==TRUE)then
		keys.ability:SetContextNum("ability_tensi_02_reset",FALSE,0)
		local resetTime = keys.AbilityMulti/(caster:GetPrimaryStatValue())
		Timer.Wait 'ability_tensi_02_reset_timer' (resetTime,
			function()
				keys.ability:SetContextNum("ability_tensi_02_reset",TRUE,0)
			end
		)
	else
		return
	end
	local telentdamage = FindTelentValue(caster,"special_bonus_unique_earthshaker") * caster:GetStrength()
	local vecCaster = caster:GetOrigin()
	local targets = keys.target_entities
	for _,v in pairs(targets) do
		local damage_table = {
				ability = keys.ability,
			    victim = v,
			    attacker = caster,
			    damage = keys.BounsDamage + telentdamage,
			    damage_type = keys.ability:GetAbilityDamageType(), 
	    	    damage_flags = 0
		}
		UnitDamageTarget(damage_table)
		UtilStun:UnitStunTarget(caster,v,keys.Duration)		            
	end
	if (targets[1] == nil) then
		return
	end
	local effectIndex = ParticleManager:CreateParticle("particles/econ/items/earthshaker/egteam_set/hero_earthshaker_egset/earthshaker_echoslam_start_fallback_low_egset.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(effectIndex, 0, targets[1]:GetOrigin())
	ParticleManager:SetParticleControl(effectIndex, 1, targets[1]:GetOrigin())
	ParticleManager:DestroyParticleSystem(effectIndex,false)
	targets[1]:EmitSound("Hero_EarthShaker.Totem.Attack")
end

function OnTensi03Passive(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	caster:SetHealth(caster:GetHealth()+keys.BounsHealth)
	caster:SetMana(caster:GetMana()+keys.BounsMana)
end

function OnTensi03SpellStart(keys)
	local caster=keys.caster
	local MaxStackCount = keys.MaxStackCount
	if keys.attacker:IsHero() then
		if caster:HasModifier("modifier_tensi03_bonus_attackspeed")~=true then
			caster.ModifierCount = 0
		end
		if caster.ModifierCount >= MaxStackCount then
			caster.ModifierCount = MaxStackCount
		else
			caster.ModifierCount = caster.ModifierCount+1
		end
		keys.ability:ApplyDataDrivenModifier(caster,caster,"modifier_tensi03_bonus_attackspeed",{})
		caster:SetModifierStackCount("modifier_tensi03_bonus_attackspeed",keys.ability,caster.ModifierCount)
	end
end