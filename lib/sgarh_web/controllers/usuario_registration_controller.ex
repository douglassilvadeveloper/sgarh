defmodule SgarhWeb.UsuarioRegistrationController do
  use SgarhWeb, :controller

  alias Sgarh.Contas
  alias Sgarh.Contas.Usuario
  alias SgarhWeb.UsuarioAuth

  def new(conn, _params) do
    changeset = Contas.change_usuario_registration(%Usuario{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"usuario" => usuario_params}) do
    case Contas.register_usuario(usuario_params) do
      {:ok, usuario} ->
        {:ok, _} =
          Contas.deliver_usuario_confirmation_instructions(
            usuario,
            &Routes.usuario_confirmation_url(conn, :edit, &1)
          )

        conn
        |> put_flash(:info, "Usuario created successfully.")
        |> UsuarioAuth.log_in_usuario(usuario)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
