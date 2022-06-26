defmodule SgarhWeb.UsuarioSettingsControllerTest do
  use SgarhWeb.ConnCase, async: true

  alias Sgarh.Contas
  import Sgarh.ContasFixtures

  setup :register_and_log_in_usuario

  describe "GET /usuarios/settings" do
    test "renders settings page", %{conn: conn} do
      conn = get(conn, Routes.usuario_settings_path(conn, :edit))
      response = html_response(conn, 200)
      assert response =~ "<h1>Settings</h1>"
    end

    test "redirects if usuario is not logged in" do
      conn = build_conn()
      conn = get(conn, Routes.usuario_settings_path(conn, :edit))
      assert redirected_to(conn) == Routes.usuario_session_path(conn, :new)
    end
  end

  describe "PUT /usuarios/settings (change password form)" do
    test "updates the usuario password and resets tokens", %{conn: conn, usuario: usuario} do
      new_password_conn =
        put(conn, Routes.usuario_settings_path(conn, :update), %{
          "action" => "update_password",
          "current_password" => valid_usuario_password(),
          "usuario" => %{
            "password" => "new valid password",
            "password_confirmation" => "new valid password"
          }
        })

      assert redirected_to(new_password_conn) == Routes.usuario_settings_path(conn, :edit)
      assert get_session(new_password_conn, :usuario_token) != get_session(conn, :usuario_token)
      assert get_flash(new_password_conn, :info) =~ "Password updated successfully"
      assert Contas.get_usuario_by_email_and_password(usuario.email, "new valid password")
    end

    test "does not update password on invalid data", %{conn: conn} do
      old_password_conn =
        put(conn, Routes.usuario_settings_path(conn, :update), %{
          "action" => "update_password",
          "current_password" => "invalid",
          "usuario" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })

      response = html_response(old_password_conn, 200)
      assert response =~ "<h1>Settings</h1>"
      assert response =~ "should be at least 12 character(s)"
      assert response =~ "does not match password"
      assert response =~ "is not valid"

      assert get_session(old_password_conn, :usuario_token) == get_session(conn, :usuario_token)
    end
  end

  describe "PUT /usuarios/settings (change email form)" do
    @tag :capture_log
    test "updates the usuario email", %{conn: conn, usuario: usuario} do
      conn =
        put(conn, Routes.usuario_settings_path(conn, :update), %{
          "action" => "update_email",
          "current_password" => valid_usuario_password(),
          "usuario" => %{"email" => unique_usuario_email()}
        })

      assert redirected_to(conn) == Routes.usuario_settings_path(conn, :edit)
      assert get_flash(conn, :info) =~ "A link to confirm your email"
      assert Contas.get_usuario_by_email(usuario.email)
    end

    test "does not update email on invalid data", %{conn: conn} do
      conn =
        put(conn, Routes.usuario_settings_path(conn, :update), %{
          "action" => "update_email",
          "current_password" => "invalid",
          "usuario" => %{"email" => "with spaces"}
        })

      response = html_response(conn, 200)
      assert response =~ "<h1>Settings</h1>"
      assert response =~ "must have the @ sign and no spaces"
      assert response =~ "is not valid"
    end
  end

  describe "GET /usuarios/settings/confirm_email/:token" do
    setup %{usuario: usuario} do
      email = unique_usuario_email()

      token =
        extract_usuario_token(fn url ->
          Contas.deliver_update_email_instructions(%{usuario | email: email}, usuario.email, url)
        end)

      %{token: token, email: email}
    end

    test "updates the usuario email once", %{conn: conn, usuario: usuario, token: token, email: email} do
      conn = get(conn, Routes.usuario_settings_path(conn, :confirm_email, token))
      assert redirected_to(conn) == Routes.usuario_settings_path(conn, :edit)
      assert get_flash(conn, :info) =~ "Email changed successfully"
      refute Contas.get_usuario_by_email(usuario.email)
      assert Contas.get_usuario_by_email(email)

      conn = get(conn, Routes.usuario_settings_path(conn, :confirm_email, token))
      assert redirected_to(conn) == Routes.usuario_settings_path(conn, :edit)
      assert get_flash(conn, :error) =~ "Email change link is invalid or it has expired"
    end

    test "does not update email with invalid token", %{conn: conn, usuario: usuario} do
      conn = get(conn, Routes.usuario_settings_path(conn, :confirm_email, "oops"))
      assert redirected_to(conn) == Routes.usuario_settings_path(conn, :edit)
      assert get_flash(conn, :error) =~ "Email change link is invalid or it has expired"
      assert Contas.get_usuario_by_email(usuario.email)
    end

    test "redirects if usuario is not logged in", %{token: token} do
      conn = build_conn()
      conn = get(conn, Routes.usuario_settings_path(conn, :confirm_email, token))
      assert redirected_to(conn) == Routes.usuario_session_path(conn, :new)
    end
  end
end
