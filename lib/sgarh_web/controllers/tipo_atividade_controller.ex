defmodule SgarhWeb.TipoAtividadeController do
  use SgarhWeb, :controller

  alias Sgarh.Atividades
  alias Sgarh.Atividades.TipoAtividade

  def index(conn, _params) do
    tipos_atividades = Atividades.list_tipos_atividades()
    render(conn, "index.html", tipos_atividades: tipos_atividades)
  end

  def new(conn, _params) do
    changeset = Atividades.change_tipo_atividade(%TipoAtividade{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"tipo_atividade" => tipo_atividade_params}) do
    case Atividades.create_tipo_atividade(tipo_atividade_params) do
      {:ok, tipo_atividade} ->
        conn
        |> put_flash(:info, "Tipo atividade created successfully.")
        |> redirect(to: Routes.tipo_atividade_path(conn, :show, tipo_atividade))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    tipo_atividade = Atividades.get_tipo_atividade!(id)
    render(conn, "show.html", tipo_atividade: tipo_atividade)
  end

  def edit(conn, %{"id" => id}) do
    tipo_atividade = Atividades.get_tipo_atividade!(id)
    changeset = Atividades.change_tipo_atividade(tipo_atividade)
    render(conn, "edit.html", tipo_atividade: tipo_atividade, changeset: changeset)
  end

  def update(conn, %{"id" => id, "tipo_atividade" => tipo_atividade_params}) do
    tipo_atividade = Atividades.get_tipo_atividade!(id)

    case Atividades.update_tipo_atividade(tipo_atividade, tipo_atividade_params) do
      {:ok, tipo_atividade} ->
        conn
        |> put_flash(:info, "Tipo atividade updated successfully.")
        |> redirect(to: Routes.tipo_atividade_path(conn, :show, tipo_atividade))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", tipo_atividade: tipo_atividade, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    tipo_atividade = Atividades.get_tipo_atividade!(id)
    {:ok, _tipo_atividade} = Atividades.delete_tipo_atividade(tipo_atividade)

    conn
    |> put_flash(:info, "Tipo atividade deleted successfully.")
    |> redirect(to: Routes.tipo_atividade_path(conn, :index))
  end
end
