defmodule SimpleCache.Element do
  use GenServer
  @default_lease_time 60 * 60 * 24

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(value: value, lease_time: lease_time) do
    start_time =
      :calendar.local_time()
      |> :calendar.datetime_to_gregorian_seconds()

    {:ok, %SimpleCache.State{value: value, lease_time: lease_time, start_time: start_time},
     time_left(start_time, lease_time)}
  end

  defp time_left(_start_time, :infinity) do
    :infinity
  end

  defp time_left(start_time, lease_time) do
    current_time =
      :calendar.local_time()
      |> :calendar.datetime_to_gregorian_seconds()

    time_elapsed(lease_time - (current_time - start_time))
  end

  defp time_elapsed(time) when time <= 0, do: 0
  defp time_elapsed(time), do: time * 1000

  def create(value, lease_time \\ @default_lease_time) do
    SimpleCache.Supervisor.start_child(value, lease_time)
  end

  def fetch(pid) do
    GenServer.call(pid, :fetch)
  end

  def replace(pid, value) do
    GenServer.cast(pid, {:replace, value})
  end

  def delete(pid) do
    GenServer.cast(pid, :delete)
  end

  def handle_call(:fetch, _from, state) do
    %SimpleCache.State{value: value, lease_time: lease_time, start_time: start_time} = state
    time_left = time_left(start_time, lease_time)
    {:reply, {:ok, value}, state, time_left}
  end

  def handle_cast({:replace, value}, state) do
    %SimpleCache.State{lease_time: lease_time, start_time: start_time} = state
    time_left = time_left(start_time, lease_time)
    {:noreply, %SimpleCache.State{state | value: value}, time_left}
  end

  def handle_cast(:delete, state) do
    {:stop, :normal, state}
  end

  def handle_info(:timeout, state) do
    {:stop, :normal, state}
  end

  def terminate(_reason, _state) do
    SimpleCache.Store.delete(self())
    :ok
  end
end
