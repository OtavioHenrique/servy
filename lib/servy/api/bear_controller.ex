defmodule Servy.Api.BearController do
  def index(conv) do
    json =
      Servy.Wildthings.list_bears()
      |> Poison.encode!

    %{ conv | status: 200, resp_headers: %{"Content-Type" => "text/html"}, resp_body: json }
  end
end
