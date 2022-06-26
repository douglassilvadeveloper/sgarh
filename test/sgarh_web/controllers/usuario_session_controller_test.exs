defmodule SgarhWeb.UsuarioSessionControllerTest do
  use SgarhWeb.ConnCase, async: true

  import Sgarh.ContasFixtures

  setup do
    %{usuario: usuario_fixture()}
  end

  describe "GET /usuarios/log_in" do
    test "renders log in page", %{conn: conn} do
      conn = get(conn, Routes.usuario_session_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "<h1>Log in</h1>"
      assert response =~ "Register</a>"
      assert response =~ "Forgot your password?</a>"
    end

    test "redirects if already logged in", %{conn: conn, usuario: usuario} do
      conn = conn |> log_in_usuario(usuario) |> get(Routes.usuario_session_path(conn, :new))
      assert redirected_to(conn) == "/"
    end
  end

  describe "POST /usuarios/log_in" do
    test "logs the usuario in", %{conn: conn, usuario: usuario} do
      conn =
        post(conn, Routes.usuario_session_path(conn, :create), %{
          "usuario" => %{"email" => usuario.email, "password" => valid_usuario_password()}
        })

      assert get_session(conn, :usuario_token)
      assert redirected_to(conn) == "/"

      # Now do a logged in request and assert on the menu
      conn = get(conn, "/")
      response = html_response(conn, 200)
      assert response =~ usuario.email
      assert response =~ "Settings</a>"
      assert response =~ "Log out</a>"
    end

    test "logs the usuario in with remember me", %{conn: conn, usuario: usuario} do
      conn =
        post(conn, Routes.usuario_session_path(conn, :create), %{
          "usuario" => %{
            "email" => usuario.email,
            "password" => valid_usuario_password(),
            "remember_me" => "true"
          }
        })

      assert conn.resp_cookies["_sgarh_web_usuario_remember_me"]
      assert redirected_to(conn) == "/"
    end

    test "logs the usuario in with return to", %{conn: conn, usuario: usuario} do
      conn =
        conn
        |> init_test_session(usuario_return_to: "/foo/bar")
        |> post(Routes.usuario_session_path(conn, :create), %{
          "usuario" => %{
            "email" => usuario.email,
            "password" => valid_usuario_password()
          }
        })

      assert redirected_to(conn) == "/foo/bar"
    end

    test "emits error message with invalid credentials", %{conn: conn, usuario: usuario} do
      conn =
        post(conn, Routes.usuario_session_path(conn, :create), %{
          "usuario" => %{"email" => usuario.email, "password" => "invalid_password"}
        })

      response = html_response(conn, 200)
      assert response =~ "<h1>Log in</h1>"
      assert response =~ "Invalid email or password"
    end
  end

  describe "DELETE /usuarios/log_out" do
    test "logs the usuario out", %{conn: conn, usuario: usuario} do
      conn = conn |> log_in_usuario(usuario) |> delete(Routes.usuario_session_path(conn, :delete))
      assert redirected_to(conn) == "/"
      refute get_session(conn, :usuario_token)
      assert get_flash(conn, :info) =~ "Logged out successfully"
    end

    test "succeeds even if the usuario is not logged in", %{conn: conn} do
      conn = delete(conn, Routes.usuario_session_path(conn, :delete))
      assert redirected_to(conn) == "/"
      refute get_session(conn, :usuario_token)
      assert get_flash(conn, :info) =~ "Logged out successfully"
    end
  end
end
