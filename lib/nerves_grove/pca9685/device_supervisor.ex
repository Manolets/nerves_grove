defmodule Nerves.Grove.PCA9685.DeviceSupervison do
  use Supervisor

  @moduledoc """
  Device pca9685 Worker
   config :pca9685,
  devices: [%{bus: 1, address: 0x40, pwm_freq: 60}],
  servos: [%{bus: 1, address: 0x42, channel: 0, position: 90, min: 175, max: 575},
           %{bus: 1, address: 0x42, channel: 1, position: 90, min: 175, max: 575},
           %{bus: 1, address: 0x42, channel: 2, position: 90, min: 175, max: 575},
           %{bus: 1, address: 0x42, channel: 3, position: 90, min: 175, max: 575},
           %{bus: 1, address: 0x42, channel: 4, position: 90, min: 175, max: 575},
           %{bus: 1, address: 0x42, channel: 5, position: 90, min: 175, max: 575},
           %{bus: 1, address: 0x42, channel: 6, position: 90, min: 175, max: 575},
           %{bus: 1, address: 0x42, channel: 7, position: 90, min: 175, max: 575},
           %{bus: 1, address: 0x43, channel: 0, position: 90, min: 175, max: 575}]
  It accepts a list because raspberry can manage several boards
    Board 0: Address = 0x40 Offset = binary 00000 (no jumpers required)
    Board 1: Address = 0x41 Offset = binary 00001 (bridge A0 as in the photo above)
    Board 2: Address = 0x42 Offset = binary 00010 (bridge A1)
    Board 3: Address = 0x43 Offset = binary 00011 (bridge A0 & A1)
    Board 4: Address = 0x44 Offset = binary 00100 (bridge A2)
  """
  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children()
    |> supervise(options())
  end

  def init(config) do
    children(config)
    |> supervise(options())
  end

  def children do
    :pca9685
    |> Application.get_env(:devices, [])
    |> Enum.map(fn %{ bus: bus, address: address} = config ->
      worker(Nerves.Grove.PCA9685.Device, [config], id: {bus, address})
    end)
  end

  def children(config) do
    config
    |> Enum.map(fn %{bus: bus, address: address} = config ->
      worker(Nerves.Grove.PCA9685.Device, [config], id: {bus, address})
    end)
  end

  def options do
    [strategy: :one_for_one, name: __MODULE__]
  end
end
