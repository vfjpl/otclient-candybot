-- Auto Mana Item Logic
SupportModule.AutoMana = {}
AutoMana = SupportModule.AutoMana

local nextMana = nil

local settings = {
  [RestoreType.cast] = 'AutoMana', -- not implemented
  [RestoreType.item] = 'AutoManaItem'
}

function AutoMana.onManaChange(player, restoreType, tries)
  local tries = tries or 2

  local Panel = SupportModule.getPanel()
  if not Panel:getChildById(settings[restoreType]):isChecked() then
    return -- has since been unchecked
  end

  if restoreType == RestoreType.item then
    local item = Panel:getChildById('CurrentManaItem'):getItem()
    if not item then
      Panel:getChildById('AutoManaItem'):setChecked(false)
      return
    end

    local manaValue = Panel:getChildById('ItemManaBar'):getValue()
    local delay = Helper.getItemUseDelay()

    if player:getManaPercent() < manaValue then
      Helper.safeUseInventoryItemWith(item:getId(), player, BotModule.isPrecisionMode())
    end

    nextMana = scheduleEvent(function()
      if player:getManaPercent() < manaValue and tries > 0 then
        tries = tries - 1
        AutoMana.onManaChange(player, restoreType, tries)
      else
        removeEvent(nextMana)
      end
    end, delay)
  end
end

function AutoMana.executeItem(player, mana, maxMana, oldMana, oldMaxMana)
  AutoMana.onManaChange(player, RestoreType.item)
end

function AutoMana.ConnectItemListener(listener)
  if g_game.isOnline() then
    addEvent(AutoMana.onManaChange(g_game.getLocalPlayer(), RestoreType.item))
  end

  connect(LocalPlayer, { onManaChange = AutoMana.executeItem })
end

function AutoMana.DisconnectItemListener(listener)
  disconnect(LocalPlayer, { onManaChange = AutoMana.executeItem })
end
