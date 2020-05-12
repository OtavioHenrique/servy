defmodule Servy.Handler do
  def handle(request) do
    request
    |> parse
    |> rewrite_request
    |> rewrite_path
    |> log
    |> route
    |> track
    |> format_response
  end

  def parse(request) do
    [method, path, _] =
      request
      |> String.split("\n")
      |> List.first
      |> String.split(" ")

    %{
      method: method,
      path: path,
      resp_body: "" ,
      status: nil
    }
  end

  def log(conv), do: IO.inspect(conv)

  def route(conv) do
    route(conv, conv.method, conv.path)
  end

  def track(%{status: 404, path: path} = conv) do
    IO.puts "Warning: #{path} is one the loose!"
    conv
  end

  def track(conv), do: conv

  def rewrite_request(%{ path: "/bears?id=" <> id } = conv) do
    %{ conv | path: "/bears/#{id}" }
  end

  def rewrite_request(conv), do: conv

  def rewrite_path(%{path: "wildlife" } = conv) do
    %{ conv | path: "/wildthings" }
  end

  def rewrite_path(conv), do: conv

  def route(conv, "GET", "/bears") do
    %{ conv | status: 200, resp_body: "Teddy" }
  end

  def route(conv, "GET", "/wildthings") do
    %{ conv | status: 200, resp_body: "Hello World" }
  end

  def route(conv, "GET", "/bears/" <> 1) do
    %{ conv | status: 200, resp_body: "Bear #{id}" }
  end

  def route(conv, _method, path) do
    %{ conv | status: 404, resp_body: "No #{path} here!" }
  end

  def format_response(conv) do
    """
    HTTP/1.1 #{conv.status} #{status_reason(conv.status)}
    Content-Type: text/html
    Content-Length: #{byte_size(conv.resp_body)}

    #{conv.resp_body}
    """
  end

  defp status_reason(code) do
    %{
      200 => "OK",
      201 => "Created",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error"
    }[code]
  end
end

request = """
GET /bears?id=1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response
