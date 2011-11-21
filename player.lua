
--[[                                            PLAYER MOVEMENT                                    ]]--

function init_player(w, h)

    -- predefined values
    player = {}
    player.x = w/2
    player.y = h/2
    player.speed = 190
    player.original_speed = 190
    player.walked = 0
    player.img = love.graphics.newImage("img/player.png")
    player.shot_img = love.graphics.newImage("img/player_shots.png")
    player.angle = 0
    player.nsteps = 1
    player.shot_steps = 3
    player.alive = 0
    player.killed = 0
    player.last_step = 0
    
    -- health 
    player.time_grabbed = 0
    player.health = {}
    player.health.max = 3
    player.health. curr = 3
    
    -- players positions on tileset image
    player.step = {}
    player.step[0] = love.graphics.newQuad(0, 0, 32, 32, 128, 32)
    player.step[1] = love.graphics.newQuad(32, 0, 32, 32, 128, 32)
    player.step[2] = love.graphics.newQuad(64, 0, 32, 32, 128, 32)
    player.step[3] = love.graphics.newQuad(96, 0, 32, 32, 128, 32)
  
    
    return player
    
end

-- movement functions, bounds applied
function move_left(player, dt)
    player.walked = player.walked + player.speed* dt
    if player_collides(player,tiles) then 
        --player.x = math.clamp (player.x - 10, 0, player.bound_x)
    else
        player.x = player.x + player.speed * dt
        player.last_step = 1
    end
end

function move_right(player, dt)
    player.walked = player.walked + player.speed* dt
    if player_collides(player,tiles) then 
        --player.x = math.clamp (player.x + 10, 0, player.bound_x)
    else
        player.x = player.x - player.speed * dt
        player.last_step = 2
    end
end

function move_up(player, dt)
    player.walked = player.walked + player.speed* dt
    if player_collides(player,tiles) then 
        --player.y = math.clamp (player.y + 10, 0, player.bound_y)
    else
        player.y = player.y - player.speed * dt
        player.last_step = 3
    end
end

function move_down(player, dt)
    player.walked = player.walked + player.speed* dt
    if player_collides(player,tiles) then 
        --player.y = math.clamp (player.y - 10, 0, player.bound_y)
    else
        player.y = player.y + player.speed * dt
        player.last_step = 4
    end
end

-- sprite is looking right so angle must be modified
function player_angle(player, mouse_x, mouse_y)
    local angle = math.getAngle(mouse_x, mouse_y, player.x, player.y)
    player.angle = -angle - math.pi/2
end

-- zombies killed, calling this function means you rock :D
function player_kill(player)
    player.killed = player.killed + 1
end

-- sets the shooting sprite we are on now
function player_shootstep(player, shot)
    if shot.left > 0 then
       if shot.not_shooting > 0.2 then 
           player.shot_steps = 3
       elseif shot.not_shooting > 0.15 then
           player.shot_steps = 2
       elseif shot.not_shooting > 0.1 then
           player.shot_steps = 1
       elseif shot.not_shooting > 0.05 then
          player.shot_steps = 0
       end
    end
end

-- sets the walking sprite we are on now
function player_step(player)
    if player.walked > 30 then 
        player.walked = 0
        if player.nsteps < 3 then
            player.nsteps = player.nsteps + 1
        else
            player.nsteps = 0
        end
    end
end

function player_move(tiles, dt)
    -- moving or not, you are alive one more moment
    player.alive = player.alive + dt
    if player_in_mud(player, tiles) then
        player.speed = player.original_speed * 0.4
    else
        player.speed = player.original_speed
    end
    
    if player_collides(player,tiles) then 
        if player.last_step == 1 then
            player.x = player.x - 1
        elseif player.last_step == 2 then
            player.x = player.x + 1
        elseif player.last_step == 3 then
            player.y = player.y + 1
        elseif player.last_step == 4 then
            player.y = player.y - 1
        end
        return
    end
    
    
    
    -- player movement, including diagonal
    if love.keyboard.isDown("d") and love.keyboard.isDown("w") then
        move_left(player, dt * 0.7)
	move_up(player, dt * 0.7)
    elseif love.keyboard.isDown("a") and love.keyboard.isDown("w") then
        move_right(player, dt * 0.7)
	move_up(player, dt * 0.7)
    elseif love.keyboard.isDown("d") and love.keyboard.isDown("s") then
        move_left(player, dt * 0.7)
        move_down(player, dt * 0.7)
    elseif love.keyboard.isDown("a") and love.keyboard.isDown("s") then
        move_right(player, dt * 0.7)
	move_down(player, dt * 0.7)
    -- straight player movement
    elseif love.keyboard.isDown("d") then
        move_left(player, dt)
    elseif love.keyboard.isDown("a") then
        move_right(player, dt)
    elseif love.keyboard.isDown("w") then
        move_up(player, dt)
    elseif love.keyboard.isDown("s") then
        move_down(player, dt)
    end
    
end

function player_attacked(player, zombie_list, dt)
-- CheckCollision(box1x, box1y, box1w, box1h, box2x, box2y, box2w, box2h)
  for i,z in ipairs(zombie_list) do
                if CheckCollision(z.x -10, z.y -10, 20, 20, player.x - 10, player.y - 10, 20, 20) then
		    player.speed = 90
		    -- yes, two zombies means twice damage
	            player.time_grabbed = player.time_grabbed + dt
		    if player.time_grabbed > 0.5 then
		        player.health.curr = player.health.curr - 1
			player.time_grabbed = 0
		    end
		end
  player.speed = 190
  end
end

-- is my player dead?
function player_dead(player, zombie_list)
    if player.health.curr == 0 then
        return true
    else
        return false
    end
end

function draw_player(player, menu)
    -- player.step contains the quads (sprites)
    -- player.nsteps contains actual sprite we are on
    love.graphics.setColor(200, 200, 200)
    love.graphics.drawq(player.img, player.step[player.nsteps], player.x, player.y, player.angle, 1, 1, 32 / 2, 32 / 2)
    love.graphics.drawq(player.shot_img, player.step[player.shot_steps], player.x, player.y, player.angle, 1, 1, 32 / 2, 32 / 2)
    
    -- health bar
    love.graphics.setColor(200, 0, 0, 200)
    if menu.health_bar then
        love.graphics.rectangle("fill", player.x - 10*player.health.max / 2, player.y - 15, 10*player.health.max, 3)
	love.graphics.setColor(0, 200, 0, 200)
	love.graphics.rectangle("fill", player.x - 10*player.health.max / 2, player.y - 15, 10*player.health.curr, 3)
    else
        love.graphics.rectangle("fill", camera:getX() + 5, camera:getY() + 5, 30*player.health.max, 25)
	love.graphics.setColor(0, 200, 0, 200)
        love.graphics.rectangle("fill", camera:getX() + 5, camera:getY() + 5, 30*player.health.curr, 25)
    end
	  
    
    --love.graphics.print(" "..string.format("%02d", player.x).." "..string.format("%02d",player.y), player.x, player.y)
end