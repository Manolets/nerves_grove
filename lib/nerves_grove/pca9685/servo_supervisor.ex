defmodule Nerves.Grove.PCA9685.ServoSupervisor do
  use Supervisor
  @servo_srv Nerves.Grove.PCA9685.Servo
  @servo_registry_name :servo_server_process_registry
  @moduledoc """
  Servo GenServer Supervisor module
    Servo managed by  pca9685 Worker
   config :pca9685,
  devices: [%{bus: 1, address: 0x40, pwm_freq: 60}],
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
  """
  def start_link(map) do
    Supervisor.start_link(__MODULE__, [map], name: __MODULE__)
  end


  def account_process_servos, do: Supervisor.which_children(__MODULE__)

  def init() do
    children()
    |> supervise(options())
  end

  def init(config) do
    [
      worker(Registry, [:unique, @servo_registry_name])
      | children(config)
    ]
    |> supervise(options())
  end

  def children do
    :pca9685
    |> Application.get_env(:servos, [])
    |> Enum.map(fn %{bus: bus, address: address} = config ->
      worker(Nerves.Grove.PCA9685.Servo, [config], id: {bus, address})
    end)
  end

  def children(config) do
    config
    |> Enum.map(fn %{bus: bus, address: address} = config ->
      worker(Nerves.Grove.PCA9685.Servo, [config], id: {bus, address})
    end)
  end

  def options do
    [strategy: :one_for_one, name: __MODULE__]
  end

end
