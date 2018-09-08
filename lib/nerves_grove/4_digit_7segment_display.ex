defmodule Nerves.Grove.Display4_7 do
  @moduledoc """
    Use this module
    alias Nerves.Grove.Display4_7
    Display4_7.set_main_pins(21, 20, 5, 13)
    Display4_7.set_segment_pins(17, 18, 27, 23, 22, 24, 25, 6)
    {:ok, pid} = Display4_7.set_number(0, 1, 2, 3)
    Display4_7.send_stop(pid)
    RingLogger.attach

    To open each digit manually:
    alias ElixirALE.GPIO
    {:ok, pidm1} = GPIO.start_link(21, :output)
    {:ok, pidm2} = GPIO.start_link(20, :output)
    {:ok, pidm3} = GPIO.start_link(5, :output)
    {:ok, pidm4} = GPIO.start_link(13, :output)
  """

  require Logger
  alias ElixirALE.GPIO
  import Nerves.Grove.OneNumberLeds
  import Nerves.Grove.PidServer

  @type main_pids() :: %{one: pid(), two: pid(), three: pid(), four: pid()}
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
    {:ok, one} = GPIO.start_link(pin_1, :output)
    {:ok, two} = GPIO.start_link(pin_2, :output)
    {:ok, three} = GPIO.start_link(pin_3, :output)
    {:ok, four} = GPIO.start_link(pin_4, :output)

    main_pids = %{one: one, two: two, three: three, four: four}
    put_pids(:mpids, main_pids)

    main_pids
  end

  def set_segment_pins(pin_a, pin_b, pin_c, pin_d, pin_e, pin_f, pin_g, pin_h) do
    Logger.debug("Starting agent pid_server #{inspect(start())}")
    segment_pids = set_pins(pin_a, pin_b, pin_c, pin_d, pin_e, pin_f, pin_g, pin_h)
    put_pids(:spids, segment_pids)

    segment_pids
  end

  def set_number(a, b, c, d) do
    characters = %{a: a, b: b, c: c, d: d}

    task_pid =
      Task.start(fn ->
        Logger.debug("characters #{inspect(characters)}")
        loop(get_pids(:mpids), get_pids(:spids), characters)
      end)

    task_pid
  end

  def send_stop(pid) do
    send(pid, :stop)
  end

  defp write_character(segment_pids, digit) do
    case digit do
      0 ->
        write(segment_pids, :zero)

      1 ->
        write(segment_pids, :one)

      2 ->
        write(segment_pids, :two)

      3 ->
        write(segment_pids, :three)

      4 ->
        write(segment_pids, :four)

      5 ->
        write(segment_pids, :five)

      6 ->
        write(segment_pids, :six)

      7 ->
        write(segment_pids, :seven)

      8 ->
        write(segment_pids, :eight)

      9 ->
        write(segment_pids, :nine)

      A ->
        write(segment_pids, :A)
    end
  end

  defp display_characters(main_pids, segment_pids, characters) do
    GPIO.write(main_pids.one, 0)
    write_character(segment_pids, characters.a)
    GPIO.write(main_pids.one, 1)
    GPIO.write(main_pids.two, 0)
    write_character(segment_pids, characters.b)
    GPIO.write(main_pids.two, 1)
    GPIO.write(main_pids.three, 0)
    write_character(segment_pids, characters.c)
    GPIO.write(main_pids.three, 1)
    GPIO.write(main_pids.four, 0)
    write_character(segment_pids, characters.d)
    GPIO.write(main_pids.four, 1)
  end

  defp loop(main_pids, segment_pids, characters) do
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

    display_characters(main_pids, segment_pids, characters)
    loop(main_pids, segment_pids, characters)
  end
end
