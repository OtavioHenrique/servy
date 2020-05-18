defmodule Servy.Controllers.Api.BearController do

  import Servy.Helpers.Common

  def index(conv) do
    json =
      Servy.Context.Wildthings.list_bears()
      |> Poison.encode!

    conv = put_header(conv, "Content-Type", "application/json")

    %{ conv | status: 200, resp_body: json }
  end
end
