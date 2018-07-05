defmodule Leds do
  use GenServer

  require Logger

  alias ElixirALE.GPIO

  def start_link do
    GenServer.start(__MODULE__, %{}, name: __MODULE__)
  end

  def init(_state) do
    work_pins = [26, 19, 13, 6, 5]
    break_pins = [0, 11, 9, 10, 22]

    create_output = fn pin ->
      {:ok, output_pid} = GPIO.start_link(pin, :output)
      output_pid
    end

    work_pids = Enum.map(work_pins, create_output)
    break_pids = Enum.map(break_pins, create_output)

    {:ok, %{work_pids: work_pids, break_pids: break_pids, light_index: 0, next_light_timer: nil}}
  end

  def turn_on do
    GenServer.cast(__MODULE__, :turn_on)
  end

  def turn_off do
    GenServer.cast(__MODULE__, :turn_off)
  end

  def break_on do
    GenServer.cast(__MODULE__, :break_on)
  end

  def break_off do
    GenServer.cast(__MODULE__, :break_off)
  end

  def light_interval do
    div(PomodoroTimer.work_interval, 5)
  end

  def handle_cast(:turn_on, state) do
    first_light = Enum.at(state[:work_pids], 0)
    Logger.info("Turning on work light 0")
    GPIO.write(first_light, 1)

    next_light_timer = Process.send_after(self(), :next_light, light_interval())

    {:noreply, %{state | light_index: 1, next_light_timer: next_light_timer}}
  end

  def handle_cast(:turn_off, state) do
    Logger.info("Turning off work lights")
    Enum.each(state[:work_pids], fn pid ->
      GPIO.write(pid, 0)
    end)

    if state[:next_light_timer] do
      Logger.info("Canceling timer")
      Process.cancel_timer(state[:next_light_timer])
    end

    {:noreply, %{state | light_index: 0, next_light_timer: nil}}
  end

  def handle_cast(:break_on, state) do
    [first_break_pid | _] = state[:break_pids]
    Logger.info("Turning on break light")
    GPIO.write(first_break_pid, 1)

    {:noreply, state}
  end

  def handle_cast(:break_off, state) do
    [first_break_pid | _] = state[:break_pids]
    Logger.info("Turning off break light")
    GPIO.write(first_break_pid, 0)

    {:noreply, state}
  end

  def handle_info(:next_light, state) do
    Logger.info("Turning on work light #{state[:light_index]}")
    GPIO.write(Enum.at(state[:work_pids], state[:light_index]), 1)

    {next_light_timer, light_index} = if state[:light_index] < 4 do
                                        {Process.send_after(self(), :next_light, light_interval()), state[:light_index] + 1}
                                      else
                                        {nil, state[:light_index]}
                                      end

    {:noreply, %{state | light_index: light_index, next_light_timer: next_light_timer}}
  end
end
