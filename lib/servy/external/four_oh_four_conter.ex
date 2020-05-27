defmodule Servy.External.FourOhFourCounter do
  @process_name :four_oh_four_counter

  alias Servy.External.GenericServer

  def start do
    GenericServer.start(__MODULE__, %{}, @process_name)
  end

  def bump_count(route) do
    GenericServer.cast(@process_name, {:bump_counter, route})
  end

  def get_count(route) do
    GenericServer.call(@process_name, {:count_route, route})
  end

  def get_counts do
    GenericServer.call(@process_name, :get_counts)
  end

  def handle_cast({:bump_counter, route}, counter) do
    Map.update(counter, route, 1, &(&1 + 1))
  end

  def handle_call(:get_counts, counter), do: {counter, counter}

  def handle_call({:count_route, route}, counter), do: { Map.get(counter, route, 0), counter}
end
