# Gardena Smart Proxy integration

Gardena Smart sprinklers integration application

This quick application creates virtual devices for sprinklers and soil sensors.

Data updates every 10 seconds by default.

This quick application works only with Gardena Smart Proxy web application.

## Configuration

`URL` - URL to the proxy web service

`Username` - Proxy auth username

`Password` - Proxy auth password

### Optional values

`Interval` - number of seconds defining how often data should be refreshed. This value will be automatically populated on initialization of quick application.

`LocationId` - An ID of the Gardena Irrigation Control unit

## Installation

You need to setup [a proxy application](https://github.com/ikubicki/gardena-smart-proxy) first.

Once that's done, you will be able to provide values for URL, Username and Password variables.

This should allow you to run quick application in your Fibaro Home Center device.

## Support

Due to horrible user experience with Fibaro Marketplace, for better communication I recommend to contact with me through GitHub or create an issue in the repository.

## Changelog

 * v.1.1.1
   * Error handling improvements

 * v.1.1.0
   * Valve controls
