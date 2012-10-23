require('math_snippet')
require('camera')

require('player')
require('weapon')
require('zombie')
require('tiles')
require('menu')
require('TEsound')
require('rain')
require('savetabletofile')

--[[                                            LOVE.LOAD                                    ]]--
function love.load()
	-- Pixel art means pixel scale
	love.graphics.setDefaultImageFilter('linear','linear')

    -- Initialize the pseudo random number generator
    math.randomseed( os.time() )
    math.random(); math.random(); math.random();
    -- done. :-)

    
    
    -- initialize
    menu = init_menu()
    tiles = init_tiles()
    --load_map(tiles, "maps/map1.lua")
    player = init_player()    
    weapon = init_weapon()
    zombie = init_zombie()
    rain = init_rain()
    
    if TEsound.disable then
        TEsound.disable_sound()
        menu.sound = false
    end
    
    -- camera doesn't go behind tilemap, game is not paused
    camera:setBounds(0, 0, tiles.w - 512, tiles.h - 512)
    gameIsPaused = false
    
end

--[[                                              LOVE.KEYPRESSED                                              ]]--

-- pressing keys while on menus
function love.keypressed( key )

    if key == "escape" then
	gameIsPaused = not gameIsPaused
    end
    
    update_menus(menu, key)
   
end

-- pressing keys while on menus
function love.keyreleased( key )
    if menu.highscore then
        if key == "rshift" or key == "lshift" then
            menu.key_shift = false
	elseif key == "capslock" then
	    menu.key_capslock = false
        end
    end
end


--[[                              LOVE.QUIT   and   LOVE.FOCUS                                     ]]--

function love.quit()
  -- print("Thanks for playing! Come back soon!")
end

-- Lose focus = pause, get focus = unpause
function love.focus(f) 
	
	if f == false then
		gameIsPaused = true
		TEsound.disable_sound()
                rain.playing = false
	elseif menu.sound then
                TEsound.enable_sound()
                TEsound.playLooping("sound/bgm.ogg", "bgm")
	end
        
end

--[[                              LOVE.MOUSEPRESSED                                     ]]--
function love.mousepressed(x, y, button)
    -- if we are paused we are done
    if gameIsPaused then return end      
    -- CLICKING ON MENUS!!
    update_menus(menu, _, button)
end

--[[                                              LOVE.UPDATE                                              ]]--
function love.update(dt)
      -- sound management
      TEsound.cleanup()
  
  
     -- camera and mouse updates
    camera:setPosition(player.x - 512/2, player.y - 512/2)
    mouse_x, mouse_y = camera:mousePosition()
  

    -- if we are paused we are done
    if gameIsPaused then return end      

    
    -- different updates for different menus
    if menu.gamestart then
        update_start_menu(menu)
        TEsound.stop("rain")
	rain.playing = false
    elseif menu.showHS then
        update_highscore_list(menu)
    elseif menu.highscore then
        blink_highscore_menu(menu, dt)
    elseif menu.settings then
        update_settings_menu(menu)
    elseif player_dead(player, zombie.list) then
        TEsound.stop("rain")
	rain.playing = false
	update_gameover_scene(menu)
	-- and don't do anything else
    else   
        -- self-explanatory playing functions
        player_move(tiles, dt)
        shoot_control(player, mouse_x, mouse_y, weapon, dt)
        update_shots(weapon, dt)
        update_zombies(zombie, player, tiles, dt)
	update_rain(rain, dt)
        zombies_shot(zombie, weapon.bullets, player)
	player_attacked(player, zombie.list, dt)
	
        player_angle(player, mouse_x, mouse_y)
        player_step(player)
	player_shootstep(player, weapon)
    end
end

--[[                                               LOVE.DRAW                                   ]]--
function love.draw()

  -- use camera
  camera:set()
  
  -- self-explanatory draw functions
  draw_tiles(tiles)
  draw_zombie_corpses(zombie)
  -- player is above corpses
  draw_player(player, menu)
  -- but zombies cover player
  draw_zombies(zombie)
  -- up it rain, shots and health
  draw_rain(rain)
  draw_shots(weapon, player)  
  draw_health(player, menu)
  
  
  if menu.gamestart then
      draw_gamestart_menu(menu, player)
  elseif menu.gameover then
      draw_gameover_menu(menu, player)
  elseif menu.highscore then
      draw_highscore_menu(menu, player)
  elseif menu.showHS then
      draw_highscore_list(menu)
  elseif menu.settings then
      draw_settings_menu(menu)
  end
  

  -- your mouse is now a circle!
  love.graphics.setColor(200, 200, 200)
  love.mouse.setVisible(false)
  love.graphics.circle("line", mouse_x, mouse_y, 10)
 -- love.graphics.print(mouse_x..","..mouse_y, mouse_x, mouse_y)
  
  
    if gameIsPaused then
      love.graphics.setColor(10, 10, 10, 200)
      love.graphics.circle("fill", player.x, player.y, 1000)
      love.graphics.setColor(200, 200, 200)
      love.graphics.print("PAUSED", camera:getX() + 220, camera:getY() + 150, 0, 1, 1)
      love.graphics.print("Press escape to continue", camera:getX() + 120, camera:getY() + 350, 0, 1, 1)
    end

  
  
  
  -- finish with camera
  camera:unset()
end
