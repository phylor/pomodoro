# Pomodoro

A hardware pomodoro timer featuring 10 LEDs and a button. It is connected to a Raspberry Pi. The code is written in Elixir using [Nerves](http://www.nerves-project.org). The LED blinking is inspired by [a project by David Strauß](https://www.stravid.com/en/harte-tomate-a-hardware-pomodoro-timer-reporting-to-a-backend-for-storing-past-pomodori/).

![Permaproto](docs/permaproto.png)

## Getting Started

- Set necessary environment variables:

    ```
    export MIX_TARGET=rpi3
    export NERVES_NETWORK_SSID=MyWifiSSID
    export NERVES_NETWORK_PSK=MySecretPassword
    ```

- Install dependencies: `mix deps.get`
- Create firmware: `mix firmware`
- Burn firmware to SD card: `mix firmware.burn`
- Or push firmware via SSH: `mix firmware.push my_ip_address`. Find the Raspberry Pi's IP address by running in iex: `SystemRegistry.match(:_) |> get_in([:state, :network_interface])`
- To see logging messages in iex: `RingLogger.attach`. To disable them: `RingLogger.detach`.
