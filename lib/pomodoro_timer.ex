defmodule PomodoroTimer do
  use GenServer

  require Logger

  def start_link do
    Leds.start_link()
    #Music.start_link()
    GenServer.start_link(__MODULE__, %{pomodoro_status: :reset, last_click: 0}, name: __MODULE__)
    #Music.play_tone(2200, 1000)
  end

  def init(state) do
    {:ok, state}
  end

  def button_pressed do
    GenServer.cast(__MODULE__, :button_pressed)
  end

  def handle_cast(:button_pressed, state) do
    Logger.info("Button pressed")
    current_click = :os.system_time(:milli_seconds)

    if state[:last_click] + 1000 < current_click do
      case state[:pomodoro_status] do
        :reset ->
          start_working()

          {:noreply, %{state | pomodoro_status: :working, last_click: :os.system_time(:milli_seconds)}}
        :working ->
          start_breaking()

          {:noreply, %{state | pomodoro_status: :breaking, last_click: :os.system_time(:milli_seconds)}}
        #:breaking ->
          #start_resetting()

          #{:noreply, %{state | pomodoro_status: :reset}}
        _ ->
          {:noreply, state}
      end
    else
      {:noreply, state}
    end
  end

  def handle_info(:start_break, state) do
    start_breaking()

    {:noreply, %{state | pomodoro_status: :breaking}}
  end

  def handle_info(:stop_break, state) do
    start_resetting()

    {:noreply, %{state | pomodoro_status: :reset}}
  end

  defp start_working do
    Leds.break_off()
    Leds.turn_on()

    Process.send_after(self(), :start_break, 5000)
  end

  defp start_breaking do
    Leds.turn_off()
    Leds.break_on()

    Process.send_after(self(), :stop_break, 5000)
  end

  defp start_resetting do
    Leds.turn_off()
    Leds.break_off()
  end
end
