# This is free and unencumbered software released into the public domain.

defmodule Nerves.Grove.Buzzer do
  @moduledoc """
  Seeed Studio [Grove Buzzer](http://wiki.seeedstudio.com/wiki/Grove_-_Buzzer)

  # Example

      alias Nerves.Grove.Buzzer

      {:ok, pid} = Buzzer.start_link(pin)

      Buzzer.beep(pid, 0.1)  # make some noise for 100 ms
  """
  alias Pigpiox.GPIO

  @doc "Beeps the buzzer for a specified duration."

  def beep(pin, duration \\ 0.1) do
    GPIO.set_mode(pin, :output)
    duration_in_ms = (duration * 1000) |> round
    on(pin)
    Process.sleep(duration_in_ms)
    off(pin)
  end

  @doc "Switches on the buzzer, making a lot of noise."

  def on(pin) do
    GPIO.write(pin, 1)
  end

  @doc "Switches off the buzzer, stopping the noise."

  def off(pin) do
    GPIO.write(pin, 0)
  end
end
