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
  { 'a', 192, 64 }, -- D-R corner l13
  { 'b', 0,  128 }, -- D-L corner l20
  { 'c', 64, 128 }, -- U-R corner 
  { 'd', 128,128 }, -- U-L corner 
  { 'e', 192,128 }, -- 
  { 'f', 0,  192 }, -- 
  { 'g', 64, 192 }, -- 
  { 'i', 128,192 }, -- 
  { 'j', 192,192 } -- 
  }

  map.collidable = {'^','h','v','H','V'}
  
map.tileString = [[
chhhhhhhhhhhhhhhhhhhhhhhd
v   ^             m     V
v   m                   V
v              m  ^     V
v      ^                V
v                       V
v    ^      m           V
v   m                   V
v              m        V
v    m                  V
v               ^       V
v        m              V
v            ^          V
v   ^             m     V
v     m     m           V
v                       V
v   m              m    V
aHHHHHHHHHHHHHHHHHHHHHHHb
]]