--[[
    GD50
    Legend of Zelda

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

GameObject = Class{}

function GameObject:init(def, x, y)
    
    -- string identifying this object type
    self.type = def.type

    self.texture = def.texture
    self.frame = def.frame or 1

    -- whether it acts as an obstacle or not
    self.solid = def.solid

    self.defaultState = def.defaultState
    self.state = self.defaultState
    self.states = def.states
    self.consumable = false
    self.destroyed = false

    -- dimensions
    self.x = x
    self.y = y
    self.width = def.width
    self.height = def.height
    self.dx = def.dx or 0
    self.dy = def.dy or 0
    self.alpha = 1

    -- default empty collision callback
    self.onCollide = function() end

    -- default empty consumption callback
    self.onConsume = function() end
end

function GameObject:update(dt)
    if self.attached then
        self.x = self.attached.x 
        self.y = self.attached.y - self.height/2
    end

    if self.projectile then
        self.x = self.x + self.dx * dt
        self.y = self.y + self.dy * dt
        self.timer = self.timer + dt
        for k, monster in pairs(self.entities) do
            if self:collides(monster) and not monster.dead then
                self:destroy()
                monster:damage(1)
                gSounds['hit-enemy']:play()
            end
        end
        if self.x < MAP_RENDER_OFFSET_X + TILE_SIZE or self.x + 16 > VIRTUAL_WIDTH - TILE_SIZE * 2 
        or self.y < MAP_RENDER_OFFSET_Y + TILE_SIZE - self.height/2
        or self.y + 16 > MAP_HEIGHT * TILE_SIZE + MAP_RENDER_OFFSET_Y - TILE_SIZE 
        or self.timer > 1 then
            self:destroy()
        end
    end
end

function GameObject:collides(target)
    return not (self.x + self.width < target.x or self.x > target.x + target.width
                 or self.y + self.height < target.y or self.y > target.y + target.height)
end

function GameObject:destroy()
    self.projectile = false
    self.state = 'broken'
    self.solid = false
    gSounds['hurt']:play()
    Timer.tween(0.75, {
        [self] = {alpha = 0}
    }
    ):finish(function ()
        self.destroyed = false
    end
    )

end

function GameObject:fire(direction, entities, dt)
    self.direction = direction
    self.entities = entities
    self.projectile = true
    
    self.timer = 0
    if self.direction == 'left' then
        self.dx = -64
        self.dy = 15
    elseif self.direction == 'right' then
        self.dx = 64
        self.dy = 15
    elseif self.direction == 'up' then
        self.dx = 0
        self.dy = -48
    else
        self.dx = 0
        self.dy = 80
    end
    self.attached = nil

end

function GameObject:render(adjacentOffsetX, adjacentOffsetY)
    love.graphics.setColor(255, 255, 255, self.alpha)
    love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.states[self.state].frame or self.frame],
        self.x + adjacentOffsetX, self.y + adjacentOffsetY)
    love.graphics.setColor(255, 255, 255, 1)

    -- debugging tool
    love.graphics.setColor(255, 0, 255, 255)
    love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
    
    love.graphics.setColor(255, 255, 255, 255)
end

