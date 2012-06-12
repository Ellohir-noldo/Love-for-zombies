function init_rain()
    rain = {}
    rain.img = love.graphics.newImage("img/rain.png")
    rain.drops = {}
    rain.amount = 90
    rain.time = 0
    rain.playing = true    
    for i = 1, rain.amount do
        drop = {}
	    drop.x = camera:getX() + math.random(530)
	    drop.y = camera:getY() + math.random(530)  
        table.insert(rain.drops, drop)
    end
    return rain
end

function enable_rain()
	rain.enable = true;
end

function disable_rain()
	rain.enable = false;
end

function update_rain(rain, dt)

    if rain.enable == false then
	TEsound.stop("rain")
    end
    
    if rain.time < 0.01 then 
        rain.time = rain.time + dt
        return
    end

    rain.time = 0
    if rain.playing == false then
        TEsound.playLooping("sound/storm.ogg", "rain") -- stream and loop background music
	rain.playing = true
    end

    for i = 1, rain.amount do
        drop = rain.drops[i]
        drop.x = drop.x - 5
	drop.y = drop.y + 5
	if drop.x < camera:getX() or drop.y > (camera:getY() + 512) then
            table.remove(rain.drops, i)
	    drop.x = camera:getX() + math.random(1000) 
	    drop.y = camera:getY() + math.random(300) 
            table.insert(rain.drops, drop)	  
	end
	
    end
end

function draw_rain(rain)
  if rain.enable == false then
	return
  else
  
      for i = 1, rain.amount do
          drop = rain.drops[i]
          love.graphics.setColor(200, 200, 200)
          love.graphics.draw(rain.img, drop.x, drop.y)
      end
  end
end