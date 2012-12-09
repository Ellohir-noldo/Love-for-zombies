-- this file is based on https://github.com/kikito/love-tile-tutorial/wiki

function init_tiles()
     tiles = {}
     -- load requires a table "tiles" to load the map to
     -- this allows to load another maps while not changing what is being printed
    
    love.filesystem.load("maps/maplist.lua")()
    tiles.maplist = maplist
    tiles.map_amount = #maplist
    tiles.map_index = 1
    return load_map(tiles, maplist[tiles.map_index])
end

function next_map()
	-- loop on circular vector
	if tiles.map_index < tiles.map_amount then
		tiles.map_index = tiles.map_index + 1
	else
		tiles.map_index = 1
	end
	-- load the map
	load_map(tiles, maplist[tiles.map_index])
end
 
 
function load_map(tiles, path)

    love.filesystem.load(path)()
    -- this loads map { img, quadInfo, tilestring }
    tiles.tileset = love.graphics.newImage(map.img)
    tiles.collidable = map.collidable
    
    tiles.chars = {}
    tiles.quads = {}
     for i,info in ipairs(map.quadInfo) do
        -- info[1] = character, info[2]= x, info[3] = y
       tiles.quads[info[1]] = love.graphics.newQuad(info[2], info[3], map.tileW, map.tileH, map.tilesetW, map.tilesetH)
       tiles.chars[i] = info[1]
    end
    
    tiles.tileTable = {}
    local width = #(map.tileString:match("[^\n]+")) 
    for x = 1,width,1 do tiles.tileTable[x] = {} end

    local rowIndex,columnIndex = 1,1
    for row in map.tileString:gmatch("[^\n]+") do
      assert(#row == width, 'Map is not aligned: width of row ' .. tostring(rowIndex) .. ' should be ' .. tostring(tiles.w) .. ', but it is ' .. tostring(#row))
      columnIndex = 1
          for character in row:gmatch(".") do
              tiles.tileTable[columnIndex][rowIndex] = character
              columnIndex = columnIndex + 1
	      if character == 'f' then
		tiles.jeep.x = (columnIndex -1.5) * map.tileW
		tiles.jeep.y = (rowIndex -0.5) * map.tileH
	       end
          end
       rowIndex=rowIndex+1
    end
    
    tiles.w = (columnIndex - 1) * map.tileW
    tiles.h = (rowIndex - 1) * map.tileH
    tiles.tileW = map.tileW
    tiles.tileH = map.tileH
    return tiles
    
end

function player_tile(player)
    return tiles.tileTable[math.ceil(player.x/tiles.tileW)][math.ceil(player.y/tiles.tileH)]
end

function player_in_mud(player)
    return player_tile(player,tiles) == 'm'
end

function player_collides(player)
    return in_table(tiles.collidable, player_tile(player,tiles))
end

function check_expand_map(player)
	local xtile = math.ceil(player.x/tiles.tileW)
	local ytile = math.ceil(player.y/tiles.tileH)
	
	if xtile < map.sizeH/5 then
		map.expand("L")
	elseif xtile > map.sizeH*4/5 then
		map.expand("R")
	end
	
	if ytile < map.sizeV/5 then
		map.expand("U")
	elseif ytile > map.sizeH*4/5 then
		map.expand("D")
	end
	
end

function draw_tiles(tiles)
  love.graphics.setColor(200, 200, 200)
    for columnIndex,column in ipairs(tiles.tileTable) do
    for rowIndex,char in ipairs(column) do
      local x,y = (columnIndex-1)*tiles.tileW, (rowIndex-1)*tiles.tileH
      love.graphics.drawq(tiles.tileset, tiles.quads[char], x, y)
    end
  end
    --love.graphics.print(" "..tiles.w.." "..tiles.h, 20, 20)
end