import header, perlin, random, illwill, os, math

proc createVArray(): array[MAP_HEIGHT, array[MAP_WIDTH, float]] = # Creates an array of floats that will store perlin values
    var world: array[MAP_HEIGHT, array[MAP_WIDTH, float]]
    return world


proc fillVArray(world: var array[MAP_HEIGHT, array[MAP_WIDTH, float]]) = # Fills the empty array with perlin values
    randomize()

    let noise = newNoise(randomSeed(),NOISE_OCTAVES,NOISE_FREQUENCY)

    for y in 0..<MAP_HEIGHT:
        for x in 0..<MAP_WIDTH:
            world[y][x] = noise.perlin(x/2,y/2)*MULT # The /2 simply means that it's zoomed in 2x, makes the map larger, more realistic and less ugly


proc createWorld*(): array[MAP_HEIGHT, array[MAP_WIDTH, float]] = # Self explanatory, creates the world
    var world = createVArray()
    world.fillVArray()
    return world


proc visualizeVArray(world: array[MAP_HEIGHT, array[MAP_WIDTH, float]]) = # This is the fun part
    var 
        tb = newTerminalBuffer(terminalWidth(), terminalHeight()) # Illwill stuff
        bb = newBoxBuffer(terminalWidth(), terminalHeight()) # Illwill stuff again
        hPos = (x:0, y:0) # The position of the highest point in the map
        wPos = (x:0, y:0) # The position of the nearest water tile to the highest position on the map
        lValue = 0.0 # Last value of the highest recorded position, basically a variable used to check the highest point on the map
        vPos = (x: rand(0..MAP_WIDTH-1), y: rand(0..MAP_HEIGHT-1)) # Village pos
        lDist = float(MAP_WIDTH) # Last distance, used to calculate the nearest water tile
        hw = (x:0, y:0) # Temporary variable to draw the rivers
 
    for y in 0..<MAP_HEIGHT:
        for x in 0..<MAP_WIDTH:
            for i in 0..<MAP_TILES.len:
                if (MAP_SETTINGS[i] <= world[y][x] and world[y][x] < MAP_SETTINGS[i+1]): # Draws the map first, tile by tile
                    tb.setForegroundColor(MAP_COLORS[i], MAP_BRIGHT[i]) # Chooses the color and brightness from the header file
                    tb.write(x, y, MAP_TILES[i]) # Writes the designated tile from the header file
            if world[y][x] > lValue: # This if chooses the hights point in the map
                lValue = world[y][x]
                hPos = (x,y)
                hw = (x,y)


    for i in 0..2: # Decides the village quantity
        vPos = (x: rand(0..MAP_WIDTH-1), y: rand(0..MAP_HEIGHT-1)) 
        while not (MAP_SETTINGS[2] < world[vPos.y][vPos.x] and world[vPos.y][vPos.x] < MAP_SETTINGS[4]): # Checks if the village position is not on water or mountains
            vPos = (x: rand(0..MAP_WIDTH-1), y: rand(0..MAP_HEIGHT-1)) 

        tb.setForegroundColor(fgYellow, bright=true)

        for y in vPos.y-1..vPos.y+1: # Draws houses in 3x3 space randomly
            for x in vPos.x-1..vPos.x+1:
                if (0 <= x and x < MAP_WIDTH and 0 <= y and y < MAP_HEIGHT):
                    if (MAP_SETTINGS[2] < world[y][x] and world[y][x] < MAP_SETTINGS[4]):
                        if rand(1) == 0:
                            tb.write(x ,y , "⌂")


    if lValue >= MAP_SETTINGS[4]: # Checks if the highest value is a mountain, if it is then we start drawing the river
        tb.setForegroundColor(MAP_COLORS[0], MAP_BRIGHT[0]) # Sets the color to bright blue
        block temp: # Block that checks the nearest water tile
            while true:
                var t = 0
                for y in 0..<MAP_HEIGHT:
                    for x in 0..<MAP_WIDTH:
                        let dist = sqrt(float((x - hPos.x)^2 + (y - hPos.y)^2))
                        if lDist > dist and world[y][x] <= MAP_SETTINGS[1]: 
                            lDist = dist
                            wPos = (x,y)
                            t = 1
                if t == 0:
                    break temp


        while hw != wPos: # This one draws the river
            var 
                tmp = hw # Temporary coordinate tuple

            if rand(1) == 0: # Decides if it writes vertically of horizontally
                if hw.x < wPos.x: # Checks if the current tile is greater or lesser than the water position and changes the tile position accordingly
                    hw.x += 1
                    bb.drawHorizLine(tmp.x, hw.x, hw.y, doubleStyle=true)
                elif hw.x > wPos.x:
                    hw.x -= 1
                    bb.drawHorizLine(tmp.x, hw.x, hw.y, doubleStyle=true)
            else:
                if hw.y < wPos.y:
                    hw.y += 1
                    bb.drawVertLine(hw.x, tmp.y, hw.y, doubleStyle=true)
                elif hw.y > wPos.y:
                    hw.y -= 1
                    bb.drawVertLine(hw.x, tmp.y, hw.y, doubleStyle=true)
            if rand(10) == 0 and world[tmp.y][tmp.x] <= MAP_SETTINGS[4]: # Draws the deviations of the rivers, still pretty buggy lol
                var
                    lx = tmp.x
                    ly = tmp.y
                    x = tmp.x
                    y = tmp.y
                    dx = tmp.x + rand(-2..2)
                    dy = tmp.y + rand(-2..2)
                while x != dx or y != dy:
                    if rand(1) == 0:
                        if x < dx:
                            if x < MAP_WIDTH-1:
                                x += 1
                                bb.drawHorizLine(lx, x, ly)
                            else:
                                break
                        elif x > dx:
                            if x > 0:
                                x -= 1
                                bb.drawHorizLine(lx, x, ly)
                            else:
                                break
                    else:
                        if y < dy:
                            if y < MAP_HEIGHT-1:
                                y += 1
                                bb.drawVertLine(lx, ly, y)
                            else:
                                break
                        elif y > dy:
                            if y > 0:
                                y -= 1
                                bb.drawVertLine(lx, ly, y)
                            else:
                                break
                    lx = x
                    ly = y


        tb.write(bb) # Writes the river
        tb.write(hPos.x,hPos.y,"○") # Writes the source of the water
        tb.write(wPos.x,wPos.y,"☼") # Writes the target of the water

    tb.display()
    sleep(1500)
    tb.clear()
    tb.resetAttributes()


proc exitProc() {.noconv.} =
    illwillDeinit()
    showCursor()
    quit(0) 

illwillInit(fullscreen=false)
setControlCHook(exitProc)
hideCursor()

for i in 0..10:
    var world = createWorld()
    world.visualizeVArray()