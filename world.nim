import noisy, illwill, random, os, header, math

proc `$`(p1, p2: tuple[x,y:int]): float =
    result = sqrt(float((p2.x-p1.x)^2 + (p2.y-p1.y^2)))

proc createMap(seed, oct: int, amp, freq, lac, gain: float): Map =
    var world: Map
    var noise = initSimplex(seed)
    noise.octaves = oct
    noise.amplitude = amp
    noise.frequency = freq
    noise.lacunarity = lac
    noise.gain = gain
    let values = noise.grid((0, 0), (MAP_WIDTH, MAP_HEIGHT))
    for y in 0..<MAP_HEIGHT:
        for x in 0..<MAP_WIDTH:
            world.hMap[y][x] = values[x, y]

    var noise2 = initSimplex(seed*2)
    noise2.octaves = oct
    noise2.amplitude = amp
    noise2.frequency = freq
    noise2.lacunarity = lac
    noise2.gain = gain
    let values2 = noise2.grid((0, 0), (MAP_WIDTH, MAP_HEIGHT))
    for y in 0..<MAP_HEIGHT:
        for x in 0..<MAP_WIDTH:
            world.bMap[y][x] = values2[x, y]
    return world

proc fillMap(map: var Map) = 
    for y in 0..<MAP_HEIGHT:
        for x in 0..<MAP_WIDTH:
            if map.hMap[y][x] <= MAP_SETTINGS[1]: # Is at or below water height
                if rand(5) != 0:
                    map.sMap[y][x] = MAP_TILES[0] # double wiggly water
                else:
                    map.sMap[y][x] = MAP_TILES[1] # single wiggly water

            elif MAP_SETTINGS[1] < map.hMap[y][x] and map.hMap[y][x] <= MAP_SETTINGS[2]: # Is at sand height
                map.sMap[y][x] = MAP_TILES[2] # sand

            elif MAP_SETTINGS[2] < map.hMap[y][x] and map.hMap[y][x] <= MAP_SETTINGS[3]: # Is plain or forest, we decide with the bMap
                if map.bMap[y][x] <= 0.3:
                    if rand(1) == 0:
                        map.sMap[y][x] = MAP_TILES[3] # wiggly grass
                    else:
                        map.sMap[y][x] = MAP_TILES[4] # straight grass
                else:
                    if rand(2) != 0:
                        map.sMap[y][x] = MAP_TILES[5] # normal tree
                    else:
                        map.sMap[y][x] = MAP_TILES[6] # different tree

            elif MAP_SETTINGS[3] < map.hMap[y][x] and map.hMap[y][x] <= MAP_SETTINGS[4]: # Is low mountain
                map.sMap[y][x] = MAP_TILES[7]

            elif MAP_SETTINGS[4] < map.hMap[y][x] and map.hMap[y][x] <= MAP_SETTINGS[5]: # Is high mountain
                map.sMap[y][x] = MAP_TILES[8]

            else:
                map.sMap[y][x] = MAP_TILES[9]


proc drawVillages(map: var Map, tb: var TerminalBuffer, amount: int): seq[tuple[x,y:int]] =
    var 
        temp, vPos: seq[tuple[x,y:int]] # vPos has to be a seq because nim can't compile the amount parameter at runtime :/
    
    for y in 0..<MAP_HEIGHT:
        for x in 0..<MAP_WIDTH:
            if MAP_SETTINGS[2] < map.hMap[y][x] and map.hMap[y][x] <= MAP_SETTINGS[3]:
                temp.add((x,y))

    for i in 0..<amount:
        let vil = temp[rand(temp.len-1)]
        vPos.add(vil)
        for y in vil.y-1..vil.y+1:
            for x in vil.x-1..vil.x+1:
                if 0 <= x and x < MAP_WIDTH and 0 <= y and y < MAP_HEIGHT:
                    if rand(1) == 0:
                        map.sMap[y][x] = MAP_TILES[10]
    
    return vPos

    
proc drawPath(map: Map, tb: var TerminalBuffer, vPos: seq[tuple[x,y:int]]) =
    var bb = newBoxBuffer(terminalWidth(), terminalHeight())
    tb.setForegroundColor(fgYellow)
    for i in 0..<vPos.len-1:
        if vPos[i]$vPos[i+1] <= MAP_WIDTH/4:
            var
                x = vPos[i].x
                y = vPos[i].y
                flag = 0
            
            while x != vPos[i+1].x and y != vPos[i+1].y:
                var 
                    px = x
                    py = y
                if rand(1) == 0:
                    if x < vPos[i+1].x: 
                        if MAP_SETTINGS[2] < map.hMap[y][x+1] and map.hMap[y][x+1] <= MAP_SETTINGS[3]:
                            x += 1
                            bb.drawHorizLine(x, px, y)
                            flag = 0
                    elif x > vPos[i+1].x: 
                        if MAP_SETTINGS[2] < map.hMap[y][x-1] and map.hMap[y][x-1] <= MAP_SETTINGS[3]:
                            x -= 1
                            bb.drawHorizLine(x, px, y)
                            flag = 0
                else:
                    if y < vPos[i+1].y: 
                        if MAP_SETTINGS[2] < map.hMap[y+1][x] and map.hMap[y+1][x] <= MAP_SETTINGS[3]:
                            y += 1
                            bb.drawVertLine(x, y, py)
                            flag = 0
                    elif y > vPos[i+1].y: 
                        if MAP_SETTINGS[2] < map.hMap[y-1][x] and map.hMap[y-1][x] <= MAP_SETTINGS[3]:
                            y -= 1
                            bb.drawVertLine(x, y, py)
                            flag = 0
                if flag == 10:
                    break
                else:
                    flag += 1
    tb.write(bb)
            
proc drawMap() =
    randomize()
    var 
        tb = newTerminalBuffer(terminalWidth(), terminalHeight())
        map = createMap(rand(10000000), 3, 1, 0.08, 0.3, 1.6)
        wCount = 0.0
        fCount = 0.0

    for y in 0..<MAP_HEIGHT:
        for x in 0..<MAP_WIDTH:
            if map.hMap[y][x] <= MAP_SETTINGS[1]:
                wCount += 1
            else:
                fCount += 1

    while wCount < MAP_HEIGHT*MAP_WIDTH/3 or fCount < MAP_HEIGHT*MAP_WIDTH/2:
        map = createMap(rand(10000000), 3, 1, 0.08, 0.3, 1.6)
        wCount = 0.0
        fCount = 0.0
        for y in 0..<MAP_HEIGHT:
            for x in 0..<MAP_WIDTH:
                if map.hMap[y][x] <= MAP_SETTINGS[1]:
                    wCount += 1
                else:
                    fCount += 1

    map.fillMap()
    let pos = map.drawVillages(tb, 3)
    
    for y in 0..<MAP_HEIGHT:
        for x in 0..<MAP_WIDTH:
            tb.setForegroundColor(map.sMap[y][x].color, map.sMap[y][x].bright)
            tb.write(x, y, map.sMap[y][x].tile)

    #drawPath(map, tb, pos)

    tb.display()

proc exitProc() {.noconv.} =
    illwillDeinit()
    showCursor()
    quit(0) 

illwillInit(fullscreen=false)
setControlCHook(exitProc)
hideCursor()

for i in 0..20:
    drawMap()
    sleep(1000)
