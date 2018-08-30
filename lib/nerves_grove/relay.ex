# This is free and unencumbered software released into the public domain.

defmodule Nerves.Grove.Relay do
  @moduledoc """
  Seeed Studio [Grove Relay](http://wiki.seeedstudio.com/wiki/Grove_-_Relay)

  # Example

      alias Nerves.Grove.Relay

      {:ok, pid} = Relay.start_link(pin)

      Relay.on(pid)   # start current flow
      Relay.off(pid)  # stop current flow
  """

  alias ElixirALE.GPIO

  @spec start_link(pos_integer) :: {:ok, pid} | {:error, any}
  def start_link(pin) do
    GPIO.start_link(pin, :output)
  end

  @doc "Switches on the relay, enabling current to flow."
  @spec on(pid) :: any
  def on(pid) do
    GPIO.write(pid, 1)
  end

  @doc "Switches off the relay, preventing current from flowing."
  @spec off(pid) :: any
  def off(pid) do
    GPIO.write(pid, 0)
  end
end
