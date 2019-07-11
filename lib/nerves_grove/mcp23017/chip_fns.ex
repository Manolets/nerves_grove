defmodule Nerves.Grove.MCP23017.Fns do
  require Logger

  @name :chip_server

  def start_link(opts) do
    GenServer.start_link(Nerves.Grove.MCP23017.Server, opts, name: via_tuple())
  end

  def via_tuple() do
    {:via, Registry, {:chip_registry, @name}}
  end

  def set_mode(pin, mode, pullUp \\ 'disable') do
      GenServer.cast(via_tuple(), {:set_mode, pin, mode, pullUp})
  end

  def output(pin, value) do
      GenServer.cast(via_tuple(), {:output, pin, value})
  end

  def input(pin) do
      GenServer.cast(via_tuple(), {:input, pin})
  end
end
