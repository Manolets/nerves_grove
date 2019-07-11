defmodule Nerves.Grove.MCP23017.Server do
  @moduledoc """
  Depending on the grounded pins the chip will have one or other address:

  A2    A1    A0      Hex addr
  GND   GND   GND     0x20
  GND   GND   3.3V    0x21
  GND   3.3V  GND     0x22
  GND   3.3V  3.3V    0x23
  3.3V  GND   GND     0x24
  3.3V  GND   3.3V    0x25
  3.3V  3.3V  GND     0x26
  3.3V  3.3V  3.3V    0x27

  To test the module try:
  Nerves.Grove.MCP23017.Supervisor.start_link(0x20)
  Nerves.Grove.MCP23017.Fns.set_mode(0, :output)
  Nerves.Grove.MCP23017.Fns.output(0, 1)
  """

  use GenServer
  require Logger
  use Bitwise
  alias Pigpiox.I2C

  @bank '16bit'

  def init(addr \\ 0x20) do
    {:ok, handle} = I2C.open(1, addr)
    state = %{handle: handle}
    {:ok, state}
  end

  @doc """
  This fns are to read from the chip, the need for two fns comes 
  from the problem that sometimes the read as well as the write fails
  """
  def single_access_read(handle, reg \\ 0x00) do
    try_read(handle, reg, self())
    data = 
    receive do
        {:success_read, value} ->
            value
    end
    
    data
  end

  def try_read(handle, reg, pid) do
    {validation, dataTransfer} = I2C.read_byte_data(handle, reg)
    if validation == :ok do
        Process.send(pid, {:success_read, dataTransfer}, [:nosuspend])
    else
        try_read(handle, reg, pid)
    end
  end

  @doc """
  This functions are to write into the chip
  """
  def single_access_write(handle, reg \\ 0x00, regValue \\ 0x0) do
    validation = I2C.write_byte_data(handle, reg, regValue)
    if validation == :ok do
        :ok
    else
        single_access_write(handle, reg, regValue)
    end
  end

  @doc """
  register_bit_select,  function to return the proper
  register and bit position to use for a particular GPIO
  and GPIO function
  """

  def register_bit_select(_handle, pin, reg8A, reg16A, reg8B, reg16B) do
    # need to add way of throwing an error if pin is outside
    # of 0-15 range

    {reg, bit} =
      if pin >= 0 && pin < 8 do
        bit = pin
        # self.bank = '8bit'
        reg =
          if @bank == '16bit' do
            reg = reg16A
            reg
          else
            reg = reg8A
            reg
          end

        {reg, bit}
      else
        bit = pin - 8
        # self.bank = '8bit'
        reg =
          if @bank == '16bit' do
            reg = reg16B
            reg
          else
            reg = reg8B
            reg
          end

        {reg, bit}

        {reg, bit}
      end


    {reg, bit}
  end


  @doc """
  set_mode, function to set up a GPIO pin to either an input
  or output. The input pullup resistor can also be enabled.
  This sets the appropriate bits in the IODIRA/B and GPPUA/B
  registers
  """
  def handle_cast({:set_mode, pin, mode, pullUp}, state) do
    handle = state.handle
    # GPIO direction set up section
    Logger.debug("Got to set mode fn")
    {reg, bit} = register_bit_select(handle, pin, 0x00, 0x00, 0x10, 0x01)

    modreg =
      if reg == 0x0 do
        0x00
      else
        reg
      end

    {:ok, regValue} = I2C.read_byte_data(handle, modreg)
    # regValue = single_access_read(handle, modreg)

    # mode = input
    if mode == :output do
      mask = 0b11111111 &&& ~~~(1 <<< bit)
      regValue = regValue &&& mask
      single_access_write(handle, reg, regValue)
    else
      mask = 0x00 ||| 1 <<< bit
      regValue = regValue ||| mask
      single_access_write(handle, reg, regValue)
    end

    # pullUp enable/disable section

    if mode == :input do
      {reg, bit} = register_bit_select(handle, pin, 0x06, 0x0C, 0x16, 0x0D)
      {:ok, regValue} = I2C.read_byte_data(handle, reg)
      # regValue = single_access_read(handle, reg)

      # pullUp = disable
      if pullUp == 'enable' do
        mask = 0x00 ||| 1 <<< bit
        regValue = regValue ||| mask
        single_access_write(handle, reg, regValue)
      else
        mask = 0b11111111 &&& ~~~(1 <<< bit)
        regValue = regValue &&& mask
        single_access_write(handle, reg, regValue)
      end
    end

    {:noreply, state}
  end


  @doc """
  output, function to set the state of a GPIO output
  pin via the appropriate bit in the OLATA/B registers
  """
  def handle_cast({:output, pin, value}, state) do
    handle = state.handle
    Logger.debug("Got to output fn")
    {reg, bit} = register_bit_select(handle, pin, 0x0A, 0x14, 0x1A, 0x15)

    regValue = single_access_read(handle, reg)

    regValue =
      if value == 1 do
        # set output high        
        mask = 0x00 ||| 1 <<< bit
        regValue = regValue ||| mask
        regValue
      else
        # set output low
        mask = 0b11111111 &&& ~~~(1 <<< bit)
        regValue = regValue &&& mask
        regValue
      end

    single_access_write(handle, reg, regValue)
    {:noreply, state}
  end

  @doc """
  input, function to get the current level of a GPIO input
  pin by reading the appropriate bit in the GPIOA/B registers
  """
  def handle_cast({:input, pin}, state) do
    handle = state.handle
    {reg, bit} = register_bit_select(handle, pin, 0x09, 0x12, 0x19, 0x13)

    regValue = single_access_read(handle, reg)

    mask = 0x00 ||| 1 <<< bit
    value = regValue &&& mask
    value = value >>> bit

    Logger.debug("Got this output: #{inspect(value)}, on pin #{inspect(pin)} ")

    {:noreply, state}
  end
  
end
