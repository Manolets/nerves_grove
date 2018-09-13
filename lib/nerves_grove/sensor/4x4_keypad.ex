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

  def start_looking() do
    start()
    r1 = 5
    r2 = 6
    r3 = 13
    r4 = 19
    row_pins = [r1, r2, r3, r4]
    c1 = 12
    c2 = 16
    c3 = 20
    c4 = 21
    column_pins = [c1, c2, c3, c4]
    put_pair(:rpin, row_pins)
    put_pair(:cpin, column_pins)

    task_pid =
      Task.start(fn ->
        loop()
      end)

    task_pid
  end

  def read(row_pins, column_pins) do
    rpin =
      for c <- 0..3, r <- 0..3 do
        column_pin = column_pins |> Enum.at(c)
        Pigpiox.GPIO.set_mode(column_pin, :output)
        Pigpiox.GPIO.write(column_pin, 1)

        row_pin = row_pins |> Enum.at(r)
        # pin_code = @pins_code |> Enum.at(n)
        Pigpiox.GPIO.set_mode(row_pin, :input)
        output = Pigpiox.GPIO.read(row_pin)
        Process.sleep(1)

        if output == {:ok, 1} do
          rp = row_pin
          put_pair(:rp, rp)
        end
      end

    Process.sleep(1)

    for r <- 0..3, c <- 0..3 do
      row_pin = row_pins |> Enum.at(r)
      Pigpiox.GPIO.set_mode(row_pin, :output)
      Pigpiox.GPIO.write(row_pin, 1)

      column_pin = column_pins |> Enum.at(c)
      # pin_code = @pins_code |> Enum.at(n)
      Pigpiox.GPIO.set_mode(column_pin, :input)
      output = Pigpiox.GPIO.read(column_pin)
      Process.sleep(1)

      Logger.debug(
        "Row : #{inspect(get_pair(:rp))}, column :#{inspect(column_pin)}, output : #{inspect(output)} "
      )

      if output == {:ok, 1} do
        button_pressed(get_pair(:rp), column_pin)
      end
    end
  end

  def button_pressed(row, column) do
    Logger.debug("Before case #{inspect(row)}, #{inspect(column)}")

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

  defp loop() do
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

    read(get_pair(:rpin), get_pair(:cpin))
    loop()
  end
end
