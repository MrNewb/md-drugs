local xtcpress = false

RegisterNetEvent("md-drugs:client:setpress", function(type)
  if xtcpress then
    Notify(locale("xtc.out"), 'error')
  else
    local coords, head = StartRay2()
    xtcpress = true
    progressbar('Setting Press On The Ground', 4000, 'uncuff')
    local press = CreateObject("bkr_prop_coke_press_01aa", coords.x, coords.y, coords.z, true, false, false)
    PlaceObjectOnGroundProperly(press)
    Freeze(press, true, head)
    local options = {
      {
        icon = "fas fa-eye",
        label = locale("targets.xtc.make"),
        distance = 2.0,
        action = function() TriggerEvent("md-drugs:client:XTCMenu", type) end,
        canInteract = function() if xtcpress then return true end end
      },
      {
        icon = "fas fa-eye",
        label = locale("targets.xtc.pick"),
        action = function() TriggerEvent("md-drugs:client:GetPressBack", type, press) end,
        distance = 2.0,
        canInteract = function() if xtcpress then return true end end
      },
    }
    AddMultiModel(press, options, nil)
  end
end)

lib.callback.register('md-drugs:client:setpress', function(type)
  if xtcpress then
    Notify(locale("xtc.out"), 'error')
    return false
  else
    local coords, head = StartRay2()
    xtcpress = true
    progressbar('Setting Press On The Ground', 4000, 'uncuff')
    local press = CreateObject("bkr_prop_coke_press_01aa", coords.x, coords.y, coords.z, true, false, false)
    PlaceObjectOnGroundProperly(press)
    Freeze(press, true, head)
    local options = {
      {
        icon = "fa-solid fa-tablets",
        label = locale("targets.xtc.make"),
        distance = 2.0,
        action = function() TriggerEvent("md-drugs:client:XTCMenu", type) end,
        canInteract = function() if xtcpress then return true end end
      },
      {
        icon = "fas fa-eye",
        label = locale("targets.xtc.pick"),
        action = function() TriggerEvent("md-drugs:client:GetPressBack", type, press) end,
        distance = 2.0,
        canInteract = function() if xtcpress then return true end end
      },
    }
    AddMultiModel(press, options, nil)
    return true, GetEntityCoords(press)
  end
end)

RegisterNetEvent("md-drugs:client:XTCMenu", function(type)
  local event = "md-drugs:client:MakeXTC"
  lib.registerContext({
    id = 'XTCmenu',
    title = 'XTC Menu',
    options = {
      { icon = GetImage('white_xtc'),  title = 'White XTC',  description = '1 X Raw XTC',                     event = event, args = { data = type, color = 'white' } },
      { icon = GetImage('red_xtc'),    title = 'Red XTC',    description = '1 X Raw XTC and 1 X Loose Coke',  event = event, args = { data = type, color = 'red' } },
      { icon = GetImage('orange_xtc'), title = 'Orange XTC', description = '1 X Raw XTC and 1 X Heroin Vial', event = event, args = { data = type, color = 'orange' } },
      { icon = GetImage('blue_xtc'),   title = 'Blue XTC',   description = '1 X Raw XTC and 1 X Crack Rock',  event = event, args = { data = type, color = 'blue' } },
    }
  })
  lib.showContext('XTCmenu')
end)

RegisterNetEvent("md-drugs:client:GetPressBack", function(type, press)
  if not progressbar(locale("xtc.pickup"), 5000, 'uncuff') then return end
  DeleteObject(press)
  xtcpress = false
  TriggerServerEvent("md-drugs:server:getpressback", type)
end)

RegisterNetEvent("md-drugs:client:stealisosafrole", function(data)
  if not ReturnMinigameSuccess() then
    Notify(locale("xtc.fail"), "error")
    return
  end
  if not progressbar(locale("xtc.iso"), 4000, 'uncuff') then return end
  TriggerServerEvent("md-drugs:server:stealisosafrole", data.data)
end)

RegisterNetEvent("md-drugs:client:stealmdp2p", function(data)
  if not ReturnMinigameSuccess() then
    Notify(locale("xtc.fail"), "error")
    return
  end
  if not progressbar(locale("xtc.mdp2p"), 4000, 'uncuff') then return end
  TriggerServerEvent("md-drugs:server:stealmdp2p", data.data)
end)

RegisterNetEvent("md-drugs:client:makingrawxtc", function(data)
  if not VerifyPlayerHasItem('isosafrole') then return end
  if not VerifyPlayerHasItem('mdp2p') then return end
  if not progressbar(locale("xtc.raw"), 4000, 'uncuff') then return end
  TriggerServerEvent("md-drugs:server:makingrawxtc", data.data)
end)

RegisterNetEvent("md-drugs:client:MakeXTC", function(data)
  if not VerifyPlayerHasItem('raw_xtc') then return end
  if not progressbar(locale("xtc.pressing"), 4000, 'uncuff') then return end
  TriggerServerEvent("md-drugs:server:makextc", data)
end)

RegisterNetEvent("md-drugs:client:stampwhite", function(data)
  lib.registerContext({
    id = 'stampxtc',
    title = 'Stamp XTC Menu',
    options = {
      {
        icon = GetImage('white_xtc'),
        title = 'White XTC',
        onSelect = function()
          if not ReturnMinigameSuccess() then
            Notify(locale("xtc.fail"), "error")
            return
          end
          if not progressbar(string.format(locale("xtc.stamp"), 'White'), 4000, 'uncuff') then return end
          TriggerServerEvent("md-drugs:server:stampwhite", data.data)
        end
      },
      {
        icon = GetImage('red_xtc'),
        title = 'Red XTC',
        onSelect = function()
          if not ReturnMinigameSuccess() then
            Notify(locale("xtc.fail"), "error")
            return
          end
          if not progressbar(string.format(locale("xtc.stamp"), 'Red'), 4000, 'uncuff') then return end
          TriggerServerEvent("md-drugs:server:stampred", data.data)
        end
      },
      {
        icon = GetImage('orange_xtc'),
        title = 'Orange XTC',
        onSelect = function()
          if not ReturnMinigameSuccess() then
            Notify(locale("xtc.fail"), "error")
            return
          end
          if not progressbar(string.format(locale("xtc.stamp"), 'Orange'), 4000, 'uncuff') then return end
          TriggerServerEvent("md-drugs:server:stamporange", data.data)
        end,
      },
      {
        icon = GetImage('blue_xtc'),
        title = 'Blue XTC',
        onSelect = function()
          if not ReturnMinigameSuccess() then
            Notify(locale("xtc.fail"), "error")
            return
          end
          if not progressbar(string.format(locale("xtc.stamp"), 'Blue'), 4000, 'uncuff') then return end
          TriggerServerEvent("md-drugs:server:stampblue", data.data)
        end
      },
    }
  })
  lib.showContext('stampxtc')
end)

RegisterNetEvent("md-drugs:client:getsinglepress", function()
  if not progressbar(locale("xtc.buyp"), 4000, 'uncuff') then return end
  TriggerServerEvent("md-drugs:server:buypress")
end)


RegisterNetEvent("md-drugs:client:exchangepresses", function(data)
  if not progressbar(locale("xtc.buyp"), 4000, 'uncuff') then return end
  TriggerServerEvent("md-drugs:server:upgradepress", data.data)
end)

RegisterNetEvent("md-drugs:client:buypress", function()
  local img = GetImage('singlepress')
  lib.registerContext({
    id = 'buypresses',
    title = 'Purchase Presses',
    options = {
      { title = locale("xtc.press.title.single"),  description = locale("xtc.press.des.single"),  icon = img, event = 'md-drugs:client:getsinglepress' },
      { title = locale("xtc.press.title.dual"),    description = locale("xtc.press.des.dual"),    icon = img, event = 'md-drugs:client:exchangepresses', args = { data = 'dual' } },
      { title = locale("xtc.press.title.triple"),  description = locale("xtc.press.des.triple"),  icon = img, event = 'md-drugs:client:exchangepresses', args = { data = 'triple' } },
      { title = locale("xtc.press.title.quad"),    description = locale("xtc.press.des.quad"),    icon = img, event = 'md-drugs:client:exchangepresses', args = { data = 'quad' } }
    }
  })
  lib.showContext('buypresses')
end)
