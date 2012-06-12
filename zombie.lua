
--[[                                            ENEMIES                                    ]]--

function init_zombie()
    -- default values
    zombie = {}
    zombie.img = love.graphics.newImage("img/zombie.png")
    zombie.dimg = love.graphics.newImage("img/dying.png")
    zombie.list = {}
    zombie.dying = {}
    
    zombie.spawn_time = 0
    zombie.time_to_spawn = 0.8 -- every 0.8 seconds a new zombie 
    
    -- players positions on tileset
    zombie.step = {}
    zombie.step[0] = love.graphics.newQuad(0, 0, 32, 32, 256, 32)
    zombie.step[1] = love.graphics.newQuad(32, 0, 32, 32, 256, 32)
    zombie.step[2] = love.graphics.newQuad(64, 0, 32, 32, 256, 32)
    zombie.step[3] = love.graphics.newQuad(96, 0, 32, 32, 256, 32)
    zombie.step[4] = love.graphics.newQuad(128, 0, 32, 32, 256, 32)
    zombie.step[5] = love.graphics.newQuad(160, 0, 32, 32, 256, 32)
    
    return zombie
end

function new_zombie(zombie_list, player)
    -- create zombie
    local z = {}
    -- random position
    z.x = math.clamp(player.x + math.random(500) * math.rsign(), 0 + 2*tiles.tileW, tiles.w - 2*tiles.tileW)
    z.y = math.clamp(player.y + math.random(500) * math.rsign(), 0 + 2*tiles.tileH, tiles.h - 2*tiles.tileH)
    -- but not too close
    if math.dist(z.x, z.y, player.x, player.y) < 100 or player_collides(z) then
        new_zombie(zombie_list, player)
	return
    end
    -- point towards player
    z.angle = math.getAngle(player.x, player.y, z.x, z.y)
    z.walked = 0
    z.nsteps = 1
    z.health = {}
    
    -- stats for this new zombie
    local r = math.random(100)
    if   r > 80 then
        -- fast, red zombie
        z.speed = 150
        z.original_speed = z.speed
        z.health.max = 2
    elseif r < 10 then
        -- slow black zombie
        z.speed = 50
        z.original_speed = z.speed
        z.health.max = 5
    else
      -- common zombie
        z.speed = 60 + math.random (30)
        z.original_speed = z.speed
	z.health.max = 1
    end
    z.health.curr = z.health.max
    
    -- direction towards player
    z.dirx = player.x - z.x
    z.diry = player.y - z.y
    z.dirx, z.diry, _ = math.normalize(z.dirx, z.diry)
    
    z.last_dirx = z.dirx
    z.last_diry = z.diry
    
    table.insert(zombie_list, z)
end


function update_zombies(zombie, player, tiles, dt)
    if zombie.spawn_time > zombie.time_to_spawn then
        new_zombie(zombie.list, player)
	zombie.spawn_time = 0
    else 
        zombie.spawn_time = zombie.spawn_time + dt
    end

    -- for every living dead
    for i,v in ipairs(zombie.list) do
        -- direction is to player's brain
	v.dirx = player.x - v.x
        v.diry = player.y - v.y
	v.dirx, v.diry, _ = math.normalize(v.dirx, v.diry)
        
	-- update angle
	v.angle = math.getAngle(player.x, player.y, v.x, v.y)
	
        if player_in_mud(v, tiles) then
                v.speed = v.original_speed * 0.4
        else
                v.speed = v.original_speed
        end
        
        v.walked = v.walked + (v.speed * dt)
        

        -- movement with colision detection and all
        dx =  (v.speed * v.dirx * dt)
        dy =  (v.speed * v.diry * dt)
        
        local currX=v.x
        v.x=v.x+dx    
        if player_collides(v,tiles) then 
                v.x=currX
        end
    
        local currY= v.y
        v.y=v.y+dy
        if player_collides(v,tiles) then 
                v.y=currY
        end
        
	-- changing sprite as walking
        if   v.walked > 30 then 
            v.walked = 0
            if v.nsteps < 4 then
                v.nsteps = v.nsteps + 1
            else
                v.nsteps = 0
            end
        end
	
    end
    
    -- for every dead-dead
    for i,v in ipairs(zombie.dying) do
        -- how long you been dead-dead?
	v.tdead = v.tdead + dt
	-- choose sprite accordingly
	if v.tdead > 8 then
	    table.remove(zombie.dying, i)
	elseif v.tdead < 0.05 then
	    v.deadsprite = 0 
	elseif v.tdead < 0.1 then
	    v.deadsprite = 1
	elseif v.tdead < 0.15 then
	    v.deadsprite = 2
	elseif v.tdead < 0.4 then
	    v.deadsprite = 3
	elseif v.tdead < 0.8 then
	    v.deadsprite = 4
	elseif v.tdead < 1.5 then
	    v.deadsprite = 5
	end
    end
end


function zombies_shot(zombie, shot_list, player)
-- CheckCollision(box1x, box1y, box1w, box1h, box2x, box2y, box2w, box2h)
  for i,z in ipairs(zombie.list) do
      for k,sh in ipairs(shot_list) do
          if CheckCollision(z.x -10, z.y -10, 20, 20, sh.x, sh.y, 1, 1) then
	        -- bullet wasted, zombie hit
		table.remove(shot_list, k)
	        z.health.curr = z.health.curr -1
		TEsound.play("sound/kill.ogg")
		-- if the dead dies
		if z.health.curr == 0 then
	            -- zombie and bullet disappear
         	    table.remove(zombie.list, i)
                    -- but a corpse is created
		    z.tdead = 0
                    z.deadsprite = 0
		    -- count one more, player!
		    player_kill(player)
		    table.insert(zombie.dying, z)
		end
	  end
      end
  end
end

function draw_zombie_corpses(zombies)
  love.graphics.setColor(200, 200, 200)
  
  -- draw the deading dead
    for i,v in ipairs(zombie.dying) do
    	  if v.health.max == 2 then
	      -- draw red zombie corpse
              love.graphics.setColor(200, 120, 120)
	  elseif v.health.max == 5 then
	      -- draw black zombie corpse
              love.graphics.setColor(120, 120, 120)
	  end
      love.graphics.drawq(zombie.dimg, zombie.step[v.deadsprite], v.x, v.y, -v.angle - math.pi/2, 1, 1, 32 / 2, 32 / 2)
  end
end

function draw_zombies(zombies)
  love.graphics.setColor(200, 200, 200)
  
  -- draw the living dead
  for i,v in ipairs(zombie.list) do
      -- if the zombie is strong
      if v.health.max > 1 then 
          -- draw health bars
          love.graphics.setColor(200, 0, 0)
          love.graphics.rectangle("fill", v.x - 10*v.health.max / 2, v.y - 15, 10*v.health.max, 3)
          love.graphics.setColor(0, 200, 0)
          love.graphics.rectangle("fill", v.x - 10*v.health.max / 2, v.y - 15, 10*v.health.curr, 3)
	  if v.health.max == 2 then
	      -- draw red zombie
              love.graphics.setColor(200, 120, 120)
	  else
	      -- draw black zombie
              love.graphics.setColor(120, 120, 120)
	  end
      end
      -- draw zombie
      love.graphics.drawq(zombie.img, zombie.step[v.nsteps], v.x, v.y, -v.angle - math.pi/2, 1, 1, 32 / 2, 32 / 2)
      love.graphics.setColor(200, 200, 200)
  end
end