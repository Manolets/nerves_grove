defmodule Nerves.Grove.Sensor.MotionSensor do
  alias Pigpiox.GPIO

  @moduledoc """
  Seeed Studio [Grove MotionSensor Sensor]
  # Example

      alias Nerves.Grove.Sensor.MotionSensor

      MotionSensor.read(17)


  """

  def read(pin) when is_integer(pin) do
    GPIO.set_mode(pin, :input)
    {:ok, output} = GPIO.read(pin)
    output == 1
  end
end
