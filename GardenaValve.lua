class 'GardenaValve' (GardenaChildDevice)

GardenaValve.class = 'com.fibaro.sprinkler'
GardenaValve.UNAVAILABLE = 'UNAVAILABLE'
GardenaValve.CLOSED = 'CLOSED'
GardenaValve.OK = 'OK'
GardenaValve.interfaces = {
    "autoTurnOff",
    "quickAppChild",
}

function GardenaValve:__init(device)
    QuickAppChild.__init(self, device)
    self.gardenaId = string.gsub(self:getVariable("name"), "^gardena%-valve%-", "")
end

function GardenaValve:forceWatering(event)
    self:turnOn(event)
end

function GardenaValve:turnOn(event)
    local callback = function(response) end
    local fallback = function(response) end
    local command = {
        type = 'VALVE_CONTROL',
        device = self.gardenaId,
        command = 'START_SECONDS_TO_OVERRIDE',
        seconds = 7200,
    }
    self.parent.client:sendCommand(command, callback, fallback)
end

function GardenaValve:turnOff(event)
    local callback = function(response) end
    local fallback = function(response) end
    local command = {
        type = 'VALVE_CONTROL',
        device = self.gardenaId,
        command = 'STOP_UNTIL_NEXT_TASK',
    }
    self.parent.client:sendCommand(command, callback, fallback)
end
