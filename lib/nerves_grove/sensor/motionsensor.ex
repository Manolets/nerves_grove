defmodule Nerves.Grove.Sensor.MotionSensor do
  alias Pigpiox.GPIO

  @moduledoc """
  Seeed Studio [Grove MotionSensor Sensor]
  # Example

      alias Nerves.Grove.Sensor

      sensor_pin = 18


  """

  def read(pin) when is_integer(pin) do
    GPIO.set_mode(pin, :input)
    output = GPIO.read(pin) |> elem(1)
    output
  end

end
