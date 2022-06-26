defmodule SgarhWeb.PageController do
  use SgarhWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
