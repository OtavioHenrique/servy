defmodule Servy.Controllers.Api.BearController do

  import Servy.Helpers.Common

  def index(conv) do
    json =
      Servy.Context.Wildthings.list_bears()
      |> Poison.encode!

    conv = put_header(conv, "Content-Type", "application/json")

    %{ conv | status: 200, resp_body: json }
  end

  def create(conv, %{ "type" => type, "name" => name }) do
    response =
      %{ "response": "Created a #{type} bear named #{name}!" }
      |> Poison.encode!

    %{ conv | status: 201, resp_headers: %{"Content-Type" => "application/json"}, resp_body: response }
  end
end
