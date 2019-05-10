defmodule Nerves.Grove.StepperMotor do
  @moduledoc """
  This module allows controll of a stepper motor,
  customizable speed and nº of steps

  Try this
  alias Nerves.Grove.StepperMotor
  StepperMotor.set_pins(19, 26, 12, 4)
  StepperMotor.clockwise(512, 1)
  """

  alias Pigpiox
  import Nerves.Grove.PidServer

  @type row_pins() :: %{a: integer(), b: integer(), c: integer(), d: integer()}
  def set_pins(in1, in2, in3, in4) do
    start()
    Pigpiox.GPIO.set_mode(in1, :output)
    Pigpiox.GPIO.set_mode(in2, :output)
    Pigpiox.GPIO.set_mode(in3, :output)
    Pigpiox.GPIO.set_mode(in4, :output)
    pins = %{a: in1, b: in2, c: in3, d: in4}
    put_pair(:pins, pins)
  end

  def clockwise(steps, sleep) do
    forward(steps, get_pair(:pins), sleep)
  end

  def forward(steps, pins, sleep) do
    get_pair(:pins)

    for _n <- 0..steps do
      Pigpiox.GPIO.write(pins.a, 1)
      Process.sleep(sleep)
      Pigpiox.GPIO.write(pins.b, 1)
      Process.sleep(sleep)
      Pigpiox.GPIO.write(pins.c, 1)
      Process.sleep(sleep)
      Pigpiox.GPIO.write(pins.d, 1)
      Process.sleep(sleep)
      Pigpiox.GPIO.write(pins.a, 0)
      Process.sleep(sleep)
      Pigpiox.GPIO.write(pins.b, 0)
      Process.sleep(sleep)
      Pigpiox.GPIO.write(pins.c, 0)
      Process.sleep(sleep)
      Pigpiox.GPIO.write(pins.d, 0)
      Process.sleep(sleep)
    end
  end

  def anticlockwise(steps, sleep) do
    backward(steps, get_pair(:pins), sleep)
  end

  def backward(steps, pins, sleep) do
    get_pair(:pins)

    for _n <- 0..steps do
      Pigpiox.GPIO.write(pins.d, 1)
      Process.sleep(sleep)
      Pigpiox.GPIO.write(pins.c, 1)
      Process.sleep(sleep)
      Pigpiox.GPIO.write(pins.b, 1)
      Process.sleep(sleep)
      Pigpiox.GPIO.write(pins.a, 1)
      Process.sleep(sleep)
      Pigpiox.GPIO.write(pins.d, 0)
      Process.sleep(sleep)
      Pigpiox.GPIO.write(pins.c, 0)
      Process.sleep(sleep)
      Pigpiox.GPIO.write(pins.b, 0)
      Process.sleep(sleep)
      Pigpiox.GPIO.write(pins.a, 0)
      Process.sleep(sleep)
    end
  end
end
