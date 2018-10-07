defmodule Nerves.Grove.Servo_shield do
  alias Pigpiox.I2C
  require Logger
  use Bitwise

  @pca9685_address 0x40
  @mode1           0x00
  @mode2           0x01
  @sleep           0x10
  @allcall         0x01
  @outdrv          0x04
  @prescale        0xFE
  @led0_on_l       0x06
  @led0_on_h       0x07
  @led0_off_l      0x08
  @led0_off_h      0x09

  @moduledoc """
  This module controlls the PCA9685, a servo shield capable of emitting multiple pwms simultaneously,

  Try this:

  alias Nerves.Grove.Servo_shield
  handle = Servo_shield.start_shield
  Servo_shield.set_pwm_freq(handle, 50)
  Servo_shield.set_pwm(handle, 0, 0, 150)
  """

  def start_shield() do
    {:ok, handle} = I2C.open(1, @pca9685_address)
    I2C.write_byte_data(handle, @mode2, @outdrv)
    I2C.write_byte_data(handle, @mode1, @allcall)
    {:ok, mode1} = I2C.read_byte_data(handle, @mode1)
    mode1 = mode1 &&& ~~~@sleep
    I2C.write_byte_data(handle, @mode1, mode1)
    Process.sleep(10)

    handle
  end

  def set_pwm_freq(handle, freq) do
    prescaleval = ((25000000.0/4096.0)/freq) -1
    prescale = prescaleval + 0.5 |> Float.floor() |> trunc()
    {:ok, olmode} = I2C.read_byte_data(handle, @mode1)
    newmode = (olmode &&& 0x7F) ||| 0x10
    I2C.write_byte_data(handle, @mode1, newmode)
    I2C.write_byte_data(handle, @prescale, prescale)
    I2C.write_byte_data(handle, @mode1, olmode)
    Process.sleep(10)
    I2C.write_byte_data(handle, @mode1, olmode ||| 0x80)
  end

  def set_pwm(handle, channel, on, off) do
    I2C.write_byte_data(handle, @led0_on_l+4*channel, on &&& 0xFF)
    I2C.write_byte_data(handle, @led0_on_h+4*channel, on >>> 8)
    I2C.write_byte_data(handle, @led0_off_l+4*channel, off &&& 0xFF)
    I2C.write_byte_data(handle, @led0_off_h+4*channel, off >>> 8)
  end

  def test() do
    handle = start_shield()
    set_pwm_freq(handle, 50)

  end

end
