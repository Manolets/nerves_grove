# This is free and unencumbered software released into the public domain.

defmodule Nerves.Grove.OLED.Display do
  @moduledoc """
  http://wiki.seeedstudio.com/wiki/Grove_-_OLED_Display_1.12%22
  http://garden.seeedstudio.com/images/8/82/SSD1327_datasheet.pdf
  """

  @default_address 0x3C
  @command_mode    0x80
  @data_mode       0x40

  # 8x8 monochrome bitmap font for ASCII code points 32-128.
  @default_font \
    {{0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00},
     {0x00,0x00,0x5F,0x00,0x00,0x00,0x00,0x00},
     {0x00,0x00,0x07,0x00,0x07,0x00,0x00,0x00},
     {0x00,0x14,0x7F,0x14,0x7F,0x14,0x00,0x00},
     {0x00,0x24,0x2A,0x7F,0x2A,0x12,0x00,0x00},
     {0x00,0x23,0x13,0x08,0x64,0x62,0x00,0x00},
     {0x00,0x36,0x49,0x55,0x22,0x50,0x00,0x00},
     {0x00,0x00,0x05,0x03,0x00,0x00,0x00,0x00},
     {0x00,0x1C,0x22,0x41,0x00,0x00,0x00,0x00},
     {0x00,0x41,0x22,0x1C,0x00,0x00,0x00,0x00},
     {0x00,0x08,0x2A,0x1C,0x2A,0x08,0x00,0x00},
     {0x00,0x08,0x08,0x3E,0x08,0x08,0x00,0x00},
     {0x00,0xA0,0x60,0x00,0x00,0x00,0x00,0x00},
     {0x00,0x08,0x08,0x08,0x08,0x08,0x00,0x00},
     {0x00,0x60,0x60,0x00,0x00,0x00,0x00,0x00},
     {0x00,0x20,0x10,0x08,0x04,0x02,0x00,0x00},
     {0x00,0x3E,0x51,0x49,0x45,0x3E,0x00,0x00},
     {0x00,0x00,0x42,0x7F,0x40,0x00,0x00,0x00},
     {0x00,0x62,0x51,0x49,0x49,0x46,0x00,0x00},
     {0x00,0x22,0x41,0x49,0x49,0x36,0x00,0x00},
     {0x00,0x18,0x14,0x12,0x7F,0x10,0x00,0x00},
     {0x00,0x27,0x45,0x45,0x45,0x39,0x00,0x00},
     {0x00,0x3C,0x4A,0x49,0x49,0x30,0x00,0x00},
     {0x00,0x01,0x71,0x09,0x05,0x03,0x00,0x00},
     {0x00,0x36,0x49,0x49,0x49,0x36,0x00,0x00},
     {0x00,0x06,0x49,0x49,0x29,0x1E,0x00,0x00},
     {0x00,0x00,0x36,0x36,0x00,0x00,0x00,0x00},
     {0x00,0x00,0xAC,0x6C,0x00,0x00,0x00,0x00},
     {0x00,0x08,0x14,0x22,0x41,0x00,0x00,0x00},
     {0x00,0x14,0x14,0x14,0x14,0x14,0x00,0x00},
     {0x00,0x41,0x22,0x14,0x08,0x00,0x00,0x00},
     {0x00,0x02,0x01,0x51,0x09,0x06,0x00,0x00},
     {0x00,0x32,0x49,0x79,0x41,0x3E,0x00,0x00},
     {0x00,0x7E,0x09,0x09,0x09,0x7E,0x00,0x00},
     {0x00,0x7F,0x49,0x49,0x49,0x36,0x00,0x00},
     {0x00,0x3E,0x41,0x41,0x41,0x22,0x00,0x00},
     {0x00,0x7F,0x41,0x41,0x22,0x1C,0x00,0x00},
     {0x00,0x7F,0x49,0x49,0x49,0x41,0x00,0x00},
     {0x00,0x7F,0x09,0x09,0x09,0x01,0x00,0x00},
     {0x00,0x3E,0x41,0x41,0x51,0x72,0x00,0x00},
     {0x00,0x7F,0x08,0x08,0x08,0x7F,0x00,0x00},
     {0x00,0x41,0x7F,0x41,0x00,0x00,0x00,0x00},
     {0x00,0x20,0x40,0x41,0x3F,0x01,0x00,0x00},
     {0x00,0x7F,0x08,0x14,0x22,0x41,0x00,0x00},
     {0x00,0x7F,0x40,0x40,0x40,0x40,0x00,0x00},
     {0x00,0x7F,0x02,0x0C,0x02,0x7F,0x00,0x00},
     {0x00,0x7F,0x04,0x08,0x10,0x7F,0x00,0x00},
     {0x00,0x3E,0x41,0x41,0x41,0x3E,0x00,0x00},
     {0x00,0x7F,0x09,0x09,0x09,0x06,0x00,0x00},
     {0x00,0x3E,0x41,0x51,0x21,0x5E,0x00,0x00},
     {0x00,0x7F,0x09,0x19,0x29,0x46,0x00,0x00},
     {0x00,0x26,0x49,0x49,0x49,0x32,0x00,0x00},
     {0x00,0x01,0x01,0x7F,0x01,0x01,0x00,0x00},
     {0x00,0x3F,0x40,0x40,0x40,0x3F,0x00,0x00},
     {0x00,0x1F,0x20,0x40,0x20,0x1F,0x00,0x00},
     {0x00,0x3F,0x40,0x38,0x40,0x3F,0x00,0x00},
     {0x00,0x63,0x14,0x08,0x14,0x63,0x00,0x00},
     {0x00,0x03,0x04,0x78,0x04,0x03,0x00,0x00},
     {0x00,0x61,0x51,0x49,0x45,0x43,0x00,0x00},
     {0x00,0x7F,0x41,0x41,0x00,0x00,0x00,0x00},
     {0x00,0x02,0x04,0x08,0x10,0x20,0x00,0x00},
     {0x00,0x41,0x41,0x7F,0x00,0x00,0x00,0x00},
     {0x00,0x04,0x02,0x01,0x02,0x04,0x00,0x00},
     {0x00,0x80,0x80,0x80,0x80,0x80,0x00,0x00},
     {0x00,0x01,0x02,0x04,0x00,0x00,0x00,0x00},
     {0x00,0x20,0x54,0x54,0x54,0x78,0x00,0x00},
     {0x00,0x7F,0x48,0x44,0x44,0x38,0x00,0x00},
     {0x00,0x38,0x44,0x44,0x28,0x00,0x00,0x00},
     {0x00,0x38,0x44,0x44,0x48,0x7F,0x00,0x00},
     {0x00,0x38,0x54,0x54,0x54,0x18,0x00,0x00},
     {0x00,0x08,0x7E,0x09,0x02,0x00,0x00,0x00},
     {0x00,0x18,0xA4,0xA4,0xA4,0x7C,0x00,0x00},
     {0x00,0x7F,0x08,0x04,0x04,0x78,0x00,0x00},
     {0x00,0x00,0x7D,0x00,0x00,0x00,0x00,0x00},
     {0x00,0x80,0x84,0x7D,0x00,0x00,0x00,0x00},
     {0x00,0x7F,0x10,0x28,0x44,0x00,0x00,0x00},
     {0x00,0x41,0x7F,0x40,0x00,0x00,0x00,0x00},
     {0x00,0x7C,0x04,0x18,0x04,0x78,0x00,0x00},
     {0x00,0x7C,0x08,0x04,0x7C,0x00,0x00,0x00},
     {0x00,0x38,0x44,0x44,0x38,0x00,0x00,0x00},
     {0x00,0xFC,0x24,0x24,0x18,0x00,0x00,0x00},
     {0x00,0x18,0x24,0x24,0xFC,0x00,0x00,0x00},
     {0x00,0x00,0x7C,0x08,0x04,0x00,0x00,0x00},
     {0x00,0x48,0x54,0x54,0x24,0x00,0x00,0x00},
     {0x00,0x04,0x7F,0x44,0x00,0x00,0x00,0x00},
     {0x00,0x3C,0x40,0x40,0x7C,0x00,0x00,0x00},
     {0x00,0x1C,0x20,0x40,0x20,0x1C,0x00,0x00},
     {0x00,0x3C,0x40,0x30,0x40,0x3C,0x00,0x00},
     {0x00,0x44,0x28,0x10,0x28,0x44,0x00,0x00},
     {0x00,0x1C,0xA0,0xA0,0x7C,0x00,0x00,0x00},
     {0x00,0x44,0x64,0x54,0x4C,0x44,0x00,0x00},
     {0x00,0x08,0x36,0x41,0x00,0x00,0x00,0x00},
     {0x00,0x00,0x7F,0x00,0x00,0x00,0x00,0x00},
     {0x00,0x41,0x36,0x08,0x00,0x00,0x00,0x00},
     {0x00,0x02,0x01,0x01,0x02,0x01,0x00,0x00},
     {0x00,0x02,0x05,0x05,0x02,0x00,0x00,0x00}}

  @spec start_link(byte) :: {:ok, pid} | {:error, any}
  def start_link(address \\ @default_address) do
    I2c.start_link("i2c-2", address)
  end

  @spec reset(pid) :: :ok
  def reset(pid) do
    send_commands(pid, <<0xFD, 0x12>>)
    off(pid)
    set_multiplex_ratio(pid, 95) # 96
    set_start_line(pid, 0)
    set_display_offset(pid, 96)
    set_vertical_mode(pid)
    send_commands(pid, <<0xAB, 0x01>>)
    set_contrast_level(pid, 0x53) # 100 nit
    send_commands(pid, <<0xB1, 0x51>>)
    send_commands(pid, <<0xB3, 0x01>>)
    send_commands(pid, <<0xB9>>)
    send_commands(pid, <<0xBC, 0x08>>)
    send_commands(pid, <<0xBE, 0x07>>)
    send_commands(pid, <<0xB6, 0x01>>)
    send_commands(pid, <<0xD5, 0x62>>)
    set_normal_mode(pid)
    set_activate_scroll(pid, false)
    on(pid)
    :timer.sleep(100) # ms
    set_row_address(pid, 0, 95)
    set_column_address(pid, 8, 8 + 47)
  end

  @spec on(pid) :: :ok
  def on(pid) do
    send_command(pid, 0xAF)
  end

  @spec off(pid) :: :ok
  def off(pid) do
    send_command(pid, 0xAE)
  end

  @spec set_column_address(pid, byte, byte) :: :ok
  def set_column_address(pid, start, end_) do
    send_commands(pid, <<0x15, start, end_>>)
  end

  @spec set_row_address(pid, byte, byte) :: :ok
  def set_row_address(pid, start, end_) do
    send_commands(pid, <<0x75, start, end_>>)
  end

  @spec set_contrast_level(pid, byte) :: :ok
  def set_contrast_level(pid, level) do
    send_commands(pid, <<0x81, level>>)
  end

  @spec set_horizontal_mode(pid) :: :ok
  def set_horizontal_mode(pid) do
    send_commands(pid, <<0xA0, 0x42>>)
    set_row_address(pid, 0, 95)
    set_column_address(pid, 8, 8 + 47)
  end

  @spec set_vertical_mode(pid) :: :ok
  def set_vertical_mode(pid) do
    send_commands(pid, <<0xA0, 0x46>>)
  end

  @spec set_start_line(pid, 0..127) :: :ok
  def set_start_line(pid, row) do
    send_commands(pid, <<0xA1, row>>)
  end

  @spec set_display_offset(pid, 0..127) :: :ok
  def set_display_offset(pid, row) do
    send_commands(pid, <<0xA2, row>>)
  end

  @spec set_normal_mode(pid) :: :ok
  def set_normal_mode(pid) do
    send_command(pid, 0xA4)
  end

  @spec set_inverse_mode(pid) :: :ok
  def set_inverse_mode(pid) do
    send_command(pid, 0xA7)
  end

  @spec set_multiplex_ratio(pid, 16..128) :: :ok
  def set_multiplex_ratio(pid, ratio) do
    send_commands(pid, <<0xA8, ratio>>)
  end

  @spec set_activate_scroll(pid, false) :: :ok
  def set_activate_scroll(pid, false) do
    send_command(pid, 0x2E)
  end

  @spec set_activate_scroll(pid, true) :: :ok
  def set_activate_scroll(pid, true) do
    send_command(pid, 0x2F)
  end

  @spec clear(pid, byte) :: :ok
  def clear(pid, color \\ 0x00) do
    (1..(96 * 48)) |> Enum.each(fn _ -> send_data(pid, color) end)
  end

  @spec send_commands(pid, <<>>) :: :ok
  defp send_commands(_pid, <<>>), do: nil

  @spec send_commands(pid, binary) :: :ok
  defp send_commands(pid, <<head, rest :: binary>>) do
    send_command(pid, head)
    send_commands(pid, rest)
  end

  @spec send_command(pid, byte) :: :ok
  defp send_command(pid, command) do
    I2c.write(pid, <<@command_mode, command>>)
  end

  @spec send_data(pid, byte) :: :ok
  defp send_data(pid, data) do
    I2c.write(pid, <<@data_mode, data>>)
  end
end
