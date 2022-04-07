from illwill import ForegroundColor

type
    Tile* = object
        tile*: string
        color*: ForegroundColor
        bright*: bool

const
    MAP_WIDTH* = 100
    MAP_HEIGHT* = 35 
    MAP_SETTINGS* = [-1.0, -0.20, -0.13, 0.50, 0.70, 1.2]
    MAP_TILES* = [Tile(tile:"≈", color:fgBlue, bright:true), 
                Tile(tile:"~", color:fgBlue, bright:true),
                Tile(tile:"∙", color:fgYellow, bright:true), 
                Tile(tile:"~", color:fgGreen, bright:true), 
                Tile(tile:"-", color:fgGreen, bright:true),
                Tile(tile:"♣", color:fgGreen, bright:false), 
                Tile(tile:"♠", color:fgGreen, bright:false),
                Tile(tile:"▲", color:fgBlack, bright:true), 
                Tile(tile:"▲", color:fgWhite, bright:false),
                Tile(tile:"≈", color:fgRed, bright:true),
                Tile(tile:"⌂", color:fgYellow, bright:false)
                ]

type
    Map* = object
        hMap*: array[MAP_HEIGHT, array[MAP_WIDTH, float]]
        bMap*: array[MAP_HEIGHT, array[MAP_WIDTH, float]]
        sMap*: array[MAP_HEIGHT, array[MAP_WIDTH, Tile]]