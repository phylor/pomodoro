defmodule PomodoroTest do
  use ExUnit.Case
  doctest Pomodoro

  @debounce_delay 1100

  setup do
    {:ok, pid} = Pomodoro.start_link(name: :test)
    {:ok, pid: pid}
  end

  test "starts in reset mode", %{pid: pid} do
    assert Pomodoro.state(pid) == :reset
  end

  test "changes state from reset to working", %{pid: pid} do
    Pomodoro.button_pressed(pid)

    assert Pomodoro.state(pid) == :working
  end

  test "changes state from working to break", %{pid: pid} do
    Pomodoro.button_pressed(pid)
    Process.sleep(@debounce_delay)
    Pomodoro.button_pressed(pid)

    assert Pomodoro.state(pid) == :breaking
  end

  test "changes state from break to reset", %{pid: pid} do
    Pomodoro.button_pressed(pid)
    Process.sleep(@debounce_delay)
    Pomodoro.button_pressed(pid)
    Process.sleep(@debounce_delay)
    Pomodoro.button_pressed(pid)

    assert Pomodoro.state(pid) == :reset
  end
end
