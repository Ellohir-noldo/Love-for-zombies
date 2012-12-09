  map = {}
  map.img = "maps/tile_split.png"
  map.tileW, map.tileH = 64, 64
  map.tilesetW, map.tilesetH = 256,256
  map.quadInfo = {
  { ' ', 0,    0 }, -- grass l00
  { 'm', 64,   0 }, -- mud l01
  { '^', 128,  0 }, -- rock l02
  { 'h', 192,  0 }, -- horizontal up wall l03
  { 'v', 0,   64 }, -- vertical right wall l10
  { 'H', 64,  64 }, -- horizontal down l11
  { 'V', 128, 64 }, -- vertical left l12
  { 'c', 192, 64 }, -- D-R corner l13
  { 'd', 0,  128 }, -- D-L corner l20
  { 'a', 64, 128 }, -- U-R corner 
  { 'b', 128,128 }, -- U-L corner 
  { 'e', 192,128 }, -- 
  { 'f', 0,  192 }, -- 
  { 'g', 64, 192 }, -- 
  { 'i', 128,192 }, --  
  { 'j', 192,192 }  --   
  }
  map.collidable = {'^','h','v','H','V'}
  
  
  
  --- RANDOMIZER PARAMETERS---

  map.sizeH = 80
  map.sizeV = 80
  map.mud = math.random(2,7) / 100
  map.rock = math.random(2,7) / 100
  
  
  
  map.tileString = ""
  
  for i=1,map.sizeV do
    for j=1,map.sizeH do
	r = math.random()
        if r < map.mud then
		map.tileString = map.tileString.."m"
	elseif r > (1 - map.rock) then 
		map.tileString = map.tileString.."^"
	else
		map.tileString = map.tileString.." "
	end
    end
        map.tileString = map.tileString.."\n"
  end
  
  
function map.expand(side)

    map.newString = ""

    if side == 'R' then
      for var in split(map.tileString, "\n") do
	for i=1,map.sizeH do
		r = math.random()
		if r < map.mud then
			var = var.."m"
		elseif r > (1 - map.rock) then 
			var=var.."^"
		else
			var=var.." "
		end
		var=var.."\n"
	end
	map.newString = map.newString..var
	map.sizeH = map.sizeH + map.sizeH
    end
    
    
    elseif side == 'L' then
      for var in split(map.tileString, "\n") do
	for i=1,map.sizeH do
		r = math.random()
		if r < map.mud then
			var = "m"..var
		elseif r > (1 - map.rock) then 
			var="^"..var
		else
			var=" "..var
		end
		var=var.."\n"
	end
	map.newString = map.newString..var
	map.sizeH = map.sizeH + map.sizeH
    end
    
    
    elseif side == 'U' then
      for j=1, map.sizeV do
    	for i=1,map.sizeH do
		r = math.random()
		if r < map.mud then
			var = "m"..var
		elseif r > (1 - map.rock) then 
			var="^"..var
		else
			var=" "..var
		end
		var=var.."\n"
	end
	map.newString = var..map.tileString
	map.sizeV = map.sizeV + map.sizeV
      end
      

    elseif side == 'D' then
      for j=1, map.sizeV do
    	for i=1,map.sizeH do
		r = math.random()
		if r < map.mud then
			var = "m"..var
		elseif r > (1 - map.rock) then 
			var="^"..var
		else
			var=" "..var
		end
		var=var.."\n"
	end
	map.newString = map.tileString..var
	map.sizeV = map.sizeV + map.sizeV
      end
      
    end


    map.tileString = map.newString
end
  --print(map.tileString)
  
  