defmodule Nerves.Grove.PCA9685.ServoSweep do
  alias Nerves.Grove.PCA9685.Servo
  use GenServer

  @moduledoc """
  Sweeps a servo through a rotation over a specified period of time.
  """

  # mS
  @default_step_delay 10

  @doc """
  Spawns a process which will rotate a servo.
  The sweep starts immediately.
  """
  @spec start_link(map, 0..180, pos_integer) :: {:ok, pid} | {:error, :normal}
  def start_link(servo_pid, target_position, duration, step_delay \\ @default_step_delay) do
    GenServer.start_link(__MODULE__, [servo_pid, target_position, duration, step_delay])
  end

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
  def init([servo_pid, target_position, duration, step_delay]) do
    current_position = Servo.position(servo_pid)

    if current_position == target_position do
      {:stop, :normal}
    else
      [{s_pid, nil}] = Registry.lookup(:servo_proccess_registry_name, servo_pid)
      Process.link(s_pid)
      total_steps = round(duration / step_delay)

      state = %{
        servo_pid: servo_pid,
        current: current_position,
        target: target_position,
        delay: step_delay,
        step: (target_position - current_position) / total_steps,
        left: total_steps,
        waiting: []
      }

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
  def handle_info(:step, %{servo_pid: p, target: t, left: 1, waiting: w} = state) do
    Servo.position(p, round(t))
    Enum.each(w, &GenServer.reply(&1, :ok))
    {:stop, :normal, state}
  end

  @doc false
  def handle_info(:step, %{servo_pid: p, current: c, delay: d, step: s, left: l} = state) do
    next = c + s
    Servo.position(p, round(next))
    state = %{state | current: next, left: l - 1}
    queue_next_step(d)
    {:noreply, state}
  end

  defp queue_next_step(step_delay) do
    Process.send_after(self(), :step, step_delay)
  end
end
