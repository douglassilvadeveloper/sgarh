defmodule Sgarh.Repo.Migrations.CreateUsuariosAuthTables do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:usuarios, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :nome, :string, size: 100
      add :email, :citext, null: false
      add :hashed_password, :string, null: false
      add :foto, :string
      add :ativo, :boolean, default: false
      add :admin, :boolean, default: false
      add :confirmed_at, :naive_datetime
      timestamps()
    end

    create unique_index(:usuarios, [:email])

    create table(:usuarios_tokens, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :usuario_id, references(:usuarios, type: :binary_id, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(updated_at: false)
    end

    create index(:usuarios_tokens, [:usuario_id])
    create unique_index(:usuarios_tokens, [:context, :token])
  end
end
