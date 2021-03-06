defmodule Servy.Context.Bear do
  defstruct id: nil, name: "", type: "", hibernating: false

  def is_grizzly(bear) do
    bear.type == "Grizzly"
  end

  def order_asc_by_name(bear, bear2) do
    bear.name <= bear2.name
  end
end
