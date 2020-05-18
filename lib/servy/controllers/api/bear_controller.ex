defmodule Servy.Controllers.Api.BearController do
  def index(conv) do
    json =
      Servy.Context.Wildthings.list_bears()
      |> Poison.encode!

    %{ conv | status: 200, resp_headers: %{"Content-Type" => "application/json"}, resp_body: json }
  end
end
