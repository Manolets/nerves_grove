defmodule Nerves.Grove.Display4_7 do
  @moduledoc """
    Use this module
    RingLogger.attach
    alias Nerves.Grove.Display4_7
    Display4_7.set_main_pins(21, 20, 5, 13)
    Display4_7.set_segment_pins(17, 18, 27, 23, 22, 24, 25, 6)
    {:ok, supp} = Display4_7.display_digits(0, 1, 2, 3)
    Display4_7.send_stop(supp)
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
    put_pids(:mpins, main_pins)

    for {key, val} <- main_pins do
      GPIO.set_mode(val, :output)
      Logger.info("key:#{inspect(key)} pin :#{inspect(val)}")
    end
  end

  def set_segment_pins(pin_a, pin_b, pin_c, pin_d, pin_e, pin_f, pin_g, pin_h) do
    Logger.debug("Starting agent pid_server #{inspect(start())}")
    segment_pins = set_one_segment_pins(pin_a, pin_b, pin_c, pin_d, pin_e, pin_f, pin_g, pin_h)
    put_pids(:spins, segment_pins)

    segment_pins
  end

  def display_digits(a, b, c, d) do
    characters = %{a: a, b: b, c: c, d: d}

    task_pid =
      Task.start(fn ->
        # Logger.debug("characters #{inspect(characters)}")
        loop(get_pids(:mpids), get_pids(:spids), characters)
      end)

    task_pid
  end

  def send_stop(pid) do
    send(pid, :stop)
  end

  defp write_character(segment_pins, digit) do
    case digit do
      0 ->
        write(segment_pins, :zero)

      1 ->
        write(segment_pins, :one)

      2 ->
        write(segment_pins, :two)

      3 ->
        write(segment_pins, :three)

      4 ->
        write(segment_pins, :four)

      5 ->
        write(segment_pins, :five)

      6 ->
        write(segment_pins, :six)

      7 ->
        write(segment_pins, :seven)

      8 ->
        write(segment_pins, :eight)

      9 ->
        write(segment_pins, :nine)

      A ->
        write(segment_pins, :A)
    end
  end

  defp display_characters(main_pins, segment_pins, characters) do
    write_char_safe(main_pins.one, segment_pins, characters.a)
    write_char_safe(main_pins.two, segment_pins, characters.b)
    write_char_safe(main_pins.three, segment_pins, characters.c)
    write_char_safe(main_pins.four, segment_pins, characters.d)
  end

  defp write_char_safe(pin, segment_pins, charater) do
    GPIO.write(pin, 0)
    write_character(segment_pins, charater)
    GPIO.write(pin, 1)
  end

  defp loop(main_pins, segment_pins, characters) do
    # Logger.debug("Into the execution loop ....")

    receive do
      :stop ->
        Logger.debug("Stopping...")
        Process.sleep(100)
        exit(:shutdown)
    after
      # Optional timeout
      2_0 -> :timeout
    end

    display_characters(main_pins, segment_pins, characters)
    loop(main_pins, segment_pins, characters)
  end
end
