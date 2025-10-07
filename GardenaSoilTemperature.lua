class 'GardenaSoilTemperature' (GardenaChildDevice)

GardenaSoilTemperature.class = 'com.fibaro.temperatureSensor'
GardenaSoilTemperature.ONLINE = 'ONLINE'
GardenaSoilTemperature.interfaces = {
    "quickAppChild", 
    "battery",
}

function GardenaSoilTemperature:__init(device)
    QuickAppChild.__init(self, device)
end
