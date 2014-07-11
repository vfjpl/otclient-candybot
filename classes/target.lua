--[[
  @Authors: Ben Dol (BeniS)
  @Details: Target setting class that represents a 
            target logic setting.
]]

TargetSetting = newclass("TargetSetting")

TargetSetting.create = function(movement, stance, attack, range, equip, target)
  local setting = TargetSetting.internalCreate()

  setting.movement = movement or 0
  setting.stance = stance or ""
  setting.attack = attack
  setting.range = range or {100, 0}
  setting.equip = equip or {}
  setting.target = target
  setting.index = index or 0
  
  return setting
end

function TargetSetting:getMovement()
  return self.movement
end

function TargetSetting:setMovement(movement)
  local oldMovement = self.movement
  if movement ~= oldMovement then
    self.movement = movement

    signalcall(self.onMovementChange, self, movement, oldMovement)
  end
end

function TargetSetting:getStance()
  return self.stance
end

function TargetSetting:setStance(stance)
  local oldStance = self.stance
  if stance ~= oldStance then
    self.stance = stance

    signalcall(self.onStanceChange, self, stance, oldStance)
  end
end

function TargetSetting:getAttack()
  return self.attack
end

function TargetSetting:setAttack(attack)
  local oldAttack = self.attack
  if attack ~= oldAttack then
    self.attack = attack

    signalcall(self.onAttackChange, self, attack, oldAttack)
  end
end

function TargetSetting:getRange(index)
  local range = self.range
  if index and self:isIndexValid(index) then
    range = self.range[index]
  end
  return range
end

function TargetSetting:setRange(range, index)
  if not index then
    local oldRange = self.range
    if oldRange ~= range then
      self.range = range

      signalcall(self.onRangeChange, self, range, oldRange)
    end
  else
    if self:isIndexValid(index) then
      local oldRange = self.range[index]
      if oldRange ~= range then
        self.range[index] = range

        signalcall(self.onRangeChange, self, range, oldRange, index)
      end
    else
      perror("Invalid index provided: " .. index)
    end
  end
end

function TargetSetting:getEquip()
  return self.equip
end

function TargetSetting:setEquip(equip)
  local oldEquip = self.equip
  if equip ~= oldEquip then
    self.equip = equip

    signalcall(self.onEquipChange, self, equip, oldEquip)
  end
end

function TargetSetting:getTarget()
  return self.target
end

function TargetSetting:setTarget(target)
  local oldTarget = self.target
  if target ~= oldTarget then
    self.target = target
    
    signalcall(self.onTargetChange, self, target, oldTarget)
  end
end

function TargetSetting:getIndex()
  return self.index
end

function TargetSetting:setIndex(index)
  local oldIndex = self.index
  if index ~= oldIndex then
    self.index = index
    
    signalcall(self.onIndexChange, self, index, oldIndex)
  end
end

function TargetSetting:isIndexValid(index)
  return index > 0 and index < 3
end


function TargetSetting.toNode(setting)
  local node = {}
  for k,v in pairs(setting) do
    if type(v) ~= "function" then
      node[k] = v
    end
  end
  return node
end

--[[ Target Class]]

Target = newclass("Target")

Target.create = function(name, priority, settings, loot, alarm)
  local target = Target.internalCreate()
  
  target.name = name or ""
  target.priority = priority or 0
  target.settings = settings or {}
  target.loot = loot or true
  target.alarm = alarm
  
  return target
end

-- gets/sets

function Target:getName()
  return self.name
end

function Target:setName(name)
  local oldName = self.name
  if name ~= oldName then
    self.name = name

    signalcall(self.onNameChange, self, name, oldName)
  end
end

function Target:getPriority()
  return self.priority
end

function Target:setPriority(priority)
  local oldPriority = self.priority
  if priority ~= oldPriority then
    self.priority = priority

    signalcall(self.onPriorityChange, self, priority, oldPriority)
  end
end

function Target:getSetting(index)
  return self.settings[index]
end

function Target:getSettings()
  return self.settings
end

function Target:setSettings(settings)
  local oldSettings = self.settings
  if settings ~= oldSettings then
    self.settings = settings
    
    signalcall(self.onSettingsChange, self, settings, oldSettings)
  end
end

function Target:addSetting(setting)
  if not table.contains(self.settings, setting) then
    setting:setTarget(self)
    setting:setIndex(#self.settings + 1)
    table.insert(self.settings, setting)

    signalcall(self.onAddSetting, self, setting)
  end
end

function Target:getLoot()
  return self.loot
end

function Target:setLoot(loot)
  local oldLoot = self.loot
  if loot ~= oldLoot then
    self.loot = loot

    signalcall(self.onLootChange, self, loot)
  end
end

function Target:getAlarm()
  return self.alarm
end

function Target:setAlarm(alarm)
  local oldAlarm = self.alarm
  if alarm ~= oldAlarm then
    self.alarm = alarm

    signalcall(self.onAlarmChange, self, alarm)
  end
end

-- methods

function Target:toNode()
  local node = {}
  for k,v in pairs(self) do
    print(tostring(k) .. " | " .. tostring(v))
    local t = type(v)
    print(t)
    if t ~= "function" and t ~= "userdata" then
      -- check for metatables
      if t == "table" then
        for _,d in pairs(v) do
          print(type(d))
        end
      end
      node[k] = v
    end
  end
  return node
end