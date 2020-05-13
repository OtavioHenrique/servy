defmodule Servy.Plugins do
  require Logger

  alias Servy.Conv

  def track(%Conv{status: 404, path: path} = conv) do
    Logger.info "Warning: #{path} is one the loose!"
    conv
  end

  def track(%Conv{} = conv), do: conv

  def log(%Conv{} = conv) do
    Logger.info(inspect conv)
    conv
  end

  def rewrite_path(%Conv{path: "wildlife" } = conv) do
    %{ conv | path: "/wildthings" }
  end

  def rewrite_path(%Conv{} = conv), do: conv
end
