defmodule Nerves.Grove.OneNumberLeds do
  @moduledoc """

    String.to_integer("FC", 16)|>Integer.digits(2)
    c ("lib/nerves_grove/one_number_led.ex")
    Ring#Logger.attach
    alias Nerves.Grove.OneNumberLeds
    OneNumberLeds.set_one_segment_pins(17, 18, 27, 23, 22, 24, 25, 6)


  """

  # Logger
  require
  alias Pigpiox.GPIO

  # 0~9
  @digits_code %{
    # [a,b,c,d,e,f,g,h]
    null: [0, 0, 0, 0, 0, 0, 0, 0],
    zero: [1, 1, 1, 1, 1, 1, 0, 0],
    one: [0, 1, 1, 0, 0, 0, 0, 0],
    two: [1, 1, 0, 1, 1, 0, 1, 0],
    three: [1, 1, 1, 1, 0, 0, 1, 0],
    four: [0, 1, 1, 0, 0, 1, 1, 0],
    five: [1, 0, 1, 1, 0, 1, 1, 0],
    six: [1, 0, 1, 1, 1, 1, 1, 0],
    seven: [1, 1, 1, 0, 0, 0, 0, 0],
    eight: [1, 1, 1, 1, 1, 1, 1, 0],
    nine: [1, 1, 1, 1, 0, 1, 1, 0],
    A: [1, 1, 1, 0, 1, 1, 1, 0],
    B: [1, 1, 1, 1, 1, 1, 1, 0],
    C: [0, 1, 1, 1, 1, 1, 1, 0]
  }
  @pins_code [:a, :b, :c, :d, :e, :f, :g, :h]

  def set_one_segment_pins(pin_a, pin_b, pin_c, pin_d, pin_e, pin_f, pin_g, pin_h) do
    input_pins = [pin_a, pin_b, pin_c, pin_d, pin_e, pin_f, pin_g, pin_h]

    segment_pins =
      for n <- 0..7 do
        pin_code = @pins_code |> Enum.at(n)
        input_pin = input_pins |> Enum.at(n)
        # GPIO.set_mode(input_pin, :output)
        # Logger.debug("input_pin: #{input_pin}")
        {pin_code, input_pin}
      end

    segment_pins
  end

  @doc """
    c ("lib/nerves_grove/one_number_led.ex")
    alias Nerves.Grove.OneNumberLeds
    digit_pids = OneNumberLeds.set_one_segment_pins(0,1,2,3,4,5,6,7)
    OneNumberLeds.write(digit_pids,:eight)
  """
  def write(digit_pins, digit) do
    digit_bits = @digits_code[digit]
    # Logger.debug("digit_pins #{inspect(digit_pins)}")
    # Logger.debug("digit_bits #{inspect(digit_bits)}")

    for n <- 0..7 do
      digit_bit = digit_bits |> Enum.at(n)
      pin = digit_pins |> Enum.at(n) |> Kernel.elem(1)

      if 1 == digit_bit do
        # Logger.debug("pin#{inspect(pin)} to 1")
        GPIO.write(pin, 1)
      else
        # Logger.debug("pin#{inspect(pin)} to 0")
        GPIO.write(pin, 0)
      end
    end
  end

  @doc """
    alias Nerves.Grove.OneNumberLeds
    digit_pids = OneNumberLeds.set_pins(0,1,2,3,4,5,6,7)
    OneNumberLeds.clear(digit_pids,:one)
  """
  def clear(digit_pins) do
    Enum.each(digit_pins, fn digit_pin ->
      GPIO.write(digit_pin, 0)
    end)
  end
end
