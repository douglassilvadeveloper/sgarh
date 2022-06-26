defmodule SgarhWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use SgarhWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import SgarhWeb.ConnCase

      alias SgarhWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint SgarhWeb.Endpoint
    end
  end

  setup tags do
    Sgarh.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  @doc """
  Setup helper that registers and logs in usuarios.

      setup :register_and_log_in_usuario

  It stores an updated connection and a registered usuario in the
  test context.
  """
  def register_and_log_in_usuario(%{conn: conn}) do
    usuario = Sgarh.ContasFixtures.usuario_fixture()
    %{conn: log_in_usuario(conn, usuario), usuario: usuario}
  end

  @doc """
  Logs the given `usuario` into the `conn`.

  It returns an updated `conn`.
  """
  def log_in_usuario(conn, usuario) do
    token = Sgarh.Contas.generate_usuario_session_token(usuario)

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_session(:usuario_token, token)
  end
end
