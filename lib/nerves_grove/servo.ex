defmodule Nerves.Grove.Servo do
  @moduledoc """
   alias Pigpiox
   Nerves.Grove.Servo.move(18, 0)

  pin = 18

  delay1 = ((180 * 13.2) + 600) |> round()
  delay2 = 20000 - delay1

  pulses = [
      %Pigpiox.Waveform.Pulse{gpio_on: pin, delay: delay1},
      %Pigpiox.Waveform.Pulse{gpio_off: pin, delay: delay2}
    ]

    Pigpiox.Waveform.add_generic(pulses)

    {:ok, wave_id} = Pigpiox.Waveform.create()

    Pigpiox.GPIO.set_mode(pin, :output)

    Pigpiox.Waveform.repeat(wave_id)

   Pigpiox.Waveform.stop

  """


  alias Pigpiox

  def rotate(pin, angle) do
    delay1 = ((angle * 13.2) + 600) |> round()
    delay2 = 20000 - delay1
    pulses = [
      %Pigpiox.Waveform.Pulse{gpio_on: pin, delay: delay1},
      %Pigpiox.Waveform.Pulse{gpio_off: pin, delay: delay2}
    ]

    Pigpiox.Waveform.add_generic(pulses)

    {:ok, wave_id} = Pigpiox.Waveform.create()

    Pigpiox.GPIO.set_mode(pin, :output)

    Pigpiox.Waveform.repeat(wave_id)

  end

  def stop() do
    Pigpiox.Waveform.stop()
  end

end
