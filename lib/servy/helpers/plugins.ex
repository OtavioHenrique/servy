defmodule Servy.Helpers.Plugins do
  require Logger

  alias Servy.Conv

  def track(%Conv{status: 404, path: path} = conv) do
    Logger.info "Warning: #{path} is one the loose!"
    Servy.External.FourOhFourCounter.bump_count(path)
    conv
  end

  def track(%Conv{} = conv), do: conv

  def log(%Conv{} = conv) do
    Logger.info(inspect conv)
    conv
  end
end
