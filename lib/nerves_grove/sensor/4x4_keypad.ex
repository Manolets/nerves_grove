defmodule Nerves.Grove.Sensor.Keypad do
  @moduledoc """
  This code will allow you to obtain the coordinates and values of
  the keys pressed on a 4x4 keyboard
  1 2 3 A
  4 5 6 B
  7 8 9 C
  * 0 # D

  Use this as allways, you need to wire it the same every time

  alias Nerves.Grove.Sensor.Keypad
  Keypad.start_looking
  RingLogger.tail
  """

  alias Pigpiox.GPIO
  require Logger
  @row_pins [5, 6, 13, 19]
  @column_pins [12, 16, 20, 21]
  def start_looking(row_p \\ @row_pins, col_p \\ @column_pins) do
    task_pid =
      Task.start(fn ->
        loop(row_p, col_p)
      end)

    task_pid
  end

  def read(row_pins, column_pins) do
    for c <- 0..3, r <- 0..3 do
      column_pin = column_pins |> Enum.at(c)
      GPIO.set_mode(column_pin, :output)
      GPIO.write(column_pin, 1)
      row_pin = row_pins |> Enum.at(r)
      GPIO.set_mode(row_pin, :input)
      output = GPIO.read(row_pin)
      Process.sleep(1)
      Logger.debug("Row : #{inspect(row_pin)},
          column :#{inspect(column_pin)},
          output : #{inspect(output)} ")

      if output == {:ok, 1} do
        read(row_pins, column_pins, row_pin)
      end
    end
  end

  defp read(row_pins, column_pins, r_pin) do
    for r <- 0..3, c <- 0..3 do
      row_pin = row_pins |> Enum.at(r)
      GPIO.set_mode(row_pin, :output)
      GPIO.write(row_pin, 1)
      column_pin = column_pins |> Enum.at(c)
      GPIO.set_mode(column_pin, :input)
      output = GPIO.read(column_pin)
      Process.sleep(1)
      Logger.debug("Row : #{inspect(r_pin)},
          column :#{inspect(column_pin)},
          output : #{inspect(output)} ")

      if output == {:ok, 1} do
        button_pressed(r_pin, column_pin)
      end
    end
  end

  def button_pressed(row, column) do
    Logger.debug("Before case row:#{inspect(row)}, column:#{inspect(column)}")

    case [row, column] do
      [5, 12] ->
        Logger.debug("1")

      [5, 16] ->
        Logger.debug("2")

      [5, 20] ->
        Logger.debug("3")

      [5, 21] ->
        Logger.debug("A")

      [6, 12] ->
        Logger.debug("4")

      [6, 16] ->
        Logger.debug("5")

      [6, 20] ->
        Logger.debug("6")

      [6, 21] ->
        Logger.debug("B")

      [13, 12] ->
        Logger.debug("7")

      [13, 16] ->
        Logger.debug("8")

      [13, 20] ->
        Logger.debug("9")

      [13, 21] ->
        Logger.debug("C")

      [19, 12] ->
        Logger.debug("*")

      [19, 16] ->
        Logger.debug("0")

      [19, 20] ->
        Logger.debug("#")

      [19, 21] ->
        Logger.debug("D")
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

    read(row_pins, column_pins)
    loop(row_pins, column_pins)
  end
end
