defmodule ParserTest do
  use ExUnit.Case
  doctest Servy.Parser

  alias Servy.Parser
  alias Servy.Conv

  test "parses the request correctly"  do
    request = """
    POST /bears HTTP/1.1\r
    Host: example.com\r
    User-Agent: ExampleBrowser/1.0\r
    Accept: */*\r
    Content-Type: application/x-www-form-urlencoded\r
    Content-Length: 21\r
    \r
    name=Baloo&type=Brown
    """

    response = Parser.parse(request)

    assert response = %Conv{
      method: "POST",
      path: "/bears",
      params: %{ "name" => "Baloo", "type" => "Brown" },
      headers: %{ "Host" => "example.com", "Content-Type" => "application/x-www-form-urlencoded" }
    }
  end
end
