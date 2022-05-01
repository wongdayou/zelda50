

PlayerPickPotState = Class{__includes = BaseState}

function PlayerPickPotState:init(player, dungeon)
    self.player = player
    self.dungeon = dungeon
    
    self.player:changeAnimation('pot-pick-' .. self.player.direction)

end

function PlayerPickPotState:enter(params)
    if self.player.direction == 'left' then
        -- self.player.item.x = self.player.x - self.player.item.width/2
        -- self.player.item.y = self.player.y + 2
        Timer.tween(0.15, {
            [self.player.item] = {
                x = self.player.x - self.player.item.width/2,
                y = self.player.y - self.player.item.height/4}
        }):finish(function()
            Timer.tween(0.15, {
            [self.player.item] = {
                x = self.player.x,
                y = self.player.y - self.player.item.height/2
            }
        }):finish(function()
            self.player.item.attached = self.player
        end)
        end)
    elseif self.player.direction == 'right' then
        -- self.player.item.x = self.player.x + self.player.width - self.player.item.width/2
        -- self.player.item.y = self.player.y + 2
        Timer.tween(0.15, {
            [self.player.item] = {
                x = self.player.x + self.player.width - self.player.item.width/2,
                y = self.player.y - self.player.item.height/4}
        }):finish(function()
            Timer.tween(0.15, {
            [self.player.item] = {
                x = self.player.x,
                y = self.player.y - self.player.item.height/2
            }
        }):finish(function()
            self.player.item.attached = self.player
        end)
        end)
    elseif self.player.direction == 'up' then
        -- self.player.item.x = self.player.x 
        -- self.player.item.y = self.player.y - self.player.item.height/2
        Timer.tween(0.15, {
            [self.player.item] = {
                x = self.player.x,
                y = self.player.y - self.player.item.height/2 - 6
            }
        }):finish(function()
            Timer.tween(0.15, {
            [self.player.item] = {y = self.player.y - self.player.item.height/2}
        }):finish(function()
            self.player.item.attached = self.player
        end)
        end)
    elseif self.player.direction == 'down' then
        -- self.player.item.x = self.player.x 
        -- self.player.item.y = self.player.y + self.player.height
        Timer.tween(0.15, {
            [self.player.item] = {
                x = self.player.x,
                y = self.player.y
            }
        }):finish(function()
            Timer.tween(0.15, {
            [self.player.item] = {y = self.player.y - self.player.item.height/2}
        }):finish(function()
            self.player.item.attached = self.player
        end)
        end)
    end
    
end

function PlayerPickPotState:update(dt)
    
    -- if we've fully elapsed through one cycle of animation, change back to idle state
    if self.player.currentAnimation.timesPlayed > 0 then
        self.player.currentAnimation.timesPlayed = 0
        self.player:changeState('pot-idle', self.dungeon)
    end

end

function PlayerPickPotState:render()
    local anim = self.player.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        self.player.x - self.player.offsetX, self.player.y - self.player.offsetY)

    
    love.graphics.draw(gTextures[self.player.item.texture], gFrames[self.player.item.texture][self.player.item.states[self.player.item.state].frame or self.player.item.frame],
        self.player.item.x + self.dungeon.currentRoom.adjacentOffsetX, self.player.item.y + self.dungeon.currentRoom.adjacentOffsetY)    
    
    --
    -- debug for player and hurtbox collision rects VV
    

    -- love.graphics.setColor(255, 0, 255, 255)
    -- love.graphics.rectangle('line', self.player.x, self.player.y, self.player.width, self.player.height)
    -- love.graphics.rectangle('line', self.player.itemPickbox.x, self.player.itemPickbox.y,
    --     self.player.itemPickbox.width, self.player.itemPickbox.height)
    -- love.graphics.setColor(255, 255, 255, 255)
end