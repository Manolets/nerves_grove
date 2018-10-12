defmodule Nerves.Grove.PCA9685.ServoServer do
  use GenServer
  alias Nerves.Grove.PCA9685.{ServoImpl}

  @moduledoc """
  GenServer that implements a positionable servo connected to an specific channel and  pin on a PCA9685 device.
  [%{bus: 1, address: 0x40, channel: 0, position: 90, min: 175, max: 575},
    %{bus: 1, address: 0x40, channel: 1, position: 90, min: 175, max: 575},
    %{bus: 1, address: 0x40, channel: 2, position: 90, min: 175, max: 575}]
  """
  @doc false
  def init([config]), do: ServoImpl.do_init([config])

  @doc false
  def handle_call(:position, _from, %{position: position} = state) do
    {:reply, position, state}
  end

  @doc false
  def handle_cast({:position, degrees}, state) do
    state = ServoImpl.set_position(degrees, state)
    {:noreply, state}
  end
end
