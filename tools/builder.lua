local Builder = {}

if not global.paths then global.paths = {} end

function Builder.new(definition)
  obj.actions = {}
  obj.index = 1
  obj.position = definition.position
  obj.last_tick = definition.tick
  return obj
end

function Builder.addbuild(builddata)
  self.actions[#self.actions + 1] = builddata
end

function Builder.update(tick)
  if self.index > #self.actions then return end
  action = self.actions[self.index]
  if tick < action.tick + self.last_tick then return end

  -- perform action
  self.position = action.positionfunction(self.position)
  self.index = self.index + 1
  game.surfaces["oarc"].create_entity{name=action.name, position=self.position, direction=action.direction}
  self.last_tick = self.last_tick + action.tick
end

return Builder
