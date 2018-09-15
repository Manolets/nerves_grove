defmodule Nerves.Grove.Lcd1602I2C.Server do
  use GenServer
  use Bitwise
  alias ElixirALE.I2C

  # Callbacks

  def init([bus, address, background]) do
    {:ok, display} = I2C.start_link(bus, address)
    send(self(), :initialize_display)
    {:ok, %{display: display, background: background}}
  end

  def handle_info(:initialize_display, %{display: display} = state) do
    # initialize to 8-line mode
    send_command(0x33, state)
    :timer.sleep(5)
    # initialize to 4-line mode
    send_command(0x32, state)
    :timer.sleep(5)
    # 2 lines of cells composed of 5*7 dots
    send_command(0x28, state)
    :timer.sleep(5)
    # enable display without cursor
    send_command(0x0C, state)
    :timer.sleep(5)
    # clear screen
    send_command(0x01, state)
    i2c_write(display, 0x08)
    {:noreply, state}
  end

  def handle_cast({:write, x, y, message}, state) do
    address = 0x80 + 0x40 * y + x
    send_command(address, state)

    message
    |> String.to_charlist()
    |> Enum.each(fn char ->
      send_data(char, state)
    end)

    {:noreply, state}
  end

  def handle_cast(:clear, state) do
    send_command(0x01, state)
  end

  # Private

  defp i2c_write(display, value) do
    I2C.write(display, <<value>>)
  end

  defp write_word(data, %{display: display, background: :light}) do
    i2c_write(display, data ||| 0x08)
  end

  defp write_word(data, %{display: display, background: :dark}) do
    i2c_write(display, data &&& 0xF7)
  end

  defp send_command(command, state) do
    # 0x04 -> RS = 0, RW = 0, EN = 1
    send_with_mask(command, 0x04, state)
  end

  defp send_data(data, state) do
    # 0x05 -> RS = 0, RW = 0, EN = 1
    send_with_mask(data, 0x05, state)
  end

  defp send_with_mask(data, mask, state) do
    # first send bits 7-4
    buffer = data &&& 0xF0
    buffer = buffer ||| mask
    write_word(buffer, state)
    :timer.sleep(2)
    # 0xFB -> EN = 0
    buffer = buffer &&& 0xFB
    write_word(buffer, state)

    # then send bits 3-0
    buffer = (data &&& 0x0F) <<< 4
    buffer = buffer ||| mask
    write_word(buffer, state)
    :timer.sleep(2)
    # 0xFB -> EN = 0
    buffer = buffer &&& 0xFB
    write_word(buffer, state)
  end
end
