defmodule Sgarh.Repo.Migrations.CreateTiposAtividades do
  use Ecto.Migration

  def change do
    create table(:tipos_atividades, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :nome, :string, size: 100

      timestamps()
    end

    create unique_index(:tipos_atividades, [:nome])
  end
end
