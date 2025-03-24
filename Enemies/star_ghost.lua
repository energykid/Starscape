star_ghost_DeathSound = custom_sound("Starscape/Enemies/star_ghost_kill.ogg")

star_ghost_Sprite = custom_sprite("Starscape/Enemies/star_ghost_asleep.png", 4, 9, 9, 40)
star_ghost_ActiveSprite = custom_sprite("Starscape/Enemies/star_ghost.png", 4, 9, 9, 60)

star_ghost = enemy_data("star_ghost")

star_ghost.Create = function(obj) 
  debug_out("blah")
  set_var(obj, "sprite_index", star_ghost_Sprite)
  set_var(obj, "pass_wall", 1)
  set_var(obj, "hp", 75)
  set_var(obj, "maxhp", 75)
  set_var(obj, "debris_score", 20)
end

star_ghost.Step = function(obj)  
  init_var(obj, "activation_timer", 0)
  
  set_var(obj, "activation_timer", get_var(obj, "activation_timer") + 1)
  
  if (get_var(obj, "activation_timer") >= 60) then
    set_var(obj, "sprite_index", star_ghost_ActiveSprite)
  
    local dir = get_direction(get_var(obj, "x"), get_var(obj, "y"), get_var(player, "x"), get_var(player, "y"))
    
    set_var(obj, "hspeed", lerp(get_var(obj, "hspeed"), dir.x, 0.12))
    set_var(obj, "vspeed", lerp(get_var(obj, "vspeed"), dir.y, 0.12))
    
    set_var(obj, "hspeed", get_var(obj, "hspeed") * 0.99)
    set_var(obj, "vspeed", get_var(obj, "vspeed") * 0.99)
  end
end

star_ghost.TakeDamage = function(obj, dmg) 
  set_var(obj, "activation_timer", 60)
end

star_ghost.Destroy = function(obj)  
  play_sound(star_ghost_DeathSound, get_var(obj, "x"))
end

register_data(star_ghost)