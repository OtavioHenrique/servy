defmodule Servy.Plugins do
    require Logger

  def track(%{status: 404, path: path} = conv) do
    Logger.info "Warning: #{path} is one the loose!"
    conv
  end

  def track(conv), do: conv

  def log(conv) do
    Logger.info(inspect conv)
    conv
  end

  def rewrite_path(%{path: "wildlife" } = conv) do
    %{ conv | path: "/wildthings" }
  end

  def rewrite_path(conv), do: conv
end
