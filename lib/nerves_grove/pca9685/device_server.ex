defmodule Nerves.Grove.PCA9685.DeviceServer do
  @moduledoc """
  Device pca9685 GenServer
  """
  use GenServer
  alias Pigpiox.I2C
  alias Nerves.Grove.PCA9685.DeviceImpl
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
  Device configuration selects a bus and a specific frecuency
  %{bus : 1, , pwm_freq: 50 }
  """
  def init(%{bus: bus} = state) do
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
         do: {:ok, handle}
  end

  defp set_pwm_freq_if_required(%{pwm_freq: hz} = state) when is_number(hz) and hz > 0,
    do: DeviceImpl.do_set_pwm_freq(state, hz)

  defp set_pwm_freq_if_required(_state), do: :ok

  @doc false
  def handle_call(:pwm_freq, _from, state) do
    hz = Map.get(state, :pwm_freq)
    {:reply, hz, state}
  end

  @doc false
  def handle_cast({:pwm_freq, hz}, %{pid: pid} = state) do
    :ok = DeviceImpl.do_set_pwm_freq(pid, hz)
    state = Map.put(state, :pwm_freq, hz)
    {:noreply, state}
  end

  @doc false
  def handle_cast({:all, on, off}, state) do
    :ok = DeviceImpl.do_set_all_pwm(state, on, off)
    {:noreply, state}
  end

  @doc false
  def handle_cast({:channel, channel_no, on, off}, state) do
    :ok = DeviceImpl.do_set_pwm(state, channel_no, on, off)
    {:noreply, state}
  end
end
