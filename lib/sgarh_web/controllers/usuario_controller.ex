defmodule SgarhWeb.UsuarioController do
  use SgarhWeb, :controller

  alias Sgarh.Contas
  alias Sgarh.Contas.Usuario

  def index(conn, _params) do
    usuarios = Contas.list_usuarios()
    changeset = Contas.change_usuario_registration(%Usuario{})
    render(conn, "index.html", usuarios: usuarios, changeset: changeset)
  end

  def delete(conn, %{"id" => id}) do
    usuario = Contas.get_usuario!(id)
    {:ok, _usuario} = Contas.delete_usuario(usuario)

    conn
    |> put_flash(:info, "Usuário deletado com sucesso.")
    |> redirect(to: Routes.usuario_path(conn, :index))
  end

end