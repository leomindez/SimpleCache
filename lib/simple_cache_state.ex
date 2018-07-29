defmodule SimpleCache.State do
  defstruct value: nil, lease_time: 0, start_time: 0
end
