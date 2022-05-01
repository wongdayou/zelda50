--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Room = Class{}

function Room:init(player)
    self.width = MAP_WIDTH
    self.height = MAP_HEIGHT

    -- reference to player for collisions, etc.
    self.player = player

    -- used to check initial placement of objects and entities, so as to avoid collision
    self.gridCheck = {}

    -- generate tiles
    self.tiles = {}
    self:generateWallsAndFloors()

    -- game objects in the room
    self.objects = {}
    self:generateObjects()
    
    -- entities in the room
    self.entities = {}
    self:generateEntities()

    

    -- doorways that lead to other dungeon rooms
    self.doorways = {}
    table.insert(self.doorways, Doorway('top', false, self))
    table.insert(self.doorways, Doorway('bottom', false, self))
    table.insert(self.doorways, Doorway('left', false, self))
    table.insert(self.doorways, Doorway('right', false, self))

    

    -- used for centering the dungeon rendering
    self.renderOffsetX = MAP_RENDER_OFFSET_X
    self.renderOffsetY = MAP_RENDER_OFFSET_Y

    -- used for drawing when this room is the next room, adjacent to the active
    self.adjacentOffsetX = 0
    self.adjacentOffsetY = 0

    
end

--[[
    Randomly creates an assortment of obstacles for the player to navigate around.
]]
function Room:generateObjects()
    -- table to check the locations of each pot so we do not have same pots on one tile

    local switchX = math.random(MAP_RENDER_OFFSET_X + TILE_SIZE, VIRTUAL_WIDTH - TILE_SIZE * 2 - 16)
    local switchY = math.random(MAP_RENDER_OFFSET_Y + TILE_SIZE, (MAP_HEIGHT * TILE_SIZE) + MAP_RENDER_OFFSET_Y - TILE_SIZE - 16)
    local switch = GameObject(
        GAME_OBJECT_DEFS['switch'],
        switchX,
        switchY
    )

    -- define a function for the switch that will open all doors in the room
    switch.onCollide = function()
        if switch.state == 'unpressed' then
            switch.state = 'pressed'
            
            -- open every door in the room if we press the switch
            for k, doorway in pairs(self.doorways) do
                doorway.open = true
            end

            gSounds['door']:play()
        end
    end

    -- add to list of objects in scene (only one switch for now)
    table.insert(self.objects, switch)

    table.insert(self.gridCheck, {x = switchX, y = switchY})

    -- determines how many pots we going to have, maximum of four in a room
    local potnum = math.random(10)
    
    
    for i = 1, potnum do
        local flag = true
        local potX = math.random(MAP_RENDER_OFFSET_X + TILE_SIZE, VIRTUAL_WIDTH - TILE_SIZE * 2 - 16)
        local potY = math.random(MAP_RENDER_OFFSET_Y + TILE_SIZE, (MAP_HEIGHT * TILE_SIZE) + MAP_RENDER_OFFSET_Y - TILE_SIZE - 16)
        
        -- generate coordinates that do not conflict with existing objects
        potX, potY = self:generateCoordinates(potX, potY, true)
        
        local pot = GameObject(
            GAME_OBJECT_DEFS['pot'],
            potX,
            potY
        )
        local frameType = 0
        local brokenFrame = 0
        if math.random(2) == 1 then
            frameType = math.random(14, 16)
            brokenFrame = frameType - 14 + 52
        else
            frameType = math.random(33, 35)
            brokenFrame = frameType - 33 + 52
        end
        
         
        pot.states = {
            ['normal'] = {
                frame = frameType
            },
            ['broken'] = {
                frame = brokenFrame
            }
        }
        
        table.insert(self.objects, pot)
        table.insert(self.gridCheck, {x = potX, y = potY})



    end
end

--[[  
    Randomly creates an assortment of enemies for the player to fight.
]]
function Room:generateEntities()
    local types = {'skeleton', 'slime', 'bat', 'ghost', 'spider'}

    for i = 1, 10 do
        local type = types[math.random(#types)]
        local mobX = math.random(MAP_RENDER_OFFSET_X + TILE_SIZE, VIRTUAL_WIDTH - TILE_SIZE * 2 - 16)
        local mobY = math.random(MAP_RENDER_OFFSET_Y + TILE_SIZE, 
                        VIRTUAL_HEIGHT - (VIRTUAL_HEIGHT - MAP_HEIGHT * TILE_SIZE) + MAP_RENDER_OFFSET_Y - TILE_SIZE - 16)
        mobX, mobY = self:generateCoordinates(mobX, mobY, false)
        table.insert(self.entities, Entity {
            animations = ENTITY_DEFS[type].animations,
            walkSpeed = ENTITY_DEFS[type].walkSpeed or 20,

            -- ensure X and Y are within bounds of the map
            x = mobX,
            y = mobY,
            
            width = 16,
            height = 16,

            health = 1
        })
        table.insert(self.gridCheck, {x = mobX, y = mobY})

        self.entities[i].stateMachine = StateMachine {
            ['walk'] = function() return EntityWalkState(self.entities[i], self.objects) end,
            ['idle'] = function() return EntityIdleState(self.entities[i], self.objects) end
        }

        self.entities[i]:changeState('walk')
    end
end



--[[
    Generates the walls and floors of the room, randomizing the various varieties
    of said tiles for visual variety.
]]
function Room:generateWallsAndFloors()
    for y = 1, self.height do
        table.insert(self.tiles, {})

        for x = 1, self.width do
            local id = TILE_EMPTY

            if x == 1 and y == 1 then
                id = TILE_TOP_LEFT_CORNER
            elseif x == 1 and y == self.height then
                id = TILE_BOTTOM_LEFT_CORNER
            elseif x == self.width and y == 1 then
                id = TILE_TOP_RIGHT_CORNER
            elseif x == self.width and y == self.height then
                id = TILE_BOTTOM_RIGHT_CORNER
            
            -- random left-hand walls, right walls, top, bottom, and floors
            elseif x == 1 then
                id = TILE_LEFT_WALLS[math.random(#TILE_LEFT_WALLS)]
            elseif x == self.width then
                id = TILE_RIGHT_WALLS[math.random(#TILE_RIGHT_WALLS)]
            elseif y == 1 then
                id = TILE_TOP_WALLS[math.random(#TILE_TOP_WALLS)]
            elseif y == self.height then
                id = TILE_BOTTOM_WALLS[math.random(#TILE_BOTTOM_WALLS)]
            else
                id = TILE_FLOORS[math.random(#TILE_FLOORS)]
            end
            
            table.insert(self.tiles[y], {
                id = id
            })
        end
    end
end

function Room:update(dt)
    
    -- don't update anything if we are sliding to another room (we have offsets)
    if self.adjacentOffsetX ~= 0 or self.adjacentOffsetY ~= 0 then return end

    self.player:update(dt)

    for i = #self.entities, 1, -1 do
        local entity = self.entities[i]

        -- remove entity from the table if health is <= 0
        if entity.health <= 0 then
            if not entity.dead then entity:die(self.objects) end
            entity.dead = true
            
        elseif not entity.dead then
            entity:processAI({room = self}, dt)
            entity:update(dt)
        end

        -- collision between the player and entities in the room
        if not entity.dead and self.player:collides(entity) and not self.player.invulnerable then
            gSounds['hit-player']:play()
            self.player:damage(1)
            self.player:goInvulnerable(1.5)

            if self.player.health == 0 then
                gStateMachine:change('game-over')
            end
        end
    end

    for k, object in pairs(self.objects) do
        
        object:update(dt)

        -- trigger collision callback on object
        if self.player:collides(object) then
            if object.consumable then
                object.onConsume(self.player)
                table.remove(self.objects, k)
            else
                object:onCollide()
            end
        end
        if object.destroyed then
            table.remove(self.objects, k)
        end
    end
end

--function to generate coordinates that do not conflict with existing objects/entities/doorways
function Room:generateCoordinates(X, Y, doorwayCheck)
    local flag = true
    while flag do
        flag = false
        -- check if there is a collision with the player
        if not ((X + 16 < self.player.x or X > self.player.x + 16 or
                    Y + 16 < self.player.y or Y > self.player.y + 22)) then flag = true end
        
        if doorwayCheck then
            -- check obstruction to door on left
            if not ((X > MAP_RENDER_OFFSET_X + TILE_SIZE + 16 or 
                Y + 16 < MAP_RENDER_OFFSET_Y + (MAP_HEIGHT / 2) * TILE_SIZE - TILE_SIZE or
                Y > MAP_RENDER_OFFSET_Y + (MAP_HEIGHT / 2) * TILE_SIZE - TILE_SIZE + 32 )) then
                flag = true
            end

            --check obstruction to door on right
            if not (X + 16 < MAP_RENDER_OFFSET_X + (MAP_WIDTH * TILE_SIZE) - TILE_SIZE - 16 or 
                Y + 16 < MAP_RENDER_OFFSET_Y + (MAP_HEIGHT / 2) * TILE_SIZE - TILE_SIZE or
                Y > MAP_RENDER_OFFSET_Y + (MAP_HEIGHT / 2) * TILE_SIZE - TILE_SIZE + 32 ) then
                flag = true
            end

            -- check obstruction to door on top
            if not (X + 16 < MAP_RENDER_OFFSET_X + (MAP_WIDTH / 2 * TILE_SIZE) - TILE_SIZE or
                X > MAP_RENDER_OFFSET_X + (MAP_WIDTH / 2 * TILE_SIZE) - TILE_SIZE + 32 or
                Y > MAP_RENDER_OFFSET_Y + TILE_SIZE + 16) then
                flag = true
            end

            -- check obstruction to door below
            if not (X + 16 < MAP_RENDER_OFFSET_X + (MAP_WIDTH / 2 * TILE_SIZE) - TILE_SIZE or
                X > MAP_RENDER_OFFSET_X + (MAP_WIDTH / 2 * TILE_SIZE) - TILE_SIZE + 32 or
                Y + 16 < MAP_RENDER_OFFSET_Y + (MAP_HEIGHT * TILE_SIZE) - TILE_SIZE - 16) then
                flag = true
            end

        end
        
        if not flag then
            for k, v in pairs(self.gridCheck) do
                -- if there is a pot collision
                if not ((X + 16 < v.x or X > v.x + 16 or
                        Y + 16 < v.y or Y > v.y + 16 )) then
                    flag = true
                    break
                end
            end
        end
        -- if there is a collision with either player or other game objects then reshuffle coordinates
        if flag then
            X = math.random(MAP_RENDER_OFFSET_X + TILE_SIZE, 
                    VIRTUAL_WIDTH - TILE_SIZE * 2 - 16)
            Y = math.random(MAP_RENDER_OFFSET_Y + TILE_SIZE, 
                    (MAP_HEIGHT * TILE_SIZE) + MAP_RENDER_OFFSET_Y - TILE_SIZE - 16)
        end

    end
    return X, Y

end

function Room:render()
    for y = 1, self.height do
        for x = 1, self.width do
            local tile = self.tiles[y][x]
            love.graphics.draw(gTextures['tiles'], gFrames['tiles'][tile.id],
                (x - 1) * TILE_SIZE + self.renderOffsetX + self.adjacentOffsetX, 
                (y - 1) * TILE_SIZE + self.renderOffsetY + self.adjacentOffsetY)
        end
    end

    -- render doorways; stencils are placed where the arches are after so the player can
    -- move through them convincingly
    for k, doorway in pairs(self.doorways) do
        doorway:render(self.adjacentOffsetX, self.adjacentOffsetY)
    end

    for k, object in pairs(self.objects) do
        object:render(self.adjacentOffsetX, self.adjacentOffsetY)
    end


    for k, entity in pairs(self.entities) do
        if not entity.dead then entity:render(self.adjacentOffsetX, self.adjacentOffsetY) end
    end
    if self.player then
        if self.player.item then
            self.player.item:render(self.adjacentOffsetX, self.adjacentOffsetY)
        end
    end

    -- stencil out the door arches so it looks like the player is going through
    love.graphics.stencil(function()
        
        -- left
        love.graphics.rectangle('fill', -TILE_SIZE - 6, MAP_RENDER_OFFSET_Y + (MAP_HEIGHT / 2) * TILE_SIZE - TILE_SIZE,
            TILE_SIZE * 2 + 6, TILE_SIZE * 2)
        
        -- right
        love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH * TILE_SIZE),
            MAP_RENDER_OFFSET_Y + (MAP_HEIGHT / 2) * TILE_SIZE - TILE_SIZE, TILE_SIZE * 2 + 6, TILE_SIZE * 2)
        
        -- top
        love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH / 2) * TILE_SIZE - TILE_SIZE,
            -TILE_SIZE - 6, TILE_SIZE * 2, TILE_SIZE * 2 + 12)
        
        --bottom
        love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH / 2) * TILE_SIZE - TILE_SIZE,
            VIRTUAL_HEIGHT - TILE_SIZE - 6, TILE_SIZE * 2, TILE_SIZE * 2 + 12)
    end, 'replace', 1)

    love.graphics.setStencilTest('less', 1)
    
    if self.player then
        self.player:render()
    end
    

    love.graphics.setStencilTest()

    
    
    --DEBUG DRAWING OF STENCIL RECTANGLES
    

    -- love.graphics.setColor(255, 0, 0, 100)
    
    -- left
    -- love.graphics.rectangle('fill', -TILE_SIZE - 6, MAP_RENDER_OFFSET_Y + (MAP_HEIGHT / 2) * TILE_SIZE - TILE_SIZE,
    -- TILE_SIZE * 2 + 6, TILE_SIZE * 2)

    -- right
    -- love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH * TILE_SIZE),
    --     MAP_RENDER_OFFSET_Y + (MAP_HEIGHT / 2) * TILE_SIZE - TILE_SIZE, TILE_SIZE * 2 + 6, TILE_SIZE * 2)

    -- top
    -- love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH / 2) * TILE_SIZE - TILE_SIZE,
    --     -TILE_SIZE - 6, TILE_SIZE * 2, TILE_SIZE * 2 + 12)

    -- bottom
    -- love.graphics.rectangle('fill', MAP_RENDER_OFFSET_X + (MAP_WIDTH / 2) * TILE_SIZE - TILE_SIZE,
    --     VIRTUAL_HEIGHT - TILE_SIZE - 6, TILE_SIZE * 2, TILE_SIZE * 2 + 12)
    
    -- love.graphics.setColor(255, 255, 255, 255)
end