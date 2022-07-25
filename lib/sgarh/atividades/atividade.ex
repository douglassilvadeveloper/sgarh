defmodule Sgarh.Atividades.Atividade do
  use Ecto.Schema
  import Ecto.Changeset

  alias Sgarh.Atividades.TipoAtividade

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "atividades" do
    field :data_base, :date
    field :data_final, :date
    field :encerrada, :boolean, default: false
    field :titulo, :string
    belongs_to :tipo_atividade, TipoAtividade

    timestamps()
  end

  @doc false
  def changeset(atividade, attrs) do
    atividade
    |> cast(attrs, [:titulo, :data_base, :data_final, :encerrada, :tipo_atividade])
    |> validate_required([:titulo, :data_base, :encerrada, :tipo_atividade])
  end
end
