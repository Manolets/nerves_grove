defmodule Nerves.Grove.PCA9685.ServoImpl do
  @default_min 150
  @default_max 600
  alias Nerves.Grove.PCA9685.Device

  @moduledoc """
  GenServer that implements a positionable servo connected to an specific channel and  pin on a PCA9685 device.
  [%{bus: 1, address: 0x40, channel: 0, position: 90, min: 175, max: 575},
    %{bus: 1, address: 0x40, channel: 1, position: 90, min: 175, max: 575},
    %{bus: 1, address: 0x40, channel: 2, position: 90, min: 175, max: 575}]
  """
  def do_init(%{bus: bus, address: address, channel: channel} = state)
      when bus in 0..2 and is_integer(address) and is_integer(channel) and channel in 0..15 do
    min = Map.get(state, :min, @default_min)
    max = Map.get(state, :max, @default_max)

    state =
      state
      |> Map.put(:min, min)
      |> Map.put(:max, max)

    state = set_initial_position(state)

    {:ok, state}
  end

  def set_position(position, %{channel: channel} = state) do
    pwm = scale(state, position)
    :ok = Device.channel(state, channel, 0, pwm)
    Map.put(state, :position, position)
  end

  defp set_initial_position(%{position: position} = state) do
    set_position(position, state)
  end

  defp set_initial_position(state), do: state

  defp scale(%{min: min, max: max}, degrees)
       when is_integer(degrees) and degrees >= 0 and degrees <= 180 do
    range = max - min
    (degrees / 180 * range) + min |> round
  end
end
