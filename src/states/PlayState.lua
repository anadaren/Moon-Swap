--[[PlayState
]]

PlayState = Class{__includes = BaseState}

function PlayState:init()

    --transition alpha
    self.transitionAlpha = 1

    --position in the grid which we're highlighting
    self.boardHighlightX = 0
    self.boardHighlightY = 0

    --timer used to switch the highlight rect's color
    self.rectHighlighted = false

    --check to make sure we can process input
    self.canInput = true

    --tile that is currently highlighted
    self.highlightedTile = nil
    
    --score and current timer
    self.score = 0
    self.timer = 100

    --set out Timer class to turn cursor highlight on and off
    Timer.every(0.5, function()
        self.rectHighlighted = not self.rectHighlighted
    end)

    --timer countdown
    Timer.every(1, function()
        self.timer = self.timer - 1
        
        --play warning when timer gets low
        if self.timer <=5 then
            gSounds['clock']:play()
        end
    end)
end

function PlayState:enter(params)
    --params are passed from prior game over

    --get current level number
    self.level = params.level

    --spawn a board and place it on the right
    self.board = params.board or Board(VIRTUAL_WIDTH - 272, 16)

    --get score (if there is one)
    self.score = params.score or 0

    --score goal and time limit to reach next level
    self.scoreGoal = self.level * 1.25 * 1000
    --self.timer = self.timer * 1.5

end

function PlayState:update(dt)
    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end

    --when time runs out, game over
    if self.timer <= 0 then
        --clears timer
        Timer.clear()

        gSounds['game-over']:play()

        gStateMachine:change('game-over', {
            score = self.score
        })
    end

    --go to next level when you reach a certain score
    if self.score >= self.scoreGoal then
        --clears timer
        Timer.clear()

        gSounds['next-level']:play()

        gStateMachine:change('begin-game', {
            level = self.level + 1,
            score = self.score
        })
    end

    if self.canInput then
        --main player movement, in four directions
        if love.keyboard.wasPressed('up') or love.keyboard.wasPressed('w') then
            self.boardHighlightY = math.max(0, self.boardHighlightY - 1)
            gSounds['select']:play()
        elseif love.keyboard.wasPressed('down') or love.keyboard.wasPressed('s') then
            self.boardHighlightY = math.min(7, self.boardHighlightY + 1)
            gSounds['select']:play()
        elseif love.keyboard.wasPressed('left') or love.keyboard.wasPressed('a') then
            self.boardHighlightX = math.max(0, self.boardHighlightX - 1)
            gSounds['select']:play()
        elseif love.keyboard.wasPressed('right') or love.keyboard.wasPressed('d') then
            self.boardHighlightX = math.min(7, self.boardHighlightX + 1)
            gSounds['select']:play()
        end

    --Select/Deselect tile
    if love.keyboard.wasPressed == 'enter' or love.keyboard.wasPressed('return') or love.keyboard.wasPressed('space') then
        --coordinates of tile player wants to select
        local x = self.boardHighlightX + 1
        local y = self.boardHighlightY + 1
        
        --if nothing is highlighted, highlight current tile
        if not self.highlightedTile then
            self.highlightedTile = self.board.tiles[y][x]

        --if we select the position already highlighted, deselect
        elseif self.highlightedTile == self.board.tiles[y][x] then
            self.highlightedTile = nil

        --if the selected tile is NOT a neighbor of the previously selected tile, play error
        --determined via whether or not the difference between the X and Y position combined is equal to 1
        elseif math.abs(self.highlightedTile.gridX - x) + math.abs(self.highlightedTile.gridY - y) > 1 then
            gSounds['error']:play()
            self.highlightedTile = nil

        else

            --the two tiles to be swapped:
            --tile 1, temporary clone of first tile selected
            local tempX, tempY = self.highlightedTile.gridX, self.highlightedTile.gridY

            --tile 2, second tile selected
            local newTile = self.board.tiles[y][x]

            --tile that just got swapped
            local justSwapped = newTile

            --Function for swapping and selecting tiles
            self:swapTiles(tempX, tempY, newTile, x ,y)

            --Swaps tiles--

            --swaps tiles x and y positions in grid
            self.highlightedTile.gridX = newTile.gridX
            self.highlightedTile.gridY = newTile.gridY
            newTile.gridX = tempX
            newTile.gridY = tempY

            --swaps tiles positions in the table of tiles (which we named board)
            self.board.tiles[self.highlightedTile.gridY][self.highlightedTile.gridX] = self.highlightedTile
            self.board.tiles[newTile.gridY][newTile.gridX] = newTile

            Timer.tween(0.1, {
                [self.highlightedTile] = {x = newTile.x, y = newTile.y},
                [newTile] = {x = self.highlightedTile.x, y = self.highlightedTile.y}
            })


            if not self.board:calculateMatches() then
                --revert the swap that just happened
                --self:swapTiles()

            else
                self:calculateMatches()
            end
            self.highlightedTile = nil
        end
        
        end       
    end
    Timer.update(dt)
end

function PlayState:swapTiles(tempX, tempY, newTile, x ,y)

    --if tile swapping doesn't make a match, swap them back
    --[[if not self.board:calculateMatches() then
        --self.highlightedTile.gridX, self.highLightedTile.gridY = newTile.gridX, newTile.gridY

            tempX, tempY = self.highlightedTile.gridX, self.highlightedTile.gridY

            --tile 2, second tile selected
            newTile = justSwapped
    
            --swaps tiles x and y positions in grid
            self.highlightedTile.gridX = newTile.gridX
            self.highlightedTile.gridY = newTile.gridY
            newTile.gridX = tempX
            newTile.gridY = tempY
    
            --swaps tiles positions in the table of tiles (which we named board)
            self.board.tiles[self.highlightedTile.gridY][self.highlightedTile.gridX] = self.highlightedTile
            self.board.tiles[newTile.gridY][newTile.gridX] = newTile
    
            --Timer.tween(0.5, {
              --  [self.highlightedTile] = {x = newTile.x, y = newTile.y},
                --[newTile] = {x = self.highlightedTile.x, y = self.highlightedTile.y}
            --})

    else]]
            

            --:finish(function()
            --self:calculateMatches()
            --end)
    --end
    --self.highlightedTile = nil

end

--Calculates matches between tiles
function PlayState:calculateMatches()
    

    --if we have any matches, remove them and then tween the blocks falling
    local matches = self.board:calculateMatches()

    if matches then
        gSounds['match']:stop()
        gSounds['match']:play()

        --add score for each match
        for k, match in pairs(matches) do
            self.score = self.score + #match * 50
        end

        --remove any matched tiles from the board
        self.board:removeMatches()

        --gets a table with tween files for all tiles that should fall
        local tilesToFall = self.board:getFallingTiles()

        --tween new tiles that spawn from ceiling
        Timer.tween(0.25, tilesToFall):finish(function()
            --recursively call function
            self:calculateMatches()
        end)
    end
end

function PlayState:render()
    --render board of tiles
    self.board:render()

    --render the tile currently highlighted (if it exists)
    if self.highlightedTile then
        --set blendmode to multiply
        love.graphics.setBlendMode('add')
        
        love.graphics.setColor(1, 1, 1, 96/255)
        love.graphics.rectangle('fill', (self.highlightedTile.gridX - 1) * 32 + (VIRTUAL_WIDTH - 272),
            (self.highlightedTile.gridY - 1) * 32 + 16, 32, 32, 4)
        
            love.graphics.setBlendMode('alpha')
    end

    --render highlight rect color based on timer
    if self.rectHighlighted then
        love.graphics.setColor(217/255, 87/255, 99/255, 1)
    else
        love.graphics.setColor(172/255, 50/255, 50/255, 1)
    end

 
    --draw currently selected tile
    --almost opaque red color
    love.graphics.setColor(255, 0, 0, 234)

    --thicker line width
    love.graphics.setLineWidth(4)

    -- line rect where tile is
    love.graphics.rectangle('line', self.boardHighlightX * 32 + (VIRTUAL_WIDTH - 272),
        self.boardHighlightY * 32 + 16, 32, 32, 4)
        
    -- reset color back to default
    love.graphics.setColor(255, 255, 255, 255)



    -- GUI text
    love.graphics.setColor(56/255, 56/255, 56/255, 234/255)
    love.graphics.rectangle('fill', 16, 16, 186, 116, 4)

    love.graphics.setColor(125/255, 125/255, 125/255, 1)
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Level: ' .. tostring(self.level), 20, 24, 182, 'center')
    love.graphics.printf('Score: ' .. tostring(self.score), 20, 52, 182, 'center')
    love.graphics.printf('Goal : ' .. tostring(self.scoreGoal), 20, 80, 182, 'center')
    love.graphics.printf('Timer: ' .. tostring(self.timer), 20, 108, 182, 'center')


    --Sidebar image
    love.graphics.draw(gTextures['sidebar'], 50, 125)
end