defmodule Pomodoro do
  use GenServer

  require Logger

  @default_name __MODULE__

  if System.get_env("REAL_TIME") do
    @work_interval 25 * 60 * 1000
    @break_interval 5 * 60 * 1000
  else
    @work_interval 5 * 1000
    @break_interval 5 * 1000
  end

  def start_link(options \\ [name: __MODULE__]) do
    Leds.start_link()
    # Music.start_link()
    GenServer.start_link(
      __MODULE__,
      %{pomodoro_status: :reset, last_click: 0, working_timer: nil, breaking_timer: nil},
      options
    )

    # Music.play_tone(2200, 1000)
  end

  def init(state) do
    {:ok, state}
  end

  def state(pid \\ @default_name) do
    GenServer.call(pid, :state)
  end

  def button_pressed(pid \\ @default_name) do
    GenServer.cast(pid, :button_pressed)
  end

  def work_interval, do: @work_interval

  def handle_call(:state, _from, state) do
    {:reply, state.pomodoro_status, state}
  end

  def handle_cast(:button_pressed, state) do
    current_click = :os.system_time(:milli_seconds)

    if state.last_click + 1000 < current_click do
      Logger.info("Button pressed")

      case state[:pomodoro_status] do
        :reset ->
          working_timer = start_working()

          {:noreply,
           %{
             state
             | pomodoro_status: :working,
               last_click: :os.system_time(:milli_seconds),
               working_timer: working_timer,
               breaking_timer: nil
           }}

        :working ->
          if state.working_timer do
            Process.cancel_timer(state.working_timer)
          end

          breaking_timer = start_breaking()

          {:noreply,
           %{
             state
             | pomodoro_status: :breaking,
               last_click: :os.system_time(:milli_seconds),
               breaking_timer: breaking_timer,
               working_timer: nil
           }}

        :breaking ->
          if state.breaking_timer do
            Process.cancel_timer(state[:breaking_timer])
          end

          start_resetting()

          {:noreply, %{state | pomodoro_status: :reset, breaking_timer: nil, working_timer: nil}}

        _ ->
          {:noreply, state}
      end
    else
      Logger.info("Button pressed, but ignored due to debouncing.")
      {:noreply, state}
    end
  end

  def handle_info(:start_break, state) do
    breaking_timer = start_breaking()

    {:noreply,
     %{state | pomodoro_status: :breaking, breaking_timer: breaking_timer, working_timer: nil}}
  end

  def handle_info(:stop_break, state) do
    start_resetting()

    {:noreply, %{state | pomodoro_status: :reset, working_timer: nil, breaking_timer: nil}}
  end

  defp start_working do
    Logger.info("Start working..")
    Leds.break_off()
    Leds.turn_on()

    Process.send_after(self(), :start_break, @work_interval)
  end

  defp start_breaking do
    Logger.info("Start breaking..")
    Leds.turn_off()
    Leds.break_on()

    Process.send_after(self(), :stop_break, @break_interval)
  end

  defp start_resetting do
    Logger.info("Start resetting..")
    Leds.turn_off()
    Leds.break_off()
    Leds.finish_cycle()
  end
end
