defmodule Nerves.Grove.MCP23017.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    children = [
      {Registry, keys: :unique, name: :chip_registry},
      worker(Nerves.Grove.MCP23017.Fns, [opts])
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
