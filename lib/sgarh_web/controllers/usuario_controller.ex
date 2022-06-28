defmodule SgarhWeb.UsuarioController do
  use SgarhWeb, :controller

  alias Sgarh.Contas
  alias Sgarh.Contas.Usuario

  def index(conn, _params) do
    usuarios = Contas.list_usuarios()
    changeset = Contas.change_usuario_registration(%Usuario{})
    render(conn, "index.html", usuarios: usuarios, changeset: changeset)
  end

end