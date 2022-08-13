--[[Board
]]

Board = Class{}

function Board:init(x, y)
    self.x = x
    self.y = y
    self.matches = {}
    self.powerUps = 1

    self:initializeTiles()
end

--creates board with a grid of tiles, in a table
function Board:initializeTiles()
    self.tiles = {}

    for tileY = 1, 8 do
        --empty table that will serve as a new row
        table.insert(self.tiles, {})

        for tileX = 1, 8 do
            
            --creates a new tile at X,Y, with a random color and variety
            table.insert(self.tiles[tileY], Tile(tileX, tileY, math.random(9), math.random(self.powerUps)))
        end
    end

    while self:calculateMatches() do
        --recursively initializes if matches were returned so there is always a matchless board upon starting
        self:initializeTiles()
    end
end

function Board:calculateMatches()
    local matches = {}

    --how many of the same color block we've found next to each other
    local matchNum = 1
    
    --goes through the board horizontally then vertically, looking for matches of 3 or more tiles
    for y = 1, 8 do
        local colorToMatch = self.tiles[y][1].color

        matchNum = 1

        --Horizontal Matches
        for x = 2, 8 do
            --checks if tile is the same color as tile we're trying to match
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
            else
                --set this tile as the new color we want to watch for
                colorToMatch = self.tiles[y][x].color

                --if there are 3 or more in a row, then there's a match
                if matchNum >= 3 then
                    local match = {}

                    --go backwards to count number of tiles in the match
                    for x2 = x - 1, x - matchNum, -1 do
                        --add each tile to the match that's
                        table.insert(match, self.tiles[y][x2])
                    end

                    --add this match to our total matches table
                    table.insert(matches, match)
                end
                
                matchNum = 1
                
                --dont need to check last two in row if we know there won't be a match
                if x >= 7 then
                    break
                end
            end
        end

        --account for the last row ending with a match
        if matchNum >= 3 then
            local match = {}

            for x = 8, 8 - matchNum + 1, -1 do
                --add each tile to the match that's
                table.insert(match, self.tiles[y][x])
            end

            --add this match to our total matches table
            table.insert(matches, match)
        end
    end

    --Vertical matches, same logic but with x and y inverted
    for x = 1, 8 do
        local colorToMatch = self.tiles[1][x].color

        matchNum = 1

        -- every vertical tile
        for y = 2, 8 do
            if self.tiles[y][x].color == colorToMatch then
                matchNum = matchNum + 1
            else
                colorToMatch = self.tiles[y][x].color

                if matchNum >= 3 then
                    local match = {}

                    for y2 = y - 1, y - matchNum, -1 do
                        table.insert(match, self.tiles[y2][x])
                    end

                    table.insert(matches, match)
                end

                matchNum = 1

                -- don't need to check last two if they won't be in a match
                if y >= 7 then
                    break
                end
            end
        end

        -- account for the last column ending with a match
        if matchNum >= 3 then
            local match = {}
            
            -- go backwards from end of last row by matchNum
            for y = 8, 8 - matchNum + 1, -1 do
                table.insert(match, self.tiles[y][x])
            end

            table.insert(matches, match)
        end
    end

    --store matches for later reference (removal)
    self.matches = matches

    --return matches table if > 0, else just return false
    return #self.matches > 0 and self.matches or false
end

--Removes all matches, between games
function Board:removeMatches()
    for k, match in pairs(self.matches) do
        for k, tile in pairs(match) do
            self.tiles[tile.gridY][tile.gridX] = nil
        end
    end

    self.matches = nil
end

function Board:getFallingTiles()
    --tween table, with tiles as keys and their x and y as the to values
    local tweens = {}

    --for each column, go up tile by tile until we hit a space
    for x = 1, 8 do
        local space = false
        local spaceY = 0

        local y = 8
        while y >= 1 do
            --if the last tile ends in a space, then
            local tile = self.tiles[y][x]
            if space then
                --if current tile is NOT a space, bring it down to the lowest space
                if tile then
                    --put the tile in the correct spot in the board, and change it's grid positions
                    self.tiles[spaceY][x] = tile
                    tile.gridY = spaceY

                    --set it's prior position to nil
                    self.tiles[y][x] = nil

                    --tween the Y position to 32 x it's grid position
                    tweens[tile] = {
                        y = (tile.gridY - 1) * 32
                    }

                    --set Y to spaceY so we start back from here again
                    space = false
                    y = spaceY

                    --set spaceY back to 0 so there's no active space
                    spaceY = 0
                end
            elseif tile == nil then
                space = true

                --if we haven't assign a space yet, set this to it
                if spaceY == 0 then
                    spaceY = y
                end
            end

            --move to next column
            y = y - 1
        end
    end

    --create replacement tiles at the top of the screen
    for x = 1, 8 do
        for y = 8, 1, -1 do
            local tile = self.tiles[y][x]

            --if the tile is nil, we need to add a new one
            if not tile then
                --adds new random tile to the top of the column
                local tile = Tile(x, y, math.random(18), math.random(self.powerUps))
                tile.y = -32
                self.tiles[y][x] = tile

                --creates a new tween to return for this tile to fall down
                tweens[tile] = {
                    y = (tile.gridY - 1) * 32
                }
            end
        end
    end

    return tweens

end

function Board:render()
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[1] do
            self.tiles[y][x]:render(self.x, self.y)
        end
    end
end