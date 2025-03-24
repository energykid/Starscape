starcryer_Sprite = custom_sprite("Starscape/Enemies/Minibosses/starcryer.png", 6, 13, 12, 0)
starcryer_ProjectileSprite = custom_sprite("Starscape/Enemies/Minibosses/starcryer_bullet.png", 1, 4, 4, 10)
starcryer_ProjectileSprite_Large = custom_sprite("Starscape/Enemies/Minibosses/starcryer_bullet_large.png", 1, 7, 7, 10)
starcryer_TrailSprite = custom_sprite("Starscape/Enemies/Minibosses/starcryer_trail.png", 3, 13, 12, 30)

starcryer_howlSound = custom_sound("Starscape/Enemies/Minibosses/starcryer_howl.ogg")
starcryer_DeathSound = custom_sound("Starscape/Enemies/Minibosses/starcryer_die.ogg")

starcryer = enemy_data("starcryer")
starcryer.Miniboss = true

starcryer.Create = function(obj)
  debug_out("blah")
  set_var(obj, "sprite_index", starcryer_Sprite)
  set_var(obj, "hp", 700)
  set_var(obj, "maxhp", 700)
  set_var(obj, "nopush", 1)
  set_var(obj, "behavior", "idle")
  set_var(obj, "ai_timer", 30)
  set_var(obj, "hspeed_target", 0)
  set_var(obj, "vspeed_target", 0)
end

starcryer.Step = function(obj)  
  init_var(obj, "sinething", 5)
  init_var(obj, "trailthing", 0)
  if (math.fmod(get_var(obj, "trailthing"), 8) == 0) then 
    local sp = spawn_particle(get_var(obj, "x"), get_var(obj, "y"), 0, 0, starcryer_TrailSprite)
    set_var(sp, "depth", get_var(obj, "depth") + 2)
    set_var(sp, "image_xscale", get_var(obj, "image_xscale"))
    set_var(sp, "image_yscale", get_var(obj, "image_yscale"))
    EnHelp.AddCallback(sp, 
      function(v) 
        set_var(v, "depth", get_var(v, "depth") + 1) 
        set_var(sp, "image_xscale", get_var(sp, "image_xscale") * 0.98)
        set_var(sp, "image_yscale", get_var(sp, "image_yscale") * 0.98)
      end)
  end
  set_var(obj, "trailthing", get_var(obj, "trailthing") + 1)
  
  set_var(obj, "image_index", get_var(obj, "image_index") + 0.2)
  
  local sprite_state = "idle"
  
  set_var(obj, "ai_timer", get_var(obj, "ai_timer") + 1)
  
  if (get_var(obj, "behavior") == "idle") then
    set_var(obj, "image_xscale", lerp(get_var(obj, "image_xscale"), 1.0, 0.2))
    set_var(obj, "image_yscale", lerp(get_var(obj, "image_yscale"), 1.0, 0.2))
    local dir = get_direction(get_var(obj, "x"), get_var(obj, "y"), player_x, player_y)
    set_var(obj, "hspeed_target", dir.x * 0.2)
    set_var(obj, "vspeed_target", dir.y * 0.2)
    if (get_var(obj, "ai_timer") > 50) then
      set_var(obj, "ai_timer", 0)
      set_var(obj, "behavior", "shoot")
      if (call_function("instance_number", {get_asset("obj_enemy")}) < 2) then
        set_var(obj, "behavior", "howl")
      end
      set_var(obj, "vspeed_target", 1)
    end
  elseif (get_var(obj, "behavior") == "howl") then
    set_var(obj, "hspeed_target", get_var(obj, "hspeed_target") * 0.9)
    set_var(obj, "vspeed_target", get_var(obj, "vspeed_target") * 0.9)
    if (get_var(obj, "ai_timer") == 50) then
      set_var(obj, "vspeed_target", -2)
      play_sound(starcryer_howlSound, get_var(obj, "x"))
      local cenx = view_x + 120
      local ceny = view_y + 140
      local rotbase = math.random(360)
      local num = 3
      if (hard_mode) then num = 4 end
      local num_increment = 120
      if (hard_mode) then num_increment = 90 end
      for i = 1,num do
        local rot = rotbase + (i * num_increment)
        local spawnx = cenx + (rot_x(rot) * 160)
        local spawny = ceny + (rot_y(rot) * 160)
        local ghost = spawn_enemy(spawnx, spawny, "star_ghost")
        set_var(ghost, "D", rot)
        set_var(ghost, "activation_timer", 10)
        EnHelp.AddCallback(ghost, function(v) 
            set_var(v, "debris_score", 0)
            init_var(v, "callback_var", 0)
            if (get_var(v, "callback_var") == 0) then
              set_var(v, "hspeed", rot_x(get_var(v, "D")) * -4)
              set_var(v, "vspeed", rot_y(get_var(v, "D")) * -4)
            end
            if (get_var(v, "callback_var") <= 20) then
              set_var(v, "hspeed", get_var(v, "hspeed") * 0.9)
              set_var(v, "vspeed", get_var(v, "vspeed") * 0.9)
            end
            set_var(v, "callback_var", get_var(v, "callback_var") + 1)
          end)
      end
    end
    if (get_var(obj, "ai_timer") >= 50) then 
      sprite_state = "crying"
    end
    if (get_var(obj, "ai_timer") > 100) then
      set_var(obj, "ai_timer", 0)
      set_var(obj, "behavior", "idle")
    end
  elseif (get_var(obj, "behavior") == "shoot") then
    local t = math.fmod(get_var(obj, "ai_timer"), 40)
    init_var(obj, "target_position_x", screen_center_x)
    init_var(obj, "target_position_y", screen_center_y)
    set_var(obj, "hspeed", get_var(obj, "hspeed") * 0.8)
    set_var(obj, "vspeed", get_var(obj, "vspeed") * 0.8)
    if (t == 1) then
      set_var(obj, "target_position_x", clamp(get_var(obj, "x") + math.random(-60, 60), view_x + 50, view_x + 170))
      set_var(obj, "target_position_y", clamp(get_var(obj, "y") + math.random(-60, 60), view_y + 110, view_y + 230))
      while (call_function("point_distance", {get_var(obj, "target_position_x"), get_var(obj, "target_position_y"), player_x, player_y}) < 60) do
        set_var(obj, "target_position_x", clamp(get_var(obj, "x") + math.random(-60, 60), view_x + 50, view_x + 170))
        set_var(obj, "target_position_y", clamp(get_var(obj, "y") + math.random(-60, 60), view_y + 110, view_y + 230))
      end
      play_sound(get_asset("snd_kleinesmenu_open"), get_var(obj, "x"))
    end
    local dir = get_direction(get_var(obj, "x"), get_var(obj, "y"), get_var(obj, "target_position_x"), get_var(obj, "target_position_y"))
    local mult = (call_function("point_distance", {get_var(obj, "x"), get_var(obj, "y"), get_var(obj, "target_position_x"), get_var(obj, "target_position_y")}) * 0.15)
    dir.x = dir.x * mult
    dir.y = dir.y * mult
    set_var(obj, "hspeed_target", dir.x)
    set_var(obj, "vspeed_target", dir.y)
    if (t >= 12 and t < 26) then
      sprite_state = "crying"
    end
    if (t == 12) then
      play_sound(get_asset("snd_fireball_fire"), get_var(obj, "x"))
      local proj_d = call_function("point_direction", {get_var(obj, "x"), get_var(obj, "y"), get_var(player, "x"), get_var(player, "y")})
      local num = 2
      if (get_global("game_loop") > 0) then num = 3 end
      for i = 0,num do
        local p_amp = 4 + (i * 2)
        if (get_global("game_loop") > 0) then p_amp = 4 + (i * 1.5) end
        local spr = starcryer_ProjectileSprite
        if (i == num) then spr = starcryer_ProjectileSprite_Large end
        local p = spawn_projectile(get_var(obj, "x"), get_var(obj, "y"), rot_x(proj_d) * p_amp, rot_y(proj_d) * p_amp, spr)
        set_var(p, "image_xscale", 0)
        set_var(p, "image_yscale", 0)
        local pfunc = function(v)
          init_var(v, "callback_var", 0)
          set_var(v, "callback_var", get_var(v, "callback_var") + 1)
          if (get_var(v, "callback_var") < 40) then 
            set_var(v, "hspeed", get_var(v, "hspeed") * 0.95)
            set_var(v, "vspeed", get_var(v, "vspeed") * 0.95)
          end
          local c = math.sin(get_var(v, "callback_var") / 3) / 10
          set_var(v, "image_xscale", lerp(get_var(v, "image_xscale"), 1 + c, 0.25))
          set_var(v, "image_yscale", lerp(get_var(v, "image_yscale"), 1 - c, 0.25))
        end
        
        EnHelp.AddCallback(p, pfunc)
      end
    end
    if (get_var(obj, "ai_timer") > 100) then
      set_var(obj, "ai_timer", 0)
      set_var(obj, "teleports_left", 2 + math.floor(math.random(2)))
      if (get_global("game_loop") > 0) then
        set_var(obj, "behavior", "teleport")
      else
        set_var(obj, "behavior", "idle")
      end
    end
  elseif (get_var(obj, "behavior") == "teleport") then
    set_var(obj, "hspeed_target", 0)
    set_var(obj, "vspeed_target", 0)
    local tt = math.fmod(get_var(obj, "ai_timer"), 40)
    if (tt > 10) then
      set_var(obj, "image_xscale", lerp(get_var(obj, "image_xscale"), 1.0, 0.2))
      set_var(obj, "image_yscale", lerp(get_var(obj, "image_yscale"), 1.0, 0.2))
    else
      set_var(obj, "image_xscale", get_var(obj, "image_xscale") - 0.1)
      set_var(obj, "image_yscale", get_var(obj, "image_yscale") + 0.12)
    end
    if (tt == 8) then
      play_sound(get_asset("snd_magick_appearify"), get_var(obj, "x"))
    end
    if (tt == 10) then
      set_var(obj, "target_position_x", view_x + 20 + math.random(200))
      set_var(obj, "target_position_y", view_y + 70 + math.random(200))
      while (call_function("point_distance", {get_var(obj, "target_position_x"), get_var(obj, "target_position_y"), player_x, player_y}) < 100) do
        set_var(obj, "target_position_x", view_x + 20 + math.random(200))
        set_var(obj, "target_position_y", view_y + 70 + math.random(200))
      end
      set_var(obj, "x", get_var(obj, "target_position_x"))
      set_var(obj, "y", get_var(obj, "target_position_y"))
      set_var(obj, "teleports_left", get_var(obj, "teleports_left") - 1)
      if (get_var(obj, "teleports_left") <= 0) then
        set_var(obj, "ai_timer", 0)
        set_var(obj, "behavior", "idle")
      end
    end
  end
  
  if (sprite_state == "idle") then
    set_var(obj, "image_index", math.fmod(get_var(obj, "image_index"), 4))
  else
    if (get_var(obj, "image_index") < 4) then set_var(obj, "image_index", 4) end
    if (get_var(obj, "image_index") > 5) then set_var(obj, "image_index", 4) end
  end
  
  local h = math.sin(get_var(obj, "sinething") / 10) * 0.025
  local v = math.sin(get_var(obj, "sinething") / 23) * 0.05
  
  set_var(obj, "hspeed", lerp(get_var(obj, "hspeed"), get_var(obj, "hspeed_target"), 0.2) + h)
  set_var(obj, "vspeed", lerp(get_var(obj, "vspeed"), get_var(obj, "vspeed_target"), 0.2) + v)
  
  set_var(obj, "sinething", get_var(obj, "sinething") + 1)
end

starcryer.Destroy = function(obj)
  play_sound_ext(starcryer_DeathSound, 1, 1, get_var(obj, "x"))
end

register_data(starcryer)