defmodule SimpleCache.Supervisor do
  use DynamicSupervisor

  @moduledoc """
    Dynamic Supervisor to start a simple cache element dinamically
  """

  def start_link(args) do
    DynamicSupervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def start_child(value, lease_time) do
    spec = {SimpleCache.Element, value: value, lease_time: lease_time}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  @impl true
  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
