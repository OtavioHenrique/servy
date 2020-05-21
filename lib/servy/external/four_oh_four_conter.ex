defmodule Servy.External.FourOhFourCounter do
  @process_name :four_oh_four_counter

  def start do
    pid = spawn(__MODULE__, :loop_state, [%{}])
    Process.register(pid, @process_name)
    pid
  end

  def bump_count(route) do
    send(@process_name, {self(), :bump_counter, route})

    receive do {:result, _state} -> :ok end
  end

  def get_count(route) do
    send(@process_name, {self(), :count_route, route})

    receive do {:result, count} -> count end
  end

  def get_counts do
    send(@process_name, {self(), :get_counts})

    receive do {:result, counts} -> counts end
  end

  def loop_state(counter) do
    receive do
      {sender, :bump_counter, route} ->
        new_map = Map.update(counter, route, 1, &(&1 + 1))
        send(sender, {:result, new_map})
        loop_state(new_map)
      {sender, :count_route, route} ->
        send(sender, {:result, counter[route]})
        loop_state(counter)
      {sender, :get_counts} ->
        send(sender, {:result, counter})
        loop_state(counter)
      _unexpected ->
        IO.puts "Unexpected command!"
        loop_state(counter)
    end
  end
end
