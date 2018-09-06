defmodule Nerves.Grove.OneNumberLeds do
  require Logger
  alias ElixirALE.GPIO

  @type pids() :: %{a: pid(), b: pid(), c: pid(), d: pid(), e: pid(), f: pid(), g: pid()}

  def set_pins(pin_a, pin_b, pin_c, pin_d, pin_e, pin_f, pin_g) do
    {:ok, a} = GPIO.start_link(pin_a, :output)
    {:ok, b} = GPIO.start_link(pin_b, :output)
    {:ok, c} = GPIO.start_link(pin_c, :output)
    {:ok, d} = GPIO.start_link(pin_d, :output)
    {:ok, e} = GPIO.start_link(pin_e, :output)
    {:ok, f} = GPIO.start_link(pin_f, :output)
    {:ok, g} = GPIO.start_link(pin_g, :output)

    pids = %{a: a, b: b, c: c, d: d, e: e, f: f, g: g}

    Logger.debug("Inspeccionando PIDs #{inspect(pids)}")
    pids
  end

  @spec new(atom() | %{a: pid(), b: pid(), c: pid(), d: pid(), e: pid(), f: pid(), g: pid()}) ::
          :ok | {:error, any()}
  def new(pids) do
    GPIO.write(pids.a, 0)
    GPIO.write(pids.b, 0)
    GPIO.write(pids.c, 0)
    GPIO.write(pids.d, 0)
    GPIO.write(pids.e, 0)
    GPIO.write(pids.f, 0)
    GPIO.write(pids.g, 0)
  end

  def zero(pids) do
    new(pids)
    GPIO.write(pids.a, 1)
    GPIO.write(pids.b, 1)
    GPIO.write(pids.c, 1)
    GPIO.write(pids.d, 1)
    GPIO.write(pids.e, 1)
    GPIO.write(pids.f, 1)
  end

  def one(pids) do
    new(pids)
    GPIO.write(pids.b, 1)
    GPIO.write(pids.c, 1)
  end

  def two(pids) do
    new(pids)
    GPIO.write(pids.a, 1)
    GPIO.write(pids.b, 1)
    GPIO.write(pids.e, 1)
    GPIO.write(pids.g, 1)
    GPIO.write(pids.d, 1)
  end

  def three(pids) do
    new(pids)
    GPIO.write(pids.a, 1)
    GPIO.write(pids.b, 1)
    GPIO.write(pids.c, 1)
    GPIO.write(pids.d, 1)
    GPIO.write(pids.g, 1)
  end

  def four(pids) do
    new(pids)
    GPIO.write(pids.b, 1)
    GPIO.write(pids.c, 1)
    GPIO.write(pids.f, 1)
    GPIO.write(pids.g, 1)
  end

  def five(pids) do
    new(pids)
    GPIO.write(pids.a, 1)
    GPIO.write(pids.f, 1)
    GPIO.write(pids.g, 1)
    GPIO.write(pids.c, 1)
    GPIO.write(pids.d, 1)
  end

  def six(pids) do
    new(pids)
    GPIO.write(pids.a, 1)
    GPIO.write(pids.f, 1)
    GPIO.write(pids.g, 1)
    GPIO.write(pids.c, 1)
    GPIO.write(pids.d, 1)
    GPIO.write(pids.e, 1)
  end

  def seven(pids) do
    new(pids)
    GPIO.write(pids.b, 1)
    GPIO.write(pids.c, 1)
    GPIO.write(pids.a, 1)
  end

  def eight(pids) do
    new(pids)
    GPIO.write(pids.a, 1)
    GPIO.write(pids.f, 1)
    GPIO.write(pids.g, 1)
    GPIO.write(pids.c, 1)
    GPIO.write(pids.d, 1)
    GPIO.write(pids.e, 1)
    GPIO.write(pids.b, 1)
  end

  def nine(pids) do
    new(pids)
    GPIO.write(pids.b, 1)
    GPIO.write(pids.c, 1)
    GPIO.write(pids.a, 1)
    GPIO.write(pids.f, 1)
    GPIO.write(pids.g, 1)
  end
end
