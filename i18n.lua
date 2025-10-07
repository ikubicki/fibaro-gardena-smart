--[[
Internationalization tool
@author ikubicki
]]
class 'i18n'

function i18n:new(langCode)
    self.phrases = phrases[langCode]
    return self
end

function i18n:get(key)
    if self.phrases[key] then
        return self.phrases[key]
    end
    return key
end

phrases = {
    pl = {
        ['pull-devices'] = 'Pobierz urządzenia',
        ['pulling-devices'] = 'Pobieranie...',
        ['remove-location'] = 'Usuń lokalizację',
        ['select-location'] = 'Wybierze lokalizację',
        ['device-updated'] = 'Urządzenie %s zostało zaktualizowane',
        ['soil-humidity'] = 'Wilgotnosc gleby',
        ['soil-temperature'] = 'Temperatura gleby',
        ['error-locations'] = '[%d] Nie można było pobrać lokalizacji: %s',
        ['error-devices'] = '[%d] Nie można było pobrać urządzeń: %s',
        ['error-updates'] = '[%d] Nie można było pobrać aktualizacji: %s',
        ['error-webhook'] = '[%d] Nie można było zaktualizować webhooka: %s',
        ['devices-count'] = 'Wykryto %s urządzeń',
        ['updates-count'] = '%s ... Zostanie zastosowanych %d aktualizacji',
        ['no-setup'] = 'W celu uruchomienia integracji proszę o określenie zmiennych URL, Username oraz Password',
        ['used-url'] = 'Adres proxy Gardena Smart: %s',
    },
    en = {
        ['pull-devices'] = 'Fetch devices',
        ['pulling-devices'] = 'Fetching...',
        ['remove-location'] = 'Remove location',
        ['select-location'] = 'Select location',
        ['device-updated'] = 'Device %s has been updated',
        ['soil-humidity'] = 'Soil humidity',
        ['soil-temperature'] = 'Soil temperature',
        ['error-locations'] = '[%d] Failed to fetch locations: %s',
        ['error-devices'] = '[%d] Failed to fetch devices: %s',
        ['error-updates'] = '[%d] Failed to fetch updates: %s',
        ['error-webhook'] = '[%d] Failed to update webhook: %s',
        ['devices-count'] = '%s devices detected',
        ['updates-count'] = '%s ... %d updates will be applied',
        ['no-setup'] = 'To start the integration, please specify URL, Username, and Password variables',
        ['used-url'] = 'Gardena Smart proxy address: %s',
    },
    de = {
        ['pull-devices'] = 'Geräte abrufen',
        ['pulling-devices'] = 'Abrufen...',
        ['remove-location'] = 'Standort entfernen',
        ['select-location'] = 'Standort auswählen',
        ['device-updated'] = 'Gerät %s wurde aktualisiert',
        ['soil-humidity'] = 'Bodenfeuchtigkeit',
        ['soil-temperature'] = 'Bodentemperatur',
        ['error-locations'] = '[%d] Standorte konnten nicht abgerufen werden: %s',
        ['error-devices'] = '[%d] Geräte konnten nicht abgerufen werden: %s',
        ['error-updates'] = '[%d] Updates konnten nicht abgerufen werden: %s',
        ['error-webhook'] = '[%d] Webhook konnte nicht aktualisiert werden: %s',
        ['devices-count'] = '%s Geräte erkannt',
        ['updates-count'] = '%s ... %d Updates werden angewendet',
        ['no-setup'] = 'Um die Integration zu starten, bitte die Variablen URL, Benutzername und Passwort angeben',
        ['used-url'] = 'Gardena-Smart-Proxy-Adresse: %s',
    }
}
