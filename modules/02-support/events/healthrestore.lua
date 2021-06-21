-- Auto Healing Logic
SupportModule.AutoHeal = {}
AutoHeal = SupportModule.AutoHeal

local nextHeal = {}

local settings = {
  [RestoreType.cast] = 'AutoHeal',
  [RestoreType.item] = 'AutoHealthItem'
}

function AutoHeal.onHealthChange(player, restoreType, tries)
  local tries = tries or 2

  local Panel = SupportModule.getPanel()
  if not Panel:getChildById(settings[restoreType]):isChecked() then
    return -- has since been unchecked
  end

  if restoreType == RestoreType.cast then
    local spellText = Panel:getChildById('HealSpellText'):getText()
    local healthValue = Panel:getChildById('HealthBar'):getValue()

    local delay = Helper.getSpellDelay(spellText)
    if player:getHealthPercent() < healthValue then
      Helper.castSpell(player, spellText)
    end

    nextHeal[RestoreType.cast] = scheduleEvent(function()
      if player:getHealthPercent() < healthValue and tries > 0 then
        tries = tries - 1
        AutoHeal.onHealthChange(player, restoreType, tries)
      else
        removeEvent(nextHeal[RestoreType.cast])
      end
    end, delay)

  elseif restoreType == RestoreType.item then

    local item = Panel:getChildById('CurrentHealthItem'):getItem()
    if not item then
      Panel:getChildById('AutoHealthItem'):setChecked(false)
      return
    end

    local healthValue = Panel:getChildById('ItemHealthBar'):getValue()
    local delay = Helper.getItemUseDelay()

    if player:getHealthPercent() < healthValue then
      Helper.safeUseInventoryItemWith(item:getId(), player, BotModule.isPrecisionMode())
    end

    nextHeal[RestoreType.item] = scheduleEvent(function()
      if player:getHealthPercent() < healthValue and tries > 0 then
        tries = tries - 1
        AutoHeal.onHealthChange(player, restoreType, tries)
      else
        removeEvent(nextHeal[RestoreType.item])
      end
    end, delay)
  end
end

function AutoHeal.executeCast(player, health, maxHealth, oldHealth, oldMaxHealth)
  AutoHeal.onHealthChange(player, RestoreType.cast)
end

function AutoHeal.ConnectCastListener(listener)
  if g_game.isOnline() then
    addEvent(AutoHeal.onHealthChange(g_game.getLocalPlayer(), RestoreType.cast))
  end

  connect(LocalPlayer, { onHealthChange = AutoHeal.executeCast })
end

function AutoHeal.DisconnectCastListener(listener)
  disconnect(LocalPlayer, { onHealthChange = AutoHeal.executeCast })
end

function AutoHeal.executeItem(player, health, maxHealth, oldHealth, oldMaxHealth)
  AutoHeal.onHealthChange(player, RestoreType.item)
end

function AutoHeal.ConnectItemListener(listener)
  if g_game.isOnline() then
    addEvent(AutoHeal.onHealthChange(g_game.getLocalPlayer(), RestoreType.item))
  end

  connect(LocalPlayer, { onHealthChange = AutoHeal.executeItem })
end

function AutoHeal.DisconnectItemListener(listener)
  disconnect(LocalPlayer, { onHealthChange = AutoHeal.executeItem })
end
