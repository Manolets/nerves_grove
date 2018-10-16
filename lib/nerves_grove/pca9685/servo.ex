defmodule Nerves.Grove.PCA9685.Servo do
  alias Nerves.Grove.PCA9685.ServoSweep
  @servo_registry_name :servo_proccess_registry_name
  @server Nerves.Grove.PCA9685.ServoServer
  @moduledoc """
  Represents a positionable servo connected to an specific channel and  pin on a PCA9685 device.
    [%{bus: 1, address: 0x40, channel: 0, position: 90, min: 175, max: 575},
    %{bus: 1, address: 0x40, channel: 1, position: 90, min: 175, max: 575},
    %{bus: 1, address: 0x40, channel: 2, position: 90, min: 175, max: 575}]

  """

  @doc """
  Connect to the channel via the PCA9695 device.
  """

  def start_link(config), do: GenServer.start_link(@server, config, name: via_tuple(config))

  # registry lookup handler
  defp via_tuple(%{bus: bus, address: address, channel: channel}),
    do: {:via, Registry, {@servo_registry_name, {bus, address, channel}}}

  @doc """
  Returns the current position of the servo.
  """
  @spec position(map) :: 0..180
  def position(map), do: GenServer.call(via_tuple(map), :position)

  @doc """
  Sets the angle position of the servo.
  It accepts a map with servo tuple id and a angle value 0..180
  """
  def position(map, degrees)
      when is_integer(degrees) and degrees >= 0 and degrees <= 180,
      do: GenServer.cast(via_tuple(map), {:position, degrees})

  @doc """
  Begin the process of sweeping to a new target position over a period of time.
  See `ServoSweep` for more information.
  """
  def sweep(map, degrees, duration, step_delay)
      when is_integer(step_delay) and step_delay > 0,
      do: sweep(map, degrees, duration, step_delay)

  @doc """
  Begin the process of sweeping to a new target position over a period of time.
  See `ServoSweep` for more information.
  """
  def sweep(map, degrees, duration)
      when is_map(map) and is_integer(duration) and duration > 200 and degrees in 0..180,
      do: ServoSweep.start_link(map, degrees, duration)
end
