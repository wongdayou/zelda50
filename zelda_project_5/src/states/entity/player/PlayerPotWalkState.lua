-- State for when player walks with pot

PlayerPotWalkState = Class {__includes = PlayerWalkState} 

function PlayerPotWalkState:enter(params)
    
end

function PlayerPotWalkState:update(dt)
    if love.keyboard.isDown('left') then
        self.entity.direction = 'left'
        self.entity:changeAnimation('pot-walk-left')
        
    elseif love.keyboard.isDown('right') then
        self.entity.direction = 'right'
        self.entity:changeAnimation('pot-walk-right')
        
    elseif love.keyboard.isDown('up') then
        self.entity.direction = 'up'
        self.entity:changeAnimation('pot-walk-up')
        
    elseif love.keyboard.isDown('down') then
        self.entity.direction = 'down'
        self.entity:changeAnimation('pot-walk-down')
        
    else
        self.entity:changeState('pot-idle', self.dungeon)
    end

    if love.keyboard.wasPressed('space') then
        -- table.insert(self.dungeon.currentRoom.entities, self.entity.item)
        self.entity.item:fire(self.entity.direction, self.dungeon.currentRoom.entities, dt)
        --self.entity.item = nil
        self.entity:changeState('pot-put-down', true) 
    end

    if love.keyboard.wasPressed('f') then
        if self.entity:checkSpace(self.dungeon.currentRoom.objects) then
            
            self.entity:changeState('pot-put-down')
        else
            gSounds['empty-block']:play()
        end
    end

    -- perform base collision detection against walls
    EntityWalkState.update(self, dt)
    -- if we bumped something when checking collision, check any object collisions
    
end

function PlayerPotWalkState:render()
    local anim = self.entity.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        self.entity.x - self.entity.offsetX, self.entity.y - self.entity.offsetY)

    love.graphics.draw(gTextures[self.entity.item.texture], gFrames[self.entity.item.texture][self.entity.item.states[self.entity.item.state].frame or self.entity.item.frame],
        self.entity.item.x + self.dungeon.currentRoom.adjacentOffsetX, self.entity.item.y + self.dungeon.currentRoom.adjacentOffsetY)
end 