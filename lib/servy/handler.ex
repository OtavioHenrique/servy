defmodule Servy.Handler do
  require Logger

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

  def log(conv) do
    Logger.info(inspect conv)
    conv
  end

  def track(%{status: 404, path: path} = conv) do
    Logger.info "Warning: #{path} is one the loose!"
    conv
  end

  def track(conv), do: conv

  def rewrite_request(%{ path: path } = conv) do
    regex = ~r{\/(?<thing>\w+)\?id=(?<id>\d+)}
    captures = Regex.named_captures(regex, path)
    rewrite_path_captures(conv, captures)
  end

  def rewrite_path_captures(conv, %{"thing" => thing, "id" => id}) do
    %{ conv | path: "/#{thing}/#{id}" }
  end

  def rewrite_path_captures(conv, nil), do: conv

  def rewrite_path(%{path: "wildlife" } = conv) do
    %{ conv | path: "/wildthings" }
  end

  def rewrite_path(conv), do: conv

  def route(%{ method: "GET", path: "/bears" } = conv) do
    %{ conv | status: 200, resp_body: "Teddy" }
  end

  def route(%{ method: "GET", path: "/wildthings" } = conv) do
    %{ conv | status: 200, resp_body: "Hello World" }
  end

  def route(%{ method: "GET", path: "/bears/" <> id } = conv) do
    %{ conv | status: 200, resp_body: "Bear #{id}" }
  end

  def route(%{ method: "GET", path: "/about" } = conv) do
    Path.expand("../../pages", __DIR__)
    |> Path.join("about.html")
    |> File.read
    |> handle_file(conv)
  end

  def handle_file({:ok, content}, conv) do
    %{ conv | status: 200, resp_body: content }
  end

  def handle_file({:error, :enoent}, conv) do
    %{ conv | status: 404, resp_body: "File not found!" }
  end

  def handle_file({:error, reason}, conv) do
    %{ conv | status: 500, resp_body: "File error: #{reason}" }
  end

  def route(%{ method: "DELETE", path: "/bears/" <> _id} = conv) do
    %{ conv | status: 403, resp_body: "Bears must never be deleted!"}
  end

  def route(%{ path: path } = conv) do
    %{ conv | status: 404, resp_body: "No #{path} here!" }
  end

  def emojify(%{ status: 200 } = conv) do
    %{ conv | resp_body: conv.resp_body <> " :)"}
  end

  def emojify(conv), do: conv

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
GET /about HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response
