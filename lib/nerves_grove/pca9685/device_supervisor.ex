defmodule Nerves.Grove.PCA9685.DeviceSupervison do
  use Supervisor

  @moduledoc """
  Device pca9685 Worker
  [%{board: "PCA9685",bus : 1, address: 0x40, pwm_freq: 60}]
  """
  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init(config) do
    children(config)
    |> supervise(options())
  end

  def children(config) do
    config
    |> Enum.map(fn %{board: board, bus: bus, address: address} = config ->
      worker(Nerves.Grove.PCA9685.Device, [config], id: {board, bus, address})
    end)
  end

  def options do
    [strategy: :one_for_one, name: __MODULE__]
  end
end
