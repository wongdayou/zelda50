--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

Player = Class{__includes = Entity}

function Player:init(def)
    Entity.init(self, def)
end

function Player:update(dt)
    Entity.update(self, dt)
end

function Player:collides(target)
    local selfY, selfHeight = self.y + self.height / 2, self.height - self.height / 2
    
    return not (self.x + self.width < target.x or self.x > target.x + target.width or
                selfY + selfHeight < target.y or selfY > target.y + target.height)
end

function Player:checkFront(objects)
    local hitboxX, hitboxY, hitboxWidth, hitboxHeight
    self.objects = objects

    if self.direction == 'left' then
        hitboxWidth = 4
        hitboxHeight = 8
        hitboxX = self.x - hitboxWidth
        hitboxY = self.y + 7
    elseif self.direction == 'right' then
        hitboxWidth = 4
        hitboxHeight = 8
        hitboxX = self.x + self.width
        hitboxY = self.y + 7
    elseif self.direction == 'up' then
        hitboxWidth = 8
        hitboxHeight = 4
        hitboxX = self.x + 4
        hitboxY = self.y - hitboxHeight
    else
        hitboxWidth = 8
        hitboxHeight = 4
        hitboxX = self.x + 4
        hitboxY = self.y + self.height
    end

    -- separate hitbox for the player; will only be active during this state
    local potPickbox = Hitbox(hitboxX, hitboxY, hitboxWidth, hitboxHeight)

    for k, object in pairs(self.objects) do
        if object:collides(potPickbox) and object.solid then 
            gSounds['pickup']:play()
            --self.item = table.remove(self.objects, k)
            self.item = object
            self.item.solid = false
            return true
            
        
        end
    end
    return false
end

function Player:checkSpace(objects)
    self.objects = objects
    local xVal = 0
    local yVal = 0
    if self.direction == 'left' then
        xVal = self.x - self.item.width
        yVal = self.y + 6
    elseif self.direction == 'right' then
        xVal = self.x + self.width
        yVal = self.y + 6
    elseif self.direction == 'up' then
        xVal = self.x
        yVal = self.y - self.item.height
    else 
        xVal = self.x
        yVal = self.y + self.height
    end
    local spaceAvail = true
    if xVal < MAP_RENDER_OFFSET_X + TILE_SIZE or xVal + 16 > VIRTUAL_WIDTH - TILE_SIZE * 2 
    or yVal < MAP_RENDER_OFFSET_Y + TILE_SIZE - self.item.height/2
    or yVal + 16 > MAP_HEIGHT * TILE_SIZE + MAP_RENDER_OFFSET_Y - TILE_SIZE then
    
        spaceAvail = false    

    else
        local potHitBox = Hitbox(xVal, yVal, 16, 16)
        
        for k, object in pairs(self.objects) do
            if object:collides(potHitBox) and object.solid then
                spaceAvail = false
                break
            end
        end
    end
    return spaceAvail
end

function Player:render()
    Entity.render(self)
    
    -- love.graphics.setColor(255, 0, 255, 255)
    -- love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
    -- love.graphics.setColor(255, 255, 255, 255)

    --debug for potpickbox
    -- love.graphics.setColor(255, 0, 255, 255)
    -- if potPickbox then 
    --     love.graphics.rectangle('line', potPickbox.x, potPickbox.y,
    --         potPickbox.width, potPickbox.height)
    --     love.graphics.setColor(255, 255, 255, 255)
    -- end
end