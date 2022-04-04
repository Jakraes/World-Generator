from illwill import ForegroundColor

const
    MAP_WIDTH* = 60
    MAP_HEIGHT* = 35
    MULT* = 1
    MAP_SETTINGS* = [0.0*MULT, 0.40*MULT, 0.42*MULT, 0.58*MULT, 0.70*MULT, 0.80*MULT, 1.0*MULT]
    MAP_TILES* = ["≈", "∙", "~", "♣", "▲", "▲"]
    MAP_COLORS* = [fgBlue, fgYellow, fgGreen, fgGreen, fgBlack, fgWhite]
    MAP_BRIGHT* = [true, true, true, false, true, false]
    NOISE_OCTAVES* = 1
    NOISE_FREQUENCY* = 0.1