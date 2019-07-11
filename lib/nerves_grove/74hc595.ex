defmodule Nerves.Grove.Chip_74hc595 do
  alias Pigpiox.GPIO
  use Bitwise
  require Logger

  @sdi 11
  @rclk 12
  @srclk 13

  # ===============   LED Mode Defne ================
  # 	You can define yourself, in binay, and convert it to Hex 
  # 	8 bits a group, 0 means off, 1 means on
  # 	like : 0101 0101, means LED1, 3, 5, 7 are on.(from left to right)
  # 	and convert to 0x55.

  # =================================================

  def setup() do
    GPIO.set_mode(@sdi, :output)
    GPIO.set_mode(@rclk, :output)
    GPIO.set_mode(@srclk, :output)
    GPIO.write(@sdi, 0)
    GPIO.write(@rclk, 0)
    GPIO.write(@srclk, 0)
  end

  def hc595_in(dat) do
    for bit <- 0..8 do
      input =
        if (0x80 &&& dat <<< bit) != 0 do
          1
        else
          0
        end

      GPIO.write(@sdi, input)
      Process.sleep(50)
      GPIO.write(@srclk, 1)
      Process.sleep(50)
      GPIO.write(@srclk, 0)
    end
  end

  def hc595_out() do
    GPIO.write(@rclk, 1)
    Process.sleep(50)
    GPIO.write(@rclk, 0)
  end

  def loop() do
    # original mode
    led0 = [0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80]
    # led1 = [0x01, 0x03, 0x07, 0x0f, 0x1f, 0x3f, 0x7f, 0xff]	#blink mode 1
    # led2 = [0x01, 0x05, 0x15, 0x55, 0xb5, 0xf5, 0xfb, 0xff]	#blink mode 2
    # led3 = [0x02, 0x03, 0x0b, 0x0f, 0x2f, 0x3f, 0xbf, 0xff]	#blink mode 3

    # Change Mode, modes from LED0 to LED3
    which_leds = led0
    # Change speed, lower value, faster speed
    sleeptime = 50

    for i <- 0..length(which_leds) do
      hc595_in(i)
      hc595_out()
      Process.sleep(sleeptime)
    end

    for i <- (length(which_leds) - 1)..-1 do
      hc595_in(i)
      hc595_out()
      Process.sleep(sleeptime)
    end

    loop()
  end
end
