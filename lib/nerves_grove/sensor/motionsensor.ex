defmodule Grove_sensor_alarm do

  alias ElixirALE.GPIO

  def setup() do
  GPIO.setmode(GPIO.BCM)

  GPIO.setup(23, GPIO.IN) #PIR
  GPIO.setup(24, GPIO.OUT) #Buzzer
end


  def start_alarm do
      try do
        {time, res} = :timer.tc fn -> :timer.sleep(1) end
        if GPIO.input(23) do
          GPIO.output(24, true)
          {time, res} = :timer.tc fn -> :timer.sleep(0.5) end #Buzzer turns on for 0.5 secs
          GPIO.output(24, false)
          IO.puts("Motion detected...")
          {time, res} = :timer.tc fn -> :timer.sleep(5) end#To avoid multipe detection
        end
      {time, res} = :timer.tc fn -> :timer.sleep(0.1) end#Loop delay
      catch
      :exit, _ -> "not really"
      end



  end

end
