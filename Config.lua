--[[
Configuration handler
@author ikubicki
]]
class 'Config'

function Config:new(app)
    self.app = app
    self:init()
    return self
end

function Config:getUrl()
    return self.url
end

function Config:getUsername()
    return self.username
end

function Config:getPassword()
    return self.password
end

function Config:getInterval()
    return tonumber(self.interval) * 1000
end

function Config:getLocationId()
    return self.locationId
end

function Config:setLocationId(locationId)
    self.locationId = locationId
    self.app:setVariable("LocationId", locationId)
end

function Config:getLastUpdateAt()
    return self.lastUpdateAt
end

function Config:setLastUpdateAt(updateAt)
    self.lastUpdateAt = updateAt
    self.app:setVariable("LastUpdateAt", updateAt)
end

--[[
This function takes variables and sets as global variables if those are not set already.
This way, adding other devices might be optional and leaves option for users, 
what they want to add into HC3 virtual devices.
]]
function Config:init()
    self.url = self.app:getVariable('URL')
    self.username = self.app:getVariable('Username')
    self.password = tostring(self.app:getVariable('Password'))
    self.locationId = self.app:getVariable('LocationId')
    self.interval = self.app:getVariable('Interval')
    if self.interval == "" or self.interval == nil then
        self.interval = 10
        self.app:setVariable('Interval', string.format('%d', self.interval))
    end
    self.lastUpdateAt = self.app:getVariable('LastUpdateAt')
end
