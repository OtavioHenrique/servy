defmodule PledgeServer do
  use ExUnit.Case

  alias Servy.External.PledgeServer

  test "pledge server" do
    {:ok, pid} = PledgeServer.start

    PledgeServer.create_pledge("test1", 100)
    PledgeServer.create_pledge("test2", 100)
    PledgeServer.create_pledge("test3", 100)
    PledgeServer.create_pledge("test4", 100)

    assert [{"test4", 100}, {"test3", 100}, {"test2", 100}] == PledgeServer.recent_pledges
    assert 300 == PledgeServer.total_pledged
  end
end
