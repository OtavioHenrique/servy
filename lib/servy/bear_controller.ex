defmodule Servy.BearController do

  alias Servy.Wildthings
  alias Servy.BearView
  alias Servy.Bear

  def index(conv) do
    bears = Wildthings.list_bears()
            |> Enum.sort(&Bear.order_asc_by_name(&1, &2))

    %{ conv | status: 200, resp_body: BearView.index(bears) }
  end

  def show(conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)

    %{ conv | status: 200, resp_body: BearView.show(bear) }
  end

  def create(conv, %{ "type" => type, "name" => name }) do
    %{ conv | status: 201, resp_body: "Created a #{type} bear named #{name}" }
  end

  def delete(conv) do
    %{ conv | status: 403, resp_body: "Bears must never be deleted!"}
  end
end
