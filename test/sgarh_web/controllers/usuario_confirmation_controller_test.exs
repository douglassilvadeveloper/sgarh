defmodule SgarhWeb.UsuarioConfirmationControllerTest do
  use SgarhWeb.ConnCase, async: true

  alias Sgarh.Contas
  alias Sgarh.Repo
  import Sgarh.ContasFixtures

  setup do
    %{usuario: usuario_fixture()}
  end

  describe "GET /usuarios/confirm" do
    test "renders the resend confirmation page", %{conn: conn} do
      conn = get(conn, Routes.usuario_confirmation_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "<h1>Resend confirmation instructions</h1>"
    end
  end

  describe "POST /usuarios/confirm" do
    @tag :capture_log
    test "sends a new confirmation token", %{conn: conn, usuario: usuario} do
      conn =
        post(conn, Routes.usuario_confirmation_path(conn, :create), %{
          "usuario" => %{"email" => usuario.email}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      assert Repo.get_by!(Contas.UsuarioToken, usuario_id: usuario.id).context == "confirm"
    end

    test "does not send confirmation token if Usuario is confirmed", %{conn: conn, usuario: usuario} do
      Repo.update!(Contas.Usuario.confirm_changeset(usuario))

      conn =
        post(conn, Routes.usuario_confirmation_path(conn, :create), %{
          "usuario" => %{"email" => usuario.email}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      refute Repo.get_by(Contas.UsuarioToken, usuario_id: usuario.id)
    end

    test "does not send confirmation token if email is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.usuario_confirmation_path(conn, :create), %{
          "usuario" => %{"email" => "unknown@example.com"}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      assert Repo.all(Contas.UsuarioToken) == []
    end
  end

  describe "GET /usuarios/confirm/:token" do
    test "renders the confirmation page", %{conn: conn} do
      conn = get(conn, Routes.usuario_confirmation_path(conn, :edit, "some-token"))
      response = html_response(conn, 200)
      assert response =~ "<h1>Confirm account</h1>"

      form_action = Routes.usuario_confirmation_path(conn, :update, "some-token")
      assert response =~ "action=\"#{form_action}\""
    end
  end

  describe "POST /usuarios/confirm/:token" do
    test "confirms the given token once", %{conn: conn, usuario: usuario} do
      token =
        extract_usuario_token(fn url ->
          Contas.deliver_usuario_confirmation_instructions(usuario, url)
        end)

      conn = post(conn, Routes.usuario_confirmation_path(conn, :update, token))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "Usuario confirmed successfully"
      assert Contas.get_usuario!(usuario.id).confirmed_at
      refute get_session(conn, :usuario_token)
      assert Repo.all(Contas.UsuarioToken) == []

      # When not logged in
      conn = post(conn, Routes.usuario_confirmation_path(conn, :update, token))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "Usuario confirmation link is invalid or it has expired"

      # When logged in
      conn =
        build_conn()
        |> log_in_usuario(usuario)
        |> post(Routes.usuario_confirmation_path(conn, :update, token))

      assert redirected_to(conn) == "/"
      refute get_flash(conn, :error)
    end

    test "does not confirm email with invalid token", %{conn: conn, usuario: usuario} do
      conn = post(conn, Routes.usuario_confirmation_path(conn, :update, "oops"))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "Usuario confirmation link is invalid or it has expired"
      refute Contas.get_usuario!(usuario.id).confirmed_at
    end
  end
end
