--[[BeginGameState
]]

BeginGameState = Class{__includes = BaseState}

function BeginGameState:init()
    --opening animation alpha
    self.transitionAlpha = 1

    --spawn a board and place it off center to the right
    self.board = Board(VIRTUAL_WIDTH - 272, 16)

    --start our level number label off-screen before animation
    self.levelLabelY = -64
end

function BeginGameState:enter(def)
    --find out which level we're on
    self.level = def.level

    --animate screen fade-in, then animated drop-down with level text

    --Fade-in animation
    --turn the opacity of the ever-present white screen down to 0
    Timer.tween(1, {
        [self] = {transitionAlpha = 0}
    })

    --Drop-down animation

    --bar comes down to center of screen in 0.25 seconds
    :finish(function()
        Timer.tween(0.25, {
            [self] = {levelLabelY = VIRTUAL_HEIGHT / 2 - 8}
        })

        --holds center position for 1 second
        :finish(function()
            Timer.after(1, function()
                --bar slides down off the screen in another 0.25 seconds
                Timer.tween(0.25, {
                    [self] = {levelLabelY = VIRTUAL_HEIGHT + 30}
                })
            
                --once that's over, switch to play state
                :finish(function()
                gStateMachine:change('play', {
                    level = self.level,
                    board = self.board
                })
                end)
            end)
        end)
    end)
end

function BeginGameState:update(dt)
    Timer.update(dt)
end

function BeginGameState:render()
    --render board
    self.board:render()

    --render opening Level # and it's background
    love.graphics.setColor(95/255, 205/255, 228/255, 200/255)
    love.graphics.rectangle('fill', 0, self.levelLabelY - 8, VIRTUAL_WIDTH, 48)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf('Level ' .. tostring(self.level),
        0, self.levelLabelY, VIRTUAL_WIDTH, 'center')

    --ever-presenmt white transition rectangle
    love.graphics.setColor(1, 1, 1, self.transitionAlpha)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
end