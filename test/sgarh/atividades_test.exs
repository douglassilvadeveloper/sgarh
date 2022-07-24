defmodule Sgarh.AtividadesTest do
  use Sgarh.DataCase

  alias Sgarh.Atividades

  describe "tipos_atividades" do
    alias Sgarh.Atividades.TipoAtividade

    import Sgarh.AtividadesFixtures

    @invalid_attrs %{nome: nil}

    test "list_tipos_atividades/0 returns all tipos_atividades" do
      tipo_atividade = tipo_atividade_fixture()
      assert Atividades.list_tipos_atividades() == [tipo_atividade]
    end

    test "get_tipo_atividade!/1 returns the tipo_atividade with given id" do
      tipo_atividade = tipo_atividade_fixture()
      assert Atividades.get_tipo_atividade!(tipo_atividade.id) == tipo_atividade
    end

    test "create_tipo_atividade/1 with valid data creates a tipo_atividade" do
      valid_attrs = %{nome: "some nome"}

      assert {:ok, %TipoAtividade{} = tipo_atividade} = Atividades.create_tipo_atividade(valid_attrs)
      assert tipo_atividade.nome == "some nome"
    end

    test "create_tipo_atividade/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Atividades.create_tipo_atividade(@invalid_attrs)
    end

    test "update_tipo_atividade/2 with valid data updates the tipo_atividade" do
      tipo_atividade = tipo_atividade_fixture()
      update_attrs = %{nome: "some updated nome"}

      assert {:ok, %TipoAtividade{} = tipo_atividade} = Atividades.update_tipo_atividade(tipo_atividade, update_attrs)
      assert tipo_atividade.nome == "some updated nome"
    end

    test "update_tipo_atividade/2 with invalid data returns error changeset" do
      tipo_atividade = tipo_atividade_fixture()
      assert {:error, %Ecto.Changeset{}} = Atividades.update_tipo_atividade(tipo_atividade, @invalid_attrs)
      assert tipo_atividade == Atividades.get_tipo_atividade!(tipo_atividade.id)
    end

    test "delete_tipo_atividade/1 deletes the tipo_atividade" do
      tipo_atividade = tipo_atividade_fixture()
      assert {:ok, %TipoAtividade{}} = Atividades.delete_tipo_atividade(tipo_atividade)
      assert_raise Ecto.NoResultsError, fn -> Atividades.get_tipo_atividade!(tipo_atividade.id) end
    end

    test "change_tipo_atividade/1 returns a tipo_atividade changeset" do
      tipo_atividade = tipo_atividade_fixture()
      assert %Ecto.Changeset{} = Atividades.change_tipo_atividade(tipo_atividade)
    end
  end
end
