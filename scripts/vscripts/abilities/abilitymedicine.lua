function OnMedicine01(keys)
	local caster = keys.caster
	local target = keys.target
	local deal_damage = keys.Damage*(target:GetMaxHealth()-target:GetHealth())*0.01+keys.BaseDamage
	local damage_table = {
			ability = keys.ability,
			victim = target,
			attacker = caster,
			damage = deal_damage,
			damage_type = keys.ability:GetAbilityDamageType(),
	    	damage_flags = 0
	}
	UnitDamageTarget(damage_table)
	keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_medicine01_debuff", {duration = 1.0 + FindTelentValue(caster,"special_bonus_unique_viper_1")})
end

function OnMedicine02(keys)
	local caster = keys.caster
	local effectIndex = ParticleManager:CreateParticle("particles/heroes/medicine/medicine02.vpcf", PATTACH_CUSTOMORIGIN, nil)
	local Damage = keys.Damage+FindTelentValue(caster,"special_bonus_unique_viper_3")
		ParticleManager:SetParticleControl(effectIndex, 0, keys.target_points[1])
		local unit = CreateUnitByName(
			"npc_dota_unit_medicine02"
			,keys.target_points[1]
			,false
			,caster
			,caster
			,caster:GetTeam()
		)
	local time =0
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("OnMedicine02Think"), 
		function ()
			if GameRules:IsGamePaused() then return 0.03 end
			if time<keys.Duration then
				time=time+0.5
				local targets = FindUnitsInRadius(
			   		caster:GetTeam(),		--caster team
			  		keys.target_points[1],		--find position
			   		nil,					--find entity
			   		keys.Radius,		--find radius
			   		DOTA_UNIT_TARGET_TEAM_ENEMY,
			   		keys.ability:GetAbilityTargetType(),
			   		0, 
			   		FIND_CLOSEST,
			   		false
		    	)

				for _,v in pairs(targets) do
					local damage_table = {
							ability = keys.ability,
						    victim = v,
						    attacker = caster,
						    damage = Damage/2,
						    damage_type = keys.ability:GetAbilityDamageType(), 
				    	    damage_flags = 0
					}					
					UnitDamageTarget(damage_table)					
				end
			else
				if unit ~=nil and unit:IsNull() == false then 
					unit:ForceKill(false)
				end
				return nil
			end
			return 0.5
		end,
	0)
end

function OnMedicine03Attacked(keys)
	local ItemAbility = keys.ability
	local Caster = keys.caster
	local Attacker = keys.attacker
	if (Attacker:IsBuilding()==false) then
		local damage_to_deal = 0
		if (Attacker:IsHero()) then
			local MaxAttribute = max(max(Attacker:GetStrength(),Attacker:GetAgility()),Attacker:GetIntellect())
			damage_to_deal = keys.PoisonDamageBase + MaxAttribute * (keys.PoisonDamageFactor + FindTelentValue(Caster,"special_bonus_unique_viper_2"))
		end
		damage_to_deal = max(damage_to_deal,keys.PoisonMinDamage)
		if (damage_to_deal>0) then
			local damage_table = {
				ability = keys.ability,
				victim = Attacker,
				attacker = Caster,
				damage = damage_to_deal,
				damage_type = DAMAGE_TYPE_MAGICAL,
				damage_flags = 1
			}
			UnitDamageTarget(damage_table)
			SendOverheadEventMessage(nil,OVERHEAD_ALERT_BONUS_POISON_DAMAGE,Attacker,damage_to_deal,nil)
		end
	end
end

function OnMedicine03TakeDamage(keys)
	local Caster = keys.caster
	local Attacker = keys.attacker
	local damage_to_deal = keys.TakenDamage * keys.BackDamage*0.01
	if (Attacker:IsBuilding()==false) and Attacker ~= Caster and Attacker:HasModifier("modifier_item_frock_OnTakeDamage") == false then
		if (damage_to_deal>0 and damage_to_deal<=Caster:GetMaxHealth()) then
			local damage_table = {
				ability = keys.ability,
				victim = Attacker,
				attacker = Caster,
				damage = damage_to_deal,
				damage_type = DAMAGE_TYPE_MAGICAL,
				damage_flags = 1
			}
			UnitDamageTarget(damage_table)
			SendOverheadEventMessage(nil,OVERHEAD_ALERT_BONUS_POISON_DAMAGE,Attacker,damage_to_deal,nil)
		end
	end
end

function OnMedicine04SpellStart(keys)
	local target = keys.target
	local caster = keys.caster
	THDReduceCooldown(keys.ability,FindTelentValue(caster,"special_bonus_unique_viper_4"))
	if is_spell_blocked(target) then return end
	keys.ability:ApplyDataDrivenModifier(caster, target, "modifier_thdots_medicine04_debuff", {})
	keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_thdots_medicine04_damage", {})
end

function OnMedicine04Start(keys)
	local caster = EntIndexToHScript(keys.caster_entindex)
	local target = keys.target
	local ability = keys.ability
	medicine04={}

	medicine04.caster = caster

	target.Team = target:GetTeam()

	local PlayerId=target:GetPlayerID()
	target:SetTeam(caster:GetTeam())
	target:MoveToPosition(target:GetOrigin())

end

function OnMedicine04Think(keys)
	local target = keys.target
	AddFOWViewer( target.Team, target:GetOrigin(), 700, 0.1, false)
	local targets = FindUnitsInRadius(
				target.Team,	
				target:GetOrigin(),	
				nil,	
				1000,		
				DOTA_UNIT_TARGET_TEAM_FRIENDLY,
				23,
				0, 
				FIND_CLOSEST,
				false
			)	
	for i=1,#targets do 
		if targets[i]~=nil and targets[i]:IsInvisible()==false and targets[i]:GetUnitName()~="npc_reimu_04_dummy_unit" and targets[i]:GetUnitName()~="ability_yuuka_flower" then
			target:MoveToTargetToAttack(targets[i])
			break
		end
	end
end

function OnMedicine04End(keys)
	local target = keys.target
	local caster = keys.caster
	target:SetTeam(target.Team)
	target:MoveToPosition(target:GetOrigin())
end

function OnTargetDealDamage(keys)
	if keys.unit:GetHealth()==0 then
		keys.unit:SetHealth(1)
		keys.unit:Kill( keys.ability, medicine04.caster)
	end	
end