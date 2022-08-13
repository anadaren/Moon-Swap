--[[
    Moon Swap, a match3 game.

    New Title Pending


    Credit for graphics:
    https://opengameart.org/users/buch

    Credit for music:
    http://freemusicarchive.org/music/RoccoW/
]]

-- initialize our nearest-neighbor filter
love.graphics.setDefaultFilter('nearest', 'nearest')

--all necessary assets for the game kept here
require 'src/Dependencies'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

--BACKGROUND_SCROLL_SPEED = 80

function love.load()
    --window bar title
    love.window.setTitle('Moon Swap')

    --seed the RNG
    math.randomseed(os.time())

    --initializes virtual resolution
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true,
        canvas = true
    })

    --set music to loop and start
    gSounds['music']:setLooping(true)
    gSounds['music']:play()

    --initliazes state machine
    gStateMachine = StateMachine {
        ['start'] = function() return StartState() end,
        ['begin-game'] = function() return BeginGameState() end,
        ['play'] = function() return PlayState() end,
        ['game-over'] = function() return GameOverState() end
    }
    gStateMachine:change('start')

    --keep track of background scrolling on the X axis
    backgroundX = 0

    --initialize input table
    love.keyboard.keysPressed = {}
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    --adds the key that was pressed to table of keys pressed on this frame
    love.keyboard.keysPressed[key] = true

end

function love.keyboard.wasPressed(key)
    --checks if key has been pressed
    if love.keyboard.keysPressed[key] then
        return true
    else
        return false
    end
end

function love.update(dt)
    --animates constant scrolling background
    --[[backgroundX = backgroundX - BACKGROUND_SCROLL_SPEED * dt

    --loops image after reaching the end
    if backgroundX <= -1024 + VIRTUAL_WIDTH - 4 + 51 then
        backgroundX = 0
    end]]
    
    --updates the current state
    gStateMachine:update(dt)

    --input
    love.keyboard.keysPressed = {}
end

function love.draw()
    push:start()
    --renders constant scrolling background
    love.graphics.draw(gTextures['background'], backgroundX, 0)

    --renders the current state on top
    gStateMachine:render()
    push:finish()
end