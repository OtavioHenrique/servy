defmodule Servy.External.FourOhFourCounter do
  @process_name :four_oh_four_counter

  use GenServer

  def start do
    GenServer.start(__MODULE__, %{}, name: @process_name)
  end

  def bump_count(route) do
    GenServer.cast(@process_name, {:bump_counter, route})
  end

  def get_count(route) do
    GenServer.call(@process_name, {:count_route, route})
  end

  def get_counts do
    GenServer.call(@process_name, :get_counts)
  end

  def handle_cast({:bump_counter, route}, counter) do
    {:noreply, Map.update(counter, route, 1, &(&1 + 1))}
  end

  def handle_call(:get_counts, _from, counter), do: {:reply, counter, counter}

  def handle_call({:count_route, route}, _from, counter), do: { :reply, Map.get(counter, route, 0), counter}
end
