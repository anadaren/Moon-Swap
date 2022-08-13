--[[Dependencies
]]

--Libraries--

--Class
Class = require 'lib/class'

--Push
push = require 'lib/push'

--Timer, located within Knife library
Timer = require 'lib/knife/timer'

--Internal requirements--

--Utility
require 'src/StateMachine'
require 'src/Util'

--Game Pieces
require 'src/Board'
require 'src/Tile'

--Game States
require 'src/states/BaseState'
require 'src/states/BeginGameState'
require 'src/states/GameOverState'
require 'src/states/PlayState'
require 'src/states/StartState'

--Sounds
gSounds = {
    ['music'] = love.audio.newSource('sounds/match-3_sounds_music3.mp3', 'static'),
    ['select'] = love.audio.newSource('sounds/match-3_sounds_select.wav', 'static'),
    ['error'] = love.audio.newSource('sounds/match-3_sounds_error.wav', 'static'),
    ['match'] = love.audio.newSource('sounds/match-3_sounds_match.wav', 'static'),
    ['clock'] = love.audio.newSource('sounds/match-3_sounds_clock.wav', 'static'),
    ['game-over'] = love.audio.newSource('sounds/match-3_sounds_game-over.wav', 'static'),
    ['next-level'] = love.audio.newSource('sounds/match-3_sounds_next-level.wav', 'static')
}

--Graphics
gTextures = {
    ['main'] = love.graphics.newImage('graphics/match3.png'),
    ['background'] = love.graphics.newImage('graphics/background.png'),
    ['startBackground'] = love.graphics.newImage('graphics/background2.png'),
    ['sidebar'] = love.graphics.newImage('graphics/sidebar.png'),
    ['startSplash'] = love.graphics.newImage('graphics/startsplash.png')
}

--Quads
gFrames = {
    --tilesheet divided into quads
    ['tiles'] = GenerateTileQuads(gTextures['main'])
}

--Fonts
gFonts = {
    ['small'] = love.graphics.newFont('fonts/font.ttf', 8),
    ['medium'] = love.graphics.newFont('fonts/font.ttf', 16),
    ['large'] = love.graphics.newFont('fonts/font.ttf', 32)
}