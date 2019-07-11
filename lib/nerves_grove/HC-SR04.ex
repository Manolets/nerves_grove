defmodule Nerves.Grove.HC_SR04 do
  alias Pigpiox.GPIO
  use GenServer
  require Logger

  @moduledoc """
  This module is for the HC-SR04 distance sensor.

  RingLogger.attach
  {:ok, pid} = Nerves.Grove.HC_SR04.start_link(26, 13)
  Nerves.Grove.HC_SR04.read_dist(pid)
  """

  def start_link(input, output) do
    GenServer.start_link(__MODULE__, [input, output])
  end

  def read_dist(pid) do
    GenServer.cast(pid, :read_dist)
  end

  def init([input, output]) do
    GPIO.set_mode(input, :input)
    GPIO.set_mode(output, :output)
    state = %{input_pin: input, output_pin: output}
    Logger.debug("Started server, pins #{inspect(input)} #{inspect(output)} ")
    {:ok, state}
  end

  def handle_cast(:read_dist, state) do
    Logger.debug("Got here")
    GPIO.write(state.output_pin, 1)
    time_taken = count(0, state)
    GPIO.write(state.output_pin, 0)
    distance = time_taken * 340 / 2
    Logger.debug("Distance: #{distance}")

    {:noreply, state}
  end

  defp count(time, state) do
    {:ok, check} = GPIO.read(state.input_pin)

    if check == 0 || time > 100 do
      time = time + 1
      count(time, state)
    end

    time
  end
end
