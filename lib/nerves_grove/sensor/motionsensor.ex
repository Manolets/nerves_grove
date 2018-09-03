defmodule Nerves.Grove.Sensor.MotionSensor do
  alias ElixirALE.GPIO

  @moduledoc """
  Seeed Studio [Grove MotionSensor Sensor]
  # Example

      alias Nerves.Grove.Sensor

      {:ok, pid} = Sensor.MotionSensor.start_link(pin)

      state = Sensor.MotionSensor.read(pid)  # check if sensor was triggered
  """
  @spec start_link(pos_integer) :: {:ok, pid} | {:error, any}
  def start_link(pin) when is_integer(pin) do
    GPIO.start_link(pin, :input)
  end

  @spec read(pid) :: boolean
  def read(pid) when is_pid(pid) do
    GPIO.read(pid) == 0
  end
end
