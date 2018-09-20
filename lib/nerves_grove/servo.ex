defmodule Nerves.Grove.Servo do
  @moduledoc """
   alias Pigpiox
   Nerves.Grove.Servo.rotate(18, 0)

  pin = 18

  delay1 = ((2000*180 / 180  ) + 600) |> round()
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

  require Logger
  alias Pigpiox

  def rotate(pin, angle) do
    Task.async(fn -> move(pin, angle) end)
    |> Task.await()
  end

  defp move(pin, angle) do
    delay1 = (2000 * angle / 180 + 600) |> round()
    delay2 = 20000 - delay1

    pulses = [
      %Pigpiox.Waveform.Pulse{gpio_on: pin, delay: delay1},
      %Pigpiox.Waveform.Pulse{gpio_off: pin, delay: delay2}
    ]

    with {:ok, wf_id} <- Pigpiox.Waveform.add_generic(pulses),
         {:ok, wave_id} <- Pigpiox.Waveform.create(),
         :ok <- Pigpiox.GPIO.set_mode(pin, :output),
         do: Pigpiox.Waveform.repeat(wave_id)

    Logger.debug("Pin introduced = #{inspect(pin)} ")
    Logger.debug("Pulses to output = #{inspect(pulses)} ")
    Process.sleep(20)
  end

  def stop() do
    Pigpiox.Waveform.stop()
  end
end
