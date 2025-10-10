--[[
Gardena Smart Proxy integration
@author ikubicki
@version 1.1.2
]]

function QuickApp:onInit()
    QuickApp:trace("Gardena Smart Proxy integration, v.1.1.2")
    self.config = Config:new(self)
    self.client = Gardena:new(self.config)
    QuickApp.i18n = i18n:new(api.get("/settings/info").defaultLanguage)
    QuickApp.builder = DeviceBuilder:new(self)
    QuickApp.builder:initChildren({
        [GardenaChildDevice.class] = GardenaChildDevice,
        [GardenaSoilTemperature.class] = GardenaSoilTemperature,
        [GardenaSoilHumidity.class] = GardenaSoilHumidity,
        [GardenaValve.class] = GardenaValve,
    })
    self:updateUI()
    self:updateWebhooks()
    self:checkOrphans()
    self:run()
end

function QuickApp:updateUI()
    if self.config:getUrl() then
        local callback = function(data)
            local opts = {}
            for _, location in ipairs(data) do
                table.insert(opts, {
                    text = location.name, 
                    type = 'option',
                    value = location.id,
                })
            end
            self:updateView("selectLocation", "options", opts)
            self:updateView("selectLocation", "selectedItem", self.config:getLocationId())
        end
        local fallback = function(response)
            self:updateView("status", "text", string.format(self.i18n:get('error-locations'), response.status or 0, response.data or response or 'Unknown error'))
        end
        self.client:getLocations(callback, fallback)
    end
    self:updateView("selectLocation", "text", self.i18n:get('select-location'))
    self:updateView("button_1", "text", self.i18n:get('pull-devices'))
    self:updateView("button_2", "text", self.i18n:get('remove-location'))
    self:updateView("button_1", "visible", false)
    self:updateView("button_2", "visible", false)
    if self.config:getLocationId() ~= "" then
        self:updateView("button_1", "visible", true)
        self:updateView("button_2", "visible", true)
    end
    if self.config:getUrl() ~= "" then
        self:updateView("status", "text", string.format(self.i18n:get('used-url'), self.config:getUrl()))
    else
        self:updateView("status", "text", self.i18n:get('no-setup'))
    end
end

function QuickApp:onSelectLocation(event)
    self.config:setLocationId(event.values[1])
    self:updateUI()
end

function QuickApp:onRemoveLocation(event)
    self.config:setLocationId("")
    self:updateUI()

    for id in pairs(self.childDevices) do
        api.delete('/devices/' .. id)
    end
end

function QuickApp:onPullDevices(event)
    self:updateView("button_1", "text", self.i18n:get('pulling-devices'))
    local callback = function(data)
        self:updateView("button_1", "text", self.i18n:get('pull-devices'))
        self:updateView("status", "text", string.format(self.i18n:get('devices-count'), #data))
        for _, device in ipairs(data) do
            -- QuickApp:debug(json.encode(device))
            self:createChild(device)
        end
    end
    local fallback = function(response)
        self:updateView("button_1", "text", self.i18n:get('pull-devices'))
        self:updateView("status", "text", string.format(self.i18n:get('error-devices'), response.status or 0, response.data or response or 'Unknown error'))
    end
    self.client:getDevices(self.config:getLocationId(), callback, fallback)
end

function QuickApp:run()
    self:pullDevicesUpdates()
    if (self.config:getInterval() > 0) then
        fibaro.setTimeout(self.config:getInterval(), function() self:run() end)
    end
end

function QuickApp:updateWebhooks()
    -- remove this
    if false then
    self:updateWebhook()
    fibaro.setTimeout(10800000, function() self:updateWebhooks() end)
    end
end

function QuickApp:updateWebhook()
    if self.config:getUrl() == "" or self.config:getLocationId() == "" then
        return
    end
    local fallback = function(response)
        self:updateView("status", "text", string.format(self.i18n:get('error-webhook'), response.status or 0, response.data or response or 'Unknown error'))
    end
    local callback = function(data)
        QuickApp:debug(json.encode(data))
    end
    self.client:updateWebhook(self.config:getLocationId(), callback, fallback)
end

function QuickApp:pullDevicesUpdates()
    if self.config:getUrl() == "" or self.config:getLocationId() == "" then
        return
    end
    -- QuickApp:debug('Pulling updates')
    local fallback = function(response)
        QuickApp:error(string.format(self.i18n:get('error-updates'), response.status or 0, response.data or response or 'Unknown error'))
        self:updateView("status", "text", string.format(self.i18n:get('error-updates'), response.status or 0, response.data or response or 'Unknown error'))
    end
    local callback = function(data)
        local timestamp = 0
        if #data < 1 then
            return
        end
        for _, d in ipairs(data) do
            self:updateChild(d)
            if d.timestamp > timestamp then
                timestamp = d.timestamp
            end
        end
        self:updateView("status", "text", string.format(self.i18n:get('updates-count'), os.date("%Y-%m-%d %H:%M:%S", timestamp), #data))
        if timestamp > 0 then
            self.config:setLastUpdateAt(timestamp)
        end
    end
    self.client:getUpdates(self.config:getLastUpdateAt(), callback, fallback)
    -- self.client:getUpdates(0, callback, fallback)
end


function QuickApp:createChild(device)
    local callbacks = {
        Valve = function(d) 
            if d.state == GardenaValve.UNAVAILABLE then
                GardenaValve:delete('valve-' .. d.id)
                return
            end
            GardenaValve:create('valve-' .. d.id, d.name):update({
                value = d.value ~= GardenaValve.CLOSED,
                dead = d.state ~= GardenaValve.OK,
            })
        end,
        SoilHumidity = function(d) 
            GardenaSoilHumidity:create('humid-' .. d.id, self.i18n:get('soil-humidity')):update({
                value = d.value,
                unit = '%',
                dead = d.state ~= GardenaSoilHumidity.ONLINE,
                batteryLevel = d.battery,
            })
        end,
        SoilTemperature = function(d) 
            GardenaSoilTemperature:create('temp-' .. d.id, self.i18n:get('soil-temperature')):update({
                value = d.value,
                unit = 'C',
                dead = d.state ~= GardenaSoilTemperature.ONLINE,
                batteryLevel = d.battery,
            })
        end,
    }
    callbacks[device.type](device)
end

function QuickApp:updateChild(device)
    local callbacks = {
        Valve = function(d) 
            if d.state == GardenaValve.UNAVAILABLE then
                GardenaValve:delete('valve-' .. d.id)
                return
            end
            GardenaValve:get('valve-' .. d.id, d.name):update({
                value = d.value ~= GardenaValve.CLOSED,
                dead = d.state ~= GardenaValve.OK,
            })
        end,
        SoilHumidity = function(d) 
            GardenaSoilHumidity:get('humid-' .. d.id, self.i18n:get('soil-humidity')):update({
                value = d.value,
                unit = '%',
                dead = d.state ~= GardenaSoilHumidity.ONLINE,
                batteryLevel = d.battery,
            })
        end,
        SoilTemperature = function(d) 
            GardenaSoilTemperature:get('temp-' .. d.id, self.i18n:get('soil-temperature')):update({
                value = d.value,
                unit = 'C',
                dead = d.state ~= GardenaSoilTemperature.ONLINE,
                batteryLevel = d.battery,
            })
        end,
    }
    callbacks[device.type](device)
end

function QuickApp:checkOrphans()
    self:_checkOrphans()
    fibaro.setTimeout(86400000, function() self:checkOrphans() end)
end

function QuickApp:_checkOrphans()
    for id in pairs(self.childDevices) do
        local child = api.get('/devices/' .. id)
        local diff = os.time(os.date("*t")) - math.max(child.modified, child.created)
        if diff > 604800 then -- 7 days
            api.put('/devices/' .. id, {
                properties = {
                    dead = true
                }
            })
        end
    end
end
