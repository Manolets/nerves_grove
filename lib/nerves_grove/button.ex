# This is free and unencumbered software released into the public domain.

defmodule Nerves.Grove.Button do
  @moduledoc """
  Seeed Studio [Grove Button](http://wiki.seeedstudio.com/wiki/Grove_-_Button)

  # Example

      alias Nerves.Grove.Button

      {:ok, pid} = Button.start_link(pin)

      state = Button.read(pid)  # check if button is pressed
  """
  alias ElixirALE.GPIO

  @spec start_link(pos_integer) :: {:ok, pid} | {:error, any}
  def start_link(pin) do
    GPIO.start_link(pin, :input)
  end

  @spec read(pid) :: boolean
  def read(pid) do
    GPIO.read(pid) == 1
  end
end
