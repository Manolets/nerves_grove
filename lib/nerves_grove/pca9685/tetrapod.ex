defmodule Nerves.Grove.PCA9685.Tetrapod do
  alias Nerves.Grove.PCA9685.{ServoSupervisor, DeviceSupervisor}
  require Logger
  @devices [%{bus: 1, address: 0x40, pwm_freq: 50}]
  @servos [
    %{limb: :frb, bus: 1, address: 0x40, channel: 0, position: 90, min: 175, max: 575},
    %{limb: :frh, bus: 1, address: 0x40, channel: 1, position: 90, min: 175, max: 575},
    %{limb: :frk, bus: 1, address: 0x40, channel: 2, position: 90, min: 175, max: 575},
    %{limb: :brb, bus: 1, address: 0x40, channel: 3, position: 90, min: 175, max: 575},
    %{limb: :brh, bus: 1, address: 0x40, channel: 4, position: 90, min: 175, max: 575},
    %{limb: :brk, bus: 1, address: 0x40, channel: 5, position: 90, min: 175, max: 575},
    %{limb: :blb, bus: 1, address: 0x40, channel: 6, position: 90, min: 175, max: 575},
    %{limb: :blh, bus: 1, address: 0x40, channel: 7, position: 90, min: 175, max: 575},
    %{limb: :blk, bus: 1, address: 0x40, channel: 8, position: 90, min: 175, max: 575},
    %{limb: :flb, bus: 1, address: 0x40, channel: 9, position: 90, min: 175, max: 575},
    %{limb: :flh, bus: 1, address: 0x40, channel: 10, position: 90, min: 175, max: 575},
    %{limb: :flk, bus: 1, address: 0x40, channel: 11, position: 90, min: 175, max: 575}
  ]
  @moduledoc """
  Tetrapod utils
  RingLogger.attach()
  Nerves.Grove.PCA9685.Tetrapod.start_shield()
  Nerves.Grove.PCA9685.Servo.position(
    Nerves.Grove.PCA9685.Tetrapod.limb_id(:brknee),90
  )
  """
  def start_shield() do
    DeviceSupervisor.start_link(@devices)
    ServoSupervisor.start_link(@servos)
  end

  def limb_id(limb) do
    Logger.debug("Limb #{limb}")

    %{bus: bus, address: address, channel: channel} =
      Enum.find(@servos, fn x ->
        %{limb: y} = x

        cond do
          limb == y -> true
          true -> false
        end
      end)

    {bus, address, channel}
  end
end
