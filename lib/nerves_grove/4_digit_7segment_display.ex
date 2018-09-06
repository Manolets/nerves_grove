defmodule Nerves.Grove.Display4_7 do
  require Logger
  alias ElixirALE.GPIO
  import Nerves.Grove.OneNumberLeds
  import Nerves.Grove.PidServer

  @type main_pids() :: %{one: pid(), two: pid(), three: pid(), four: pid()}
  @type pids() :: %{a: pid(), b: pid(), c: pid(), d: pid(), e: pid(), f: pid(), g: pid()}

  def set_main_pins(pin_1, pin_2, pin_3, pin_4) do
    start_link(0)

    {:ok, one} = GPIO.start_link(pin_1, :output)
    {:ok, two} = GPIO.start_link(pin_2, :output)
    {:ok, three} = GPIO.start_link(pin_3, :output)
    {:ok, four} = GPIO.start_link(pin_4, :output)

    main_pids = %{one: one, two: two, three: three, four: four}
    put_pids(:mpids, main_pids)

    Logger.debug("Inspeccionando PIDs de los dígitos #{inspect(main_pids)}")

    main_pids
  end

  def set_segment_pins(pin_a, pin_b, pin_c, pin_d, pin_e, pin_f, pin_g) do
    segment_pids = set_pins(pin_a, pin_b, pin_c, pin_d, pin_e, pin_f, pin_g)
    put_pids(:spids, segment_pids)
    segment_pids
  end

  @type numbers() :: %{a: integer(), b: integer(), c: integer(), d: integer()}
  def set_number(a, b, c, d) do
    numbers = %{a: a, b: b, c: c, d: d}

    task_pid =
      Task.start(fn ->
        loop(take_pids(:mpids), take_pids(:spids), numbers)
      end)

    task_pid
  end

  def new_digit(main_pids) do
    GPIO.write(main_pids.one, 1)
    GPIO.write(main_pids.two, 1)
    GPIO.write(main_pids.three, 1)
    GPIO.write(main_pids.four, 1)
  end

  def write_number(main_pids, segment_pids, numbers) do
    case numbers do
      0 ->
        zero(segment_pids)

      1 ->
        one(segment_pids)

      2 ->
        two(segment_pids)

      3 ->
        three(segment_pids)

      4 ->
        four(segment_pids)

      5 ->
        five(segment_pids)

      6 ->
        six(segment_pids)

      7 ->
        seven(segment_pids)

      8 ->
        eight(segment_pids)

      9 ->
        nine(segment_pids)
    end

    new_digit(main_pids)
  end

  def print_number(main_pids, segment_pids, numbers) do
    GPIO.write(main_pids.one, 0)
    write_number(main_pids, segment_pids, numbers.a)

    GPIO.write(main_pids.two, 0)
    write_number(main_pids, segment_pids, numbers.b)

    GPIO.write(main_pids.three, 0)
    write_number(main_pids, segment_pids, numbers.c)

    GPIO.write(main_pids.four, 0)
    write_number(main_pids, segment_pids, numbers.d)

    print_number(main_pids, segment_pids, numbers)
  end

  def send_stop(pid) do
    send(pid, :stop)
  end

  def loop(main_pids, segment_pids, numbers) do
    print_number(main_pids, segment_pids, numbers)

    receive do
      :stop ->
        Logger.debug("Stopping...")
        Process.sleep(100)
        exit(:shutdown)
    end

    Process.sleep(100)
    loop(main_pids, segment_pids, numbers)
  end
end
