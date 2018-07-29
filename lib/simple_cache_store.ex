defmodule SimpleCache.Store do
  @table_id __MODULE__

  def init do
    :ets.new(@table_id, [:public, :named_table])
    :ok
  end

  def insert(key, pid) do
    :ets.insert(@table_id, {key, pid})
  end

  def lookup(key) do
    :ets.lookup(@table_id, key)
    |> found_element
  end

  def delete(pid) do
    :ets.delete(@table_id, pid)
  end

  defp found_element([{_key, pid}]) do
    {:ok, pid}
  end

  defp found_element([]) do
    {:error, :not_found}
  end
end
