class 'GardenaSoilHumidity' (GardenaChildDevice)

GardenaSoilHumidity.class = 'com.fibaro.humiditySensor'
GardenaSoilHumidity.ONLINE = 'ONLINE'
GardenaSoilHumidity.interfaces = {
    "quickAppChild", 
    "battery",
}

function GardenaSoilHumidity:__init(device)
    QuickAppChild.__init(self, device)
end
