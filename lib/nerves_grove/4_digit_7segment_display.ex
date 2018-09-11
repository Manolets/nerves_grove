defmodule Nerves.Grove.Display4_7 do
  @moduledoc """
    Use this module
    RingLogger.attach
    alias Nerves.Grove.Display4_7
    Display4_7.set_main_pins(21, 20, 5, 13)
    Display4_7.set_digit_pins(17, 18, 27, 23, 22, 24, 25, 6)
    {:ok, tpid} = Display4_7.display_digits(0, 1, 2, 3)
    Display4_7.send_stop(tpid)
    c ("lib/nerves_grove/4_digit_7segment_display.ex")
    To open each digit manually:
    alias ElixirALE.GPIO
    GPIO.set_mode(21, :output)
    GPIO.set_mode(20, :output)
    GPIO.set_mode(5, :output)
    GPIO.set_mode(13, :output)
  """

  require Logger
  alias Pigpiox.GPIO
  import Nerves.Grove.OneNumberLeds
  import Nerves.Grove.PidServer

  @type main_pins() :: %{one: pid(), two: pid(), three: pid(), four: pid()}
  @type pids() :: %{
          a: pid(),
          b: pid(),
          c: pid(),
          d: pid(),
          e: pid(),
          f: pid(),
          g: pid(),
          h: pid()
        }
  @type characters() :: %{a: integer(), b: integer(), c: integer(), d: integer()}

  def set_main_pins(pin_1, pin_2, pin_3, pin_4) do
    Logger.debug("Starting agent pid_server #{inspect(start())}")
    main_pins = %{one: pin_1, two: pin_2, three: pin_3, four: pin_4}
    put_pair(:mpins, main_pins)

    for {key, val} <- main_pins do
      GPIO.set_mode(val, :output)
      Logger.info("key:#{inspect(key)} pin :#{inspect(val)}")
    end
  end

  def set_digit_pins(pin_a, pin_b, pin_c, pin_d, pin_e, pin_f, pin_g, pin_h) do
    Logger.debug("Starting agent pid_server #{inspect(start())}")
    digit_pins = set_one_segment_pins(pin_a, pin_b, pin_c, pin_d, pin_e, pin_f, pin_g, pin_h)
    put_pair(:dpins, digit_pins)

    digit_pins
  end

@doc """
    alias Nerves.Grove.Display4_7
    Display4_7.set_main_pins(21, 20, 5, 13)
    Display4_7.set_digit_pins(17, 18, 27, 23, 22, 24, 25, 6)
    {:ok, pid} = Display4_7.display_digits(0, 1, 2, 3)
    Display4_7.send_stop(pid)
    c ("lib/nerves_grove/4_digit_7segment_display.ex")
"""
  def display_digits(a, b, c, d) do
    characters = %{a: a, b: b, c: c, d: d}

    task_pid =
      Task.start(fn ->
        loop(get_pair(:mpids), get_pair(:dpins), characters)
      end)

    task_pid
  end

  def send_stop(pid) do
    send(pid, :stop)
  end

  defp write_character(digit_pins, digit) do
    case digit do
      0 ->
        write(digit_pins, :zero)

      1 ->
        write(digit_pins, :one)

      2 ->
        write(digit_pins, :two)

      3 ->
        write(digit_pins, :three)

      4 ->
        write(digit_pins, :four)

      5 ->
        write(digit_pins, :five)

      6 ->
        write(digit_pins, :six)

      7 ->
        write(digit_pins, :seven)

      8 ->
        write(digit_pins, :eight)

      9 ->
        write(digit_pins, :nine)

      A ->
        write(digit_pins, :A)
    end
  end

  defp display_characters(main_pins, digit_pins, characters) do
    write_char_safe(main_pins.one, digit_pins, characters.a)
    write_char_safe(main_pins.two, digit_pins, characters.b)
    write_char_safe(main_pins.three, digit_pins, characters.c)
    write_char_safe(main_pins.four, digit_pins, characters.d)
  end

  defp write_char_safe(pin, digit_pins, charater) do
    GPIO.write(pin, 0)
    write_character(digit_pins, charater)
    GPIO.write(pin, 1)
  end

  defp loop(main_pins, digit_pins, characters) do
     Logger.debug("Into the execution loop with characters #{inspect(characters)}")
    receive do
      :stop ->
        Logger.debug("Stopping...")
        Process.sleep(100)
        exit(:shutdown)
    after
      # Optional timeout
      2_0 -> :timeout
    end

    display_characters(main_pins, digit_pins, characters)
    loop(main_pins, digit_pins, characters)
  end
end
