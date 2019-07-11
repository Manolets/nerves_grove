defmodule Nerves.Grove.MCP23017 do
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

  To test this module:

  handle = Nerves.Grove.MCP23017.init
  for pin <- 0..15 do
  Nerves.Grove.MCP23017.set_mode(handle, pin, :output, 'disable')
  Process.sleep(1)
  Nerves.Grove.MCP23017.output(handle, pin, 1)
  end
  """

  alias Pigpiox.I2C
  use Bitwise
  require Logger

  @mcp_addr 0x20
  @bank '16bit'

  def init(addr \\ @mcp_addr) do
    {:ok, handle} = I2C.open(1, addr)

    handle
  end

  @doc """
  single_access_read, function to read a single data register
  of the MCP230xx gpio expander 
  """
  def single_access_read(handle, reg \\ 0x00) do
    {:ok, dataTransfer} = I2C.read_byte_data(handle, reg)

    dataTransfer
  end

  @doc """
  single_access_write, function to write to a single data register
  of the MCP230xx gpio expander
  """
  def single_access_write(handle, reg \\ 0x00, regValue \\ 0x0) do
    I2C.write_byte_data(handle, reg, regValue)
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

    Logger.debug(
      "Outputting this info {#{inspect(reg)}, #{inspect(bit)}} from registr_bit_select "
    )

    {reg, bit}
  end

  @doc """
  interrupt_options, function to set the options for the 2 interrupt pins
  """
  def interrupt_options(handle, outputType \\ 'activehigh', bankControl \\ 'separate') do
    # self.bank = '8bit'
    reg =
      if @bank == '16bit' do
        reg = 0x0A
        reg
      else
        reg = 0x05
        reg
      end

    {odrBit, intpolBit} =
      case outputType do
        'activelow' ->
          odrBit = 0
          intpolBit = 0
          {odrBit, intpolBit}

        'opendrain' ->
          odrBit = 1
          intpolBit = 0
          {odrBit, intpolBit}

        _ ->
          odrBit = 0
          intpolBit = 1
          {odrBit, intpolBit}
      end

    # bankControl = 'separate'
    mirrorBit =
      if bankControl == 'both' do
        mirrorBit = 1
        mirrorBit
      else
        mirrorBit = 0
        mirrorBit
      end

    regValue = single_access_read(handle, reg)
    regValue = regValue &&& 0b10111001
    regValue = regValue ||| (mirrorBit <<< 6) + (odrBit <<< 2) + (intpolBit <<< 1)
    single_access_write(handle, reg, regValue)
  end

  @doc """
  set_register_addressing, function to change how the registers
  are mapped.  For an MCP23008, bank should always equal '8bit'.  This
  sets bit 7 of the IOCON register
  """

  def set_register_addressing(handle, regScheme \\ '8bit') do
    # self.bank = '8bit'
    reg =
      if @bank == '16bit' do
        reg = 0x0A
        reg
      else
        reg = 0x05
        reg
      end

    # regScheme = '8bit'
    bankBit =
      if regScheme == '16bit' do
        bankBit = 0
        @bank = '16bit'
        bankBit
      else
        bankBit = 1
        # @bank = '8bit'
        bankBit
      end

    regValue = single_access_read(handle, reg)
    regValue = regValue &&& 0b01111111
    regValue = regValue ||| bankBit <<< 7
    single_access_write(handle, reg, regValue)
  end

  @doc """
  set_mode, function to set up a GPIO pin to either an input
  or output. The input pullup resistor can also be enabled.
  This sets the appropriate bits in the IODIRA/B and GPPUA/B
  registers
  """
  def set_mode(handle, pin, mode, pullUp \\ 'disable') do
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

    Logger.debug("Ended set mode fn")
  end

  @doc """
  invert_input, function to invert the output of the pins
  corresponding GPIO register bit.  Sets bit in IPOLA/B
  """
  def invert_input(handle, pin, invert \\ False) do
    # input invert on/off section

    {reg, bit} = register_bit_select(handle, pin, 0x01, 0x02, 0x11, 0x03)

    regValue = single_access_read(handle, reg)

    # invert = False
    if invert == True do
      mask = 0x00 ||| 1 <<< bit
      regValue = regValue ||| mask
      single_access_write(handle, reg, regValue)
    else
      mask = 0b11111111 &&& ~~~(1 <<< bit)
      regValue = regValue &&& mask
      single_access_write(handle, reg, regValue)
    end
  end

  @doc """
  output, function to set the state of a GPIO output
  pin via the appropriate bit in the OLATA/B registers
  """
  def output(handle, pin, value) do
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
  end

  @doc """
  input, function to get the current level of a GPIO input
  pin by reading the appropriate bit in the GPIOA/B registers
  """
  def input(handle, pin) do
    {reg, bit} = register_bit_select(handle, pin, 0x09, 0x12, 0x19, 0x13)

    regValue = single_access_read(handle, reg)

    mask = 0x00 ||| 1 <<< bit
    value = regValue &&& mask
    value = value >>> bit

    value
  end

  @doc """
  input_at_interrupt, function to get the current level of a GPIO input
  pin when an interrupt has occurred by reading the appropriate bit in the
  INTCAPA/B registers
  """
  def input_at_interrupt(handle, pin) do
    {reg, bit} = register_bit_select(handle, pin, 0x08, 0x10, 0x18, 0x11)

    regValue = single_access_read(handle, reg)

    mask = 0x00 ||| 1 <<< bit
    value = regValue &&& mask
    value = value >>> bit

    value
  end

  @doc """
    add_interrupt, function to set up the interrupt options
    for a specific GPIO including callback functions to be executed
    when an interrupt occurs
  """
  def add_interrupt(handle, pin, _callbackFunctLow \\ 'empty', _callbackFunctHigh \\ 'empty') do
    # set bit in GPINTENA/B registers

    {reg, bit} = register_bit_select(handle, pin, 0x02, 0x04, 0x12, 0x05)

    regValue = single_access_read(handle, reg)
    mask = 0x00 ||| 1 <<< bit
    regValue = regValue ||| mask
    single_access_write(handle, reg, regValue)

    # set bit in INTCONA/B registers

    {reg, bit} = register_bit_select(handle, pin, 0x04, 0x08, 0x14, 0x09)

    regValue = single_access_read(handle, reg)
    mask = 0b11111111 &&& ~~~(1 <<< bit)
    regValue = regValue &&& mask
    single_access_write(handle, reg, regValue)

    # set bit in DEFVALA/B registers - not required    

    # set call back functions in function list
    # my cmmt# self.callBackFuncts[pin][0]=callbackFunctLow
    # my cmmt# self.callBackFuncts[pin][1]=callbackFunctHigh    
  end

  @doc """
  remove_interrupt, function to remove the interrupt settings
  from an MCP230xx pin
  """
  def remove_interrupt(handle, pin) do
    # set bit in GPINTENA/B registers

    {reg, bit} = register_bit_select(handle, pin, 0x02, 0x04, 0x12, 0x05)

    regValue = single_access_read(handle, reg)
    mask = 0b11111111 &&& ~~~(1 <<< bit)
    regValue = regValue &&& mask
    single_access_write(handle, reg, regValue)

    # reset call back functions in function list to 'empty'
    # my cmmt# self.callBackFuncts[pin][0]='empty'
    # my cmmt# self.callBackFuncts[pin][1]='empty'
  end

  @doc """
  function called by RPI.GPIO on an bank A interrupt condition.
      This function will figure out which MCP230xx pin caused the
      interrupt and initiate the appropriate callback function
  """
  def callbackA(handle, _gpio) do
    # read INTF register
    # self.bank = '8bit'
    reg =
      if @bank == '16bit' do
        reg = 0x0E
        reg
      else
        reg = 0x07
        reg
      end

    regValue = single_access_read(handle, reg)

    # pin = -1

    list =
      for i <- 0..8 do
        if regValue == 1 <<< i do
          pin = i
          pin
        end
      end

    list = Enum.filter(list, &(!is_nil(&1)))
    pin = List.first(list)
    value = input_at_interrupt(handle, pin)
    # Line to stop warning mine
    value
    # my cmmt#if self.callBackFuncts[pin][value] != 'empty':
    # my cmmt#   self.callBackFuncts[pin][value](pin)
  end

  @doc """
        function called by RPI.GPIO on an bank B interrupt condition.
        This function will figure out which MCP230xx pin caused the
        interrupt and initiate the appropriate callback function
  """
  def callbackB(handle, _gpio) do
    # read INTF register
    # self.bank = '8bit'
    reg =
      if @bank == '16bit' do
        reg = 0x0F
        reg
      else
        reg = 0x17
        reg
      end

    regValue = single_access_read(handle, reg)

    _pin = -1

    list =
      for i <- 0..8 do
        if regValue == 1 <<< i do
          pin = i + 8
          pin
        end
      end

    list = Enum.filter(list, &(!is_nil(&1)))
    pin = List.first(list)
    _value = input_at_interrupt(handle, pin)

    # my cmmt#if self.callBackFuncts[pin][value] != 'empty' do
    # my cmmt#    self.callBackFuncts[pin][value](pin)
  end

  @doc """
    function called by RPI.GPIO on either a bank A  or bank B
  interrupt condition. This function will figure out which MCP230xx
  pin caused the interrupt and initiate the appropriate callback function
  """
  def callbackBoth(handle, _gpio) do
    # read INTF register
    # self.bank = '8bit'
    {regA, regB} =
      if @bank == '16bit' do
        regA = 0x0E
        regB = 0x0F
        {regA, regB}
      else
        regA = 0x07
        regB = 0x17
        {regA, regB}
      end

    regValue = single_access_read(handle, regA)

    _pin = -1

    # check GPIOA bank for interrupt
    list =
      for i <- 0..8 do
        if regValue == 1 <<< i do
          pin = i
          pin
        end
      end

    list = Enum.filter(list, &(!is_nil(&1)))
    pin = List.first(list)

    # check GPIOB bank for interrupt if none found in GPIOA bank

    if pin == -1 do
      regValue = single_access_read(handle, regB)

      for i <- 0..8 do
        if regValue == 1 <<< i do
          pin = i + 8
          _value = input_at_interrupt(handle, pin)
        end
      end
    end

    if pin != -1 do
      _value = input_at_interrupt(handle, pin)
    end

    # my cmmt#if self.callBackFuncts[pin][value] != 'empty':
    # my cmmt#    self.callBackFuncts[pin][value](pin)
  end

  @doc """
        register_reset, function to put chip back to default
        settings
  """
  def register_reset(handle) do
    Logger.debug("Resetting chip and closing handle")

    # my cmmt#if self.chip == 'MCP23008' do
    # my cmmt#    self.single_access_write(0x00, 0xFF)
    # my cmmt#    for i in range(1, 12):
    # my cmmt#        self.single_access_write(i, 0x00)
    # my cmmt#else:
    set_register_addressing(handle, '16bit')
    single_access_write(handle, 0x00, 0xFF)
    single_access_write(handle, 0x01, 0xFF)

    for i <- 2..22 do
      single_access_write(handle, i, 0x00)
    end

    I2C.close(handle)
  end

  @doc """
  def __del__(self):
      ###__del__, function to clean up expander object and put chip
      back to default settings###

      #print('deleting')

      self.register_reset()

      return

  if __name__ == "__main__":

  import RPi.GPIO as IO
  import time, sys

  address = 0x21
  intPin = 5

  # set up GPIO settings
  IO.setwarnings(False)
  IO.setmode(IO.BCM)
  IO.setup(intPin,IO.IN, pull_up_down=IO.PUD_DOWN) # set intPin to input
      
  MCP = MCP230XX('MCP23017', address, '16bit')

  for i in range(0,22):
      print(hex(MCP.single_access_read(i)))

  def functA(pin):
      print('pin '+str(pin)+' interrupted...how rude')
      MCP.output(0, 1)
      return

  def functB(pin):
      print('pin '+str(pin)+' is going to sleep')
      MCP.output(0, 0)
      return

  # output tests

  MCP.set_mode(0, :output)
  MCP.output(0, 1)
  time.sleep(3)
  MCP.output(0, 0)    

  # input tests    

  MCP.set_mode(2, :input, 'enable') # was pin 2
  #MCP.invert_input(2, True)
  for i in range(0,10):
      print(MCP.input(2))
      time.sleep(0.5)
  #MCP.invert_input(2, False)

  # interrupt option tests
  MCP.interrupt_options(outputType = 'activehigh', bankControl = 'separate')
  MCP.set_mode(10,:input, 'enable')
  MCP.add_interrupt(10, callbackFunctLow=functA, callbackFunctHigh=functB)
  time.sleep(0.5)
  IO.add_event_detect(intPin,IO.RISING,callback=MCP.callbackB)

  try:
      while True:
          time.sleep(0.25)

  except:
      IO.cleanup()
      MCP.remove_interrupt(10)       
  finally:        
      MCP.__del__()        
  """
  def close_all(handle) do
    register_reset(handle)
  end
end
