defmodule SimpleCache do
  def insert(key, value) do
    insert_new_value(key, value, SimpleCache.Store.lookup(key))
  end

  def lookup(key) do
    {:ok, pid} = SimpleCache.Store.lookup(key)
    {:ok, value} = SimpleCache.Element.fetch(pid)
    {:ok, value}
  end

  def delete(key) do
    SimpleCache.Store.lookup(key)
    |> delete_value
  end

  defp delete_value({:ok, pid}) do
    SimpleCache.Element.delete(pid)
  end

  defp delete_value({:error, _reason}) do
    :ok
  end

  defp insert_new_value(_key, value, {:ok, pid}) do
    SimpleCache.Element.replace(pid, value)
  end

  defp insert_new_value(key, value, {:error, _}) do
    {:ok, pid} = SimpleCache.Element.create(value)
    SimpleCache.Store.insert(key, pid)
  end
end
