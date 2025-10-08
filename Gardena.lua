--[[
Netatmo SDK
@author ikubicki
]]
class 'Gardena'

function Gardena:new(config)
    self.config = config
    self.locationId = config:getLocationId()
    self.basicAuthorization = base64:enc(self.config:getUsername() .. ':' .. self.config:getPassword())
    self.http = HTTPClient:new({
        baseUrl = self.config:getUrl()
    })
    return self
end

function Gardena:getLocations(callback, fallback)

    local buildLocation = function(data)
        return {
            id = data.id,
            name = data.attributes.name
        }
    end
    local fail = function(response)
        QuickApp:error('Unable to pull locations')
        QuickApp:debug(response.status)
        QuickApp:debug(response.data)
        if fallback ~= nil then
            fallback(response)
        end
    end
    local success = function(response)
        if response.status > 299 then
            fail(response)
            return
        end
        local data = json.decode(response.data)
        local locations = {}
        for _, l in  ipairs(data.data) do
            if l.type == "LOCATION" then
                table.insert(locations, buildLocation(l))
            end
        end
        if callback ~= nil then
            callback(locations)
        end
    end
    local headers = {
        Authorization = "Basic " .. self.basicAuthorization
    }
    self.http:get('/proxy/locations', success, fail, headers)
end

function Gardena:getDevices(locationId, callback, fallback)
    local buildValve = function(data, collection)
        local valve = {
            id = data.id,
            type = "Valve",
            name = data.attributes.name.value,
            value = data.attributes.activity.value,
            state = data.attributes.state.value,
        }
        for _, d in ipairs(collection) do
            if d.type == "COMMON" and d.id == data.relationships.device.data.id then
                valve.model = d.attributes.modelType.value
                if d.attributes.rfLinkState.value ~= "ONLINE" then
                    valve.state = d.attributes.rfLinkState.value
                end
            end
        end
        return valve
    end
    local buildHumiditySensor = function(data, collection)
        local sensor = {
            id = data.id,
            type = "SoilHumidity",
            model = nil,
            name = nil,
            value = data.attributes.soilHumidity.value,
            state = nil,
            battery = 100,
        }
        for _, d in ipairs(collection) do
            if d.type == "COMMON" and d.id == sensor.id then
                sensor.name = d.attributes.name.value
                sensor.battery = d.attributes.batteryLevel.value
                sensor.state = d.attributes.rfLinkState.value
                sensor.model = d.attributes.modelType.value
            end
        end
        return sensor
    end
    local buildTemperatureSensor = function(data, collection)
        local sensor = {
            id = data.id,
            type = "SoilTemperature",
            model = nil,
            name = nil,
            value = data.attributes.soilTemperature.value,
            state = nil,
            battery = 100,
        }
        for _, d in ipairs(collection) do
            if d.type == "COMMON" and d.id == sensor.id then
                sensor.name = d.attributes.name.value
                sensor.battery = d.attributes.batteryLevel.value
                sensor.state = d.attributes.rfLinkState.value
                sensor.model = d.attributes.modelType.value
            end
        end
        return sensor
    end
    local fail = function(response)
        QuickApp:error('Unable to pull devices')
        if fallback ~= nil then
            fallback(response)
        end
    end
    local success = function(response)
        if response.status > 299 then
            fail(response)
            return
        end
        local data = json.decode(response.data)
        local devices = {}
        for _, d in  ipairs(data.included) do
            if d.type == "VALVE" then
                table.insert(devices, buildValve(d, data.included))
            end
            if d.type == "SENSOR" then
                table.insert(devices, buildHumiditySensor(d, data.included))
                table.insert(devices, buildTemperatureSensor(d, data.included))
            end
        end
        if callback ~= nil then
            callback(devices)
        end
    end
    if locationId == "" then
        fail({
            error = "Location ID is missing",
            status = 400
        })
        return 
    end
    local headers = {
        Authorization = "Basic " .. self.basicAuthorization
    }
    self.http:get('/proxy/locations/' .. locationId, success, fail, headers)
end

function Gardena:getUpdates(lastUpdateAt, callback, fallback)
    local fail = function(response)
        QuickApp:error('Unable to pull devices')
        if fallback ~= nil then
            fallback(response)
        end
    end
    local success = function(response)
        if response.status > 299 then
            fail(response)
            return
        end
        local data = json.decode(response.data)
        local devices = {}
        for _, d in ipairs(data) do
            if d.type == "Valve" then
                table.insert(devices, {
                    id = d.id,
                    type = "Valve",
                    name = d.name,
                    value = d.activity,
                    state = d.state,
                    timestamp = d.timestamp,
                })
            end
            if d.type == "Sensor" then
                table.insert(devices, {
                    id = d.id,
                    type = "SoilHumidity",
                    value = d.humidity,
                    state = d.rfLinkState,
                    timestamp = d.timestamp,
                    battery = d.batteryLevel,
                })
                table.insert(devices, {
                    id = d.id,
                    type = "SoilTemperature",
                    value = d.temperature,
                    state = d.rfLinkState,
                    timestamp = d.timestamp,
                    battery = d.batteryLevel,
                })
            end
        end
        if callback ~= nil then
            callback(devices)
        end
    end
    local headers = {
        Authorization = "Basic " .. self.basicAuthorization
    }
    self.http:get('/devices?from=' .. lastUpdateAt, success, fail, headers)
end

function Gardena:updateWebhook(locationId, callback, fallback)
    local fail = function(response)
        QuickApp:error('Unable to update the webhook')
        if fallback ~= nil then
            fallback(response)
        end
    end
    local success = function(response)
        if response.status > 299 then
            fail(response)
            return
        end
        local data = json.decode(response.data)
        if callback ~= nil then
            callback({
                hmacSecret = data.data.attributes.hmacSecret,
                validUntil = data.data.attributes.validUntil,
            })
        end
    end
    local headers = {
        Authorization = "Basic " .. self.basicAuthorization,
        ['User-Agent'] = 'fibaro quick app',
        ['Content-Type'] = 'application/json',
    }
    local data = {
        data = {
            id = "fibaroQA",
            attributes = {
                url = self.config:getUrl() .. '/callbacks',
                locationId = locationId,
            }
        }
    }
    self.http:post('/proxy/webhook', data, success, fail, headers)
end

function Gardena:sendCommand(command, callback, fallback)
    local data = self:getCommandPayload(command)
    local headers = {
        Authorization = "Basic " .. self.basicAuthorization,
        ['User-Agent'] = 'fibaro quick app',
        ['Content-Type'] = 'application/json',
    }
    self.http:put('/proxy/command/' .. command.device, data, callback, fail, headers)
end

function Gardena:getCommandPayload(command)
    local generators = {
        VALVE_CONTROL = function(command)
            local handlers = {
                START_SECONDS_TO_OVERRIDE = function(command)
                    return {
                        id = "fibaroQaValve",
                        type = command.type,
                        attributes = {
                            command = command.command,
                            seconds = command.seconds,
                        },
                    }
                end,
                STOP_UNTIL_NEXT_TASK = function(command)
                    return {
                        id = 'fibaroQaValve',
                        type = command.type,
                        attributes = {
                            command = command.command,
                            seconds = 0,
                        }
                    }
                end,
            }
            return handlers[command.command](command)
        end,
    }
    return {
        data = generators[command.type](command)
    }
end
