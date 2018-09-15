defmodule Nerves.Grove.Lcd1602I2C.Impl do
  # API
  def start_link([bus, address, background]) do
    GenServer.start_link(
      __MODULE__,
      [bus, address, background],
      name: __MODULE__
    )
  end

  def clear do
    GenServer.cast(__MODULE__, :clear)
  end

  def write(x, y, message) when x < 0, do: write(0, y, message)
  def write(x, y, message) when x > 15, do: write(15, y, message)
  def write(x, y, message) when y < 0, do: write(x, 0, message)
  def write(x, y, message) when y > 1, do: write(x, 1, message)

  def write(x, y, message) do
    GenServer.cast(__MODULE__, {:write, x, y, message})
  end
end
