function init_menu()
    menu = {}
    menu.gamestart = true -- initial values
    menu.gameover = false
    menu.highscore = false
    menu.showHS = false
    menu.showHS_back = false
    menu.settings = false
    menu.setting = 1
    menu.darkness = true
    menu.sound = true
    menu.rain = 0
    menu.size = 1
    menu.HS = table.load("highscore.txt") or {}
    menu.gameover_color = 256 -- for the gameover scene
    menu.gameover_size = 0
    menu.item = 1 -- start menu item
    menu.death_sound = true -- played on gameover
    menu.inputname = "" -- highscore input name
    TEsound.playLooping("sound/bgm.mp3", "bgm") -- stream and loop background music
    menu.font = love.graphics.newFont("img/Adler.ttf", 20)
    love.graphics.setFont(menu.font)
    
    
    menu. key_disable = { --keys to disable in case they are not in use.
      "up","down","left","right","home","end","pageup","pagedown",--Navigation keys
      "insert","tab","clear","delete",--Editing keys
      "f1","f2","f3","f4","f5","f6","f7","f8","f9","f10","f11","f12","f13","f14","f15",--Function keys
      "numlock","scrollock","ralt","lalt","rmeta","lmeta","lsuper","rsuper","mode","compose","lctrl","rctrl", --Modifier keys
      "pause","escape","help","print","sysreq","break","menu","power","euro","undo"--Miscellaneous keys
    }
    menu.key_capslock = false
    menu.key_shift = false    
    
    menu.blink_time = 0
    
    return menu
end

function update_menus(menu, key, button)
   if menu.gamestart then
      update_start_menu(menu, key, button)
   elseif menu.highscore then
      update_highscore_menu(menu, key)
   elseif menu.showHS then
      update_highscore_list(menu, key, button)
   elseif menu.settings then
      update_settings_menu(menu, key, button)
    end
	
end

function update_gameover_scene(menu, player)
        menu.gameover = true
	-- color drift to black (max black)
	menu.gameover_color = math.max(menu.gameover_color - 1, 0)
	-- circle growth on player, Bond Style
	menu.gameover_size = menu.gameover_size + 5
	
	
	if menu.death_sound then
	    TEsound.stop("all")
	    TEsound.play("sound/death.mp3")
	    menu.death_sound = false -- death sound only sounds once
	end
	
	if menu.gameover_color == 0 then -- screen is at last black
	    menu.highscore = true -- go highscore
	    menu.gameover = false -- quit this menu
	end  

end

function update_start_menu(menu, key, button)

	  -- ups and downs selection
	if key== "up" and menu.item > 1 then
          menu.item = menu.item - 1 
	elseif key == "down" and menu.item < 4 then
          menu.item = menu.item + 1
	elseif key== "w" and menu.item > 1 then
          menu.item = menu.item - 1
	elseif key == "s" and menu.item < 4 then
          menu.item = menu.item + 1
	end
	
	-- mouse selection
	mx, my = camera:mousePosition()
	if my > camera:getY() + 400 then
	    menu.item = 4
	elseif my > camera:getY() + 350 then
	    menu.item = 3
	elseif my > camera:getY() + 300 then
	    menu.item = 2
	elseif my > camera:getY() + 250 then
	    menu.item = 1
	end
        
        --  start playing
        if menu.item == 1 and (button == "l" or key=="return") then
            menu.showHS = false
            menu.gamestart = false
	    menu.gameover = false
	    menu.settings = false
        -- show highscores
	elseif menu.item == 2 and (button == "l"  or key=="return") then
            menu.showHS = true
            menu.gamestart = false
	    menu.gameover = false
	    menu.settings = false
        -- settings
	elseif menu.item == 3 and (button == "l"  or key=="return") then
            menu.showHS = false
            menu.gamestart = false
	    menu.gameover = false
	    menu.settings = true
        -- exit
	elseif menu.item == 4 and (button == "l"  or key=="return") then
          love.event.push('quit') -- Exit
	end
   
end

function update_highscore_menu(menu, key)
    -- getting the input char by char, like oldskool
    if key == "return" or key == "escape" then
        points = {}
        points.kills = player.zkilled
        points.alive = player.talive
	points.name = menu.inputname
        table.insert(menu.HS, points)
	table.sort(menu.HS, function(a,b) if a.kills == b.kills then return a.alive>b.alive else return a.kills>b.kills end end)
	for i,h in ipairs(menu.HS) do
            if i < 5 then   else     table.remove(menu.HS, i)     end	       
	end
	table.save(menu.HS, "highscore.txt")
	TEsound.stop("bgm") -- do not stack bgm!
	love.load() -- bad restart but hey...
    elseif key == "backspace" then
        menu.inputname = string.sub(menu.inputname, 0, string.len(menu.inputname) -1 ) -- OLDSKOOL!
    elseif key == "rshift" or key == "lshift" then -- enable shift
        menu.key_shift = true
    elseif key == "capslock" then -- enable capslock
        menu.key_capslock = true
    elseif in_table(menu.key_disable,key) then
        -- nothing
    elseif menu.key_shift or menu.key_capslock then
        menu.inputname = menu.inputname..string.upper(key)
    else
        menu.inputname = menu.inputname..key
    end
end

function blink_highscore_menu(menu, dt)
        menu.blink_time = menu.blink_time + dt
        -- blink every 1/3 seconds
        if menu.blink_time > 0.6 then
            menu.blink_time = 0
        end
end

function update_highscore_list(menu, key, button)
    if key == "return" or key == "escape" then
        menu.showHS = false
	menu.gamestart = true
	menu.gameover = false
	menu.settings = false
	load_map(tiles, "maps/randomMap.lua")
    end
    
    -- mouse selection
    mx, my = camera:mousePosition()
    if my > camera:getY() + 450 then
        menu.showHS_back = true
    elseif my > camera:getY() + 350 then
	menu.showHS_back = false
    end
    
    if menu.showHS_back and button == "l" then
            menu.showHS = false
            menu.gamestart = true
	    menu.gameover = false
            menu.settings = false
	    load_map(tiles, "maps/randomMap.lua")
    end
    
end

function update_settings_menu(menu, key, button)

        if key == "escape" then
            menu.showHS = false
            menu.gamestart = true
	    menu.gameover = false
	    menu.settings = false
        end

	  -- ups and downs selection
	if key== "up" and menu.setting > 1 then
          menu.setting = menu.setting - 1 
	elseif key == "down" and menu.setting < 5 then
          menu.setting = menu.setting + 1
	elseif key== "w" and menu.setting > 1 then
          menu.setting = menu.setting - 1
	elseif key == "s" and menu.setting < 5 then
          menu.setting = menu.setting + 1
	end
	
        -- mouse selection
	mx, my = camera:mousePosition()
        if my > camera:getY() + 450 then
	    menu.setting = 5
        elseif my > camera:getY() + 400 then
	    menu.setting = 4
        elseif my > camera:getY() + 350 then
	    menu.setting = 3
	elseif my > camera:getY() + 300 then
	    menu.setting = 2
	elseif my > camera:getY() + 250 then
	    menu.setting = 1
	end
	
        

        if menu.setting == 1 and (button == "l"  or key=="return") then
            menu.darkness = not menu.darkness
        elseif menu.setting == 2 and (button == "l"  or key=="return") then
            if menu.sound then
                TEsound.disable_sound()
                menu.sound = false
            else
                TEsound.enable_sound()
                TEsound.playLooping("sound/bgm.mp3", "bgm") -- stream and loop background music
                menu.sound = true
            end
        elseif menu.setting == 3 and (button == "l"  or key=="return") then
            if menu.size == 1 then
                menu.size = 2
                camera:scale(0.5,0.5)
                love.graphics.setMode(1024, 1024, false, true, 0) 
            else
                menu.size = 1
                camera:scale(2,2)
                love.graphics.setMode(512, 512, false, true, 0) 
            end
        elseif menu.setting == 4 and (button == "l"  or key=="return") then
            if menu.rain == false then
		menu.rain = true
		enable_rain()
	    else
		menu.rain=false
		disable_rain()
	    end
        elseif menu.setting == 5 and (button == "l"  or key=="return") then
            menu.showHS = false
            menu.gamestart = true
	    menu.gameover = false
	    menu.settings = false
        end
        
end


function draw_gamestart_menu(menu, player)
      -- fill the camera with dark semitransparent background
      love.graphics.setColor(10, 10, 10, 170)
      love.graphics.circle("fill", player.x, player.y, 1000)
      
      -- title
      love.graphics.setColor(200, 200, 200)
      love.graphics.print("Love for zombies", camera:getX() + 10, camera:getY() + 10, 0, 2, 2 )
      love.graphics.print("By Ellohir", camera:getX() + 440, camera:getY() + 500, 0, 0.5, 0.5)
      love.graphics.print("Powered by Love", camera:getX() + 1, camera:getY() + 500, 0, 0.5, 0.5)
      
      -- if selected, color is red, else is white
      -- really unefficient here
      if menu.item == 1 then
          love.graphics.setColor(200, 20, 20)
      end
      love.graphics.print("Start game", camera:getX() + 200, camera:getY() + 250 )
      love.graphics.setColor(200, 200, 200)
      if menu.item == 2 then
          love.graphics.setColor(200, 20, 20)
      end
      love.graphics.print("Highscores", camera:getX() + 200, camera:getY() + 300)
      love.graphics.setColor(200, 200, 200)
      if menu.item == 3 then
          love.graphics.setColor(200, 20, 20)
      end
      love.graphics.print("Settings", camera:getX() + 200, camera:getY() + 350)
      love.graphics.setColor(200, 200, 200)
      if menu.item == 4 then
          love.graphics.setColor(200, 20, 20)
      end
      love.graphics.print("Exit", camera:getX() + 200, camera:getY() + 400)
      love.graphics.setColor(200, 200, 200)
      
end

function draw_settings_menu(menu)
      -- fill the camera with dark semitransparent background
      love.graphics.setColor(10, 10, 10, 170)
      love.graphics.circle("fill", player.x, player.y, 1000)
      
      -- title
      love.graphics.setColor(200, 200, 200)
      love.graphics.print("Love for zombies", camera:getX() + 10, camera:getY() + 10, 0, 2, 2 )


      if menu.setting == 1 then
          love.graphics.setColor(200, 20, 20)
      end      
      if menu.darkness == false then
          love.graphics.print("Darkness off",  camera:getX() + 200, camera:getY() + 250 )
      else
          love.graphics.print("Darkness on",  camera:getX() + 200, camera:getY() + 250 )
      end
      
      love.graphics.setColor(200, 200, 200)
      if menu.setting == 2 then
          love.graphics.setColor(200, 20, 20)
      end
      if menu.sound then
          love.graphics.print("Sound on",  camera:getX() + 200, camera:getY() + 300 )
      else
          love.graphics.print("Sound off",  camera:getX() + 200, camera:getY() + 300 )
      end
      
      love.graphics.setColor(200, 200, 200)
      if menu.setting == 3 then
          love.graphics.setColor(200, 20, 20)
      end
      if menu.size == 1 then
          love.graphics.print("Window size = 512x512",  camera:getX() + 200, camera:getY() + 350 )
      else
          love.graphics.print("Window size = 1024x1024",  camera:getX() + 200, camera:getY() + 350 )
      end
     
      love.graphics.setColor(200, 200, 200)
      if menu.setting == 4 then
          love.graphics.setColor(200, 20, 20)
      end
      if menu.rain then
	love.graphics.print("Rain effect on",  camera:getX() + 200, camera:getY() + 400 )
      else
	love.graphics.print("Rain effect off",  camera:getX() + 200, camera:getY() + 400 )
      end

      
      love.graphics.setColor(200, 200, 200)
      if menu.setting == 5 then
          love.graphics.setColor(200, 20, 20)
      end
      love.graphics.print("Back",  camera:getX() + 200, camera:getY() + 450 )

end

function draw_gameover_menu(menu, player)
      -- gameover scene with the bond circle growing and darkening
      love.graphics.setColor(menu.gameover_color, menu.gameover_color/6, menu.gameover_color/6)
      love.graphics.circle("fill", player.x, player.y, menu.gameover_size, 50)
      -- and the text for the scene
      love.graphics.setColor(200, 200, 200)
      love.graphics.print("GAME OVER", camera:getX() + 100, camera:getY() + 100)
      love.graphics.print("You survived "..string.format("%.2f",player.talive).." seconds", camera:getX() + 100, camera:getY() + 150)
      love.graphics.print("You killed "..string.format("%d",player.zkilled).." zombies", camera:getX() + 100, camera:getY() + 180)

end

function draw_highscore_menu(menu, player)
      -- dark semitransparent background
      love.graphics.setColor(10, 10, 10, 170)
      love.graphics.circle("fill", player.x, player.y, 1000)
        -- title
      love.graphics.setColor(200, 200, 200)
      love.graphics.print("Love for zombies", camera:getX() + 10, camera:getY() + 10, 0, 2, 2 )


      -- highscore
      love.graphics.print("Highscore", camera:getX() + 100, camera:getY() + 100)
      
      if menu.blink_time < 0.3 then
        cursor = "_"
      else 
        cursor = ""
      end
      
      love.graphics.print("Name: "..menu.inputname..cursor, camera:getX() + 100, camera:getY() + 150)
      love.graphics.print("\nSurviving: "..string.format("%.2f",player.talive).." seconds\nEliminating: "..string.format("%d",player.zkilled).." zombies", camera:getX() + 100, camera:getY() + 180)
     -- if menu.key_capslock or menu.key_shift then
     --     love.graphics.print("\nCAPS ON", camera:getX() + 150, camera:getY() + 150)
     -- end
      
end

function draw_highscore_list(menu)
      -- dark semitransparent background
      love.graphics.setColor(10, 10, 10, 170)
      love.graphics.circle("fill", player.x, player.y, 1000)

      -- title
      love.graphics.setColor(200, 200, 200)
      love.graphics.print("Love for zombies", camera:getX() + 10, camera:getY() + 10, 0, 2, 2 )
      
      love.graphics.print("Name             Survived     Kills", camera:getX() + 100, camera:getY() + 120)
      table.sort(menu.HS, function(a,b) if a.kills == b.kills then return a.alive>b.alive else return a.kills>b.kills end end)
      for i,h in ipairs(menu.HS) do
          if i < 5 then
              love.graphics.print(h.name,                                   camera:getX() + 100,       camera:getY() + 120 + i*50)
              love.graphics.print(string.format("%.2f",h.alive),        camera:getX() + 290,       camera:getY() + 120 + i*50)
              love.graphics.print(h.kills,                                      camera:getX() + 420,       camera:getY() + 120 + i*50)
	  else
              table.remove(menu.HS, i)	  
	  end
      end
      if menu.showHS_back then
          love.graphics.setColor(200, 20, 20)
      end
      love.graphics.print("Back", camera:getX() + 100, camera:getY() + 450)
 end
