defmodule Nerves.Grove.PCA9685.DeviceServer do
  @moduledoc """
  Device pca9685 GenServer
  """
  use GenServer
  alias Nerves.Grove.PCA9685.DeviceImpl
  require Logger

  @doc """
  GenServer.init/1 callback
  Device configuration selects a bus and a specific frecuency
  """
  def init(state), do: DeviceImpl.do_init(state)

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
  def handle_cast({:pwm_freq, hz}, %{handle: handle} = state) do
    :ok = DeviceImpl.do_set_pwm_freq(handle, hz)
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
