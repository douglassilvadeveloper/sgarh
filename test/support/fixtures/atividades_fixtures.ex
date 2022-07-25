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

  @doc """
  Generate a atividade.
  """
  def atividade_fixture(attrs \\ %{}) do
    {:ok, atividade} =
      attrs
      |> Enum.into(%{
        data_base: ~D[2022-07-23],
        data_final: ~D[2022-07-23],
        encerrada: true,
        titulo: "some titulo"
      })
      |> Sgarh.Atividades.create_atividade()

    atividade
  end
end
