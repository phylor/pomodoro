defmodule Pomodoro.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  @target Mix.Project.config()[:target]

  use Application

  require Logger

  alias ElixirALE.GPIO

  @input_pin 16

  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    PomodoroTimer.start_link()

    Logger.info("Starting pin #{@input_pin} as input")
    {:ok, input_pid} = GPIO.start_link(@input_pin, :input)
    spawn(fn -> listen_forever(input_pid) end)

    # opts = [strategy: :one_for_one, name: Pomodoro.Supervisor]
    # Supervisor.start_link(children(@target), opts)
  end

  # List all child processes to be supervised
  def children("host") do
    [
      # Starts a worker by calling: Pomodoro.Worker.start_link(arg)
      # {Pomodoro.Worker, arg},
    ]
  end

  def children(_target) do
    [
      # Starts a worker by calling: Pomodoro.Worker.start_link(arg)
      # {Pomodoro.Worker, arg},
    ]
  end

  defp listen_forever(input_pid) do
    # Start listening for interrupts on rising and falling edges
    GPIO.set_int(input_pid, :both)
    listen_loop()
  end

  defp listen_loop() do
    # Infinite loop receiving interrupts from gpio
    receive do
      {:gpio_interrupt, p, :rising} ->
        Logger.debug("Received rising event on pin #{p}")

      {:gpio_interrupt, p, :falling} ->
        Logger.debug("Received falling event on pin #{p}")

        PomodoroTimer.button_pressed()
    end

    listen_loop()
  end
end
