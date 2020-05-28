defmodule PledgeServerHandRolled do
  use ExUnit.Case

  alias Servy.External.PledgeServerHandRolled

  test "pledge server" do
    PledgeServerHandRolled.start

    PledgeServerHandRolled.create_pledge("test1", 100)
    PledgeServerHandRolled.create_pledge("test2", 100)
    PledgeServerHandRolled.create_pledge("test3", 100)
    PledgeServerHandRolled.create_pledge("test4", 100)

    assert [{"test4", 100}, {"test3", 100}, {"test2", 100}] == PledgeServerHandRolled.recent_pledges
    assert 300 == PledgeServerHandRolled.total_pledged
  end
end
