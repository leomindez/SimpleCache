defmodule SimpleCache.Application do
  use Application

  def start(_type, _args) do
    init_store_db()

    children = [
      {SimpleCache.Supervisor, []}
    ]

    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)
  end

  defp init_store_db() do
    SimpleCache.Store.init()
  end
end
