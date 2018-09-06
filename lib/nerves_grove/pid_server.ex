defmodule Nerves.Grove.PidServer do
  use Agent
  require Logger

  def start_link(_) do
    Agent.start_link(fn -> Map.new() end, name: __MODULE__)
  end

  def put_pids(key, value) do
    Agent.update(__MODULE__, &map_put(&1, key, value))
  end

  def take_pids(key) do
    Agent.get(__MODULE__, &map_get(&1, key))
  end

  defp map_get(map, key) do
    value = Map.get(map, key)
    Logger.debug(" Value #{inspect(value)} from key #{inspect(key)}")
    value
  end

  defp map_put(map, key, value) do
    result = Map.put(map, key, value)
    Logger.debug(" Value #{inspect(value)} added to key #{inspect(key)}")
    result
  end
end
