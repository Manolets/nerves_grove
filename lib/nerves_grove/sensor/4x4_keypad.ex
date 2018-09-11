defmodule Nerves.Grove.Sensor.Keypad do
  @moduledoc """
  This code will allow you to obtain the coordinates and values of
  the keys pressed on a 4x4 keyboard
  1 2 3 A
  4 5 6 B
  7 8 9 C
  * 0 # D

  Use this as an example

  alias Nerves.Grove.Sensor.Keypad
  Keypad.set_rows(26, 12, 13, 14) #Important you do the rows first to start PID server
  Keypad.set_column(19, 18, 6, 5)
  Keypad.start_looking
  """

  import Nerves.Grove.PidServer
  alias Pigpiox
  require Logger

  @type row_pins() :: %{row1: integer(), row2: integer(), row3: integer(), row4: integer()}
  @type column_pins() :: %{
          column1: integer(),
          column2: integer(),
          column3: integer(),
          column4: integer()
        }
  # @pins_code [:one, :two, :three, :four]

  def set_rows(r1, r2, r3, r4) do
    start()
    row_pins = %{row1: r1, row2: r2, row3: r3, row4: r4}
    put_pids(:rpins, row_pins)
    row_pins
  end

  def set_column(c1, c2, c3, c4) do
    column_pins = %{column1: c1, column2: c2, column3: c3, column4: c4}
    put_pids(:cpins, column_pins)
    column_pins
  end

  def start_looking() do
    task_pid =
      Task.start(fn ->
        loop(get_pids(:rpids), get_pids(:cpids))
      end)

    task_pid
  end

  def read_rows(row_pins, column_pins) do
    for n <- 0..3 do
      column_pin = column_pins |> Enum.at(n)
      Pigpiox.GPIO.set_mode(column_pin, :output)
      Pigpiox.GPIO.write(column_pin, 1)
    end

    for n <- 0..3 do
      row_pin = row_pins |> Enum.at(n)
      # pin_code = @pins_code |> Enum.at(n)
      Pigpiox.GPIO.set_mode(row_pin, :input)
      output = Pigpiox.GPIO.read(row_pin)

      if output == {:ok, 1} do
        put_pids(:rowoutput, row_pin)
      end
    end

    read_columns(row_pins, column_pins)
  end

  def read_columns(row_pins, column_pins) do
    for n <- 0..3 do
      row_pin = row_pins |> Enum.at(n)
      Pigpiox.GPIO.set_mode(row_pin, :output)
      Pigpiox.GPIO.write(row_pin, 1)
    end

    for n <- 0..3 do
      column_pin = column_pins |> Enum.at(n)
      # pin_code = @pins_code |> Enum.at(n)
      Pigpiox.GPIO.set_mode(column_pin, :input)
      output = Pigpiox.GPIO.read(column_pin)

      if output == {:ok, 1} do
        put_pids(:columnoutput, column_pin)
      end
    end

    button_pressed(get_pids(:rowoutput), get_pids(:columnoutput))
  end

  def button_pressed(row, column) do
    case [row, column] do
      [r1, c1] ->
        Logger.debug("1")
    end
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
