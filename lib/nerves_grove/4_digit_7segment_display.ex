defmodule Nerves.Grove.Display4_7 do
  @moduledoc """
    Use this module
    Ring#Logger.attach
    alias Nerves.Grove.Display4_7
    Display4_7.set_main_pins(21, 20, 5, 13)
    Display4_7.set_digit_pins(17, 18, 27, 23, 22, 24, 25, 6)
    {:ok, tpid} = Display4_7.display_digits(8, 4, :null, 1)

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

  # Logger
  require
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
    # Logger.debug("Starting agent pid_server #{inspect(start())}")
    main_pins = %{one: pin_1, two: pin_2, three: pin_3, four: pin_4}
    put_pair(:mpins, main_pins)

    for {key, val} <- main_pins do
      GPIO.set_mode(val, :output)
      # Logger.info("key:#{inspect(key)} pin :#{inspect(val)}")
    end
  end

  def set_digit_pins(pin_a, pin_b, pin_c, pin_d, pin_e, pin_f, pin_g, pin_h) do
    # Logger.debug("Starting agent pid_server #{inspect(start())}")
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
    with {:ok, tpid} <- get_pair(:tpid) do
      send_stop(tpid)
    end

    characters = %{a: a, b: b, c: c, d: d}

    task_pid =
      Task.start(fn ->
        loop(get_pair(:mpins), get_pair(:dpins), characters)
      end)

    put_pair(:tpid, task_pid)
    task_pid
  end

  def send_stop(pid) when not is_nil(pid) do
    send(pid, :stop)
  end

  def write_character(digit_pins, digit) do
    letter = ?A..?Z
    number = 0..9
    nmbrlist = [:zero, :one, :two, :three, :four, :five, :six, :seven, :eight, :nine]

    cond do
      Enum.member?(letter, digit) ->
        write(digit_pins, digit |> inspect |> String.to_existing_atom())

      Enum.member?(number, digit) ->
        write(digit_pins, nmbrlist |> Enum.at(digit |> inspect |> String.to_integer()))

      digit == :null ->
        write(digit_pins, :null)
    end
  end

  @doc """
  Pigpiox.GPIO.write(21, 0)
  Pigpiox.GPIO.write(20, 0)
  Pigpiox.GPIO.write(5, 0)
  Pigpiox.GPIO.write(13, 0)

  Pigpiox.GPIO.write(21, 1)
  Pigpiox.GPIO.write(20, 1)
  Pigpiox.GPIO.write(5, 1)
  Pigpiox.GPIO.write(13, 1)

  alias Nerves.Grove.Display4_7
  Display4_7.set_main_pins(21, 20, 5, 13)
  Display4_7.set_digit_pins(17, 18, 27, 23, 22, 24, 25, 6)
  digit_pins = Nerves.Grove.PidServer.get_pair(:dpins)
  Display4_7.write_character(digit_pins, 1)
  #mpins = Nerves.Grove.PidServer.get_pair(:mpins)

  """
  def display_characters(main_pins, digit_pins, characters) do
    write_char_safe(main_pins.one, digit_pins, characters.a)
    write_character(digit_pins, :null)
    write_char_safe(main_pins.two, digit_pins, characters.b)
    write_character(digit_pins, :null)
    write_char_safe(main_pins.three, digit_pins, characters.c)
    write_character(digit_pins, :null)
    write_char_safe(main_pins.four, digit_pins, characters.d)
    write_character(digit_pins, :null)
  end

  defp write_char_safe(pin, digit_pins, charater) do
    GPIO.write(pin, 0)
    write_character(digit_pins, charater)
    GPIO.write(pin, 1)
  end

  defp loop(main_pins, digit_pins, characters) do
    # Logger.debug("Into the execution loop with main_pins #{inspect(main_pins)}")
    # Logger.debug("characters #{inspect(characters)}")

    receive do
      :stop ->
        # Logger.debug("Stopping...")
        Process.sleep(100)
        exit(:shutdown)
    after
      # Optional timeout
      5 -> :timeout
    end

    display_characters(main_pins, digit_pins, characters)
    loop(main_pins, digit_pins, characters)
  end
end
