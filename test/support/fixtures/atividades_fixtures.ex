defmodule Sgarh.AtividadesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sgarh.Atividades` context.
  """

  @doc """
  Generate a tipo_atividade.
  """
  def tipo_atividade_fixture(attrs \\ %{}) do
    {:ok, tipo_atividade} =
      attrs
      |> Enum.into(%{
        nome: "some nome"
      })
      |> Sgarh.Atividades.create_tipo_atividade()

    tipo_atividade
  end
end
