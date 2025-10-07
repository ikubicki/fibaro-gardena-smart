class 'GardenaChildDevice' (QuickAppChild)

GardenaChildDevice.class = 'com.fibaro.multilevelSensor'

function GardenaChildDevice:__init(device)
    self.device = false
    QuickAppChild.__init(self, device)
end

function GardenaChildDevice:create(name, label, class)
    if not class then
        class = self.class
    end
    local id = 'gardena-' .. name
    local options = {
        manufacturer = 'Gardena',
        model = 'GARDENA smart device'
    }
    if label == nil then
        label = id
    end
    self.device = QuickApp.builder:createChild(id, label, class, options, self.interfaces)
    return self
end

function GardenaChildDevice:get(name, label, class)
    if not class then
        class = self.class
    end
    local id = 'gardena-' .. name
    local options = {
        manufacturer = 'Gardena',
        model = 'GARDENA smart device'
    }
    if label == nil then
        label = id
    end
    self.device = QuickApp.builder:updateChild(id, label, class, options, self.interfaces)
    return self
end

function GardenaChildDevice:delete(name)
    QuickApp.builder:deleteChild('gardena-' .. name)
end

function GardenaChildDevice:update(properties)
    
    if self.device == nil or not self.device then
        return false
    end
    if type(properties) ~= 'table' then
        properties = {
            value = properties
        }
    end
    for name, value in pairs(properties) do
        self.device:updateProperty(name, value)
    end
    --  QuickApp:trace(string.format(QuickApp.i18n:get('device-updated'), self.device.name))
    return true
end
