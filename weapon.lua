--[[                                            SHOOTING                                    ]]--

function init_weapon()
    -- default values 
    weapon = {}
    weapon.speed = 14
    weapon.pack = 8
    weapon.left = weapon.pack
    weapon.angle = 0
    weapon.not_shooting = 1
    weapon.not_reloading = 1
    weapon.img = love.graphics.newImage("img/bullet.png")
    weapon.bulletQ = love.graphics.newQuad(0,0, 4, 8, 16, 16)
    weapon.rockQ = love.graphics.newQuad(6,0, 7, 8, 16, 16)
    weapon.bullets = {}
    weapon.rocked = {}
    weapon.blink = false
    weapon.blink_time = 0
    return weapon
end

function shoot(player, mouse_x, mouse_y, weapon)
  if weapon.left > 0 then
   -- create a bullet
   local s = {}
   -- it's on the player
   s.x = player.x
   s.y = player.y
   -- aiming mouse
   s.dirx = mouse_x - player.x
   s.diry = mouse_y - player.y
   s.dirx, s.diry, _ = math.normalize(s.dirx, s.diry)
   local angle = math.getAngle(mouse_x, mouse_y, s.x, s.y)
   s.angle = -angle
   
   -- offset calculation:
   -- it's not on the player, it's on the gun
   s.y = s.y + 3 * math.sin(s.angle)
   s.x = s.x + 8 * math.cos(s.angle) 
   
   -- get to list of shots, one less on cardtridge, gunshot sound
   table.insert(weapon.bullets, s)
   weapon.left = weapon.left - 1
   TEsound.play("sound/shot.ogg")
  else
    -- no ammo left!
    weapon.blink = true    
    TEsound.play("sound/empty.ogg")
  end
end


function shoot_control(player, mouse_x, mouse_y, shot, dt)
    if player.alive < 0.2 then return end

    -- so I heard you want to shoot?
    if love.mouse.isDown("l") then
      -- you can't shoot unless it's 1/3 seconds past from last
      if weapon.not_shooting > 0.3 and weapon.not_reloading > 0.8 then
          -- shoot
	  shoot(player, mouse_x, mouse_y, weapon, weapon.bullets)
	  weapon.not_shooting = 0
      end
    elseif love.mouse.isDown("r") then
     -- same for realoading
      if weapon.not_reloading > 1.5 then
          reload_weapon(weapon)
	  weapon.not_reloading = 0
	  weapon.blink = false
      end
    end
end

function update_shots(weapon, dt)
    -- move every shot in its direction
    for i,v in ipairs(weapon.bullets) do
      v.x = v.x + (weapon.speed * v.dirx)
      v.y = v.y + (weapon.speed * v.diry)
      if v.x > tiles.w or v.x < 0 or v.y > tiles.h or v.y < 0 then
        table.remove(weapon.bullets, i)
      end
    end
    
    -- keep track of the bullet rebound flash
    for i,sh in ipairs(weapon.rocked) do
      sh.time = sh.time + dt
      if sh.time > 0.1 then
        table.remove(weapon.rocked, i)
      end
    end
    
    -- which bullets hit rocks?
    bullets_hit_rocks(weapon.bullets)
    
    -- keep the time counting
    weapon.not_shooting = weapon.not_shooting + dt
    weapon.not_reloading = weapon.not_reloading + dt
    
    if weapon.blink then
        weapon.blink_time = weapon.blink_time + dt
        -- blink every 1/3 seconds
        if weapon.blink_time > 0.6 then
            weapon.blink_time = 0
        end
    end
end

-- this needs no explanation
function reload_weapon(weapon)
    weapon.left = weapon.pack
    TEsound.play("sound/reload.ogg")
end

function bullets_hit_rocks(shot_list)
    for k,sh in ipairs(shot_list) do
        if player_collides(sh,tiles) then
            sh.time = 0
            table.insert(weapon.rocked, sh) 
            if math.dist(player.x,player.y, sh.x,sh.y) < 400 then
                TEsound.play("sound/rock.wav")
            end
            table.remove(shot_list, k)
        end
    end
end

function draw_shots(weapon, player)
  love.graphics.setColor(200, 200, 200)
      -- draw shots
      for k,sh in ipairs(weapon.bullets) do
	  love.graphics.drawq(weapon.img, weapon.bulletQ, sh.x, sh.y, sh.angle, 0.6, 0.8)
	end

      for k,sh in ipairs(weapon.rocked) do
	  love.graphics.drawq(weapon.img, weapon.rockQ, sh.x, sh.y, sh.angle, 0.6, 0.8)
	end
	  
   
  -- ammo left
  if weapon.blink == false then
      for i = 1, weapon.left do
          love.graphics.setColor(200, 200, 200)
          love.graphics.drawq(weapon.img, weapon.bulletQ, 500 + camera:getX() - 11 * i, camera:getY() + 10, 0, 2, 2)
          --love.graphics.print(string.format("%02d",shot.left), camera:getX() +10 + 20, camera:getY() + 10)
      end
  elseif weapon.blink_time < 0.3 then
      love.graphics.setColor(250, 0, 0)
      love.graphics.print("RELOAD", 410 + camera:getX() +10, camera:getY() + 5)
  end
   
end