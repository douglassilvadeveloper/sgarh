defmodule SgarhWeb.UsuarioAuthTest do
  use SgarhWeb.ConnCase, async: true

  alias Sgarh.Contas
  alias SgarhWeb.UsuarioAuth
  import Sgarh.ContasFixtures

  @remember_me_cookie "_sgarh_web_usuario_remember_me"

  setup %{conn: conn} do
    conn =
      conn
      |> Map.replace!(:secret_key_base, SgarhWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})

    %{usuario: usuario_fixture(), conn: conn}
  end

  describe "log_in_usuario/3" do
    test "stores the usuario token in the session", %{conn: conn, usuario: usuario} do
      conn = UsuarioAuth.log_in_usuario(conn, usuario)
      assert token = get_session(conn, :usuario_token)
      assert get_session(conn, :live_socket_id) == "usuarios_sessions:#{Base.url_encode64(token)}"
      assert redirected_to(conn) == "/"
      assert Contas.get_usuario_by_session_token(token)
    end

    test "clears everything previously stored in the session", %{conn: conn, usuario: usuario} do
      conn = conn |> put_session(:to_be_removed, "value") |> UsuarioAuth.log_in_usuario(usuario)
      refute get_session(conn, :to_be_removed)
    end

    test "redirects to the configured path", %{conn: conn, usuario: usuario} do
      conn = conn |> put_session(:usuario_return_to, "/hello") |> UsuarioAuth.log_in_usuario(usuario)
      assert redirected_to(conn) == "/hello"
    end

    test "writes a cookie if remember_me is configured", %{conn: conn, usuario: usuario} do
      conn = conn |> fetch_cookies() |> UsuarioAuth.log_in_usuario(usuario, %{"remember_me" => "true"})
      assert get_session(conn, :usuario_token) == conn.cookies[@remember_me_cookie]

      assert %{value: signed_token, max_age: max_age} = conn.resp_cookies[@remember_me_cookie]
      assert signed_token != get_session(conn, :usuario_token)
      assert max_age == 5_184_000
    end
  end

  describe "logout_usuario/1" do
    test "erases session and cookies", %{conn: conn, usuario: usuario} do
      usuario_token = Contas.generate_usuario_session_token(usuario)

      conn =
        conn
        |> put_session(:usuario_token, usuario_token)
        |> put_req_cookie(@remember_me_cookie, usuario_token)
        |> fetch_cookies()
        |> UsuarioAuth.log_out_usuario()

      refute get_session(conn, :usuario_token)
      refute conn.cookies[@remember_me_cookie]
      assert %{max_age: 0} = conn.resp_cookies[@remember_me_cookie]
      assert redirected_to(conn) == "/"
      refute Contas.get_usuario_by_session_token(usuario_token)
    end

    test "broadcasts to the given live_socket_id", %{conn: conn} do
      live_socket_id = "usuarios_sessions:abcdef-token"
      SgarhWeb.Endpoint.subscribe(live_socket_id)

      conn
      |> put_session(:live_socket_id, live_socket_id)
      |> UsuarioAuth.log_out_usuario()

      assert_receive %Phoenix.Socket.Broadcast{event: "disconnect", topic: ^live_socket_id}
    end

    test "works even if usuario is already logged out", %{conn: conn} do
      conn = conn |> fetch_cookies() |> UsuarioAuth.log_out_usuario()
      refute get_session(conn, :usuario_token)
      assert %{max_age: 0} = conn.resp_cookies[@remember_me_cookie]
      assert redirected_to(conn) == "/"
    end
  end

  describe "fetch_current_usuario/2" do
    test "authenticates usuario from session", %{conn: conn, usuario: usuario} do
      usuario_token = Contas.generate_usuario_session_token(usuario)
      conn = conn |> put_session(:usuario_token, usuario_token) |> UsuarioAuth.fetch_current_usuario([])
      assert conn.assigns.current_usuario.id == usuario.id
    end

    test "authenticates usuario from cookies", %{conn: conn, usuario: usuario} do
      logged_in_conn =
        conn |> fetch_cookies() |> UsuarioAuth.log_in_usuario(usuario, %{"remember_me" => "true"})

      usuario_token = logged_in_conn.cookies[@remember_me_cookie]
      %{value: signed_token} = logged_in_conn.resp_cookies[@remember_me_cookie]

      conn =
        conn
        |> put_req_cookie(@remember_me_cookie, signed_token)
        |> UsuarioAuth.fetch_current_usuario([])

      assert get_session(conn, :usuario_token) == usuario_token
      assert conn.assigns.current_usuario.id == usuario.id
    end

    test "does not authenticate if data is missing", %{conn: conn, usuario: usuario} do
      _ = Contas.generate_usuario_session_token(usuario)
      conn = UsuarioAuth.fetch_current_usuario(conn, [])
      refute get_session(conn, :usuario_token)
      refute conn.assigns.current_usuario
    end
  end

  describe "redirect_if_usuario_is_authenticated/2" do
    test "redirects if usuario is authenticated", %{conn: conn, usuario: usuario} do
      conn = conn |> assign(:current_usuario, usuario) |> UsuarioAuth.redirect_if_usuario_is_authenticated([])
      assert conn.halted
      assert redirected_to(conn) == "/"
    end

    test "does not redirect if usuario is not authenticated", %{conn: conn} do
      conn = UsuarioAuth.redirect_if_usuario_is_authenticated(conn, [])
      refute conn.halted
      refute conn.status
    end
  end

  describe "require_authenticated_usuario/2" do
    test "redirects if usuario is not authenticated", %{conn: conn} do
      conn = conn |> fetch_flash() |> UsuarioAuth.require_authenticated_usuario([])
      assert conn.halted
      assert redirected_to(conn) == Routes.usuario_session_path(conn, :new)
      assert get_flash(conn, :error) == "You must log in to access this page."
    end

    test "stores the path to redirect to on GET", %{conn: conn} do
      halted_conn =
        %{conn | path_info: ["foo"], query_string: ""}
        |> fetch_flash()
        |> UsuarioAuth.require_authenticated_usuario([])

      assert halted_conn.halted
      assert get_session(halted_conn, :usuario_return_to) == "/foo"

      halted_conn =
        %{conn | path_info: ["foo"], query_string: "bar=baz"}
        |> fetch_flash()
        |> UsuarioAuth.require_authenticated_usuario([])

      assert halted_conn.halted
      assert get_session(halted_conn, :usuario_return_to) == "/foo?bar=baz"

      halted_conn =
        %{conn | path_info: ["foo"], query_string: "bar", method: "POST"}
        |> fetch_flash()
        |> UsuarioAuth.require_authenticated_usuario([])

      assert halted_conn.halted
      refute get_session(halted_conn, :usuario_return_to)
    end

    test "does not redirect if usuario is authenticated", %{conn: conn, usuario: usuario} do
      conn = conn |> assign(:current_usuario, usuario) |> UsuarioAuth.require_authenticated_usuario([])
      refute conn.halted
      refute conn.status
    end
  end
end
