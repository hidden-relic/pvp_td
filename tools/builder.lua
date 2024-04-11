local Builder = {}

-- usage:
-- local Builder = require('utils/builder')
-- -- require the file to get the builder methods under the name Builder

-- local spawner = Builder:new({position={x=0, y=0}, tick=game.tick})
-- -- create an instance, supplying the spawn position and the tick to start counting from.

-- -- if you don't plan on immediately using the instance's addbuild method,
-- -- reset the tick before you do use it so it knows where to begin counting from:
-- spawner.last_tick = game.tick
-- -- resetting the counter

-- spawner:addbuild{tick=60, name="small-biter"}
-- -- will spawn a small biter 60 ticks from spawner.last_tick

-- -- chain together a wave:
-- for i = 1, 10 do
--     spawner:addbuild{tick=60, name="small-biter"}
-- end
-- -- this will spawn 10 small biters in a row, 60 ticks apart


function Builder:new(definition)
    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    obj.actions = {}
    obj.index = 1
    obj.position = definition.position
    obj.last_tick = definition.tick
    return obj
end

function Builder:addbuild(builddata)
    self.actions[#self.actions + 1] = builddata
end

function Builder:update(tick)
    if self.index > #self.actions then return end
    local action = self.actions[self.index]
    if tick < action.tick + self.last_tick then return end
    
    -- perform action
    self.position = action.positionfunction(self.position) or self.position
    self.index = self.index + 1
    local bug = game.surfaces["oarc"].create_entity{name=action.name, position=self.position, direction=action.direction}
    bug.set_command
    {
        type = defines.command.compound,
        structure_type = defines.compound_command.return_last, 
        commands = 
        {
            {type=defines.command.go_to_location, destination={x=self.position.x, y=self.position.y+64}, distraction=defines.distraction.none},
            {type=defines.command.go_to_location, destination={x=self.position.x+64, y=self.position.y+64}, distraction=defines.distraction.none},
            {type=defines.command.go_to_location, destination={x=self.position.x+64, y=self.position.y}, distraction=defines.distraction.none},
            {type=defines.command.go_to_location, destination={x=self.position.x, y=self.position.y}, distraction=defines.distraction.none},
            --   {type=defines.command.attack, target=game.player.character}
        }
    }
    self.last_tick = self.last_tick + action.tick
end

return Builder