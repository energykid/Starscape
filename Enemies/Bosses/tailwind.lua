tailwind_HeadSprite = custom_sprite("Starscape/Enemies/Bosses/tailwind_head.png", 1, 38, 48, 0)
tailwind_BodySprite = custom_sprite("Starscape/Enemies/Bosses/tailwind_body.png", 1, 17, 12, 0)
tailwind_ProjectileSprite = custom_sprite("Starscape/Enemies/Minibosses/starcryer_bullet.png", 1, 4, 4, 10)
tailwind_ProjectileSprite_Large = custom_sprite("Starscape/Enemies/Minibosses/starcryer_bullet_large.png", 1, 7, 7, 10)

tailwind_Trail = {}

tailwind = enemy_data("tailwind")
tailwind.Boss = true
tailwind.BossFloor = 3
tailwind.ShouldForceBoss = function()
  return FORCE_TAILWIND and (get_global("current_floormap") == get_global("floormap_3"))
end

tailwind.BossIntro = function(obj)
  init_var(obj, "bossTimer", 0)
  if (get_var(obj, "bossTimer") == 0) then
    play_music(StarscapeMusic.post_wonder)
  end
  if (get_var(obj, "bossTimer") == 60) then
    spawn_enemy(view_x + 120, view_y + 120, "tailwind")
  end
  if (get_var(obj, "bossTimer") == 120) then
    boss_message(120, 80, "tailwind")
  end
  set_var(obj, "bossTimer", get_var(obj, "bossTimer") + 1)
end

function teleportTailwind(obj, x, y)
  set_var(obj, "x", x)
  set_var(obj, "y", y)
  for i = 1, #tailwind_Trail do
    tailwind_Trail[i][1] = x
    tailwind_Trail[i][2] = y
  end
end

tailwind.Create = function(obj)
  tailwind_Trail = {}
  set_var(obj, "sprite_index", tailwind_HeadSprite)
  -- set damage to 0, effectively removing contact damage from the enemy
  -- (setting it to -1 will cause it to work like spr_eatr and remove max health, in case you're curious) 
  set_var(obj, "damage", 0)
  set_var(obj, "pass_wall", 1)
  set_var(obj, "y", view_y + 350)
  set_var(obj, "vspeed", -3)
  set_var(obj, "hp", 3000)
  set_var(obj, "maxhp", 3000)
  set_var(obj, "hp_damage", 3000)
  set_var(obj, "state", "INTRO")
  set_var(obj, "ai_timer", 30)
  set_var(obj, "hspeed_target", 0)
  set_var(obj, "vspeed_target", 0)
end

streaks = {}

function addStreak(xx, yy, xsp, ysp, ww)
  local str = {}
  str.x = xx
  str.y = yy
  str.xsp = xsp
  str.ysp = ysp
  str.w = ww
  table.insert(streaks, 1, str)
end

streakstep = function(v)
  v.w = lerp(v.w, -0.2, 0.12)
end

function drawStreak(x1, y1, x2, y2, width)
  local col = create_color(255, 255, 255)
  local x = lerp(x1, x2, 0.5)
  local y = lerp(y1, y2, 0.5)
  local direc = call_function("point_direction", {x1, y1, x2, y2})
  local xx1 = rot_x(direc + 90) * width
  local yy1 = rot_y(direc + 90) * width
  local xx2 = rot_x(direc - 90) * width
  local yy2 = rot_y(direc - 90) * width
  draw_primitive_begin()
  draw_vertex_color(x1, y1, col, 0.6)
  draw_vertex_color(x1, y1, col, 0.6)
  draw_vertex_color(x + xx1, y + yy1, col, 0.6)
  draw_vertex_color(x + xx2, y + yy2, col, 0.6)
  draw_vertex_color(x2, y2, col, 0.6)
  draw_vertex_color(x2, y2, col, 0.6)
  draw_primitive_end()
end

tailwind.Draw = function(obj) -- here's where all the Fun Stuff happens
  init_var(obj, "trailthing", 0)
  set_var(obj, "trailthing", get_var(obj, "trailthing") + 1)
  if (#tailwind_Trail > 3) then
    -- create a new primitive strip using frame 0 of tailwind_BodySprite
    draw_primitive_begin_texture(tailwind_BodySprite, 0) 
    local dir = call_function("point_direction", {get_var(obj, "x"), get_var(obj, "y"), tailwind_Trail[1][1], tailwind_Trail[1][2]}) + 90
    
    -- for every coordinate inside tailwind_Trail except the last one, perform the following code
    for i = 1, #tailwind_Trail - 1 do
      -- set "d" (distance) to 18 plus a little modulator variable to make the trail wavier
      local d = 18 + (math.sin(get_var(obj, "trailthing") / 10 + (i / 5)) * 5);
      if (i > 1) then
        dir = call_function("point_direction", {tailwind_Trail[i - 1][1], tailwind_Trail[i - 1][2], tailwind_Trail[i][1], tailwind_Trail[i][2]}) + 90
      end
      local value = tailwind_Trail[i]
      local xx = value[1] - rot_x(dir) * d
      local yy = value[2] - rot_y(dir) * d
      draw_vertex_texture(xx, yy, 0, i / #tailwind_Trail)
      xx = value[1] + rot_x(dir) * d
      yy = value[2] + rot_y(dir) * d
      draw_vertex_texture(xx, yy, 1, i / #tailwind_Trail)
    end
    draw_primitive_end()
  end

  for i = 1, #streaks do
    local value = streaks[i]
    drawStreak(value.x - value.xsp, value.y - value.ysp, value.x + value.xsp, value.y + value.ysp, value.w) 
    streakstep(value)
    value.x = value.x + value.xsp
    value.y = value.y + value.ysp
  end
  for i = 1, #streaks do
    local value = streaks[i]
    if value.w <= 0 then
      table.remove(streaks, i)
      i = i - 1
    end
  end
end

tailwind.BossBackground = function(obj)
  init_var(obj, "backgroundTimer", 0)
  set_var(obj, "backgroundTimer", lerp(get_var(obj, "backgroundTimer"), 1, 0.05))
  local col = create_color(18, 22, 50)
  draw_sprite_ext(view_x, view_y + 120 - (60 * get_var(obj, "backgroundTimer")), get_asset("spr_bg_upgrade"), 0, 0, 1, 1, col, 1)
end

function rotateToVelocity(o)
  set_var(o, "image_angle", call_function("point_direction", {0, 0, get_var(o, "hspeed"), get_var(o, "vspeed")}))
end

RotationModes = {
  Upright = 0,
  Omnidirectional = 1
}

States = {
  Intro = "INTRO",
  SideRise = "SIDERISE", -- rise up from left then right in either order, shoot bullets from either side to the center horizontally
  TopBottom = "TOPBOTTOM", -- go from left to right on top then reverse on bottom, firing shotgun sprays of bubbles
  Tides = "TIDES", -- force wind, moving the player from left to right and forcing them to weave between bullets on the center
  Gusts = "GUSTS", -- force wind, slowly pushing the player up while bullets come from the bottom of the screen with a wall at the top
  Dive = "DIVE", -- dive down, forcing the player down with it, then spray short range bullets from the bottom of the screen shortly after
  Tornado = "TORNADO" -- force wind, slowly pushing the player up while bullets come from the bottom of the screen with a wall at the top
}

function ChangeState(obj, states)
  set_var(obj, "ai_timer", 0)
  local state = states[math.random(1, #states)]
  set_var(obj, "state", state)
end

b = false

tailwind.Step = function(obj)
  init_var(obj, "flip_rising", 1)
  init_var(obj, "sinething", 0)
  set_var(obj, "sinething", get_var(obj, "sinething") + 1)
  local RotationMode = RotationModes.Upright
  -- boss death animations are programmed by default to only happen when "behavior" is "dead"
  -- this value will auto-set when the enemy's health reaches zero, don't worry about setting that
  if (get_var(obj, "behavior") == "dead") then
    init_var(obj, "deadTimer", 0)
    if (get_var(obj, "deadTimer") == 0) then
      clear_bullets(get_var(obj, "x"), get_var(obj, "y"))
    end
    if (get_var(obj, "deadTimer") > 120) then
      kill_boss_effect()
      call_function("instance_destroy", {obj})
      play_sound(get_asset("snd_boom"), view_x + 120)
    else
      set_var(obj, "hspeed", lerp(get_var(obj, "hspeed"), ((view_x + 120) - get_var(obj, "x")) / 50, 0.1) + math.random(-1.0, 1.0) / 5)
      set_var(obj, "vspeed", lerp(get_var(obj, "vspeed"), ((view_y + 120) - get_var(obj, "y")) / 50, 0.1) + math.random(-1.0, 1.0) / 5)
      set_var(obj, "sinething", get_var(obj, "sinething") + 1 + (get_var(obj, "deadTimer") / 60))
      set_var(obj, "image_xscale", lerp(get_var(obj, "image_xscale"), 1 + (math.sin(get_var(obj, "sinething") / 10) * 0.2), 0.2))
      set_var(obj, "image_yscale", lerp(get_var(obj, "image_yscale"), 1 - (math.sin(get_var(obj, "sinething") / 10) * 0.2), 0.2))
      if (math.fmod(get_var(obj, "deadTimer"), 9) == 0) then
        play_sound_ext(get_asset("snd_gulp"), 0.25 + (get_var(obj, "deadTimer") / 60), 1, get_var(obj, "x"))
        play_sound_ext(get_asset("snd_pball_absorb"), 0.75 + (get_var(obj, "deadTimer") / 60), 0.5, get_var(obj, "x"))
      end
    end
    set_var(obj, "deadTimer", get_var(obj, "deadTimer") + 1)
  else
    
    if (get_var(obj, "state") == States.Intro) then
      if (get_var(obj, "ai_timer") <= 1) then
        set_var(obj, "y", view_y + 350)
        set_var(obj, "x", view_x + 40 + math.random(160))
        set_var(obj, "hspeed", (-10 + math.random(20)) / 10)
      end
      set_var(obj, "image_xscale", 1 + (math.sin(get_var(obj, "sinething") / 10) * 0.2))
      set_var(obj, "image_yscale", 1 - (math.sin(get_var(obj, "sinething") / 10) * 0.2))
      set_var(obj, "vspeed", -2 + (math.sin(get_var(obj, "sinething") / 15) * 2))
      if (get_var(obj, "y") < view_y) then
        set_var(obj, "ai_timer", 0)
        set_var(obj, "state", States.Dive)
      end
      -- Dive Attack
    elseif (get_var(obj, "state") == States.Dive) then
      RotationMode = RotationModes.Omnidirectional
      if (get_var(obj, "ai_timer") == 1) then
        teleportTailwind(obj, view_x + 120, view_y - 20)
        set_var(obj, "hspeed", (-10 + math.random(20)) / 10)
        set_var(obj, "vspeed", 0)
      end
      set_var(obj, "vspeed", get_var(obj, "vspeed") + 0.4)
      set_var(obj, "image_xscale", 1 + (math.sin(get_var(obj, "sinething") / 4) * 0.2))
      set_var(obj, "image_yscale", 1 - (math.sin(get_var(obj, "sinething") / 4) * 0.2))
      if (get_var(obj, "y") > view_y + 150) then
        init_var(obj, "telegraph_cooldown", 0)
        if (get_var(obj, "telegraph_cooldown") <= 15 and math.fmod(get_var(obj, "telegraph_cooldown"), 5) == 0) then
          for i = 0, 240, 20 do
            local j = get_var(obj, "telegraph_cooldown") * 4
            spawn_particle(view_x + i + math.fmod(j / 2, 20), view_y + 240 + j, 0, 0, get_asset("spr_danger_new"))
          end
        end
        set_var(obj, "telegraph_cooldown", get_var(obj, "telegraph_cooldown") + 1)
      end
      if (get_var(obj, "y") > view_y + 300) then
        init_var(obj, "dive_cooldown", 0)
        if (get_var(obj, "dive_cooldown") == 0) then
          play_sound(get_asset("snd_thunk2"), get_var(obj, "x"))
          if (player_dead == false) then 
            set_var(player, "v_counter", 0)
          end
        end
        if (get_var(obj, "dive_cooldown") == 15) then
          local pfunc = function(v)
            set_var(v, "vspeed", get_var(v, "vspeed") + 0.02)
            set_var(v, "image_yscale", lerp(get_var(v, "image_yscale"), 1, 0.2))
            set_var(v, "image_xscale", lerp(get_var(v, "image_xscale"), 1, 0.2))
          end
          for i = 20, 220, 10 do
            local pa = spawn_particle(view_x + i, view_y + 270, 0, 0, get_asset("spr_dash"))
            set_var(pa, "image_angle", 100 - math.random(20))
            set_var(pa, "image_yscale", 1.5)
            set_var(pa, "image_xscale", 1 + (math.random(10) / 15))
            set_var(pa, "depth", -100)
            local p = spawn_projectile(view_x + i, view_y + 270, (-10 + math.random(20)) / 50, -(math.random(30) / 10), get_asset("spr_bullet_medium_bubble"))
            set_var(p, "depth", 10)
            EnHelp.AddCallback(p, pfunc)
          end
          play_sound(get_asset("snd_explode"), view_x + 120)
          add_screenshake(5)
        end
        set_var(obj, "dive_cooldown", get_var(obj, "dive_cooldown") + 1)
        if (get_var(obj, "dive_cooldown") > 100) then
          set_var(obj, "dive_cooldown", 0)
          set_var(obj, "telegraph_cooldown", 0)
          ChangeState(obj, {States.Gusts, States.SideRise})
        end
      elseif (get_var(obj, "y") < view_y + 250) then
        if (player_dead == false) then 
          set_var(player, "v_counter", get_var(obj, "vspeed"))
        end
        addStreak(view_x + math.random(240), view_y + math.random(240), get_var(obj, "hspeed"), get_var(obj, "vspeed"), 5)
      end
      -- Gusts Attack
    elseif (get_var(obj, "state") == States.Gusts) then
      if (get_var(obj, "ai_timer") < 240) then
        set_var(obj, "image_xscale", 1 + (math.sin(get_var(obj, "sinething") / 15) * 0.2))
        set_var(obj, "image_yscale", 1 - (math.sin(get_var(obj, "sinething") / 15) * 0.2))
        set_var(obj, "hspeed", lerp(get_var(obj, "x"), view_x + 120 + (math.sin(get_var(obj, "sinething") / 60) * 80), 0.1) - get_var(obj, "x"))
        set_var(obj, "vspeed", lerp(get_var(obj, "y"), view_y + 120 - (math.sin(get_var(obj, "sinething") / 10) * 10), 0.1) - get_var(obj, "y"))
        if (math.fmod(get_var(obj, "ai_timer"), 5) == 0) then
          play_sound_ext(get_asset("snd_succ"), 0.2 + (math.random(10) / 20), 0.4, view_x + 120)
          local pfunc2 = function(v)
            init_var(v, "pfunctimer", 0)
            set_var(v, "pfunctimer", get_var(v, "pfunctimer") + 1)
            set_var(v, "image_yscale", lerp(get_var(v, "image_yscale"), 1, 0.1))
            if (get_var(v, "pfunctimer") > 30) then
              get_var(v, "mask_index", get_asset("spr_enemy_bullet_plasma"))
              set_var(v, "vspeed", get_var(v, "vspeed") - 0.05)
            else
              get_var(v, "mask_index", get_asset("spr_nothing"))
              set_var(v, "vspeed", get_var(v, "vspeed") * 0.98)
            end
          end
          if (math.fmod(get_var(obj, "ai_timer"), 20) == 0) then
            local b = spawn_projectile(view_x + math.random(20, 200), view_y + 270, (-10 + math.random(20)) / 50, -(math.random(30) / 15), get_asset("spr_enemy_bullet_plasma"))
            set_var(b, "image_yscale", 0)
            EnHelp.AddCallback(b, rotateToVelocity)
            EnHelp.AddCallback(b, pfunc2)
            play_sound_ext(get_asset("snd_gulp"), 0.5 + (math.random(10) / 10), 1, get_var(b, "x"))
          end
          local pfunc = function(v)
            set_var(v, "vspeed", get_var(v, "vspeed") - 0.1)
            set_var(v, "image_yscale", lerp(get_var(v, "image_yscale"), 1, 0.1))
          end
          local a = spawn_projectile(view_x + math.random(20, 200), view_y + 70, (-10 + math.random(20)) / 50, (10 + math.random(20)) / 10, get_asset("spr_bullet_dopple_blue"))
          EnHelp.AddCallback(a, pfunc)
          EnHelp.AddCallback(a, rotateToVelocity)
        end
        if (player_dead == false) then 
          set_var(player, "v_counter", -1)
        end
        addStreak(view_x + math.random(240), view_y + 60 + math.random(240), 0, -3, 4)
      else
        if (get_var(obj, "ai_timer") < 320) then
          set_var(obj, "image_xscale", lerp(get_var(obj, "image_xscale"), 1.3, 0.05))
          set_var(obj, "image_yscale", lerp(get_var(obj, "image_yscale"), 0.7, 0.05))
          set_var(obj, "hspeed", get_var(obj, "hspeed") * 0.95)
          set_var(obj, "vspeed", get_var(obj, "vspeed") * 0.95)
        else
          set_var(obj, "image_xscale", lerp(get_var(obj, "image_xscale"), 0.7, 0.15))
          set_var(obj, "image_yscale", lerp(get_var(obj, "image_yscale"), 1.3, 0.15))
          if (get_var(obj, "ai_timer") == 320) then
            local pfunc = function(v) 
              set_var(v, "hspeed", get_var(v, "hspeed") * 1.06)
              set_var(v, "vspeed", get_var(v, "vspeed") * 1.06)
            end
            local d = 45
            play_sound(get_asset("snd_shotspread"), get_var(obj, "x"))
            if (hard_mode) then d = d / 2 end
            for i = 0, 350, d do
              local a = spawn_projectile(get_var(obj, "x"), get_var(obj, "y"), rot_x(i) / 3, rot_y(i) / 3, get_asset("spr_bullet_medium_ice"))
              EnHelp.AddCallback(a, pfunc)
            end
            for i = d / 2, 350 + (d / 2), d do
              local a = spawn_projectile(get_var(obj, "x"), get_var(obj, "y"), rot_x(i) / 4, rot_y(i) / 4, get_asset("spr_bullet_dopple_blue"))
              set_var(a, "image_angle", call_function("point_direction", {0, 0, rot_x(i), rot_y(i)}))
              EnHelp.AddCallback(a, pfunc)
              end
          end
          set_var(obj, "vspeed", get_var(obj, "vspeed") - 0.2)
          if (get_var(obj, "y") < view_y - 30) then
            ChangeState(obj, {States.Tides, States.Dive})
          end
        end
        if (get_var(obj, "ai_timer") == 240) then
          for i = 0, 360, 45 do
            local x = rot_x(i)
            local y = rot_y(i)
            local a = spawn_particle(get_var(obj, "x") + (x * 60), get_var(obj, "y") + (y * 60), -x / 2, -y / 2, get_asset("spr_danger_new"))
            local pfunc = function(v) 
              set_var(v, "hspeed", get_var(v, "hspeed") * 0.9)
              set_var(v, "vspeed", get_var(v, "vspeed") * 0.9)
            end
            EnHelp.AddCallback(a, pfunc)
          end
          play_sound(get_asset("snd_gather_alt"), get_var(obj, "x"))
        end
      end
      -- Tides Attack
    elseif (get_var(obj, "state") == States.Tides) then
      init_var(obj, "flip_tides", 1)
      if (get_var(obj, "ai_timer") == 1) then
        set_var(obj, "flip_tides", 1)
        set_var(obj, "pushplayer", 1)
      end
      RotationMode = RotationModes.Omnidirectional
      init_var(obj, "pushplayer", 0)
      set_var(obj, "pushplayer", get_var(obj, "pushplayer") * 0.92)
      if (get_var(obj, "ai_timer") < 80) then
        set_var(obj, "tide_direction", (player_x < view_x + 120))
      end
      if (math.fmod(get_var(obj, "ai_timer"), 30) == 1) then
        local a = spawn_projectile(view_x + 120 - 5 + math.random(10), view_y + 70 + math.random(240), 0, 0, get_asset("spr_seal_ember_effect_blue"))
        set_var(a, "image_xscale", 0.2)
        set_var(a, "image_yscale", 0)
        EnHelp.AddCallback(a, function (v)
          init_var(v, "pfunctimer", 0)
          init_var(v, "pfunctarget", (10 + math.random(10)) / 5)
          if (get_var(v, "pfunctimer") < 60) then
            set_var(a, "image_yscale", lerp(get_var(v, "image_yscale"), get_var(v, "pfunctarget"), 0.08))
          else
            set_var(a, "image_yscale", lerp(get_var(v, "image_yscale"), -0.2, 0.1))
            if (get_var(a, "image_yscale") <= 0) then
              call_function("instance_destroy", {a, false})
            end
          end
          if (get_var(a, "image_yscale") < 0.2) then
            set_var(a, "mask_index", get_asset("obj_nothing"))
          else
            set_var(a, "mask_index", get_asset("spr_seal_ember_effect_blue"))
          end
          set_var(v, "pfunctimer", get_var(v, "pfunctimer") + 1)
        end)
      end
      if (get_var(obj, "ai_timer") <= 320) then
        if (math.fmod(get_var(obj, "ai_timer"), 80) > 60) then
          set_var(obj, "tide_direction", (player_x < view_x + 120))
        end
        set_var(obj, "hspeed", get_var(obj, "hspeed") * 1.06)
        if (math.fmod(get_var(obj, "ai_timer"), 80) >= 20 and math.fmod(get_var(obj, "ai_timer"), 80) <= 50) then
          local bb = (math.fmod(get_var(obj, "ai_timer"), 80) - 20) / 15
          if (get_var(obj, "tide_direction")) then
            set_var(obj, "pushplayer", math.max(get_var(obj, "pushplayer"), bb))
          else
            set_var(obj, "pushplayer", math.min(get_var(obj, "pushplayer"), -bb))
          end
        end
        if (math.fmod(get_var(obj, "ai_timer"), 80) == 20) then
          play_sound(get_asset("snd_gather"), view_x + 120)
        end
        if (math.fmod(get_var(obj, "ai_timer"), 80) == 50) then
          set_var(obj, "vspeed", 0)
          if (get_var(obj, "tide_direction")) then
            set_var(obj, "pushplayer", 8)
            teleportTailwind(obj, view_x - 50, view_y + 120 + math.random(60))
            for j = 1, 4 do
              for i = 1, 20 do
                local a = spawn_projectile(view_x + 25, view_y + 70 + math.random(240), (10 + math.random(20)) / 20 * j, math.random(-10, 10) / 10, get_asset("spr_enemy_bullet_plasma"))
                EnHelp.AddCallback(a, function (v)
                  set_var(v, "hspeed", get_var(v, "hspeed") - 0.2)
                end)
                EnHelp.AddCallback(a, rotateToVelocity)
              end
            end
            set_var(obj, "hspeed", 1)
          else
            teleportTailwind(obj, view_x + 290, view_y + 120 + math.random(60))
            set_var(obj, "pushplayer", -8)
            for j = 1, 4 do
              for i = 1, 20 do
                local a = spawn_projectile(view_x + 240 - 25, view_y + 70 + math.random(240), -(10 + math.random(20)) / 20 * j, math.random(-10, 10) / 10, get_asset("spr_enemy_bullet_plasma"))
                EnHelp.AddCallback(a, function (v)
                  set_var(v, "hspeed", get_var(v, "hspeed") + 0.2)
                end)
                EnHelp.AddCallback(a, rotateToVelocity)
              end
            end
            set_var(obj, "hspeed", -1)
          end
          play_sound(get_asset("snd_stream_impact"), lerp(view_x, get_var(obj, "x"), 0.2))
          play_sound(get_asset("snd_revolver"), view_x + 120)
          add_screenshake(5)
        end
        addStreak(view_x + math.random(240), view_y + 60 + math.random(240), get_var(obj, "pushplayer"), 0, 3)
      end
      if (get_var(obj, "ai_timer") == 390) then
        ChangeState(obj, {States.Dive, States.Gusts, States.SideRise})
      end
    -- Side Rise Attack
    elseif (get_var(obj, "state") == States.SideRise) then
      set_var(obj, "damage", 1)
      set_var(obj, "image_xscale", 1 + (math.sin(get_var(obj, "sinething") / 25) * 0.2))
      set_var(obj, "image_yscale", 1 - (math.sin(get_var(obj, "sinething") / 25) * 0.2))
      addStreak(view_x + math.random(240), view_y + 60 + math.random(240), 0, -3, 4)
      if (math.fmod(get_var(obj, "ai_timer"), 5) == 0) then
        play_sound_ext(get_asset("snd_succ"), 0.2 + (math.random(10) / 20), 0.5, view_x + 120)
        local pfunc = function(v)
          set_var(v, "vspeed", get_var(v, "vspeed") - 0.1)
          set_var(v, "image_yscale", lerp(get_var(v, "image_yscale"), 1, 0.1))
        end
        local a = spawn_projectile(view_x + math.random(20, 200), view_y + 70, (-10 + math.random(20)) / 50, (10 + math.random(20)) / 10, get_asset("spr_bullet_dopple_blue"))
        EnHelp.AddCallback(a, pfunc)
        EnHelp.AddCallback(a, rotateToVelocity)
      end
      if (player_dead == false) then
        set_var(player, "v_counter", -0.7)
      end
      if (get_var(obj, "ai_timer") <= 1) then
        local bv = math.random(50) < 25
        if (bv) then
          set_var(obj, "flip_rising", 1)
        else
          set_var(obj, "flip_rising", -1)
        end
      end
      local f = math.fmod(get_var(obj, "ai_timer"), 120)
      local projTime = math.fmod(get_var(obj, "ai_timer"), 15)
      if (projTime == 2 and f > 20) then
        play_sound_ext(get_asset("snd_gun_empty"), 0.5 + (math.random(10) / 30), 0.5, get_var(obj, "x"))
        play_sound_ext(get_asset("snd_fireball_fire"), 1, 1.2, get_var(obj, "x"))
        local part = spawn_particle(get_var(obj, "x") - (get_var(obj, "flip_rising") * 30), get_var(obj, "y"), 0, 0, get_asset("spr_lightning_gigaball"))
        EnHelp.AddCallback(part, function(v)
          set_var(v, "image_xscale", (get_var(v, "image_xscale") * 0.8))
          set_var(v, "image_yscale", (get_var(v, "image_yscale") * 0.8))
        end)
        for i = 1, 3 do
          local a = spawn_projectile(get_var(obj, "x") - (get_var(obj, "flip_rising") * 30), get_var(obj, "y"), -(get_var(obj, "flip_rising") * math.random(1, 10) / 5), 0, get_asset("spr_enemy_bullet_spark_shot"))
          set_var(a, "image_yscale", 0)
          EnHelp.AddCallback(a, function(v) 
            set_var(v, "hspeed", get_var(v, "hspeed") * 1.06)
            set_var(v, "image_xscale", (sign(get_var(v, "hspeed"))) + (get_var(v, "hspeed") / 6))
            set_var(v, "image_yscale", lerp(get_var(v, "image_yscale"), 1, 0.1))
          end)
        end
      end
      if (f < 60) then
        if (f == 1) then
          set_var(obj, "flip_rising", -get_var(obj, "flip_rising"))
          teleportTailwind(obj, view_x + 120 + (get_var(obj, "flip_rising") * 80), view_y + 350)
          set_var(obj, "hspeed", 0)
          set_var(obj, "vspeed", -3.5)
        end
        set_var(obj, "vspeed", get_var(obj, "vspeed") * 0.99)
      else
        set_var(obj, "vspeed", get_var(obj, "vspeed") * 1.03)
      end
      if (get_var(obj, "ai_timer") >= 235) then
        set_var(obj, "damage", 0)
        ChangeState(obj, {States.Dive})
      end
    end
    set_var(obj, "ai_timer", get_var(obj, "ai_timer") + 1)
  end

  -- body curving

  table.insert(tailwind_Trail, 1, {get_var(obj, "x"), get_var(obj, "y")}) -- insert the current coordinate to the beginning of tailwind_Trail
  if (#tailwind_Trail > 20) then -- if the amount of coordinates in tailwind_Trail is more than 20, delete the backmost one
    table.remove(tailwind_Trail, 20)
  end
  if (RotationMode == RotationModes.Omnidirectional) then
    set_var(obj, "image_angle", call_function("point_direction", {0, 0, get_var(obj, "hspeed"), get_var(obj, "vspeed")}) - 90)
    for i = #tailwind_Trail, 2, -1 do -- extra math stuff for a tiny little bit of extra polish, ignore this if you'd like
      local dist = math.min(call_function("point_distance", {tailwind_Trail[i - 1][1], tailwind_Trail[i - 1][2], tailwind_Trail[i][1], tailwind_Trail[i][2]}), 5)
      local dir = call_function("point_direction", {tailwind_Trail[i - 1][1], tailwind_Trail[i - 1][2], tailwind_Trail[i][1], tailwind_Trail[i][2]})
      tailwind_Trail[i][1] = tailwind_Trail[i - 1][1] + (rot_x(dir) * dist)
      tailwind_Trail[i][2] = tailwind_Trail[i - 1][2] + (rot_y(dir) * dist)
    end
  else
    set_var(obj, "image_angle", 0)
    for i = #tailwind_Trail, 1, -1 do -- extra math stuff for a tiny little bit of extra polish, ignore this if you'd like
      local yy = get_var(obj, "y") + (i * 6)
      local inc = 1 / i
      tailwind_Trail[i][1] = lerp(tailwind_Trail[i][1], get_var(obj, "x"), inc)
      tailwind_Trail[i][2] = lerp(tailwind_Trail[i][2], yy, inc)
    end
  end
end

tailwind.Destroy = function(obj)
  
end

register_data(tailwind)