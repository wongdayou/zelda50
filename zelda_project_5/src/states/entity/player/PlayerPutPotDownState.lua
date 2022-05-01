PlayerPutPotDownState = Class{__includes = BaseState}

function PlayerPutPotDownState:init(player, dungeon)
    self.player = player
    self.dungeon = dungeon

    self.player:changeAnimation('pot-put-down-' .. self.player.direction)
end

function PlayerPutPotDownState:enter(throwing)

    if not throwing then
        if self.player.direction == 'left' then
            Timer.tween(0.15, {
                [self.player.item] = {
                    x = self.player.x - self.player.item.width/2, 
                    y = self.player.y - self.player.item.height/4
                }
            }):finish(function()
                Timer.tween(0.15, {
                [self.player.item] = {   
                    x = self.player.x - self.player.item.width,
                    y = self.player.y + 6            
                }
            }):finish(function()
                self:collapse()
                self.player.item = nil
            end)
            end)

        elseif self.player.direction == 'right' then
            Timer.tween(0.15, {
                [self.player.item] = {
                    x = self.player.x + self.player.item.width/2,
                    y = self.player.y - self.player.item.height/4,
                }
            }):finish(function()
                Timer.tween(0.15, {
                [self.player.item] = {
                    x = self.player.x + self.player.width,
                    y = self.player.y + 6
                }
            }):finish(function()
                self:collapse()
                self.player.item = nil
            end)
            end)
        elseif self.player.direction == 'up' then
            Timer.tween(0.15, {
                [self.player.item] = {
                    y = self.player.y - self.player.item.height/2 - 6
                }
            }):finish(function()
                Timer.tween(0.15, {
                [self.player.item] = {
                    y = self.player.y - self.player.item.height}
            }):finish(function()
                self:collapse()
                self.player.item = nil
            end)
            end)
        elseif self.player.direction == 'down' then
            Timer.tween(0.15, {
                [self.player.item] = {
                    y = self.player.y}
            }):finish(function()
                Timer.tween(0.15, {
                [self.player.item] = {y = self.player.y + self.player.height}
            }):finish(function()
                self:collapse()
                self.player.item = nil
            end)
            end)
        end
        self.player.item.solid = true
        self.player.item.attached = nil
    end
    

end

function PlayerPutPotDownState:update(dt)
    
    
    -- if we've fully elapsed through one cycle of animation, change back to idle state
    if self.player.currentAnimation.timesPlayed > 0 then
        self.player.currentAnimation.timesPlayed = 0
        self.player.item = nil
        self.player:changeState('idle', self.dungeon)
    end
end

function PlayerPutPotDownState:collapse()
    for k, monster in pairs(self.dungeon.currentRoom.entities) do
        if monster:getsHit(self.player.item) then
            monster:damage(1)
            gSounds['hit-enemy']:play()
        end
    end
end


function PlayerPutPotDownState:render()
    local anim = self.player.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        self.player.x - self.player.offsetX, self.player.y - self.player.offsetY)

    if self.player.item then
        love.graphics.draw(gTextures[self.player.item.texture], gFrames[self.player.item.texture][self.player.item.states[self.player.item.state].frame or self.player.item.frame],
            self.player.item.x + self.dungeon.currentRoom.adjacentOffsetX, self.player.item.y + self.dungeon.currentRoom.adjacentOffsetY)
    end    
    
    --
    -- debug for player and hurtbox collision rects VV
    

    -- love.graphics.setColor(255, 0, 255, 255)
    -- love.graphics.rectangle('line', self.player.x, self.player.y, self.player.width, self.player.height)
    -- love.graphics.rectangle('line', self.player.itemPickbox.x, self.player.itemPickbox.y,
    --     self.player.itemPickbox.width, self.player.itemPickbox.height)
    -- love.graphics.setColor(255, 255, 255, 255)
end