defmodule Nerves.Grove.PCA9685.Servo do
  @moduledoc """
  Represents a positionable servo connected to an specific channel and  pin on a PCA9685 device.
    [%{bus: 1, address: 0x40, channel: 0, position: 90, min: 175, max: 575},
    %{bus: 1, address: 0x40, channel: 1, position: 90, min: 175, max: 575},
    %{bus: 1, address: 0x40, channel: 2, position: 90, min: 175, max: 575}]

  """

  @doc """
  Connect to the channel via the PCA9695 device.
  """
  @spec start_link(map) :: {:ok, pid}
  def start_link(config), do: GenServer.start_link(__MODULE__, [config])

  @doc """
  Returns the current position of the servo.
  """
  @spec position(pid) :: 0..180
  def position(pid), do: GenServer.call(pid, :position)

  @doc """
  Sets the position of the servo.
  """
  @spec position(pid, degrees :: 0..180) :: :ok
  def position(pid, degrees)
      when is_integer(degrees) and degrees >= 0 and degrees <= 180,
      do: GenServer.cast(pid, {:position, degrees})
end
