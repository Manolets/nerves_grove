defmodule Nerves.Grove.Sensor.MotionSensor do
  alias ElixirALE.GPIO

  @spec start_link(pos_integer) :: {:ok, pid} | {:error, any}
  def start_link(pin) when is_integer(pin) do
    GPIO.start_link(pin, :output)
  end

  def read(pid) do
    GPIO.read(pid)
  end

end
