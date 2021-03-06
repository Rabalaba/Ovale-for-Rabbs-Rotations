local OVALE, Ovale = ...
local OvaleScripts = Ovale.OvaleScripts

do
	local name = "icyveins_demonhunter_vengeance"
	local desc = "[7.0] Icy-Veins: DemonHunter Vengeance"
	local code = [[
Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_demonhunter_spells)

AddCheckBox(opt_interrupt L(interrupt) default specialization=vengeance)
AddCheckBox(opt_melee_range L(not_in_melee_range) specialization=vengeance)



AddFunction VengeancePlayDefensively
{
	CheckBoxOn(opt_demonhunter_vengeance_defensive)
}

AddFunction VengeancePlayOffensively
{
	not VengeancePlayDefensively()
}

AddFunction VengeanceHealMe
{
	if (HealthPercent() < 70) Spell(fel_devastation)
	if (HealthPercent() < 70) Spell(soul_cleave)
	if (IncomingDamage(5) >= MaxHealth() * 0.7) Spell(soul_cleave)
}

AddFunction VengeanceDefaultShortCDActions
{
	if (Charges(demon_spikes) == 0 and PainDeficit() >= 60) Spell(demonic_infusion)
	if (Charges(demon_spikes) >= 2) Spell(demon_spikes)
	if ((IncomingDamage(10 physical=1) > 0 or SpellCooldown(demonic_infusion) < 3) and not target.DebuffPresent(fiery_brand_debuff) and BuffExpires(metamorphosis_veng_buff)) Spell(demon_spikes)
	if (Pain() > SpellData(demon_spikes pain) + SpellData(soul_barrier pain)) Spell(soul_barrier)
	if (CheckBoxOn(opt_melee_range) and not target.InRange(shear))
	{
		if (target.InRange(felblade)) Spell(felblade)
		if (target.Distance(less 30) or (target.Distance(less 40) and Talent(abyssal_strike_talent))) Spell(infernal_strike)
		Spell(throw_glaive_veng)
		Texture(misc_arrowlup help=L(not_in_melee_range))
	}
}

AddFunction VengeanceDefaultMainActions
{
	VengeanceHealMe()
	if (VengeancePlayOffensively() and HasArtifactTrait(fiery_demise) and target.TimeToDie() >= 8) Spell(fiery_brand)
	if (VengeancePlayOffensively() or BuffStacks(soul_fragments) <= 2) Spell(soul_carver)
	if (VengeancePlayOffensively()) Spell(fel_devastation)
	if (Pain() >= SpellData(demon_spikes pain) + SpellData(soul_cleave pain) + SpellData(soul_cleave extra_pain) and (not Talent(fracture_talent) or VengeancePlayDefensively())) Spell(soul_cleave)
	Spell(immolation_aura)
	Spell(felblade)
	Spell(fel_eruption)
	if (BuffStacks(soul_fragments) >= 1 and target.DebuffExpires(frailty_debuff)) Spell(spirit_bomb)
	if (BuffPresent(blade_turning_buff)) Spell(shear)
	if (VengeancePlayOffensively() and Pain() >= SpellData(demon_spikes pain) + SpellData(soul_cleave pain) + SpellData(fracture pain)) Spell(fracture)
	if (not SigilCharging(flame) and target.DebuffRemaining(sigil_of_flame_debuff) <= 2-Talent(quickened_sigils_talent))
	{
		if (Talent(flame_crash_talent) and (SpellCharges(infernal_strike) >= SpellMaxCharges(infernal_strike))) Spell(infernal_strike)
		Spell(sigil_of_flame)
	}
	if (not Talent(flame_crash_talent) and (SpellCharges(infernal_strike) >= SpellMaxCharges(infernal_strike))) Spell(infernal_strike)
	Spell(shear)
}

AddFunction VengeanceDefaultAoEActions
{
	VengeanceHealMe()
	if (BuffStacks(soul_fragments) <= 2) Spell(soul_carver)
	if (VengeancePlayOffensively()) Spell(fel_devastation)
	if (Pain() >= SpellData(demon_spikes pain) + SpellData(soul_cleave pain) + SpellData(soul_cleave extra_pain)) Spell(soul_cleave)
	if (Talent(burning_alive_talent) or (VengeancePlayOffensively() and HasArtifactTrait(fiery_demise) and target.TimeToDie() >= 8)) Spell(fiery_brand)
	Spell(immolation_aura)
	if (BuffStacks(soul_fragments) >= 1 and target.DebuffExpires(frailty_debuff)) Spell(spirit_bomb)
	Spell(felblade)
	if (BuffPresent(blade_turning_buff)) Spell(shear)
	if (not SigilCharging(flame) and target.DebuffRemaining(sigil_of_flame_debuff) <= 2-Talent(quickened_sigils_talent))
	{
		if (Talent(flame_crash_talent) and (SpellCharges(infernal_strike) >= SpellMaxCharges(infernal_strike))) Spell(infernal_strike)
		Spell(sigil_of_flame)
	}
	Spell(fel_eruption)
	if (not Talent(flame_crash_talent) and (SpellCharges(infernal_strike) >= SpellMaxCharges(infernal_strike))) Spell(infernal_strike)
	Spell(shear)
}

AddFunction VengeanceDefaultCdActions
{
	VengeanceInterruptActions()
	if IncomingDamage(1.5 magic=1) > 0 Spell(empower_wards)
	Spell(fiery_brand)
	Item(Trinket0Slot usable=1)
	Item(Trinket1Slot usable=1)
	Spell(metamorphosis_veng)
}

AddFunction VengeanceInterruptActions
{
	if CheckBoxOn(opt_interrupt) and not target.IsFriend() and target.IsInterruptible()
	{
		if target.InRange(consume_magic) Spell(consume_magic)
		if not target.Classification(worldboss) and not SigilCharging(silence misery chains)
		{
			if target.Distance(less 8) Spell(arcane_torrent_dh)
			Spell(fel_eruption)
			if (target.RemainingCastTime() >= (2 - Talent(quickened_sigils_talent) + GCDRemaining()))
			{
				Spell(sigil_of_silence)
				Spell(sigil_of_misery)
				Spell(sigil_of_chains)
			}
			if target.CreatureType(Demon) Spell(imprison)
		}
		if target.IsTargetingPlayer() Spell(empower_wards)
	}
}

AddCheckBox(opt_demonhunter_vengeance_defensive L("Play Defensively") default specialization=vengeance)
AddCheckBox(opt_demonhunter_vengeance_aoe L(AOE) default specialization=vengeance)

AddIcon help=shortcd specialization=vengeance
{
	VengeanceDefaultShortCDActions()
}

AddIcon enemies=1 help=main specialization=vengeance
{
	VengeanceDefaultMainActions()
}

AddIcon checkbox=opt_demonhunter_vengeance_aoe help=aoe specialization=vengeance
{
	VengeanceDefaultAoEActions()
}

AddIcon help=cd specialization=vengeance
{
	#if not InCombat() VengeancePrecombatCdActions()
	VengeanceDefaultCdActions()
}
	]]
	OvaleScripts:RegisterScript("DEMONHUNTER", "vengeance", name, desc, code, "script")
end

-- THE REST OF THIS FILE IS AUTOMATICALLY GENERATED.
-- ANY CHANGES MADE BELOW THIS POINT WILL BE LOST.

do
	local name = "simulationcraft_demon_hunter_havoc_t19p"
	local desc = "[7.0] SimulationCraft: Demon_Hunter_Havoc_T19P"
	local code = [[
# Based on SimulationCraft profile "Demon_Hunter_Havoc_T19P".
#	class=demonhunter
#	spec=havoc
#	talents=2220311

Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_demonhunter_spells)


AddFunction pooling_for_meta
{
	if not CheckBoxOn(opt_meta_only_during_boss) or IsBossFight() SpellCooldown(metamorphosis_havoc) == 0 and { not Talent(demonic_talent) or not SpellCooldown(eye_beam) == 0 } and { not Talent(chaos_blades_talent) or SpellCooldown(chaos_blades) == 0 } and { not Talent(nemesis_talent) or target.DebuffPresent(nemesis_debuff) or SpellCooldown(nemesis) == 0 }
}

AddFunction pooling_for_blade_dance
{
	blade_dance() and Fury() - 40 < 35 - TalentPoints(first_blood_talent) * 20 and Enemies() >= 3 + TalentPoints(chaos_cleave_talent) * 2
}

AddFunction pooling_for_chaos_strike
{
	Talent(chaos_cleave_talent) and FuryDeficit() > 40 and not False(raid_event_adds_exists) and 600 < 2 * GCD()
}

AddFunction blade_dance
{
	Talent(first_blood_talent) or Enemies() >= 3 + TalentPoints(chaos_cleave_talent) * 2
}

AddCheckBox(opt_interrupt L(interrupt) default specialization=havoc)
AddCheckBox(opt_melee_range L(not_in_melee_range) specialization=havoc)
AddCheckBox(opt_meta_only_during_boss L(meta_only_during_boss) default specialization=havoc)

AddFunction HavocUseItemActions
{
	Item(Trinket0Slot usable=1)
	Item(Trinket1Slot usable=1)
}

AddFunction HavocInterruptActions
{
	if CheckBoxOn(opt_interrupt) and not target.IsFriend() and target.IsInterruptible()
	{
		if target.InRange(consume_magic) Spell(consume_magic)
		if not target.Classification(worldboss)
		{
			if target.Distance(less 8) Spell(arcane_torrent_dh)
			if target.Distance(less 8) Spell(chaos_nova)
			Spell(fel_eruption)
			if target.CreatureType(Demon) Spell(imprison)
		}
	}
}

AddFunction HavocGetInMeleeRange
{
	if CheckBoxOn(opt_melee_range) and not target.InRange(demons_bite)
	{
		Spell(felblade)
		Texture(misc_arrowlup help=L(not_in_melee_range))
	}
}

### actions.default

AddFunction HavocDefaultMainActions
{
	#call_action_list,name=cooldown
	HavocCooldownMainActions()

	unless HavocCooldownMainPostConditions()
	{
		#fel_rush,animation_cancel=1,if=time=0
		if TimeInCombat() == 0 Spell(fel_rush)
		#pick_up_fragment,if=talent.demonic_appetite.enabled&fury.deficit>=35
		if Talent(demonic_appetite_talent) and FuryDeficit() >= 35 Spell(pick_up_fragment)
		#vengeful_retreat,if=(talent.prepared.enabled|talent.momentum.enabled)&buff.prepared.down&buff.momentum.down
		if { Talent(prepared_talent) or Talent(momentum_talent) } and BuffExpires(prepared_buff) and BuffExpires(momentum_buff) Spell(vengeful_retreat)
		#fel_rush,if=(talent.momentum.enabled|talent.fel_mastery.enabled)&(!talent.momentum.enabled|(charges=2|cooldown.vengeful_retreat.remains>4)&buff.momentum.down)&(!talent.fel_mastery.enabled|fury.deficit>=25)&(charges=2|(raid_event.movement.in>10&raid_event.adds.in>10))
		if { Talent(momentum_talent) or Talent(fel_mastery_talent) } and { not Talent(momentum_talent) or { Charges(fel_rush) == 2 or SpellCooldown(vengeful_retreat) > 4 } and BuffExpires(momentum_buff) } and { not Talent(fel_mastery_talent) or FuryDeficit() >= 25 } and { Charges(fel_rush) == 2 or 600 > 10 and 600 > 10 } Spell(fel_rush)
		#fel_barrage,if=charges>=5&(buff.momentum.up|!talent.momentum.enabled)&((active_enemies>desired_targets&active_enemies>1)|raid_event.adds.in>30)
		if Charges(fel_barrage) >= 5 and { BuffPresent(momentum_buff) or not Talent(momentum_talent) } and { Enemies() > Enemies(tagged=1) and Enemies() > 1 or 600 > 30 } Spell(fel_barrage)
		#throw_glaive,if=talent.bloodlet.enabled&(!talent.momentum.enabled|buff.momentum.up)&charges=2
		if Talent(bloodlet_talent) and { not Talent(momentum_talent) or BuffPresent(momentum_buff) } and Charges(throw_glaive_havoc) == 2 Spell(throw_glaive_havoc)
		#fel_eruption
		Spell(fel_eruption)
		#fury_of_the_illidari,if=(active_enemies>desired_targets&active_enemies>1)|raid_event.adds.in>55&(!talent.momentum.enabled|buff.momentum.up)
		if Enemies() > Enemies(tagged=1) and Enemies() > 1 or 600 > 55 and { not Talent(momentum_talent) or BuffPresent(momentum_buff) } Spell(fury_of_the_illidari)
		#eye_beam,if=talent.demonic.enabled&(talent.demon_blades.enabled|talent.blind_fury.enabled|(!talent.blind_fury.enabled&fury.deficit<30))&((active_enemies>desired_targets&active_enemies>1)|raid_event.adds.in>30)
		if Talent(demonic_talent) and { Talent(demon_blades_talent) or Talent(blind_fury_talent) or not Talent(blind_fury_talent) and FuryDeficit() < 30 } and { Enemies() > Enemies(tagged=1) and Enemies() > 1 or 600 > 30 } Spell(eye_beam)
		#death_sweep,if=variable.blade_dance
		if blade_dance() Spell(death_sweep)
		#blade_dance,if=variable.blade_dance
		if blade_dance() Spell(blade_dance)
		#throw_glaive,if=talent.bloodlet.enabled&spell_targets>=2&(!talent.master_of_the_glaive.enabled|!talent.momentum.enabled|buff.momentum.up)&(spell_targets>=3|raid_event.adds.in>recharge_time+cooldown)
		if Talent(bloodlet_talent) and Enemies() >= 2 and { not Talent(master_of_the_glaive_talent) or not Talent(momentum_talent) or BuffPresent(momentum_buff) } and { Enemies() >= 3 or 600 > SpellChargeCooldown(throw_glaive_havoc) + SpellCooldown(throw_glaive_havoc) } Spell(throw_glaive_havoc)
		#felblade,if=fury.deficit>=30+buff.prepared.up*8
		if FuryDeficit() >= 30 + BuffPresent(prepared_buff) * 8 Spell(felblade)
		#eye_beam,if=talent.blind_fury.enabled&(spell_targets.eye_beam_tick>desired_targets|fury.deficit>=35)
		if Talent(blind_fury_talent) and { Enemies() > Enemies(tagged=1) or FuryDeficit() >= 35 } Spell(eye_beam)
		#annihilation,if=(talent.demon_blades.enabled|!talent.momentum.enabled|buff.momentum.up|fury.deficit<30+buff.prepared.up*8|buff.metamorphosis.remains<5)&!variable.pooling_for_blade_dance
		if { Talent(demon_blades_talent) or not Talent(momentum_talent) or BuffPresent(momentum_buff) or FuryDeficit() < 30 + BuffPresent(prepared_buff) * 8 or BuffRemaining(metamorphosis_havoc_buff) < 5 } and not pooling_for_blade_dance() Spell(annihilation)
		#throw_glaive,if=talent.bloodlet.enabled&(!talent.master_of_the_glaive.enabled|!talent.momentum.enabled|buff.momentum.up)&raid_event.adds.in>recharge_time+cooldown
		if Talent(bloodlet_talent) and { not Talent(master_of_the_glaive_talent) or not Talent(momentum_talent) or BuffPresent(momentum_buff) } and 600 > SpellChargeCooldown(throw_glaive_havoc) + SpellCooldown(throw_glaive_havoc) Spell(throw_glaive_havoc)
		#eye_beam,if=!talent.demonic.enabled&!talent.blind_fury.enabled&((spell_targets.eye_beam_tick>desired_targets&active_enemies>1)|(raid_event.adds.in>45&!variable.pooling_for_meta&buff.metamorphosis.down&(artifact.anguish_of_the_deceiver.enabled|active_enemies>1)&!talent.chaos_cleave.enabled))
		if not Talent(demonic_talent) and not Talent(blind_fury_talent) and { Enemies() > Enemies(tagged=1) and Enemies() > 1 or 600 > 45 and not pooling_for_meta() and BuffExpires(metamorphosis_havoc_buff) and { HasArtifactTrait(anguish_of_the_deceiver) or Enemies() > 1 } and not Talent(chaos_cleave_talent) } Spell(eye_beam)
		#demons_bite,if=talent.demonic.enabled&!talent.blind_fury.enabled&buff.metamorphosis.down&cooldown.eye_beam.remains<gcd&fury.deficit>=20
		if Talent(demonic_talent) and not Talent(blind_fury_talent) and BuffExpires(metamorphosis_havoc_buff) and SpellCooldown(eye_beam) < GCD() and FuryDeficit() >= 20 Spell(demons_bite)
		#demons_bite,if=talent.demonic.enabled&!talent.blind_fury.enabled&buff.metamorphosis.down&cooldown.eye_beam.remains<2*gcd&fury.deficit>=45
		if Talent(demonic_talent) and not Talent(blind_fury_talent) and BuffExpires(metamorphosis_havoc_buff) and SpellCooldown(eye_beam) < 2 * GCD() and FuryDeficit() >= 45 Spell(demons_bite)
		#throw_glaive,if=buff.metamorphosis.down&spell_targets>=2
		if BuffExpires(metamorphosis_havoc_buff) and Enemies() >= 2 Spell(throw_glaive_havoc)
		#chaos_strike,if=(talent.demon_blades.enabled|!talent.momentum.enabled|buff.momentum.up|fury.deficit<30+buff.prepared.up*8)&!variable.pooling_for_chaos_strike&!variable.pooling_for_meta&!variable.pooling_for_blade_dance&(!talent.demonic.enabled|!cooldown.eye_beam.ready|(talent.blind_fury.enabled&fury.deficit<35))
		if { Talent(demon_blades_talent) or not Talent(momentum_talent) or BuffPresent(momentum_buff) or FuryDeficit() < 30 + BuffPresent(prepared_buff) * 8 } and not pooling_for_chaos_strike() and not pooling_for_meta() and not pooling_for_blade_dance() and { not Talent(demonic_talent) or not SpellCooldown(eye_beam) == 0 or Talent(blind_fury_talent) and FuryDeficit() < 35 } Spell(chaos_strike)
		#fel_barrage,if=charges=4&buff.metamorphosis.down&(buff.momentum.up|!talent.momentum.enabled)&((active_enemies>desired_targets&active_enemies>1)|raid_event.adds.in>30)
		if Charges(fel_barrage) == 4 and BuffExpires(metamorphosis_havoc_buff) and { BuffPresent(momentum_buff) or not Talent(momentum_talent) } and { Enemies() > Enemies(tagged=1) and Enemies() > 1 or 600 > 30 } Spell(fel_barrage)
		#fel_rush,if=!talent.momentum.enabled&raid_event.movement.in>charges*10
		if not Talent(momentum_talent) and 600 > Charges(fel_rush) * 10 Spell(fel_rush)
		#demons_bite
		Spell(demons_bite)
		#throw_glaive,if=buff.out_of_range.up
		if not target.InRange() Spell(throw_glaive_havoc)
		#felblade,if=movement.distance|buff.out_of_range.up
		if target.Distance() or not target.InRange() Spell(felblade)
		#fel_rush,if=movement.distance>15|(buff.out_of_range.up&!talent.momentum.enabled)
		if target.Distance() > 15 or not target.InRange() and not Talent(momentum_talent) Spell(fel_rush)
		#vengeful_retreat,if=movement.distance>15
		if target.Distance() > 15 Spell(vengeful_retreat)
		#throw_glaive,if=!talent.bloodlet.enabled
		if not Talent(bloodlet_talent) Spell(throw_glaive_havoc)
	}
}

AddFunction HavocDefaultMainPostConditions
{
	HavocCooldownMainPostConditions()
}

AddFunction HavocDefaultShortCdActions
{
	#auto_attack
	HavocGetInMeleeRange()
	#variable,name=pooling_for_meta,value=cooldown.metamorphosis.ready&(!talent.demonic.enabled|!cooldown.eye_beam.ready)&(!talent.chaos_blades.enabled|cooldown.chaos_blades.ready)&(!talent.nemesis.enabled|debuff.nemesis.up|cooldown.nemesis.ready)
	#variable,name=blade_dance,value=talent.first_blood.enabled|spell_targets.blade_dance1>=3+(talent.chaos_cleave.enabled*2)
	#variable,name=pooling_for_blade_dance,value=variable.blade_dance&fury-40<35-talent.first_blood.enabled*20&(spell_targets.blade_dance1>=3+(talent.chaos_cleave.enabled*2))
	#variable,name=pooling_for_chaos_strike,value=talent.chaos_cleave.enabled&fury.deficit>40&!raid_event.adds.up&raid_event.adds.in<2*gcd
	#blur,if=artifact.demon_speed.enabled&cooldown.fel_rush.charges_fractional<0.5&cooldown.vengeful_retreat.remains-buff.momentum.remains>4
	if HasArtifactTrait(demon_speed) and SpellCharges(fel_rush count=0) < 0.5 and SpellCooldown(vengeful_retreat) - BuffRemaining(momentum_buff) > 4 Spell(blur)
	#call_action_list,name=cooldown
	HavocCooldownShortCdActions()
}

AddFunction HavocDefaultShortCdPostConditions
{
	HavocCooldownShortCdPostConditions() or TimeInCombat() == 0 and Spell(fel_rush) or Talent(demonic_appetite_talent) and FuryDeficit() >= 35 and Spell(pick_up_fragment) or { Talent(prepared_talent) or Talent(momentum_talent) } and BuffExpires(prepared_buff) and BuffExpires(momentum_buff) and Spell(vengeful_retreat) or { Talent(momentum_talent) or Talent(fel_mastery_talent) } and { not Talent(momentum_talent) or { Charges(fel_rush) == 2 or SpellCooldown(vengeful_retreat) > 4 } and BuffExpires(momentum_buff) } and { not Talent(fel_mastery_talent) or FuryDeficit() >= 25 } and { Charges(fel_rush) == 2 or 600 > 10 and 600 > 10 } and Spell(fel_rush) or Charges(fel_barrage) >= 5 and { BuffPresent(momentum_buff) or not Talent(momentum_talent) } and { Enemies() > Enemies(tagged=1) and Enemies() > 1 or 600 > 30 } and Spell(fel_barrage) or Talent(bloodlet_talent) and { not Talent(momentum_talent) or BuffPresent(momentum_buff) } and Charges(throw_glaive_havoc) == 2 and Spell(throw_glaive_havoc) or Spell(fel_eruption) or { Enemies() > Enemies(tagged=1) and Enemies() > 1 or 600 > 55 and { not Talent(momentum_talent) or BuffPresent(momentum_buff) } } and Spell(fury_of_the_illidari) or Talent(demonic_talent) and { Talent(demon_blades_talent) or Talent(blind_fury_talent) or not Talent(blind_fury_talent) and FuryDeficit() < 30 } and { Enemies() > Enemies(tagged=1) and Enemies() > 1 or 600 > 30 } and Spell(eye_beam) or blade_dance() and Spell(death_sweep) or blade_dance() and Spell(blade_dance) or Talent(bloodlet_talent) and Enemies() >= 2 and { not Talent(master_of_the_glaive_talent) or not Talent(momentum_talent) or BuffPresent(momentum_buff) } and { Enemies() >= 3 or 600 > SpellChargeCooldown(throw_glaive_havoc) + SpellCooldown(throw_glaive_havoc) } and Spell(throw_glaive_havoc) or FuryDeficit() >= 30 + BuffPresent(prepared_buff) * 8 and Spell(felblade) or Talent(blind_fury_talent) and { Enemies() > Enemies(tagged=1) or FuryDeficit() >= 35 } and Spell(eye_beam) or { Talent(demon_blades_talent) or not Talent(momentum_talent) or BuffPresent(momentum_buff) or FuryDeficit() < 30 + BuffPresent(prepared_buff) * 8 or BuffRemaining(metamorphosis_havoc_buff) < 5 } and not pooling_for_blade_dance() and Spell(annihilation) or Talent(bloodlet_talent) and { not Talent(master_of_the_glaive_talent) or not Talent(momentum_talent) or BuffPresent(momentum_buff) } and 600 > SpellChargeCooldown(throw_glaive_havoc) + SpellCooldown(throw_glaive_havoc) and Spell(throw_glaive_havoc) or not Talent(demonic_talent) and not Talent(blind_fury_talent) and { Enemies() > Enemies(tagged=1) and Enemies() > 1 or 600 > 45 and not pooling_for_meta() and BuffExpires(metamorphosis_havoc_buff) and { HasArtifactTrait(anguish_of_the_deceiver) or Enemies() > 1 } and not Talent(chaos_cleave_talent) } and Spell(eye_beam) or Talent(demonic_talent) and not Talent(blind_fury_talent) and BuffExpires(metamorphosis_havoc_buff) and SpellCooldown(eye_beam) < GCD() and FuryDeficit() >= 20 and Spell(demons_bite) or Talent(demonic_talent) and not Talent(blind_fury_talent) and BuffExpires(metamorphosis_havoc_buff) and SpellCooldown(eye_beam) < 2 * GCD() and FuryDeficit() >= 45 and Spell(demons_bite) or BuffExpires(metamorphosis_havoc_buff) and Enemies() >= 2 and Spell(throw_glaive_havoc) or { Talent(demon_blades_talent) or not Talent(momentum_talent) or BuffPresent(momentum_buff) or FuryDeficit() < 30 + BuffPresent(prepared_buff) * 8 } and not pooling_for_chaos_strike() and not pooling_for_meta() and not pooling_for_blade_dance() and { not Talent(demonic_talent) or not SpellCooldown(eye_beam) == 0 or Talent(blind_fury_talent) and FuryDeficit() < 35 } and Spell(chaos_strike) or Charges(fel_barrage) == 4 and BuffExpires(metamorphosis_havoc_buff) and { BuffPresent(momentum_buff) or not Talent(momentum_talent) } and { Enemies() > Enemies(tagged=1) and Enemies() > 1 or 600 > 30 } and Spell(fel_barrage) or not Talent(momentum_talent) and 600 > Charges(fel_rush) * 10 and Spell(fel_rush) or Spell(demons_bite) or not target.InRange() and Spell(throw_glaive_havoc) or { target.Distance() or not target.InRange() } and Spell(felblade) or { target.Distance() > 15 or not target.InRange() and not Talent(momentum_talent) } and Spell(fel_rush) or target.Distance() > 15 and Spell(vengeful_retreat) or not Talent(bloodlet_talent) and Spell(throw_glaive_havoc)
}

AddFunction HavocDefaultCdActions
{
	unless HasArtifactTrait(demon_speed) and SpellCharges(fel_rush count=0) < 0.5 and SpellCooldown(vengeful_retreat) - BuffRemaining(momentum_buff) > 4 and Spell(blur)
	{
		#call_action_list,name=cooldown
		HavocCooldownCdActions()

		unless HavocCooldownCdPostConditions() or TimeInCombat() == 0 and Spell(fel_rush) or Talent(demonic_appetite_talent) and FuryDeficit() >= 35 and Spell(pick_up_fragment)
		{
			#consume_magic
			HavocInterruptActions()
		}
	}
}

AddFunction HavocDefaultCdPostConditions
{
	HasArtifactTrait(demon_speed) and SpellCharges(fel_rush count=0) < 0.5 and SpellCooldown(vengeful_retreat) - BuffRemaining(momentum_buff) > 4 and Spell(blur) or HavocCooldownCdPostConditions() or TimeInCombat() == 0 and Spell(fel_rush) or Talent(demonic_appetite_talent) and FuryDeficit() >= 35 and Spell(pick_up_fragment) or { Talent(prepared_talent) or Talent(momentum_talent) } and BuffExpires(prepared_buff) and BuffExpires(momentum_buff) and Spell(vengeful_retreat) or { Talent(momentum_talent) or Talent(fel_mastery_talent) } and { not Talent(momentum_talent) or { Charges(fel_rush) == 2 or SpellCooldown(vengeful_retreat) > 4 } and BuffExpires(momentum_buff) } and { not Talent(fel_mastery_talent) or FuryDeficit() >= 25 } and { Charges(fel_rush) == 2 or 600 > 10 and 600 > 10 } and Spell(fel_rush) or Charges(fel_barrage) >= 5 and { BuffPresent(momentum_buff) or not Talent(momentum_talent) } and { Enemies() > Enemies(tagged=1) and Enemies() > 1 or 600 > 30 } and Spell(fel_barrage) or Talent(bloodlet_talent) and { not Talent(momentum_talent) or BuffPresent(momentum_buff) } and Charges(throw_glaive_havoc) == 2 and Spell(throw_glaive_havoc) or Spell(fel_eruption) or { Enemies() > Enemies(tagged=1) and Enemies() > 1 or 600 > 55 and { not Talent(momentum_talent) or BuffPresent(momentum_buff) } } and Spell(fury_of_the_illidari) or Talent(demonic_talent) and { Talent(demon_blades_talent) or Talent(blind_fury_talent) or not Talent(blind_fury_talent) and FuryDeficit() < 30 } and { Enemies() > Enemies(tagged=1) and Enemies() > 1 or 600 > 30 } and Spell(eye_beam) or blade_dance() and Spell(death_sweep) or blade_dance() and Spell(blade_dance) or Talent(bloodlet_talent) and Enemies() >= 2 and { not Talent(master_of_the_glaive_talent) or not Talent(momentum_talent) or BuffPresent(momentum_buff) } and { Enemies() >= 3 or 600 > SpellChargeCooldown(throw_glaive_havoc) + SpellCooldown(throw_glaive_havoc) } and Spell(throw_glaive_havoc) or FuryDeficit() >= 30 + BuffPresent(prepared_buff) * 8 and Spell(felblade) or Talent(blind_fury_talent) and { Enemies() > Enemies(tagged=1) or FuryDeficit() >= 35 } and Spell(eye_beam) or { Talent(demon_blades_talent) or not Talent(momentum_talent) or BuffPresent(momentum_buff) or FuryDeficit() < 30 + BuffPresent(prepared_buff) * 8 or BuffRemaining(metamorphosis_havoc_buff) < 5 } and not pooling_for_blade_dance() and Spell(annihilation) or Talent(bloodlet_talent) and { not Talent(master_of_the_glaive_talent) or not Talent(momentum_talent) or BuffPresent(momentum_buff) } and 600 > SpellChargeCooldown(throw_glaive_havoc) + SpellCooldown(throw_glaive_havoc) and Spell(throw_glaive_havoc) or not Talent(demonic_talent) and not Talent(blind_fury_talent) and { Enemies() > Enemies(tagged=1) and Enemies() > 1 or 600 > 45 and not pooling_for_meta() and BuffExpires(metamorphosis_havoc_buff) and { HasArtifactTrait(anguish_of_the_deceiver) or Enemies() > 1 } and not Talent(chaos_cleave_talent) } and Spell(eye_beam) or Talent(demonic_talent) and not Talent(blind_fury_talent) and BuffExpires(metamorphosis_havoc_buff) and SpellCooldown(eye_beam) < GCD() and FuryDeficit() >= 20 and Spell(demons_bite) or Talent(demonic_talent) and not Talent(blind_fury_talent) and BuffExpires(metamorphosis_havoc_buff) and SpellCooldown(eye_beam) < 2 * GCD() and FuryDeficit() >= 45 and Spell(demons_bite) or BuffExpires(metamorphosis_havoc_buff) and Enemies() >= 2 and Spell(throw_glaive_havoc) or { Talent(demon_blades_talent) or not Talent(momentum_talent) or BuffPresent(momentum_buff) or FuryDeficit() < 30 + BuffPresent(prepared_buff) * 8 } and not pooling_for_chaos_strike() and not pooling_for_meta() and not pooling_for_blade_dance() and { not Talent(demonic_talent) or not SpellCooldown(eye_beam) == 0 or Talent(blind_fury_talent) and FuryDeficit() < 35 } and Spell(chaos_strike) or Charges(fel_barrage) == 4 and BuffExpires(metamorphosis_havoc_buff) and { BuffPresent(momentum_buff) or not Talent(momentum_talent) } and { Enemies() > Enemies(tagged=1) and Enemies() > 1 or 600 > 30 } and Spell(fel_barrage) or not Talent(momentum_talent) and 600 > Charges(fel_rush) * 10 and Spell(fel_rush) or Spell(demons_bite) or not target.InRange() and Spell(throw_glaive_havoc) or { target.Distance() or not target.InRange() } and Spell(felblade) or { target.Distance() > 15 or not target.InRange() and not Talent(momentum_talent) } and Spell(fel_rush) or target.Distance() > 15 and Spell(vengeful_retreat) or not Talent(bloodlet_talent) and Spell(throw_glaive_havoc)
}

### actions.cooldown

AddFunction HavocCooldownMainActions
{
}

AddFunction HavocCooldownMainPostConditions
{
}

AddFunction HavocCooldownShortCdActions
{
}

AddFunction HavocCooldownShortCdPostConditions
{
}

AddFunction HavocCooldownCdActions
{
	#use_item,slot=trinket2,if=buff.chaos_blades.up|!talent.chaos_blades.enabled
	if BuffPresent(chaos_blades_buff) or not Talent(chaos_blades_talent) HavocUseItemActions()
	#nemesis,target_if=min:target.time_to_die,if=raid_event.adds.exists&debuff.nemesis.down&((active_enemies>desired_targets&active_enemies>1)|raid_event.adds.in>60)
	if False(raid_event_adds_exists) and target.DebuffExpires(nemesis_debuff) and { Enemies() > Enemies(tagged=1) and Enemies() > 1 or 600 > 60 } Spell(nemesis)
	#nemesis,if=!raid_event.adds.exists&(cooldown.metamorphosis.remains>100|target.time_to_die<70)
	if not False(raid_event_adds_exists) and { SpellCooldown(metamorphosis_havoc) > 100 or target.TimeToDie() < 70 } Spell(nemesis)
	#nemesis,sync=metamorphosis,if=!raid_event.adds.exists
	if not { Talent(demon_reborn_talent) and Talent(demonic_talent) } and Spell(metamorphosis_havoc) and not False(raid_event_adds_exists) Spell(nemesis)
	#chaos_blades,if=buff.metamorphosis.up|cooldown.metamorphosis.remains>100|target.time_to_die<20
	if BuffPresent(metamorphosis_havoc_buff) or SpellCooldown(metamorphosis_havoc) > 100 or target.TimeToDie() < 20 Spell(chaos_blades)
	#metamorphosis,if=variable.pooling_for_meta&fury.deficit<30
	if pooling_for_meta() and FuryDeficit() < 30 Spell(metamorphosis_havoc)
}

AddFunction HavocCooldownCdPostConditions
{
}

### actions.precombat

AddFunction HavocPrecombatMainActions
{
	#flask,type=flask_of_the_seventh_demon
	#food,type=nightborne_delicacy_platter
	#augmentation,type=defiled
	Spell(augmentation)
}

AddFunction HavocPrecombatMainPostConditions
{
}

AddFunction HavocPrecombatShortCdActions
{
}

AddFunction HavocPrecombatShortCdPostConditions
{
	Spell(augmentation)
}

AddFunction HavocPrecombatCdActions
{
	unless Spell(augmentation)
	{
		#snapshot_stats
		#potion,name=old_war
		#metamorphosis,if=!(talent.demon_reborn.enabled&talent.demonic.enabled)
		if not { Talent(demon_reborn_talent) and Talent(demonic_talent) } Spell(metamorphosis_havoc)
	}
}

AddFunction HavocPrecombatCdPostConditions
{
	Spell(augmentation)
}

### Havoc icons.

AddCheckBox(opt_demonhunter_havoc_aoe L(AOE) default specialization=havoc)

AddIcon checkbox=!opt_demonhunter_havoc_aoe enemies=1 help=shortcd specialization=havoc
{
	if not InCombat() HavocPrecombatShortCdActions()
	unless not InCombat() and HavocPrecombatShortCdPostConditions()
	{
		HavocDefaultShortCdActions()
	}
}

AddIcon checkbox=opt_demonhunter_havoc_aoe help=shortcd specialization=havoc
{
	if not InCombat() HavocPrecombatShortCdActions()
	unless not InCombat() and HavocPrecombatShortCdPostConditions()
	{
		HavocDefaultShortCdActions()
	}
}

AddIcon enemies=1 help=main specialization=havoc
{
	if not InCombat() HavocPrecombatMainActions()
	unless not InCombat() and HavocPrecombatMainPostConditions()
	{
		HavocDefaultMainActions()
	}
}

AddIcon checkbox=opt_demonhunter_havoc_aoe help=aoe specialization=havoc
{
	if not InCombat() HavocPrecombatMainActions()
	unless not InCombat() and HavocPrecombatMainPostConditions()
	{
		HavocDefaultMainActions()
	}
}

AddIcon checkbox=!opt_demonhunter_havoc_aoe enemies=1 help=cd specialization=havoc
{
	if not InCombat() HavocPrecombatCdActions()
	unless not InCombat() and HavocPrecombatCdPostConditions()
	{
		HavocDefaultCdActions()
	}
}

AddIcon checkbox=opt_demonhunter_havoc_aoe help=cd specialization=havoc
{
	if not InCombat() HavocPrecombatCdActions()
	unless not InCombat() and HavocPrecombatCdPostConditions()
	{
		HavocDefaultCdActions()
	}
}

### Required symbols
# anguish_of_the_deceiver
# annihilation
# arcane_torrent_dh
# augmentation
# blade_dance
# blind_fury_talent
# bloodlet_talent
# blur
# chaos_blades
# chaos_blades_buff
# chaos_blades_talent
# chaos_cleave_talent
# chaos_strike
# consume_magic
# death_sweep
# demon_blades_talent
# demon_reborn_talent
# demon_speed
# demonic_appetite_talent
# demonic_talent
# demons_bite
# eye_beam
# fel_barrage
# fel_eruption
# fel_mastery_talent
# fel_rush
# felblade
# first_blood_talent
# fury_of_the_illidari
# imprison
# master_of_the_glaive_talent
# metamorphosis_havoc
# metamorphosis_havoc_buff
# momentum_buff
# momentum_talent
# nemesis
# nemesis_debuff
# nemesis_talent
# pick_up_fragment
# prepared_buff
# prepared_talent
# throw_glaive_havoc
# vengeful_retreat
]]
	OvaleScripts:RegisterScript("DEMONHUNTER", "havoc", name, desc, code, "script")
end

do
	local name = "simulationcraft_demon_hunter_vengeance_t19p"
	local desc = "[7.0] SimulationCraft: Demon_Hunter_Vengeance_T19P"
	local code = [[
# Based on SimulationCraft profile "Demon_Hunter_Vengeance_T19P".
#	class=demonhunter
#	spec=vengeance
#	talents=3323313

Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_demonhunter_spells)

AddCheckBox(opt_interrupt L(interrupt) default specialization=vengeance)
AddCheckBox(opt_melee_range L(not_in_melee_range) specialization=vengeance)

AddFunction VengeanceUseItemActions
{
	Item(Trinket0Slot usable=1)
	Item(Trinket1Slot usable=1)
}

AddFunction VengeanceInterruptActions
{
	if CheckBoxOn(opt_interrupt) and not target.IsFriend() and target.IsInterruptible()
	{
		if target.InRange(consume_magic) Spell(consume_magic)
		if not target.Classification(worldboss)
		{
			unless SigilCharging(silence misery chains)
			{
				if target.RemainingCastTime() >= 2 or target.RemainingCastTime() >= 1 and Talent(quickened_sigils_talent) Spell(sigil_of_silence)
				if target.Distance(less 8) Spell(arcane_torrent_dh)
				Spell(sigil_of_misery)
				Spell(fel_eruption)
				if target.CreatureType(Demon) Spell(imprison)
				Spell(sigil_of_chains)
				if target.IsTargetingPlayer() Spell(empower_wards)
			}
		}
	}
}

AddFunction VengeanceGetInMeleeRange
{
	if CheckBoxOn(opt_melee_range) and not target.InRange(shear) Texture(misc_arrowlup help=L(not_in_melee_range))
}

### actions.default

AddFunction VengeanceDefaultMainActions
{
	#infernal_strike,if=!sigil_placed&!in_flight&remains-travel_time-delay<0.3*duration&artifact.fiery_demise.enabled&dot.fiery_brand.ticking
	if not SigilCharging(flame) and not InFlightToTarget(infernal_strike) and target.DebuffRemaining(infernal_strike_debuff) - TravelTime(infernal_strike) - 0 < 0.3 * BaseDuration(infernal_strike_debuff) and HasArtifactTrait(fiery_demise) and target.DebuffPresent(fiery_brand_debuff) Spell(infernal_strike)
	#infernal_strike,if=!sigil_placed&!in_flight&remains-travel_time-delay<0.3*duration&(!artifact.fiery_demise.enabled|(max_charges-charges_fractional)*recharge_time<cooldown.fiery_brand.remains+5)&(cooldown.sigil_of_flame.remains>7|charges=2)
	if not SigilCharging(flame) and not InFlightToTarget(infernal_strike) and target.DebuffRemaining(infernal_strike_debuff) - TravelTime(infernal_strike) - 0 < 0.3 * BaseDuration(infernal_strike_debuff) and { not HasArtifactTrait(fiery_demise) or { SpellMaxCharges(infernal_strike) - Charges(infernal_strike count=0) } * SpellChargeCooldown(infernal_strike) < SpellCooldown(fiery_brand) + 5 } and { SpellCooldown(sigil_of_flame) > 7 or Charges(infernal_strike) == 2 } Spell(infernal_strike)
	#spirit_bomb,if=debuff.frailty.down
	if target.DebuffExpires(frailty_debuff) Spell(spirit_bomb)
	#soul_carver,if=dot.fiery_brand.ticking
	if target.DebuffPresent(fiery_brand_debuff) Spell(soul_carver)
	#immolation_aura,if=pain<=80
	if Pain() <= 80 Spell(immolation_aura)
	#felblade,if=pain<=70
	if Pain() <= 70 Spell(felblade)
	#soul_barrier
	Spell(soul_barrier)
	#soul_cleave,if=soul_fragments=5
	if BuffStacks(soul_fragments) == 5 Spell(soul_cleave)
	#soul_cleave,if=incoming_damage_5s>=health.max*0.70
	if IncomingDamage(5) >= MaxHealth() * 0.7 Spell(soul_cleave)
	#fel_eruption
	Spell(fel_eruption)
	#sigil_of_flame,if=remains-delay<=0.3*duration
	if target.DebuffRemaining(sigil_of_flame_debuff) - 0 <= 0.3 * BaseDuration(sigil_of_flame_debuff) Spell(sigil_of_flame)
	#fracture,if=pain>=80&soul_fragments<4&incoming_damage_4s<=health.max*0.20
	if Pain() >= 80 and BuffStacks(soul_fragments) < 4 and IncomingDamage(4) <= MaxHealth() * 0.2 Spell(fracture)
	#soul_cleave,if=pain>=80
	if Pain() >= 80 Spell(soul_cleave)
	#shear
	Spell(shear)
}

AddFunction VengeanceDefaultMainPostConditions
{
}

AddFunction VengeanceDefaultShortCdActions
{
	#auto_attack
	VengeanceGetInMeleeRange()
	#demon_spikes,if=charges=2|buff.demon_spikes.down&!dot.fiery_brand.ticking&buff.metamorphosis.down
	if Charges(demon_spikes) == 2 or BuffExpires(demon_spikes_buff) and not target.DebuffPresent(fiery_brand_debuff) and BuffExpires(metamorphosis_veng_buff) Spell(demon_spikes)

	unless not SigilCharging(flame) and not InFlightToTarget(infernal_strike) and target.DebuffRemaining(infernal_strike_debuff) - TravelTime(infernal_strike) - 0 < 0.3 * BaseDuration(infernal_strike_debuff) and HasArtifactTrait(fiery_demise) and target.DebuffPresent(fiery_brand_debuff) and Spell(infernal_strike) or not SigilCharging(flame) and not InFlightToTarget(infernal_strike) and target.DebuffRemaining(infernal_strike_debuff) - TravelTime(infernal_strike) - 0 < 0.3 * BaseDuration(infernal_strike_debuff) and { not HasArtifactTrait(fiery_demise) or { SpellMaxCharges(infernal_strike) - Charges(infernal_strike count=0) } * SpellChargeCooldown(infernal_strike) < SpellCooldown(fiery_brand) + 5 } and { SpellCooldown(sigil_of_flame) > 7 or Charges(infernal_strike) == 2 } and Spell(infernal_strike) or target.DebuffExpires(frailty_debuff) and Spell(spirit_bomb) or target.DebuffPresent(fiery_brand_debuff) and Spell(soul_carver) or Pain() <= 80 and Spell(immolation_aura) or Pain() <= 70 and Spell(felblade) or Spell(soul_barrier) or BuffStacks(soul_fragments) == 5 and Spell(soul_cleave)
	{
		#fel_devastation,if=incoming_damage_5s>health.max*0.70
		if IncomingDamage(5) > MaxHealth() * 0.7 Spell(fel_devastation)
	}
}

AddFunction VengeanceDefaultShortCdPostConditions
{
	not SigilCharging(flame) and not InFlightToTarget(infernal_strike) and target.DebuffRemaining(infernal_strike_debuff) - TravelTime(infernal_strike) - 0 < 0.3 * BaseDuration(infernal_strike_debuff) and HasArtifactTrait(fiery_demise) and target.DebuffPresent(fiery_brand_debuff) and Spell(infernal_strike) or not SigilCharging(flame) and not InFlightToTarget(infernal_strike) and target.DebuffRemaining(infernal_strike_debuff) - TravelTime(infernal_strike) - 0 < 0.3 * BaseDuration(infernal_strike_debuff) and { not HasArtifactTrait(fiery_demise) or { SpellMaxCharges(infernal_strike) - Charges(infernal_strike count=0) } * SpellChargeCooldown(infernal_strike) < SpellCooldown(fiery_brand) + 5 } and { SpellCooldown(sigil_of_flame) > 7 or Charges(infernal_strike) == 2 } and Spell(infernal_strike) or target.DebuffExpires(frailty_debuff) and Spell(spirit_bomb) or target.DebuffPresent(fiery_brand_debuff) and Spell(soul_carver) or Pain() <= 80 and Spell(immolation_aura) or Pain() <= 70 and Spell(felblade) or Spell(soul_barrier) or BuffStacks(soul_fragments) == 5 and Spell(soul_cleave) or IncomingDamage(5) >= MaxHealth() * 0.7 and Spell(soul_cleave) or Spell(fel_eruption) or target.DebuffRemaining(sigil_of_flame_debuff) - 0 <= 0.3 * BaseDuration(sigil_of_flame_debuff) and Spell(sigil_of_flame) or Pain() >= 80 and BuffStacks(soul_fragments) < 4 and IncomingDamage(4) <= MaxHealth() * 0.2 and Spell(fracture) or Pain() >= 80 and Spell(soul_cleave) or Spell(shear)
}

AddFunction VengeanceDefaultCdActions
{
	#consume_magic
	VengeanceInterruptActions()
	#use_item,slot=trinket2
	VengeanceUseItemActions()
	#fiery_brand,if=buff.demon_spikes.down&buff.metamorphosis.down
	if BuffExpires(demon_spikes_buff) and BuffExpires(metamorphosis_veng_buff) Spell(fiery_brand)

	unless { Charges(demon_spikes) == 2 or BuffExpires(demon_spikes_buff) and not target.DebuffPresent(fiery_brand_debuff) and BuffExpires(metamorphosis_veng_buff) } and Spell(demon_spikes)
	{
		#empower_wards,if=debuff.casting.up
		if target.IsInterruptible() Spell(empower_wards)

		unless not SigilCharging(flame) and not InFlightToTarget(infernal_strike) and target.DebuffRemaining(infernal_strike_debuff) - TravelTime(infernal_strike) - 0 < 0.3 * BaseDuration(infernal_strike_debuff) and HasArtifactTrait(fiery_demise) and target.DebuffPresent(fiery_brand_debuff) and Spell(infernal_strike) or not SigilCharging(flame) and not InFlightToTarget(infernal_strike) and target.DebuffRemaining(infernal_strike_debuff) - TravelTime(infernal_strike) - 0 < 0.3 * BaseDuration(infernal_strike_debuff) and { not HasArtifactTrait(fiery_demise) or { SpellMaxCharges(infernal_strike) - Charges(infernal_strike count=0) } * SpellChargeCooldown(infernal_strike) < SpellCooldown(fiery_brand) + 5 } and { SpellCooldown(sigil_of_flame) > 7 or Charges(infernal_strike) == 2 } and Spell(infernal_strike) or target.DebuffExpires(frailty_debuff) and Spell(spirit_bomb) or target.DebuffPresent(fiery_brand_debuff) and Spell(soul_carver) or Pain() <= 80 and Spell(immolation_aura) or Pain() <= 70 and Spell(felblade) or Spell(soul_barrier) or BuffStacks(soul_fragments) == 5 and Spell(soul_cleave)
		{
			#metamorphosis,if=buff.demon_spikes.down&!dot.fiery_brand.ticking&buff.metamorphosis.down&incoming_damage_5s>health.max*0.70
			if BuffExpires(demon_spikes_buff) and not target.DebuffPresent(fiery_brand_debuff) and BuffExpires(metamorphosis_veng_buff) and IncomingDamage(5) > MaxHealth() * 0.7 Spell(metamorphosis_veng)
		}
	}
}

AddFunction VengeanceDefaultCdPostConditions
{
	{ Charges(demon_spikes) == 2 or BuffExpires(demon_spikes_buff) and not target.DebuffPresent(fiery_brand_debuff) and BuffExpires(metamorphosis_veng_buff) } and Spell(demon_spikes) or not SigilCharging(flame) and not InFlightToTarget(infernal_strike) and target.DebuffRemaining(infernal_strike_debuff) - TravelTime(infernal_strike) - 0 < 0.3 * BaseDuration(infernal_strike_debuff) and HasArtifactTrait(fiery_demise) and target.DebuffPresent(fiery_brand_debuff) and Spell(infernal_strike) or not SigilCharging(flame) and not InFlightToTarget(infernal_strike) and target.DebuffRemaining(infernal_strike_debuff) - TravelTime(infernal_strike) - 0 < 0.3 * BaseDuration(infernal_strike_debuff) and { not HasArtifactTrait(fiery_demise) or { SpellMaxCharges(infernal_strike) - Charges(infernal_strike count=0) } * SpellChargeCooldown(infernal_strike) < SpellCooldown(fiery_brand) + 5 } and { SpellCooldown(sigil_of_flame) > 7 or Charges(infernal_strike) == 2 } and Spell(infernal_strike) or target.DebuffExpires(frailty_debuff) and Spell(spirit_bomb) or target.DebuffPresent(fiery_brand_debuff) and Spell(soul_carver) or Pain() <= 80 and Spell(immolation_aura) or Pain() <= 70 and Spell(felblade) or Spell(soul_barrier) or BuffStacks(soul_fragments) == 5 and Spell(soul_cleave) or IncomingDamage(5) > MaxHealth() * 0.7 and Spell(fel_devastation) or IncomingDamage(5) >= MaxHealth() * 0.7 and Spell(soul_cleave) or Spell(fel_eruption) or target.DebuffRemaining(sigil_of_flame_debuff) - 0 <= 0.3 * BaseDuration(sigil_of_flame_debuff) and Spell(sigil_of_flame) or Pain() >= 80 and BuffStacks(soul_fragments) < 4 and IncomingDamage(4) <= MaxHealth() * 0.2 and Spell(fracture) or Pain() >= 80 and Spell(soul_cleave) or Spell(shear)
}

### actions.precombat

AddFunction VengeancePrecombatMainActions
{
	#flask,type=flask_of_the_seventh_demon
	#food,type=nightborne_delicacy_platter
	#augmentation,type=defiled
	Spell(augmentation)
}

AddFunction VengeancePrecombatMainPostConditions
{
}

AddFunction VengeancePrecombatShortCdActions
{
}

AddFunction VengeancePrecombatShortCdPostConditions
{
	Spell(augmentation)
}

AddFunction VengeancePrecombatCdActions
{
}

AddFunction VengeancePrecombatCdPostConditions
{
	Spell(augmentation)
}

### Vengeance icons.

AddCheckBox(opt_demonhunter_vengeance_aoe L(AOE) default specialization=vengeance)

AddIcon checkbox=!opt_demonhunter_vengeance_aoe enemies=1 help=shortcd specialization=vengeance
{
	if not InCombat() VengeancePrecombatShortCdActions()
	unless not InCombat() and VengeancePrecombatShortCdPostConditions()
	{
		VengeanceDefaultShortCdActions()
	}
}

AddIcon checkbox=opt_demonhunter_vengeance_aoe help=shortcd specialization=vengeance
{
	if not InCombat() VengeancePrecombatShortCdActions()
	unless not InCombat() and VengeancePrecombatShortCdPostConditions()
	{
		VengeanceDefaultShortCdActions()
	}
}

AddIcon enemies=1 help=main specialization=vengeance
{
	if not InCombat() VengeancePrecombatMainActions()
	unless not InCombat() and VengeancePrecombatMainPostConditions()
	{
		VengeanceDefaultMainActions()
	}
}

AddIcon checkbox=opt_demonhunter_vengeance_aoe help=aoe specialization=vengeance
{
	if not InCombat() VengeancePrecombatMainActions()
	unless not InCombat() and VengeancePrecombatMainPostConditions()
	{
		VengeanceDefaultMainActions()
	}
}

AddIcon checkbox=!opt_demonhunter_vengeance_aoe enemies=1 help=cd specialization=vengeance
{
	if not InCombat() VengeancePrecombatCdActions()
	unless not InCombat() and VengeancePrecombatCdPostConditions()
	{
		VengeanceDefaultCdActions()
	}
}

AddIcon checkbox=opt_demonhunter_vengeance_aoe help=cd specialization=vengeance
{
	if not InCombat() VengeancePrecombatCdActions()
	unless not InCombat() and VengeancePrecombatCdPostConditions()
	{
		VengeanceDefaultCdActions()
	}
}

### Required symbols
# arcane_torrent_dh
# augmentation
# consume_magic
# demon_spikes
# demon_spikes_buff
# empower_wards
# fel_devastation
# fel_eruption
# felblade
# fiery_brand
# fiery_brand_debuff
# fiery_demise
# fracture
# frailty_debuff
# immolation_aura
# imprison
# infernal_strike
# infernal_strike_debuff
# metamorphosis_veng
# metamorphosis_veng_buff
# shear
# sigil_of_chains
# sigil_of_flame
# sigil_of_flame_debuff
# sigil_of_misery
# sigil_of_silence
# soul_barrier
# soul_carver
# soul_cleave
# spirit_bomb
]]
	OvaleScripts:RegisterScript("DEMONHUNTER", "vengeance", name, desc, code, "script")
end
