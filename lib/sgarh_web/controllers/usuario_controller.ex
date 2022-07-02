defmodule SgarhWeb.UsuarioController do
  use SgarhWeb, :controller

  alias Sgarh.Contas
  alias Sgarh.Contas.Usuario

  def index(conn, _params) do
    usuarios = Contas.list_usuarios()
    changeset = Contas.change_usuario_registration(%Usuario{})
    render(conn, "index.html", usuarios: usuarios, changeset: changeset)
  end

  def show(conn, %{"id" => id}) do
    usuario = Contas.get_usuario!(id)
    changeset = Contas.change_usuario_registration(usuario)
    render(conn, "show.html", usuario: usuario, changeset: changeset)
  end

  def delete(conn, %{"id" => id}) do
    usuario = Contas.get_usuario!(id)
    {:ok, _usuario} = Contas.delete_usuario(usuario)

    conn
    |> put_flash(:info, "Usuário deletado com sucesso.")
    |> redirect(to: Routes.usuario_path(conn, :index))
  end

  def edit(conn, %{"id" => id}) do
    usuario = Contas.get_usuario!(id)
    changeset = Contas.change_usuario(usuario)
    render(conn, "edit.html", usuario: usuario, changeset: changeset)
  end

  def update(conn, %{"id" => id, "usuario" => usuario_params}) do
    usuario = Contas.get_usuario!(id)

    case Contas.update_usuario(usuario, usuario_params) do
      {:ok, usuario} ->
        conn
        |> put_flash(:info, "Usuário atualizado com sucesso.")
        |> redirect(to: Routes.usuario_path(conn, :show, usuario))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", usuario: usuario, changeset: changeset)
    end
  end

end