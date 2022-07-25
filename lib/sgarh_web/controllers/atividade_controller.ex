defmodule SgarhWeb.AtividadeController do
  use SgarhWeb, :controller

  alias Sgarh.Atividades
  alias Sgarh.Atividades.Atividade

  def index(conn, _params) do
    atividades = Atividades.list_atividades()
    render(conn, "index.html", atividades: atividades)
  end

  def new(conn, _params) do
    changeset = Atividades.change_atividade(%Atividade{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"atividade" => atividade_params}) do
    case Atividades.create_atividade(atividade_params) do
      {:ok, atividade} ->
        conn
        |> put_flash(:info, "Atividade created successfully.")
        |> redirect(to: Routes.atividade_path(conn, :show, atividade))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    atividade = Atividades.get_atividade!(id)
    render(conn, "show.html", atividade: atividade)
  end

  def edit(conn, %{"id" => id}) do
    atividade = Atividades.get_atividade!(id)
    changeset = Atividades.change_atividade(atividade)
    render(conn, "edit.html", atividade: atividade, changeset: changeset)
  end

  def update(conn, %{"id" => id, "atividade" => atividade_params}) do
    atividade = Atividades.get_atividade!(id)

    case Atividades.update_atividade(atividade, atividade_params) do
      {:ok, atividade} ->
        conn
        |> put_flash(:info, "Atividade updated successfully.")
        |> redirect(to: Routes.atividade_path(conn, :show, atividade))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", atividade: atividade, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    atividade = Atividades.get_atividade!(id)
    {:ok, _atividade} = Atividades.delete_atividade(atividade)

    conn
    |> put_flash(:info, "Atividade deleted successfully.")
    |> redirect(to: Routes.atividade_path(conn, :index))
  end
end
