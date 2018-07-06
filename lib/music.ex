defmodule Music do
  use GenServer

  @output_pin 12

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def play_tone(delay, duration_millis) do
    # Pigpiox.Waveform.clear_all()

    # pulses = [
    #  %Pigpiox.Waveform.Pulse{gpio_on: @output_pin, delay: delay},
    #  %Pigpiox.Waveform.Pulse{gpio_off: @output_pin, delay: delay}
    # ]

    # Pigpiox.Waveform.add_generic(pulses)

    # {:ok, wave_id} = Pigpiox.Waveform.create()

    # Pigpiox.GPIO.set_mode(@output_pin, :output)

    # Pigpiox.Waveform.repeat(wave_id)

    # Process.send_after(self(), :stop_tone, duration_millis)
  end

  def handle_info(:stop_tone, state) do
    # Pigpiox.Waveform.stop()
    # Pigpiox.Waveform.clear_all()

    {:noreply, state}
  end
end
