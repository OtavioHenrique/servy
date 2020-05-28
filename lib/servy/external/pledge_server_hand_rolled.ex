defmodule Servy.External.PledgeServerHandRolled do
  @process_name :pledge_server_hand_roll

  alias Servy.External.GenericServer

  def start do
    GenericServer.start(__MODULE__, [], @process_name)
  end

  def create_pledge(name, amount) do
    GenericServer.call(@process_name, {:create_pledge, name, amount})
  end

  def recent_pledges do
    GenericServer.call(@process_name, :recent_pledges)
  end

  def total_pledged do
    GenericServer.call(@process_name, :total_pledged)
  end

  def clear do
    GenericServer.cast(@process_name, :clear)
  end

  def handle_cast(:clear, _state) do
    []
  end

  def handle_call(:total_pledged, state) do
    total = Enum.map(state, &elem(&1, 1)) |> Enum.sum
    {total, state}
  end

  def handle_call(:recent_pledges, state) do
    {state, state}
  end

  def handle_call({:create_pledge, name, amount}, state) do
    {:ok, id} = send_pledge_to_service(name, amount)

    most_recent_pledges = Enum.take(state, 2)

    new_state = [ {name, amount} | most_recent_pledges ]

    {id, new_state}
  end

  def handle_info(other, state) do
    IO.puts "Unexpected message: #{inspect other}"
    state
  end

  defp send_pledge_to_service(_name, _amount) do
    {:ok, "pledge-#{:rand.uniform(100)}"}
  end
end
