defmodule Nerves.Grove.PCA9685.DeviceImpl do
  @moduledoc """
  Device pca9685 GenServer Implementation
  """
  alias Pigpiox.I2C
  use Bitwise
  require Logger

  @pca9685_address 0x40
  @mode1 0x00
  @mode2 0x01
  @prescale 0xFE
  @led0_on_l 0x06
  @led0_on_h 0x07
  @led0_off_l 0x08
  @led0_off_h 0x09
  @all_led_on_l 0xFA
  @all_led_on_h 0xFB
  @all_led_off_l 0xFC
  @all_led_off_h 0xFD
  # Bits:
  # @restart 0x80
  @sleep 0x10
  @allcall 0x01
  # @invrt 0x10
  @outdrv 0x04

  def do_init(%{bus: bus} = state) do
    with {:ok, handle} <- I2C.open(bus, @pca9685_address),
         state <- Map.put(state, :handle, handle),
         :ok <- I2C.write_byte_data(handle, @mode2, @outdrv),
         :ok <- I2C.write_byte_data(handle, @mode1, @allcall),
         :ok <- Process.sleep(5),
         {:ok, mode1} <- I2C.read_byte_data(handle, @mode1),
         :ok <- I2C.write_byte_data(handle, @mode1, mode1 &&& ~~~@sleep),
         :ok <- Process.sleep(5),
         :ok <- set_pwm_freq_if_required(state),
         :ok <- Logger.info("Connected to PCA9685 at #{bus} whit handle value:#{handle}"),
         do: {:ok, state}
  end

  defp set_pwm_freq_if_required(%{pwm_freq: hz} = state) when is_number(hz) and hz > 0,
    do: do_set_pwm_freq(state, hz)

  defp set_pwm_freq_if_required(_state), do: :ok

  def do_set_pwm_freq(%{handle: handle}, freq) do
    prescaleval = 25_000_000.0 / 4096.0 / freq - 1
    prescale = (prescaleval + 0.5) |> Float.floor() |> trunc()
    Logger.debug("Final pre-scale: #{prescale}")

    {:ok, olmode} = I2C.read_byte_data(handle, @mode1)
    newmode = (olmode &&& 0x7F) ||| 0x10
    I2C.write_byte_data(handle, @mode1, newmode)
    I2C.write_byte_data(handle, @prescale, prescale)
    I2C.write_byte_data(handle, @mode1, olmode)
    Process.sleep(5)
    I2C.write_byte_data(handle, @mode1, olmode ||| 0x80)
  end

  def do_set_pwm(%{handle: handle}, channel, on, off) do
    with :ok <- I2C.write_byte_data(handle, @led0_on_l + 4 * channel, on &&& 0xFF),
         :ok <- I2C.write_byte_data(handle, @led0_on_h + 4 * channel, on >>> 8),
         :ok <- I2C.write_byte_data(handle, @led0_off_l + 4 * channel, off &&& 0xFF),
         :ok <- I2C.write_byte_data(handle, @led0_off_h + 4 * channel, off >>> 8),
         do: :ok
  end

  def do_set_all_pwm(%{handle: handle}, on, off) do
    with :ok <- I2C.write_byte_data(handle, @all_led_on_l, on &&& 0xFF),
         :ok <- I2C.write_byte_data(handle, @all_led_on_h, on >>> 8),
         :ok <- I2C.write_byte_data(handle, @all_led_off_l, off &&& 0xFF),
         :ok <- I2C.write_byte_data(handle, @all_led_off_h, off >>> 8),
         do: :ok
  end
end
