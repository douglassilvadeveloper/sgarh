defmodule Sgarh.Repo.Migrations.CreateAtividades do
  use Ecto.Migration

  def change do
    create table(:atividades, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :tipo_atividade_id, references(:tipos_atividades, on_delete: :restrict, type: :binary_id), null: true
      add :titulo, :string, size: 150
      add :data_base, :date
      add :data_final, :date
      add :encerrada, :boolean, default: false, null: false

      timestamps()
    end

    create index(:atividades, [:tipo_atividade_id])
  end
end
