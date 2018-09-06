defmodule Nerves.Grove.PidServer do
  use Agent
  require Logger

  def start_link(_) do
    Agent.start_link(fn -> Map.new() end, name: __MODULE__)
  end

  @doc "Add named struct"
  def put_pids(key, value) do
    Agent.update(__MODULE__, &Map.put(&1, key, value))
  end

  def take_pids(key) do
    Agent.get(__MODULE__, &Map.get(&1, key))
  end
end
