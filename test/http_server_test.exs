defmodule HttpServerTest do
  use ExUnit.Case

  import Servy.HttpServer

  test "server running correctly" do
    request = """
    GET /test_http_server HTTP/1.1\r
    Host: 127.0.0.1\r
    User-Agent: ExampleeBrowser/1.0\r
    Accept: */*\r
    \r
    """

    spawn(Servy.HttpServer, :start, [5000])

    resp = HTTPoison.get!("localhost:5000/test_http_server")

    assert resp.body == "No /test_http_server here!"
  end
end
