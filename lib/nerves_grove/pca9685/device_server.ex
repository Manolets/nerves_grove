defmodule Nerves.Grove.PCA9685.DeviceServer do
  use GenServer
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
  # Bits:
  # @restart 0x80
  @sleep 0x10
  @allcall 0x01
  # @invrt 0x10
  @outdrv 0x04

  @doc """
  GenServer.init/1 callback
  """
  def init(handle) do
    with {:ok, handle} <- I2C.open(1, @pca9685_address),
         :ok <- I2C.write_byte_data(handle, @mode2, @outdrv),
         :ok <- I2C.write_byte_data(handle, @mode1, @allcall),
         :ok <- Process.sleep(5),
         {:ok, mode1} <- I2C.read_byte_data(handle, @mode1),
         :ok <- I2C.write_byte_data(handle, @mode1, mode1 &&& ~~~@sleep),
         :ok <- Process.sleep(5),
         do: {:ok, handle}
  end
end
