defmodule Servy.Helpers.Common do
  def put_header(conv, header, value) do
    %{ conv | resp_headers: Map.put(conv.resp_headers, header, value) }
  end
end
