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

  describe "atividades" do
    alias Sgarh.Atividades.Atividade

    import Sgarh.AtividadesFixtures

    @invalid_attrs %{data_base: nil, data_final: nil, encerrada: nil, titulo: nil}

    test "list_atividades/0 returns all atividades" do
      atividade = atividade_fixture()
      assert Atividades.list_atividades() == [atividade]
    end

    test "get_atividade!/1 returns the atividade with given id" do
      atividade = atividade_fixture()
      assert Atividades.get_atividade!(atividade.id) == atividade
    end

    test "create_atividade/1 with valid data creates a atividade" do
      valid_attrs = %{data_base: ~D[2022-07-23], data_final: ~D[2022-07-23], encerrada: true, titulo: "some titulo"}

      assert {:ok, %Atividade{} = atividade} = Atividades.create_atividade(valid_attrs)
      assert atividade.data_base == ~D[2022-07-23]
      assert atividade.data_final == ~D[2022-07-23]
      assert atividade.encerrada == true
      assert atividade.titulo == "some titulo"
    end

    test "create_atividade/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Atividades.create_atividade(@invalid_attrs)
    end

    test "update_atividade/2 with valid data updates the atividade" do
      atividade = atividade_fixture()
      update_attrs = %{data_base: ~D[2022-07-24], data_final: ~D[2022-07-24], encerrada: false, titulo: "some updated titulo"}

      assert {:ok, %Atividade{} = atividade} = Atividades.update_atividade(atividade, update_attrs)
      assert atividade.data_base == ~D[2022-07-24]
      assert atividade.data_final == ~D[2022-07-24]
      assert atividade.encerrada == false
      assert atividade.titulo == "some updated titulo"
    end

    test "update_atividade/2 with invalid data returns error changeset" do
      atividade = atividade_fixture()
      assert {:error, %Ecto.Changeset{}} = Atividades.update_atividade(atividade, @invalid_attrs)
      assert atividade == Atividades.get_atividade!(atividade.id)
    end

    test "delete_atividade/1 deletes the atividade" do
      atividade = atividade_fixture()
      assert {:ok, %Atividade{}} = Atividades.delete_atividade(atividade)
      assert_raise Ecto.NoResultsError, fn -> Atividades.get_atividade!(atividade.id) end
    end

    test "change_atividade/1 returns a atividade changeset" do
      atividade = atividade_fixture()
      assert %Ecto.Changeset{} = Atividades.change_atividade(atividade)
    end
  end
end
