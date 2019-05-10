defmodule Nerves.Grove.PCA9685.Device do
  #alias Pigpiox.I2C
  use Bitwise
  require Logger
  @type pulse :: 0..4096
  @type channel :: 0..15
  @server Nerves.Grove.PCA9685.DeviceServer
  @device_registry_name :PCA9685_proccess_registry
  #@pca9685_address 0x40
  #@mode1 0x00
  #@mode2 0x01
  #@prescale 0xFE
  #@led0_on_l 0x06
  #@led0_on_h 0x07
  #@led0_off_l 0x08
  #@led0_off_h 0x09
  # Bits:
  # @restart 0x80
  #@sleep 0x10
  #@allcall 0x01
  # @invrt 0x10
  #@outdrv 0x04
  @moduledoc """
  This module controlls the PCA9685, a servo shield capable of emitting multiple pwms simultaneously,

  Try this:

  alias Nerves.Grove.PCA9685.Device
  handle = Device.start_shield
  Device.set_servo(handle, 0, 90)
  """
  @doc """
  Connects to a PCA9685 device over the i2c bus using Pigpiox.
  http://wiki.sunfounder.cc/index.php?title=PCA9685_16_Channel_12_Bit_PWM_Servo_Driver
  It accepts a map indicating bus number and an integer setting frecuency
    [%{bus : 1, address: 0x40, pwm_freq: 60}]
  It accepts a list because raspberry can manage several boards
  Board 0: Address = 0x40 Offset = binary 00000 (no jumpers required)
  Board 1: Address = 0x41 Offset = binary 00001 (bridge A0 as in the photo above)
  Board 2: Address = 0x42 Offset = binary 00010 (bridge A1)
  Board 3: Address = 0x43 Offset = binary 00011 (bridge A0 & A1)
  Board 4: Address = 0x44 Offset = binary 00100 (bridge A2)
  """

  def start_link(config), do: GenServer.start_link(@server, config, name: via_tuple(config))

  # registry lookup handler
  defp via_tuple(%{bus: bus, address: address}),
    do: {:via, Registry, {@device_registry_name, {bus, address}}}

  @doc """
  Disconnect PCA9685 device over the i2c bus using Pigpiox.
  """
  def stop(map), do: GenServer.stop(:normal, map)

  @doc """
  Returns the currently configured PWM frequency.
  """
  def pwm_freq(map),
    do: GenServer.call(via_tuple(map), :pwm_freq)

  @doc """
  Configures the PWM Pulse-width modulation frequency.
  F(hz)=1/T(s) 50hz=20ms
  """
  def pwm_freq(map, hz)
      when is_integer(hz),
      do: GenServer.cast(via_tuple(map), {:pwm_freq, hz})

  @doc """
  Sets all channels to the specified duty cycle.
  """

  def all(map, on, off)
      when on in 0..4096 and off in 0..4096,
      do: GenServer.cast(via_tuple(map), {:all, on, off})

  @doc """
  Sets the channel to a specified duty cycle.
  """
  def channel(map, channel, on, off)
      when is_integer(channel)
      when on in 0..4096 and off in 0..4096 and channel in 0..15,
      do: GenServer.cast(via_tuple(map), {:channel, channel, on, off})
end
