defmodule Servy.External.PledgeServer do
  @process_name :pledge_server

  use GenServer

  defmodule State do
    defstruct cache_size: 3, pledges: []
  end

  def start do
    GenServer.start(__MODULE__, %State{}, name: @process_name)
  end

  def create_pledge(name, amount) do
    GenServer.call(@process_name, {:create_pledge, name, amount})
  end

  def recent_pledges do
    GenServer.call(@process_name, :recent_pledges)
  end

  def total_pledged do
    GenServer.call(@process_name, :total_pledged)
  end

  def clear do
    GenServer.cast(@process_name, :clear)
  end

  def set_cache_size(size) do
    GenServer.cast(@process_name, {:set_cache_size, size})
  end

  def init(state) do
    recent_pledges = fetch_recent_pledges_from_service
    {:ok, %State{ state | pledges: recent_pledges }}
  end

  def handle_cast(:clear, state) do
    {:noreply, %{ state | pledges: [] }}
  end

  def handle_cast({:set_cache_size, size}, state) do
    {:noreply, %State{ state | cache_size: size }}
  end

  def handle_call(:total_pledged, _from, state) do
    total = Enum.map(state.pledges, &elem(&1, 1)) |> Enum.sum
    {:reply, total, state}
  end

  def handle_call(:recent_pledges, _from, state) do
    {:reply, state.pledges, state}
  end

  def handle_call({:create_pledge, name, amount}, _from, state) do
    {:ok, id} = send_pledge_to_service(name, amount)

    most_recent_pledges = Enum.take(state.pledges, state.cache_size - 1)

    cached_pledges = [ {name, amount} | most_recent_pledges ]

    {:reply, id, %State{ state | pledges: cached_pledges }}
  end

  def handle_info(message, state) do
    IO.puts "Can't toutch this! #{inspect state}"
    {:noreply, state}
  end

  defp send_pledge_to_service(_name, _amount) do
    {:ok, "pledge-#{:rand.uniform(100)}"}
  end

  defp fetch_recent_pledges_from_service do
    [ {"wilma", 15}, {"fred", 25} ]
  end
end
