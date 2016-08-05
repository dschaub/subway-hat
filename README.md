# Raspberry Pi NYC Subway Hat

I bought a Raspberry Pi 3 and a [Unicorn HAT](https://shop.pimoroni.com/products/unicorn-hat) and made a subway timer out of it.

## Installation

**Hardware:**

1. Somehow obtain a Raspberry Pi and Unicorn HAT
1. Follow Pimoroni's instructions to install the Unicorn HAT stuff. It'll disable analog audio, which otherwise messes with the lights

**Ruby:**

1. Follow the instructions to set up [rbenv](https://github.com/rbenv/rbenv) and [ruby-build](https://github.com/rbenv/ruby-build)
1. Install Ruby 2.3.1 with `rbenv install 2.3.1`. It takes a while. Also it failed the first time on some dependencies (I think openssl and another one), but after that went fine
1. Install [rbenv-sudo](https://github.com/dcarley/rbenv-sudo). Lighting up the Unicorn HAT requires root privileges, so this plugin helped a bit with that

**MTA API:**

1. Sign up for an [MTA developer account](http://web.mta.info/developers/)
1. On your Pi, `echo "export MTA_API_KEY=<api key here>" >> ~/.profile` and restart your terminal

**Finally:**

I haven't packaged this up as a legit gem with dependencies yet, so until then:

1. Get on your Pi and clone this repo somewhere
1. `sudo apt-get install -y protobuf`
1. `gem install protobuf ws2812`
1. Run it!
    1. The short version: `./on STATION_ID`
    1. The long version: `rbenv sudo MTA_API_KEY=$MTA_API_KEY ruby clock.rb --stop STOP_ID --station STATION_ID --test --rotation [ROTATION] --brightness [BRIGHTNESS]` (or see options.rb)

`STATION_ID` is the GTFS Stop ID of a station with a northbound and southbound stop. I'll add an easy reference for those at some point, but for now, you'll have to download the MTA's static schedule information. It's over at the [MTA developer site](http://web.mta.info/developers/developer-data-terms.html) -- scroll to the bottom and accept the agreement, then download the "New York City Transit Subway" ZIP file. stops.txt will have all of the Stop IDs mapped to their common names.

## Really obvious disclaimer

If you use this it's at your own peril, or more likely your Raspberry Pi's and/or Unicorn HAT's. I'm not responsible for anything that happens to you, your Raspberry Pi, your Unicorn HAT, or the log cabin you burn down with the sparks produced from shorting out your hardware by maxing out the brightness.

## Copyright

Copyright 2016 Dan Schaub. See LICENSE.txt for the full text of Creative Commons BY-NC-SA.
