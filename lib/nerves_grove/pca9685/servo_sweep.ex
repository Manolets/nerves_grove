defmodule Nerves.Grove.PCA9685.ServoSweep do
  alias Nerves.Grove.PCA9685.Servo
  require Logger
  use GenServer

  @moduledoc """
  Sweeps a servo through a rotation over a specified period of time.
  alias Nerves.Grove.PCA9685.{ServoSupervisor,Servo,DeviceSupervisor,Device}
  Nerves.Grove.PCA9685.Tetrapod.start_shield()
  RingLogger.attach()
  Servo.tsweep(%{bus: 1, address: 0x40, channel: 0},90,1000,100)
  Servo.nsweep(%{bus: 1, address: 0x40, channel: 0},90,10,100)
  """

  # mS
  # @default_step_delay 1000

  @doc """
  Spawns a process which will rotate a servo.
  The sweep starts immediately.
  """
  def start_link(servo_via, target_position, total_steps, step_delay),
    do: GenServer.start_link(__MODULE__, [servo_via, target_position, total_steps, step_delay])

  @doc """
  Wait until the servo sweep has been completed or cancelled.
  """
  @spec await(pid) :: :ok | :cancelled
  def await(pid), do: GenServer.call(pid, :await)

  @doc """
  Cancel the servo sweep.
  """
  @spec cancel(pid) :: :ok
  def cancel(pid), do: GenServer.cast(pid, :cancel)

  ########################################################
  # CALLBACKS
  ########################################################

  @doc false
  def init([servo_via, target_position, total_steps, step_delay]) do
    current_position = Servo.position(servo_via)

    if current_position == target_position do
      {:stop, :normal}
    else
      servo_pid =
        with %{bus: bus, address: address, channel: channel} <- servo_via,
             [{servo_pid, _}] <-
               Registry.lookup(:servo_proccess_registry_name, {bus, address, channel}),
             true <- Process.link(servo_pid),
             do: servo_pid

      Logger.debug("servo_pid:#{inspect(servo_pid)}")

      state = %{
        servo_via: servo_via,
        servo_pid: servo_pid,
        current: current_position,
        target: target_position,
        delay: step_delay,
        step: (target_position - current_position) / total_steps,
        left: total_steps,
        waiting: []
      }

      Logger.debug("state: #{inspect(state)})")
      queue_next_step(step_delay)
      {:ok, state}
    end
  end

  @doc false
  def handle_call(:await, from, state) do
    waiting = Map.get(state, :waiting)
    waiting = [from | waiting]
    state = Map.put(state, :waiting, waiting)
    {:noreply, state}
  end

  @doc false
  def handle_cast(:cancel, %{waiting: w} = state) do
    Enum.each(w, &GenServer.reply(&1, :cancelled))
    {:stop, :normal, state}
  end

  @doc false
  def handle_info(:step, %{servo_via: p, target: t, left: 1, waiting: w} = state) do
    Servo.position(p, round(t))
    Logger.debug("Servo.position(#{inspect(p)}, round(#{t}))")
    Enum.each(w, &GenServer.reply(&1, :ok))
    {:stop, :normal, state}
  end

  @doc false
  def handle_info(:step, %{servo_via: p, current: c, delay: d, step: s, left: l} = state) do
    next = c + s
    Servo.position(p, round(next))
    Logger.debug("Servo.position(#{inspect(p)}, round(#{next})")
    state = %{state | current: next, left: l - 1}
    queue_next_step(d)
    {:noreply, state}
  end

  defp queue_next_step(step_delay) do
    Logger.debug("Process.send_after(#{inspect(self())}, :step, #{step_delay})")
    Process.send_after(self(), :step, step_delay)
  end
end
