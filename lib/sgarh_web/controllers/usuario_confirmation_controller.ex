defmodule SgarhWeb.UsuarioConfirmationController do
  use SgarhWeb, :controller

  alias Sgarh.Contas

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"usuario" => %{"email" => email}}) do
    if usuario = Contas.get_usuario_by_email(email) do
      Contas.deliver_usuario_confirmation_instructions(
        usuario,
        &Routes.usuario_confirmation_url(conn, :edit, &1)
      )
    end

    conn
    |> put_flash(
      :info,
      "If your email is in our system and it has not been confirmed yet, " <>
        "you will receive an email with instructions shortly."
    )
    |> redirect(to: "/")
  end

  def edit(conn, %{"token" => token}) do
    render(conn, "edit.html", token: token)
  end

  # Do not log in the usuario after confirmation to avoid a
  # leaked token giving the usuario access to the account.
  def update(conn, %{"token" => token}) do
    case Contas.confirm_usuario(token) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Usuario confirmed successfully.")
        |> redirect(to: "/")

      :error ->
        # If there is a current usuario and the account was already confirmed,
        # then odds are that the confirmation link was already visited, either
        # by some automation or by the usuario themselves, so we redirect without
        # a warning message.
        case conn.assigns do
          %{current_usuario: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
            redirect(conn, to: "/")

          %{} ->
            conn
            |> put_flash(:error, "Usuario confirmation link is invalid or it has expired.")
            |> redirect(to: "/")
        end
    end
  end
end
