defmodule Nerves.Grove.PCA9685.DeviceServer do
  @moduledoc """
  Device pca9685 GenServer
  """
  use GenServer
  alias Nerves.Grove.PCA9685.DeviceImpl

  @doc """
  GenServer.init/1 callback
  Device configuration selects a bus and a specific frecuency

  """
  def init(config), do: DeviceImpl.do_init(config)

  @doc false
  def terminate(reason, state) do
    DeviceImpl.do_terminate(state)
    {:stop, reason}
  end

  @doc false
  def handle_call(:pwm_freq, _from, state) do
    hz = Map.get(state, :pwm_freq)
    {:reply, hz, state}
  end

  @doc false
  def handle_cast({:pwm_freq, hz}, state) do
    :ok = DeviceImpl.do_set_pwm_freq(hz, state)
    {:noreply, state}
  end

  @doc false
  def handle_cast({:all, on, off}, state) do
    :ok = DeviceImpl.do_set_all_pwm(on, off, state)
    {:noreply, state}
  end

  @doc false
  def handle_cast({:channel, channel_no, on, off}, state) do
    :ok = DeviceImpl.do_set_pwm(channel_no, on, off, state)
    {:noreply, state}
  end
end
