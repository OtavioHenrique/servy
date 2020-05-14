defmodule Servy.Handler do
  require Logger

  alias Servy.Conv
  alias Servy.BearController

  import Servy.Plugins
  import Servy.Parser, only: [parse: 1]
  import Servy.FileHandler

  @moduledoc "Handles HTTP requests."

  @pages_path Path.expand("pages", File.cwd!)

  def handle(request) do
    request
    |> parse
    |> rewrite_request
    |> rewrite_path
    |> log
    |> route
    |> emojify
    |> track
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

  def route(%Conv{ method: "GET", path: "/wildthings" } = conv) do
    %{ conv | status: 200, resp_body: "Hello World" }
  end

  def route(%Conv{ method: "GET", path: "/bears" } = conv) do
    BearController.index(conv)
  end

  def route(%Conv{ method: "GET", path: "/bears/" <> id } = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(%Conv{ method: "GET", path: "/pages/" <> file } = conv) do
    @pages_path
    |> Path.join(file <> ".html")
    |> File.read
    |> handle_file(conv)
  end

  def route(%Conv{ method: "POST", path: "/bears" } = conv) do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{ method: "DELETE", path: "/bears/" <> _id} = conv) do
    BearController.delete(conv)
  end

  def route(%Conv{ path: path } = conv) do
    %{ conv | status: 404, resp_body: "No #{path} here!" }
  end

  def emojify(%Conv{ status: 200 } = conv) do
    %{ conv | resp_body: conv.resp_body <> " :)"}
  end

  def emojify(conv), do: conv

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}
    Content-Type: text/html
    Content-Length: #{byte_size(conv.resp_body)}

    #{conv.resp_body}
    """
  end
end

request = """
GET /pages/about HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

request_post =  """
POST /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
Content-Type: application/x-www-form-urlencoded
Content-Length: 21

name=Baloo&type=Brown
"""

response = Servy.Handler.handle(request_post)

IO.puts response
