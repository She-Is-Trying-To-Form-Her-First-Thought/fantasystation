/datum/species/monkey/randomize_features(mob/living/carbon/human/human_mob)
	var/list/features = ..()
	features["tail_monkey"] = /datum/sprite_accessory/tails/monkey/default::name
	return features

/mob/living/carbon/human/species/monkey/punpun/Initialize(mapload)
	. = ..()
	add_quirk(/datum/quirk/excitable)
