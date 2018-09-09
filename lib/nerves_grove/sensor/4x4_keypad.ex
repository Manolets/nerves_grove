defmodule Nerves.Grove.Sensor.Keypad do
  import Nerves.Grove.PidServer
  alias GpioRpi
  require Logger

  start()
  @type row_pins() :: %{row1: integer(), row2: integer(), row3: integer(), row4: integer()}
  @type column_pins() :: %{
          column1: integer(),
          column2: integer(),
          column3: integer(),
          column4: integer()
        }
  @pins_code [:one, :two, :three, :four]

  def set_rows(r1, r2, r3, r4) do
    row_pins = %{row1: r1, row2: r2, row3: r3, row4: r4}
    put_pids(:rpins, row_pins)
    row_pins
  end

  def set_column(c1, c2, c3, c4) do
    column_pins = %{column1: c1, column2: c2, column3: c3, column4: c4}
    put_pids(:cpins, column_pins)
    column_pins
  end

  def start() do
    task_pid =
      Task.start(fn ->
        loop(get_pids(:rpids), get_pids(:cpids))
      end)

    task_pid
  end

  def read_rows(row_pins, column_pins) do
    for n <- 0..3 do
      column_pin = column_pins |> Enum.at(n)
      {:ok, column_pid} = GpioRpi.start_link(column_pin, :output)
      GpioRpi.write(column_pid, 1)
      column_pid = [] ++ []
      column_pid
    end

    for n <- 0..3 do
      row_pin = row_pins |> Enum.at(n)
      pin_code = @pins_code |> Enum.at(n)
      {:ok, row_pid} = GpioRpi.start_link(row_pin, :input)
      GpioRpi.set_int(row_pid, :raise)
      {pin_code, row_pid}
    end

    #GpioRpi.release()
  end

  def send_stop(pid) do
    send(pid, :stop)
  end

  defp loop(row_pins, column_pins) do
    Logger.debug("Into the execution loop....")

    receive do
      :stop ->
        IO.puts("Stopping...")
        Process.sleep(100)
        exit(:shutdown)
    after
      # Optional timeout
      3_000 -> :timeout
    end

    read_rows(row_pins, column_pins)
    loop(row_pins, column_pins)
  end
end
