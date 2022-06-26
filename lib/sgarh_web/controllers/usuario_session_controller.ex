defmodule SgarhWeb.UsuarioSessionController do
  use SgarhWeb, :controller

  alias Sgarh.Contas
  alias SgarhWeb.UsuarioAuth

  def new(conn, _params) do
    render(conn, "new.html", error_message: nil)
  end

  def create(conn, %{"usuario" => usuario_params}) do
    %{"email" => email, "password" => password} = usuario_params

    if usuario = Contas.get_usuario_by_email_and_password(email, password) do
      UsuarioAuth.log_in_usuario(conn, usuario, usuario_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      render(conn, "new.html", error_message: "Invalid email or password")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UsuarioAuth.log_out_usuario()
  end
end
