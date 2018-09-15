defmodule Nerves.Grove.Lcd1602I2C do
  @moduledoc """
  LCD1602 display I2c controller with OTP GenServer in Elixir
  https://www.embeddedadventures.com/datasheets/LCD-1602_hw_v1_doc_v1.pdf
  """

  import Nerves.Grove.Lcd1602I2C.Impl

  def start_link(_type, _args) do
    start_link(["i2c-1", 0x27, :light])
    {:ok, self()}
  end

  def write_lcd(x, y, message) do
    write(x, y, message)
  end

  def clear_lcd do
    clear()
  end

  def test do
    write_lcd(4, 0, "Hello")
    write_lcd(7, 1, "world!")
  end
end
