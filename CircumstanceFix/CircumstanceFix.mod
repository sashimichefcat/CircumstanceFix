return {
	run = function()
		fassert(rawget(_G, "new_mod"))
		new_mod("CircumstanceFix", {
			mod_script = "CircumstanceFix/scripts/mods/CircumstanceFix/CircumstanceFix",
		})
	end,
	packages = {},
}
