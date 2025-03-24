require("EnnsHelpers/callbacks")
require("EnnsHelpers/math")

-- set this to true to force tailwind to spawn on floor 3
FORCE_TAILWIND = true

debug = global_data()

debug.Step = function()
  if (call_function("keyboard_check_pressed", {call_function("ord", {"R"})}) == 1) then
    --spawn_boss_intro(view_x + 120, view_y + 120, "tailwind") 
    --  (this will spawn tailwind; uncomment if you want to test the boss.)
    --  (make sure whatever room you test this from DOESN'T have an opening at the bottom LOL)
  end
end

register_data(debug)

-- below is the "boss" i came up with to test out spawn intros.
-- beware, uncommenting the below code will make it impossible to progress
-- it will, however, allow you to fight three simultaneous battle balls
-- so who's the real winner huh

--[[
bosstest = enemy_data("bosstest")

bosstest.Boss = true
bosstest.ShouldForceBoss = function() return true end
bosstest.BossFloor = 1
bosstest.BossIntro = function(obj)
  init_var(obj, "bossTimer", 0)
  if (get_var(obj, "bossTimer") == 40) then
    play_music(get_asset("mus_the_4th"))
  end
  set_var(obj, "bossTimer", get_var(obj, "bossTimer") + 1)
  if (get_var(obj, "bossTimer") == 50) then
    boss_message(120, 64, "three simultaneous")
    boss_message(120, 220, "battle balls")
  end

  if (get_var(obj, "bossTimer") == 180) then
    for i = 1, 3 do
      play_sound(get_asset("snd_explode"), view_x + 120)
      local a = spawn_enemy(view_x + (i * 60), view_y, "obj_battleball")
      local pfunc = function(v)
        init_var(v, "customTimer", 0)
        if (get_var(v, "customTimer") == 0) then 
          set_var(v, "behavior", "nothing") 
          set_var(v, "vspeed", 8)
          if (i == 2) then
            set_var(v, "vspeed", 6)
          end
        end
        set_var(v, "customTimer", get_var(v, "customTimer") + 1)
        if (get_var(v, "customTimer") < 60) then
          set_var(v, "vspeed", get_var(v, "vspeed") * 0.94)
        else
          set_var(v, "behavior", "default") 
        end
      end
      EnHelp.AddCallback(a, pfunc)
    end
  end
end
bosstest.BossBackground = function(obj)
  init_var(obj, "backgroundTimer", 0)
  set_var(obj, "backgroundTimer", lerp(get_var(obj, "backgroundTimer"), 1, 0.15))
  local col = create_color(45, 32, 32)
  draw_sprite_ext(view_x, view_y + 120 - (60 * get_var(obj, "backgroundTimer")), get_asset("spr_bg_upgrade"), 0, 0, 1, 1, col, 1)
end

register_data(bosstest)
]]

function mod_load()
  require("Starscape/Music/music_definitions")
  require("Starscape/Enemies/gossamer")
  require("Starscape/Enemies/star_ghost")
  require("Starscape/Enemies/Minibosses/starcrier")
  require("Starscape/Enemies/Bosses/tailwind")
  require("Starscape/Rooms/room_definitions")
end

function mod_unload() end