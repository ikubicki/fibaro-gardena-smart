class 'GardenaValve' (GardenaChildDevice)

GardenaValve.class = 'com.fibaro.sprinkler'
GardenaValve.UNAVAILABLE = 'UNAVAILABLE'
GardenaValve.CLOSED = 'CLOSED'
GardenaValve.OK = 'OK'
GardenaValve.interfaces = {
    "autoTurnOff",
    "quickAppChild",
    "power",
}

function GardenaValve:__init(device)
    QuickAppChild.__init(self, device)
end
