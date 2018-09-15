defmodule Nerves.Grove.Sensor.Keypad do
  @moduledoc """
  This code will allow you to obtain the coordinates and values of
  the keys pressed on a 4x4 keyboard
  1 2 3 A
  4 5 6 B
  7 8 9 C
  * 0 # D

  Use this as allways, you need to wire it the same every time
  {:ok, pid} = Keypad.start_looking
  alias Pigpiox.GPIO
  alias Nerves.Grove.Sensor.Keypad
  {:ok, pid}=Keypad.start_keypad

  Keypad.read()
  Keypad.send_stop (pid)
  RingLogger.tail
  GPIO.set_mode(12, :output)
  GPIO.write(12, 1)
  GPIO.set_mode(5, :input)
  GPIO.read(5)
  GPIO.set_mode(5, :output)
  GPIO.write(5, 1)
  GPIO.set_mode(12, :input)
  GPIO.read(12)
  """

  alias Pigpiox.GPIO
  require Logger
  @row_pins [27, 22, 13, 19]
  @column_pins [12, 16, 20, 21]
  #  def start_looking(row_p \\ @row_pins, col_p \\ @column_pins) do
  #    task_pid =
  #      Task.start(fn ->
  #        loop(row_p, col_p)
  #      end)
  #
  #    task_pid
  #  end


  def start_keypad(row_p \\ @row_pins, col_p \\ @column_pins) do
    task_pid =
      Task.start(fn ->
        loop(row_p, col_p)
      end)

    task_pid
  end

  def send_stop(pid) do
    send(pid, :stop)
  end

  def read(row_pins \\ @row_pins, column_pins \\ @column_pins) do
    c_returns =
      column_pins
      |> Enum.map(fn column_pin ->
        GPIO.set_mode(column_pin, :output)
        GPIO.write(column_pin, 1)
      end)

    r_reads =
      row_pins
      |> Enum.map(fn row_pin ->
        GPIO.set_mode(row_pin, :input)
        GPIO.read(row_pin)
      end)

    r_returns =
      row_pins
      |> Enum.map(fn row_pin ->
        GPIO.set_mode(row_pin, :output)
        GPIO.write(row_pin, 1)
      end)

    c_reads =
      column_pins
      |> Enum.map(fn column_pin ->
        GPIO.set_mode(column_pin, :input)
        GPIO.read(column_pin)
      end)

    Logger.debug("c_returns:#{inspect(c_returns)}r_reads:#{inspect(r_reads)}")
    Logger.debug("r_returns:#{inspect(r_returns)}c_reads:#{inspect(c_reads)}")
  end



  defp button_pressed(row, column) do
    Logger.debug("Before case row:#{inspect(row)}, column:#{inspect(column)}")

    case [row, column] do
      [5, 12] ->
        Logger.debug("-->1")

      [5, 16] ->
        Logger.debug("-->2")

      [5, 20] ->
        Logger.debug("-->3")

      [5, 21] ->
        Logger.debug("-->A")

      [6, 12] ->
        Logger.debug("-->4")

      [6, 16] ->
        Logger.debug("-->5")

      [6, 20] ->
        Logger.debug("-->6")

      [6, 21] ->
        Logger.debug("-->B")

      [13, 12] ->
        Logger.debug("-->7")

      [13, 16] ->
        Logger.debug("-->8")

      [13, 20] ->
        Logger.debug("-->9")

      [13, 21] ->
        Logger.debug("-->C")

      [19, 12] ->
        Logger.debug("-->*")

      [19, 16] ->
        Logger.debug("-->0")

      [19, 20] ->
        Logger.debug("-->#")

      [19, 21] ->
        Logger.debug("-->D")
    end
  end



  defp loop(row_p, col_p) do
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
    read(row_p, col_p)
    loop(row_p, col_p)
  end
end
