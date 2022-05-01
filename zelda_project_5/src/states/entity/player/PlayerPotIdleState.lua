-- State when player is holding a pot and stationary



PlayerPotIdleState = Class {__includes = EntityIdleState}

function PlayerPotIdleState:init(entity)
    self.entity = entity 

    self.entity:changeAnimation('pot-idle-' .. self.entity.direction)

end

function PlayerPotIdleState:enter(dungeon)
    
    -- render offset for spaced character sprite (negated in render function of state)
    -- if there is any abnormalities in displaying the sprites later consider changing this
    self.entity.offsetY = 5
    self.entity.offsetX = 0
    self.dungeon = dungeon
end

function PlayerPotIdleState:update(dt)
    if love.keyboard.isDown('left') or love.keyboard.isDown('right') or
       love.keyboard.isDown('up') or love.keyboard.isDown('down') then
        self.entity:changeState('pot-walk')
    end

    if love.keyboard.wasPressed('f') then
        if self.entity:checkSpace(self.dungeon.currentRoom.objects) then
            self.entity:changeState('pot-put-down')
        else
            gSounds['empty-block']:play()
        end
    end

    if love.keyboard.wasPressed('space') then
        -- table.insert(self.dungeon.currentRoom.objects, self.entity.item)
        self.entity.item:fire(self.entity.direction, self.dungeon.currentRoom.entities, dt)
        --self.entity.item = nil
        self.entity:changeState('pot-put-down', true) 
    end


end

function PlayerPotIdleState:render()
    local anim = self.entity.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        self.entity.x - self.entity.offsetX, self.entity.y - self.entity.offsetY)

    if self.entity.item then
        love.graphics.draw(gTextures[self.entity.item.texture], gFrames[self.entity.item.texture][self.entity.item.states[self.entity.item.state].frame or self.entity.item.frame],
            self.entity.item.x + self.dungeon.currentRoom.adjacentOffsetX, self.entity.item.y + self.dungeon.currentRoom.adjacentOffsetY)
    end
end