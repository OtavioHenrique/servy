defmodule Servy.BearController do

  alias Servy.Wildthings
  alias Servy.Bear

  def index(conv) do
    bears = Wildthings.list_bears()
            |> Enum.filter(&Bear.is_grizzly(&1))
            |> Enum.sort(&Bear.order_asc_by_name(&1, &2))
            |> Enum.map(&bear_item(&1))
            |> Enum.join

    %{ conv | status: 200, resp_body: "<ul>#{bears}</ul>" }
  end

  def show(conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)

    %{ conv | status: 200, resp_body: "<h1>Bear #{bear.id} - #{bear.name}</h1>" }
  end

  def create(conv, %{ "type" => type, "name" => name }) do
    %{ conv | status: 201, resp_body: "Created a #{type} bear named #{name}" }
  end

  def delete(conv) do
    %{ conv | status: 403, resp_body: "Bears must never be deleted!"}
  end

  defp bear_item(bear) do
    "<li>#{bear.name} - #{bear.type}</li>"
  end
end
