-- this file is based on https://github.com/kikito/love-tile-tutorial/wiki

function init_tiles()
     tiles = {}
     -- load requires a table "tiles" to load the map to
     -- this allows to load another maps while not changing what is being printed
     load_map(tiles, "maps/map1.lua")
     
    return tiles
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
          end
       rowIndex=rowIndex+1
    end
    
    tiles.w = (columnIndex - 1) * map.tileW
    tiles.h = (rowIndex - 1) * map.tileH
    tiles.tileW = map.tileW
    tiles.tileH = map.tileH
    return tiles
    
end

function player_tile(player, tiles)
    return tiles.tileTable[math.ceil(player.x/tiles.tileW)][math.ceil(player.y/tiles.tileH)]
end

function player_in_mud(player, tiles)
    return player_tile(player,tiles) == 'm'
end

function player_collides(player, tiles)
    return in_table(tiles.collidable, player_tile(player,tiles))
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