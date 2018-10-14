defmodule Nerves.Grove.PCA9685.DeviceSupervisor do
  use Supervisor
  @dev_srv Nerves.Grove.PCA9685.Device
  @device_registry_name :PCA9685_proccess_registry
  @moduledoc """
  Device pca9685 Worker
  config :pca9685,
  devices: [%{bus: 1, address: 0x40, pwm_freq: 50}],
  servos: [%{bus: 1, address: 0x40, channel: 0, position: 90, min: 175, max: 575},
           %{bus: 1, address: 0x40, channel: 1, position: 90, min: 175, max: 575},
           %{bus: 1, address: 0x40, channel: 2, position: 90, min: 175, max: 575},
           %{bus: 1, address: 0x40, channel: 3, position: 90, min: 175, max: 575},
           %{bus: 1, address: 0x40, channel: 4, position: 90, min: 175, max: 575},
           %{bus: 1, address: 0x40, channel: 5, position: 90, min: 175, max: 575},
           %{bus: 1, address: 0x40, channel: 6, position: 90, min: 175, max: 575},
           %{bus: 1, address: 0x40, channel: 7, position: 90, min: 175, max: 575},
           %{bus: 1, address: 0x43, channel: 8, position: 90, min: 175, max: 575},
           %{bus: 1, address: 0x43, channel: 9, position: 90, min: 175, max: 575},
           %{bus: 1, address: 0x43, channel: 10, position: 90, min: 175, max: 575},
           %{bus: 1, address: 0x43, channel: 11, position: 90, min: 175, max: 575},
          ]
  It accepts a list because raspberry can manage several boards
    Board 0: Address = 0x40 Offset = binary 00000 (no jumpers required)
    Board 1: Address = 0x41 Offset = binary 00001 (bridge A0 as in the photo above)
    Board 2: Address = 0x42 Offset = binary 00010 (bridge A1)
    Board 3: Address = 0x43 Offset = binary 00011 (bridge A0 & A1)
    Board 4: Address = 0x44 Offset = binary 00100 (bridge A2)

    Nerves.Grove.PCA9685.DeviceSupervisor.start_link (%{bus: 1, address: 0x40, pwm_freq: 60})
  """
  def start_link(config) when is_list(config) do
    Supervisor.start_link(__MODULE__, config, name: __MODULE__)
  end

  def init(config) when is_list(config) do
    [
      # worker(Registry, [:unique, @device_registry_name])
      {Registry, keys: :unique, name: @device_registry_name}
      | children(config)
    ]
    # supervise(options())
    |> Supervisor.init(options())
  end

  def children(config) do
    config
    |> Enum.map(fn %{bus: bus, address: address} = config ->
      worker(Nerves.Grove.PCA9685.Device, [config], id: {bus, address})
    end)
  end

  def start_link(), do: Supervisor.start_link(__MODULE__, [], name: __MODULE__)

  def init() do
    [
      # worker(Registry, [:unique, @device_registry_name])
      {Registry, keys: :unique, name: @device_registry_name}
      | children()
    ]
    # supervise(options())
    |> Supervisor.init(options())
  end

  def children do
    :pca9685
    |> Application.get_env(:devices, [])
    |> Enum.map(fn %{bus: bus, address: address} = config ->
      worker(Nerves.Grove.PCA9685.Device, [config], id: {bus, address})
    end)
  end

  def start_device(%{bus: bus, address: address} = map) do
    # And we use `start_child/2` to start a new Chat.Server process
    with {:ok, _pid} <-
           Supervisor.start_child(__MODULE__, worker(@dev_srv, [map], id: {bus, address})) do
      {:ok, {bus, address}}
    else
      {:error, error} -> {:error, error}
    end
  end

  def account_process_devices, do: Supervisor.which_children(__MODULE__)

  defp options do
    [strategy: :one_for_one, name: __MODULE__]
  end
end
