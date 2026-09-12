extends RefCounted
class_name PerkPurchaseService
## Purchase flow for one-shot passive perks (design: obsidian note 14).
## Demo payment: supply credits only (ProfileState.currency). Item costs
## (cost_items) are reserved until the inventory system exists.
## The hub UI (workshop robot message) is a thin caller of this service.


static func can_purchase(perk_id: StringName) -> bool:
	var definition := SkillCatalog.find_perk(perk_id)
	if definition == null:
		return false
	if GameSession.profile.has_perk(perk_id):
		return false
	return GameSession.profile.get_currency() >= definition.cost_credits


static func purchase(perk_id: StringName) -> bool:
	var definition := SkillCatalog.find_perk(perk_id)
	if definition == null:
		push_error(
			"PerkPurchaseService: perk '%s' is not in the catalog" % perk_id
		)
		return false

	var profile := GameSession.profile
	if profile.has_perk(perk_id):
		push_warning(
			"PerkPurchaseService: perk '%s' is already acquired" % perk_id
		)
		return false

	if profile.get_currency() < definition.cost_credits:
		push_warning(
			"PerkPurchaseService: not enough credits for '%s'" % perk_id
		)
		return false

	if not definition.cost_items.is_empty():
		var item_cost_warning := (
			"PerkPurchaseService: item costs for '%s' are ignored "
			+ "until the inventory system exists"
		)
		push_warning(item_cost_warning % perk_id)

	if definition.cost_credits > 0:
		profile.set_currency(profile.get_currency() - definition.cost_credits)
	if not profile.acquire_perk(perk_id):
		push_error(
			"PerkPurchaseService: failed to record perk '%s'" % perk_id
		)
		return false

	PerkEffectApplier.apply(definition)
	return true
