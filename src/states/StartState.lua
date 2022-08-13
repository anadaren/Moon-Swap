--[[Statestate

]]

local positions = {}

StartState = Class{__includes = BaseState}

function StartState:init()
    --currently selected menu item
    self.currentMenuItem = 1

    --the different colors for rotating title text
    self.colors = {
        [1] = {217/255, 87/255, 99/255, 1},
        [2] = {95/255, 205/255, 228/255, 1},
        [3] = {251/255, 242/255, 54/255, 1},
        [4] = {118/255, 66/255, 138/255, 1},
        [5] = {153/255, 229/255, 80/255, 1},
        [6] = {223/255, 113/255, 38/255, 1},
        [7] = {223/255, 113/255, 38/255, 1},
        [8] = {223/255, 113/255, 38/255, 1}
    }

    --placing the letters of the title text, with a position relative to the center
    self.letterTable = {
        {'M', -160},
        {'O', -115},
        {'O', -75},
        {'N', -35},
        {'S', 36},
        {'W', 80},
        {'A', 125},
        {'P', 165}
    }

    --making the rotating title text change between the colors
    --time the color change (half a second)
    self.colorTimer = Timer.every(0.085, function()
        --shift color to next color via counting down, looping if needed
        --assign it to 0 so the loop below moves it to 1, default start
        self.colors[0] = self.colors[6]

        for i = 8, 1, -1 do
            self.colors[i] = self.colors[i-1]
        end
    end)

    --generate full table of tiles just for display
    for i = 1, 64 do
        table.insert(positions, gFrames['tiles'][math.random(18)][math.random(6)])
    end

    --used to animate starting transition, using tweens
    self.transitionAlpha = 0

    --if option is selected pause input
    self.pauseInput = false
end

function StartState:update(dt)
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

    --if input isn't paused, then input can continue
    if not self.pauseInput then

        --change menu slection
        if love.keyboard.wasPressed('up') or love.keyboard.wasPressed('down') then
            self.currentMenuItem = self.currentMenuItem == 1 and 2 or 1
            gSounds['select']:play()
        end

        --switch to another state when an option is selected
        if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
           if self.currentMenuItem == 1 then
                --start game

                --tween transition animation, then switch to game state
                Timer.tween(1, {
                    [self] = {transitionAlpha = 1}
                }):finish(function()
                    gStateMachine:change('begin-game', {
                        level = 1
                    })
                --remove color timer from Timer class because it's no longer relevant
                self.colorTimer:remove()
                end)
           else
                --quit
                love.event.quit()
           end
        
           --turn off input for starting transition
           self.pauseInput = true
        end
    end

    --update Timer, which will be used for fade transitions
    Timer.update(dt)
end

function StartState:render()
    --render all tiles and their shadows
    for y = 1, 8 do
        for x = 1, 8 do
            
            --render shadow
            love.graphics.setColor(0, 0, 0, 1)
            love.graphics.draw(gTextures['main'], positions[(y - 1) * x + x],
                (x - 1) * 32 + 128 + 3, (y - 1) * 32 + 16 + 3)

            --render tile
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(gTextures['main'], positions[(y - 1) * x + x],
                (x - 1) * 32 + 128, (y - 1) * 32 + 16)
        end
    end

    --render background
    love.graphics.draw(gTextures['startBackground'], 0, 0)
    
    --render moon graphic
    love.graphics.draw(gTextures['startSplash'], VIRTUAL_WIDTH/2-125, 10)

    --draw menu text
    self:drawMatch3Text(-60)
    self:drawOptions(12)

    --draw transition rect; normally transparent, unless in a transition
    love.graphics.setColor(255, 255, 255, self.transitionAlpha)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)

end    

--off-center title/menu text, placed off to the side relative to center
function StartState:drawMatch3Text(y)
    --draw semi-transparent rect behind title
    love.graphics.setColor(1, 1, 1, 128/255)
    love.graphics.rectangle('fill', VIRTUAL_WIDTH / 2 - 76, VIRTUAL_HEIGHT / 2 + y - 11, 150, 58, 6)

    --draw title shadows
    love.graphics.setFont(gFonts['large'])
    self:drawTextShadow('MOON SWAP', VIRTUAL_HEIGHT / 2 + y)

    --print title letters in their corresponding current color
    for i = 1, 8 do
        love.graphics.setColor(self.colors[i])
        love.graphics.printf(self.letterTable[i][1], 0, VIRTUAL_HEIGHT / 2 + y,
            VIRTUAL_WIDTH + self.letterTable[i][2], 'center')
    end
end

--draw "Start" and "Quit" text over semi-transparent menu rectangles
function StartState:drawOptions(y)
    --draw rect behind options text
    love.graphics.setColor(1, 1, 1, 128/255)
    love.graphics.rectangle('fill', VIRTUAL_WIDTH / 2 - 76, VIRTUAL_HEIGHT / 2 + y, 150, 58, 6)

    --draw start text
    love.graphics.setFont(gFonts['medium'])
    self:drawTextShadow('Start', VIRTUAL_HEIGHT / 2 + y + 8)

    if self.currentMenuItem == 1 then
        love.graphics.setColor(99/255, 155/255, 1, 1)
    else
        love.graphics.setColor(48/255, 96/255, 1, 1)
    end

    love.graphics.printf('Start', 0, VIRTUAL_HEIGHT / 2 + y + 8, VIRTUAL_WIDTH, 'center')

    --draw quit text
    love.graphics.setFont(gFonts['medium'])
    self:drawTextShadow('Quit', VIRTUAL_HEIGHT / 2 + y + 33)

    if self.currentMenuItem == 2 then
        love.graphics.setColor(99/255, 155/255, 1, 1)
    else
        love.graphics.setColor(48/255, 96/255, 1, 1)
    end

    love.graphics.printf('Quit', 0, VIRTUAL_HEIGHT / 2 + y + 33, VIRTUAL_WIDTH, 'center')
end

--helper function for bolder menu text shadows
function StartState:drawTextShadow(text, y)
    love.graphics.setColor(34/255, 32/255, 52/255, 1)
    love.graphics.printf(text, 2, y + 1, VIRTUAL_WIDTH, 'center')
    love.graphics.printf(text, 1, y + 1, VIRTUAL_WIDTH, 'center')
    love.graphics.printf(text, 0, y + 1, VIRTUAL_WIDTH, 'center')
    love.graphics.printf(text, 1, y + 2, VIRTUAL_WIDTH, 'center')
end
