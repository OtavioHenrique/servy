defmodule Servy.Handler do
  require Logger

  alias Servy.Conv
  alias Servy.Controllers.BearController
  alias Servy.VideoCam

  import Servy.Helpers.Plugins
  import Servy.Parser, only: [parse: 1]
  import Servy.Helpers.FileHandler

  @moduledoc "Handles HTTP requests."

  @pages_path Path.expand("pages", File.cwd!)

  def handle(request) do
    request
    |> parse
    |> rewrite_request
    |> log
    |> route
    |> track
    |> put_content_length
    |> format_response
  end

  def rewrite_request(%Conv{ path: path } = conv) do
    regex = ~r{\/(?<thing>\w+)\?id=(?<id>\d+)}
    captures = Regex.named_captures(regex, path)
    rewrite_path_captures(conv, captures)
  end

  def rewrite_path_captures(conv, %{"thing" => thing, "id" => id}) do
    %{ conv | path: "/#{thing}/#{id}" }
  end

  def rewrite_path_captures(conv, nil), do: conv

  def route(%Conv{ method: "GET", path: "/api/bears" } = conv) do
    Servy.Controllers.Api.BearController.index(conv)
  end

  def route(%Conv{ method: "POST", path: "/api/bears" } = conv) do
    Servy.Controllers.Api.BearController.create(conv, conv.params)
  end

  def route(%Conv{ method: "GET", path: "/bears" } = conv) do
    BearController.index(conv)
  end

  def route(%Conv{ method: "GET", path: "/bears/" <> id } = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(%Conv{ method: "POST", path: "/bears" } = conv) do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{ method: "DELETE", path: "/bears/" <> _id} = conv) do
    BearController.delete(conv)
  end

  def route(%Conv{ method: "GET", path: "/pages/" <> file } = conv) do
    @pages_path
    |> Path.join(file <> ".html")
    |> File.read
    |> handle_file(conv)
  end

  def route(%Conv{ method: "GET", path: "/snapshots" } = conv) do
    parent = self()

    spawn(fn -> send(parent, {:result, VideoCam.get_snapshot("cam-1")}) end)
    spawn(fn -> send(parent, {:result, VideoCam.get_snapshot("cam-2")}) end)
    spawn(fn -> send(parent, {:result, VideoCam.get_snapshot("cam-3")}) end)

    snapshot1 = receive do {:result, filename} -> filename  end
    snapshot2 = receive do {:result, filename} -> filename  end
    snapshot3 = receive do {:result, filename} -> filename  end

    snapshots = [snapshot1, snapshot2, snapshot3]

    %{ conv | status: 200, resp_body: inspect snapshots }
  end

  def route(%Conv{ path: path } = conv) do
    %{ conv | status: 404, resp_headers: %{"Content-Type" => "text/html"}, resp_body: "No #{path} here!" }
  end

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    #{format_response_headers(conv)}
    \r
    #{conv.resp_body}
    """
  end

  defp put_content_length(%Conv{} = conv) do
    Servy.Helpers.Common.put_header(conv, "Content-Length", byte_size(conv.resp_body))
  end

  defp format_response_headers(conv) do
    Enum.map(conv.resp_headers, fn { key, value } -> "#{key}: #{value}\r" end)
    |> Enum.sort
    |> Enum.join("\n")
  end
end
