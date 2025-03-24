gossamer_Sprite = custom_sprite("Starscape/Enemies/gossamer.png", 4, 7, 11, 10)

gossamer = enemy_data("gossamer")

gossamer.Create = function(obj)
  debug_out("blah")
  set_var(obj, "sprite_index", gossamer_Sprite)
  set_var(obj, "pass_wall", 1)
  set_var(obj, "hp", 90)
  set_var(obj, "maxhp", 90)
  set_var(obj, "debris_score", 30)
  set_var(obj, "target_x", get_var(player, "x"))
  set_var(obj, "target_y", get_var(player, "y"))
end

gossamer.Step = function(obj)
  init_var(obj, "timer", 0)
  local time = math.fmod(get_var(obj, "timer"), 110)
  local dir = get_direction(get_var(obj, "x"), get_var(obj, "y"), get_var(player, "x"), get_var(player, "y"))
  if (time == 65) then
    play_sound_ext(get_asset("snd_gulp"), 0.6 + (math.random(10) / 40), 0.3, get_var(obj, "x"))
  end
  if (time > 50 and time < 60) then
    set_var(obj, "image_xscale", lerp(get_var(obj, "image_xscale"), 1.7, 0.15))
    set_var(obj, "image_yscale", lerp(get_var(obj, "image_yscale"), 0.4, 0.15))
  elseif (time > 60 and time < 75) then
    set_var(obj, "image_xscale", lerp(get_var(obj, "image_xscale"), 0.7, 0.1))
    set_var(obj, "image_yscale", lerp(get_var(obj, "image_yscale"), 1.3, 0.1))
    local speed = 2.5
    set_var(obj, "hspeed", lerp(get_var(obj, "hspeed"), dir.x * speed, 0.15))
    set_var(obj, "vspeed", lerp(get_var(obj, "vspeed"), dir.y * speed, 0.15))
  else
    set_var(obj, "image_xscale", lerp(get_var(obj, "image_xscale"), 1, 0.04))
    set_var(obj, "image_yscale", lerp(get_var(obj, "image_yscale"), 1, 0.04))
    local speed = 0.2
    set_var(obj, "hspeed", lerp(get_var(obj, "hspeed"), dir.x * speed, 0.01))
    set_var(obj, "vspeed", lerp(get_var(obj, "vspeed"), dir.y * speed, 0.01))
  end
  local dist = call_function("point_distance", {
      0,
      0,
      get_var(obj, "hspeed"),
      get_var(obj, "vspeed")})
  local direc = call_function("point_direction", {
      0,
      0,
      get_var(obj, "hspeed"),
      get_var(obj, "vspeed")})
  set_var(obj, "image_index", get_var(obj, "image_index") + dist / 5)
  set_var(obj, "image_angle", direc - 90)
  set_var(obj, "timer", get_var(obj, "timer") + 1)
end

register_data(gossamer)