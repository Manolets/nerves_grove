defmodule Nerves.Grove.Sensor.MotionSensor do
  alias ElixirALE.GPIO

  def start_link(pin) when is_integer(pin) do
    GPIO.start_link(pin, :output)
  end

  def on(pid) do
    GPIO.read(pid)
  end

  def off(pid) do
    GPIO.read(pid)
  end
end
