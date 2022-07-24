defmodule Sgarh.Atividades.TipoAtividade do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tipos_atividades" do
    field :nome, :string

    timestamps()
  end

  @doc false
  def changeset(tipo_atividade, attrs) do
    tipo_atividade
    |> cast(attrs, [:nome])
    |> validate_required([:nome])
  end
end
