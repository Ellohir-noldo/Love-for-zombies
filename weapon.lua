--[[                                            SHOOTING                                    ]]--

function init_weapon()
    -- default values 
    weapon = {}
    
    weapon.handgun = {}
    weapon.handgun.img = love.graphics.newImage("img/handgun.png")
    weapon.handgun.pack = 8
    weapon.handgun.left = weapon.handgun.pack
    weapon.handgun.rate = 0.3
    weapon.handgun.not_shooting = 1
    weapon.handgun.not_reloading = 1
    weapon.handgun.reload_time = 0.75
    weapon.handgun.reload_sound = "sound/reload_gun.mp3"
    weapon.handgun.time_frame_0 = 0.05
    weapon.handgun.time_frame_1 = 0.10
    weapon.handgun.time_frame_2 = 0.15
    weapon.handgun.time_frame_3 = 0.20
    
    
    weapon.machinegun = {}
    weapon.machinegun.img = love.graphics.newImage("img/machinegun.png")
    weapon.machinegun.pack = 16
    weapon.machinegun.left = weapon.machinegun.pack
    weapon.machinegun.rate = 0.1
    weapon.machinegun.not_shooting = 1
    weapon.machinegun.not_reloading = 1
    weapon.machinegun.reload_time = 2.5
    weapon.machinegun.reload_sound = "sound/reload_mg.mp3"
    weapon.machinegun.time_frame_0 = 0.01
    weapon.machinegun.time_frame_1 = 0.03
    weapon.machinegun.time_frame_2 = 0.06
    weapon.machinegun.time_frame_3 = 0.10
    
    weapon.current = weapon.handgun
    
    
    weapon.img = love.graphics.newImage("img/bullet.png")
    weapon.gunui = love.graphics.newImage("img/gunui.png")
    weapon.bullet_speed = 18
    weapon.angle = 0
    weapon.bulletQ = love.graphics.newQuad(0,0, 4, 8, 16, 16)
    weapon.rockQ = love.graphics.newQuad(6,0, 7, 8, 16, 16)
    weapon.bullets = {}
    weapon.rocked = {}
    weapon.blink = false
    weapon.blink_time = 0
    return weapon
end

function shoot(player, mouse_x, mouse_y, weapon)
  if weapon.current.left > 0 then
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
   s.y = s.y + 7 * math.sin(s.angle)
   s.x = s.x + 8 * math.cos(s.angle) 
   
   -- get to list of shots, one less on cardtridge, gunshot sound
   table.insert(weapon.bullets, s)
   weapon.current.left = weapon.current.left - 1
   TEsound.play("sound/shot.mp3")
  else
    -- no ammo left!
    weapon.blink = true    
    TEsound.play("sound/empty.mp3")
  end
end


function shoot_control(player, mouse_x, mouse_y, shot, dt)
    if player.talive < 0.2 then return end

    -- so I heard you want to shoot?
    if love.mouse.isDown("l") then
      -- you can't shoot unless it's some time past from last
      if weapon.current.not_shooting > weapon.current.rate and weapon.current.not_reloading > weapon.current.reload_time then
          -- shoot
	  shoot(player, mouse_x, mouse_y, weapon, weapon.bullets)
	  weapon.current.not_shooting = 0
      end
    elseif love.mouse.isDown("r") then
     -- same for realoading
      if weapon.current.not_reloading > weapon.current.reload_time then
          reload_weapon(weapon)
	  weapon.current.not_reloading = 0
	  weapon.blink = false
      end
    end
end

function update_shots(weapon, dt)
    -- move every shot in its direction
    for i,v in ipairs(weapon.bullets) do
      v.x = v.x + (weapon.bullet_speed * v.dirx)
      v.y = v.y + (weapon.bullet_speed * v.diry)
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
    weapon.current.not_shooting = weapon.current.not_shooting + dt
    weapon.current.not_reloading = weapon.current.not_reloading + dt
    
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
    weapon.current.left = weapon.current.pack
    TEsound.play(weapon.current.reload_sound)
end

function bullets_hit_rocks(shot_list)
    for k,sh in ipairs(shot_list) do
        if player_collides(sh,tiles) then
            sh.time = 0
            table.insert(weapon.rocked, sh) 
            if math.dist(player.x,player.y, sh.x,sh.y) < 400 then
                TEsound.play("sound/rock.mp3")
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
      for i = 1, weapon.current.left do
          love.graphics.setColor(200, 200, 200)
          love.graphics.drawq(weapon.img, weapon.bulletQ, 500 + camera:getX() - 11 * i, camera:getY() + 10, 0, 2, 2)
          --love.graphics.print(string.format("%02d",shot.left), camera:getX() +10 + 20, camera:getY() + 10)
      end
  elseif weapon.blink_time < 0.3 then
      love.graphics.setColor(250, 0, 0)
      love.graphics.print("RELOAD", 410 + camera:getX() +10, camera:getY() + 5)
  end
   
   -- draw gun uni
   
    love.graphics.setColor(200, 200, 200)
    love.graphics.draw(weapon.gunui, camera:getX(), camera:getY() + 480)
    love.graphics.setColor(200, 0, 0, 200)
    if weapon.current == weapon.handgun then
	love.graphics.rectangle("line", camera:getX()+1, camera:getY() + 479, 32, 32)
	love.graphics.setColor(200, 0, 0, 30)
	love.graphics.rectangle("fill", camera:getX()+1, camera:getY() + 479, 32, 32)
    elseif weapon.current == weapon.machinegun then
        love.graphics.rectangle("line", camera:getX() + 33, camera:getY() + 479, 32, 32)
	love.graphics.setColor(200, 0, 0, 30)
	love.graphics.rectangle("fill", camera:getX() + 33, camera:getY() + 479, 32, 32)
    end
end