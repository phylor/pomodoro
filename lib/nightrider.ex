defmodule Nightrider do
  use GenServer

  alias ElixirALE.GPIO

  def start_link(break_pids) do
    GenServer.start(
      __MODULE__,
      %{break_pids: break_pids, nightrider_timer: nil, nightrider_step: 1, nightrider_index: 0},
      name: __MODULE__
    )
  end

  def init(state) do
    {:ok, state}
  end

  def start do
    GenServer.cast(__MODULE__, :start)
  end

  def stop do
    GenServer.cast(__MODULE__, :stop)
  end

  def handle_cast(:start, state) do
    nightrider_timer = Process.send_after(self(), :nightrider_step, 100)

    {:noreply, %{state | nightrider_index: 0, nightrider_timer: nightrider_timer}}
  end

  def handle_cast(:stop, state) do
    if state.nightrider_timer do
      Process.cancel_timer(state.nightrider_timer)
    end

    {:noreply, state}
  end

  def handle_info(:nightrider_step, state) do
    previous_pid = Enum.at(state.break_pids, state.nightrider_index - state.nightrider_step)
    current_pid = Enum.at(state.break_pids, state.nightrider_index)

    GPIO.write(previous_pid, 0)
    GPIO.write(current_pid, 1)

    nightrider_timer = Process.send_after(self(), :nightrider_step, 100)

    nightrider_step =
      cond do
        state.nightrider_index >= 4 -> -1
        state.nightrider_index <= 0 -> 1
        true -> state.nightrider_step
      end

    nightrider_index = state.nightrider_index + nightrider_step

    {:noreply,
     %{
       state
       | nightrider_index: nightrider_index,
         nightrider_step: nightrider_step,
         nightrider_timer: nightrider_timer
     }}
  end
end
