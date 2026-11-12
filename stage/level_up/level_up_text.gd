class_name LevelUpText
# The words the level-up view shows for skills, offers and talents.


static func get_monogram(text: String) -> String:
	var letters := ""
	for word in text.split(" ", false):
		letters += word[0]
	return letters.substr(0, 2).to_upper()


static func get_offer_title(offer: DraftOffer) -> String:
	return "%s %s" % [OwnedSkill.RANK_NAMES[offer.rank], offer.skill.name]


static func get_offer_description(offer: DraftOffer) -> String:
	if offer.is_upgrade():
		var upgrade := offer.skill.upgrades[offer.rank - 1]
		return "" if upgrade.mod == null else upgrade.mod.get_description()
	return get_skill_description(offer.skill)


static func get_skill_description(skill: Learnable) -> String:
	var active := skill as SkillData
	if active == null:
		return "\n".join(skill.get_basic_mods().map(func(mod: SkillMod) -> String: return mod.get_description()))
	var lines := PackedStringArray()
	for effect in active.effects:
		lines.append(effect.get_description())
	lines.append("Delay %d · Cooldown %d · AP %d" % [active.delay, active.cooldown, active.ap_cost])
	return "\n".join(lines)


static func get_talent_description(talent: Talent, bag: Array[Learnable]) -> String:
	var mod_description := "" if talent.mod == null else talent.mod.get_description()
	if talent.granted_class == null:
		return mod_description
	var class_description := "Become %s. %s" % [talent.granted_class.name, get_class_offer_changes(talent.granted_class, bag)]
	return ("%s. %s" % [mod_description.replace("\n", ", "), class_description]).trim_prefix(". ")


static func get_class_offer_changes(class_data: ClassData, bag: Array[Learnable]) -> String:
	var unlocked := PackedStringArray()
	var favoured := PackedStringArray()
	var disfavoured := PackedStringArray()
	for skill in bag:
		if skill.required_class == class_data:
			unlocked.append(skill.name)
		elif skill.class_offer_weights.has(class_data):
			var weight := skill.class_offer_weights[class_data]
			if weight > skill.offer_weight:
				favoured.append(skill.name)
			elif weight < skill.offer_weight:
				disfavoured.append(skill.name)
	var parts := PackedStringArray()
	if not unlocked.is_empty():
		parts.append("Unlocks %s." % ", ".join(unlocked))
	if not favoured.is_empty():
		parts.append("Favours %s." % ", ".join(favoured))
	if not disfavoured.is_empty():
		parts.append("Fewer %s." % ", ".join(disfavoured))
	return " ".join(parts)


static func get_owned_tooltip(owned: OwnedSkill, hero: Character) -> String:
	var lines := PackedStringArray(["%s %s" % [OwnedSkill.RANK_NAMES[owned.get_rank()], owned.skill.name]])
	var active := owned.skill as SkillData
	if active == null:
		for mod in owned.get_mods():
			lines.append(mod.get_description())
	else:
		lines.append(_strip_bbcode(get_skill_description(hero.skills[hero.build.actives.find(owned)])))
	for talent in owned.talents:
		lines.append("• %s" % talent.name)
	return "\n".join(lines)


static func get_talent_tooltip(talent: Talent, bag: Array[Learnable]) -> String:
	return "%s\n%s" % [talent.name, _strip_bbcode(get_talent_description(talent, bag))]


static func _strip_bbcode(text: String) -> String:
	var regex := RegEx.create_from_string("\\[[^\\]]*\\]")
	return regex.sub(text, "", true)
