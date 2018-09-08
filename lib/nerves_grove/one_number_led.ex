defmodule Nerves.Grove.OneNumberLeds do
  @moduledoc """
          [a,b,c,d,e,f,g,h]
  null =  [0,0,0,0,0,0,0,0]
  zero =  [1,1,1,1,1,1,0,0]
  one =   [0,1,1,0,0,0,0,0]
  two =   [1,1,0,1,1,0,1,0]
  three = [1,1,1,1,0,0,1,0]
  four =  [0,1,1,0,0,1,1,0]
          [a,b,c,d,e,f,g,h]
  five =  [1,0,1,1,0,1,1,0]
  six =   [1,0,1,1,1,1,1,0]
  seven = [1,1,1,0,0,0,0,0]
  eight = [1,1,1,1,1,1,1,0]
  nine =  [1,1,1,1,0,1,1,0]
  A =     [1,1,1,0,1,1,1,0]
          [a,b,c,d,e,f,g,h]
  String.to_integer("FC", 16)|>Integer.digits(2)
  c "lib/kv/display/comprehensions.ex"
  """
  require Logger
  import Nerves.Grove.PidServer
  alias ElixirALE.GPIO

  # 0~9
  @digits_code %{
    null: 0x00,
    zero: 0xFC,
    one: 0x60,
    two: 0xDA,
    three: 0xF2,
    four: 0x66,
    five: 0xB6,
    six: 0xBE,
    seven: 0xE0,
    eight: 0xFE,
    nine: 0xF6,
    A: 0xEE
  }
  @pins_code [:a, :b, :c, :d, :e, :f, :g, :h]

  @doc """
  c "lib/kv/display/comprehensions.ex"
  Nerves.Grove.OneNumberLeds.set_pins(17, 18, 27, 23, 22, 24, 25, 13)
  """
  def set_pins(pin_a, pin_b, pin_c, pin_d, pin_e, pin_f, pin_g, pin_h) do
    Logger.debug("Starting agent pid_server #{inspect(start())}")
    input_pins = [pin_a, pin_b, pin_c, pin_d, pin_e, pin_f, pin_g, pin_h]

    digit_pids =
      for n <- 0..7 do
        input_pin = input_pins |> Enum.at(n)
        pin_code = @pins_code |> Enum.at(n)
        {:ok, digit_pid} = GPIO.start_link(input_pin, :output)
        {pin_code, digit_pid}
        # digit_pid = input_pins |> Enum.at(n)
        # pin_code = @pins_code |> Enum.at(n)
        # {pin_code, digit_pid}
      end

    ### Save digit_pids into actor
    put_pids(:digit_pids, digit_pids)
    Logger.info("digit_pids#{inspect(digit_pids)}")
    digit_pids
  end

  @doc """
    alias Nerves.Grove.OneNumberLeds
    digit_pids = Comprehension.set_pins(0,1,2,3,4,5,6,7)
    Comprehension.clear_all(digit_pids,Comprehension.@digits_code.eight)
  """
  def clear(digit_pids) do
    Enum.each(digit_pids, fn digit_pid ->
      GPIO.write(digit_pid, 0)
      # Logger.info("digit_pid#{inspect(digit_pid)}")
    end)
  end

  @doc """
    c "lib/kv/display/comprehensions.ex"
    alias Nerves.Grove.OneNumberLeds
    digit_pids = Comprehension.set_pins("a", "b", "c", "d", "e", "f", "g", "h")
    Comprehension.write(digit_pids,:eight)
  """
  def write(digit_pids, digit) do
    digit_bits = @digits_code[digit] |> Integer.digits(2)

    for n <- 0..7 do
      digit_bit = digit_bits |> Enum.at(n)
      pid = digit_pids |> Enum.at(n) |> Kernel.elem(1)

      if 1 == digit_bit do
        # Logger.info("pid#{inspect(pid)} to 1")
        GPIO.write(pid, 1)
      else
        # Logger.info("pid#{inspect(pid)} to 0")
        GPIO.write(pid, 0)
      end
    end
  end

  @doc """
    c "lib/kv/display/comprehensions.ex"
    alias Nerves.Grove.OneNumberLeds
    digit_pids = Comprehension.set_pins("a", "b", "c", "d", "e", "f", "g", "h")
    Comprehension.release()
  """
  def release() do
    get_pids(:digit_pids)
    |> Enum.each(fn digit_pid ->
      # Logger.info("pid#{inspect(digit_pid |> Kernel.elem(1))}}")
      GPIO.release(digit_pid)
    end)
  end
end
