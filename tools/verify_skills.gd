extends Node
## Runtime contract checks for the skills system (perks + active skills).
## Run: godot --path . --headless res://tools/verify_skills.tscn
## Writes .godot/skills_test.ok on success, quits itself.


func _ready() -> void:
	# --- Catalog contracts -------------------------------------------------
	assert(SkillCatalog.get_all_perks().size() == 8)
	assert(SkillCatalog.get_all_active_skills().size() == 4)
	assert(SkillCatalog.get_perks_by_branch(SkillBranch.Type.CRAFT).size() == 4)
	assert(SkillCatalog.get_perks_by_branch(SkillBranch.Type.PILOT).size() == 4)
	assert(
		SkillCatalog.get_active_skills_by_branch(SkillBranch.Type.CRAFT).size()
		== 2
	)
	assert(
		SkillCatalog.get_active_skills_by_branch(SkillBranch.Type.PILOT).size()
		== 2
	)
	for perk in SkillCatalog.get_all_perks():
		assert(perk.is_valid())
	for skill in SkillCatalog.get_all_active_skills():
		assert(skill.is_valid())
	assert(SkillCatalog.require_perk(&"hull_plating") != null)
	assert(SkillCatalog.require_active_skill(&"afterburner") != null)
	assert(SkillCatalog.find_perk(&"nonexistent") == null)

	# --- Purchase flow ------------------------------------------------------
	GameSession.initialize_new_game()
	var profile := GameSession.profile
	profile.set_currency(1000)

	assert(PerkPurchaseService.can_purchase(&"hull_plating"))
	assert(PerkPurchaseService.purchase(&"hull_plating"))
	assert(profile.has_perk(&"hull_plating"))
	assert(profile.get_currency() == 800)
	assert(GameSession.craft.health.get_max_hp() == 125)

	# Duplicate purchase is rejected and costs nothing.
	assert(not PerkPurchaseService.can_purchase(&"hull_plating"))
	assert(not PerkPurchaseService.purchase(&"hull_plating"))
	assert(profile.get_currency() == 800)

	# SCALE effect computes from the base fuel rate.
	assert(PerkPurchaseService.purchase(&"fuel_economizer"))
	assert(
		is_equal_approx(
			GameSession.craft.fuel_tank.get_gallons_per_map_unit(),
			0.425
		)
	)

	# Weapon steps ride on the existing CraftUpgradeState.
	assert(PerkPurchaseService.purchase(&"weapon_calibration"))
	assert(GameSession.craft.upgrades.get_weapon_damage_upgrade() == 1)

	# Pilot branch reaches PlayerState.
	assert(PerkPurchaseService.purchase(&"vitality"))
	assert(GameSession.player.health.get_max_hp() == 125)

	# --- Insufficient funds -------------------------------------------------
	GameSession.initialize_new_game()
	profile = GameSession.profile
	profile.set_currency(10)
	assert(not PerkPurchaseService.can_purchase(&"hull_plating"))
	assert(not PerkPurchaseService.purchase(&"hull_plating"))
	assert(not profile.has_perk(&"hull_plating"))
	assert(profile.get_currency() == 10)
	assert(GameSession.craft.health.get_max_hp() == 100)

	# --- reapply_all: the save-load contract --------------------------------
	# Fresh models + acquired ids => deterministic restoration.
	profile.acquire_perk(&"hull_plating")
	profile.acquire_perk(&"fuel_economizer")
	PerkEffectApplier.reapply_all(profile)
	assert(GameSession.craft.health.get_max_hp() == 125)
	assert(
		is_equal_approx(
			GameSession.craft.fuel_tank.get_gallons_per_map_unit(),
			0.425
		)
	)

	# --- Active skill loadout ------------------------------------------------
	assert(
		ActiveSkillLoadoutService.select(
			SkillBranch.Type.CRAFT,
			&"afterburner"
		)
	)
	assert(
		profile.get_selected_active_skill(SkillBranch.Type.CRAFT)
		== &"afterburner"
	)
	# Wrong branch is rejected.
	assert(
		not ActiveSkillLoadoutService.select(
			SkillBranch.Type.CRAFT,
			&"dash"
		)
	)
	# Unknown skill is rejected.
	assert(
		not ActiveSkillLoadoutService.select(
			SkillBranch.Type.PILOT,
			&"nonexistent"
		)
	)
	var selected := ActiveSkillLoadoutService.get_selected_definition(
		SkillBranch.Type.CRAFT
	)
	assert(selected != null)
	assert(selected.kind == ActiveSkillDefinition.KIND_AFTERBURNER)
	assert(
		ActiveSkillLoadoutService.get_selected_definition(
			SkillBranch.Type.PILOT
		)
		== null
	)

	# --- Flight controller runtime (cooldown gate + boost effect) ------------
	WorldUtils.reset_base_scroll_speed()
	WorldUtils.set_flight_speed_multiplier(1.0)
	var base_speed := WorldUtils.scroll_speed()

	var controller := FlightActiveSkillController.new()
	add_child(controller)
	assert(controller.try_activate())
	assert(
		is_equal_approx(WorldUtils.scroll_speed(), base_speed * 1.5)
	)
	# Second activation is blocked while the effect/cooldown is running.
	assert(not controller.try_activate())
	remove_child(controller)
	controller.free()
	# Leaving the tree resets the boost.
	assert(is_equal_approx(WorldUtils.get_flight_boost_multiplier(), 1.0))
	assert(is_equal_approx(WorldUtils.scroll_speed(), base_speed))

	var result := FileAccess.open("res://.godot/skills_test.ok", FileAccess.WRITE)
	assert(result != null)
	result.store_string("Skills runtime contracts: OK")
	get_tree().quit()
