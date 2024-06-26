---@meta _
-- grabbing our dependencies,
-- these funky (---@) comments are just there
--	 to help VS Code find the definitions of things

---@diagnostic disable-next-line: undefined-global
local mods = rom.mods

---@module 'SGG_Modding-ENVY-auto'
mods['SGG_Modding-ENVY'].auto()
-- ^ this gives us `public` and `import`, among others
--	and makes all globals we define private to this plugin.
---@diagnostic disable: lowercase-global

---@diagnostic disable-next-line: undefined-global
rom = rom
---@diagnostic disable-next-line: undefined-global
_PLUGIN = _PLUGIN

-- get definitions for the game's globals
---@module 'SGG_Modding-Hades2GameDef-Globals'
game = rom.game
---@module 'game-import'
import_as_fallback(game)

---@module 'SGG_Modding-ModUtil'
modutil = mods['SGG_Modding-ModUtil']

---@module 'SGG_Modding-Chalk'
chalk = mods["SGG_Modding-Chalk"]

---@module 'SGG_Modding-ReLoad'
reload = mods['SGG_Modding-ReLoad']

---@module 'SGG_Modding-SJSON'
sjson = mods['SGG_Modding-SJSON']

---@module 'config'
config = chalk.auto 'config.lua'
-- ^ this updates our `.cfg` file in the config folder!
public.config = config -- so other mods can access our config

local function on_ready()
	-- what to do when we are ready, but not re-do on reload.
	if config.enabled == false then return end
	if config.grace_period_enabled == true then
	local ShieldChargeStages = game.DeepCopyTable(game.WeaponData.WeaponAxeBlock2.ChargeWeaponStages)
	local FirstStage = ShieldChargeStages[1]
	FirstStage.ForceRelease = false
	ShieldChargeStages[1] = FirstStage
	ShieldChargeStages[2] = {
		DeferSwap = FirstStage.DeferSwap,
		Wait = config.axe_grace_period,
		ForceRelease = true,
	}
	game.WeaponData.WeaponAxeBlock2.ChargeWeaponStages = game.DeepCopyTable(
		ShieldChargeStages)
	end
	if config.always_mouse_aim_special == true then
		local weaponsPath = sjson.get_game_data_path() .. config.player_weapons_subpath;
		sjson.hook(weaponsPath, function(data)
			local weaponsData = data.Weapons
			for key, weaponData in pairs(weaponsData) do
				if weaponData.Name == config.special_axe_attack_name then
					weaponData.UseTargetAngle = true
					weaponData.SetCompleteAngleOnCharge = true
					weaponData.CanUseKeyboardAim = true
					break
				end
			end
			return data
		end)
	end
end

local function on_reload()
	-- what to do when we are ready, but also again on every reload.
	-- only do things that are safe to run over and over.
end

-- this allows us to limit certain functions to not be reloaded.
local loader = reload.auto_single()

-- this runs only when modutil and the game's lua is ready
modutil.on_ready_final(function()
	loader.load(on_ready, on_reload)
end)
