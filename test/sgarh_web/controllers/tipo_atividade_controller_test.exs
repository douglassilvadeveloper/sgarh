defmodule SgarhWeb.TipoAtividadeControllerTest do
  use SgarhWeb.ConnCase

  import Sgarh.AtividadesFixtures

  @create_attrs %{nome: "some nome"}
  @update_attrs %{nome: "some updated nome"}
  @invalid_attrs %{nome: nil}

  describe "index" do
    test "lists all tipos_atividades", %{conn: conn} do
      conn = get(conn, Routes.tipo_atividade_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Tipos atividades"
    end
  end

  describe "new tipo_atividade" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.tipo_atividade_path(conn, :new))
      assert html_response(conn, 200) =~ "New Tipo atividade"
    end
  end

  describe "create tipo_atividade" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.tipo_atividade_path(conn, :create), tipo_atividade: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.tipo_atividade_path(conn, :show, id)

      conn = get(conn, Routes.tipo_atividade_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Tipo atividade"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.tipo_atividade_path(conn, :create), tipo_atividade: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Tipo atividade"
    end
  end

  describe "edit tipo_atividade" do
    setup [:create_tipo_atividade]

    test "renders form for editing chosen tipo_atividade", %{conn: conn, tipo_atividade: tipo_atividade} do
      conn = get(conn, Routes.tipo_atividade_path(conn, :edit, tipo_atividade))
      assert html_response(conn, 200) =~ "Edit Tipo atividade"
    end
  end

  describe "update tipo_atividade" do
    setup [:create_tipo_atividade]

    test "redirects when data is valid", %{conn: conn, tipo_atividade: tipo_atividade} do
      conn = put(conn, Routes.tipo_atividade_path(conn, :update, tipo_atividade), tipo_atividade: @update_attrs)
      assert redirected_to(conn) == Routes.tipo_atividade_path(conn, :show, tipo_atividade)

      conn = get(conn, Routes.tipo_atividade_path(conn, :show, tipo_atividade))
      assert html_response(conn, 200) =~ "some updated nome"
    end

    test "renders errors when data is invalid", %{conn: conn, tipo_atividade: tipo_atividade} do
      conn = put(conn, Routes.tipo_atividade_path(conn, :update, tipo_atividade), tipo_atividade: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Tipo atividade"
    end
  end

  describe "delete tipo_atividade" do
    setup [:create_tipo_atividade]

    test "deletes chosen tipo_atividade", %{conn: conn, tipo_atividade: tipo_atividade} do
      conn = delete(conn, Routes.tipo_atividade_path(conn, :delete, tipo_atividade))
      assert redirected_to(conn) == Routes.tipo_atividade_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.tipo_atividade_path(conn, :show, tipo_atividade))
      end
    end
  end

  defp create_tipo_atividade(_) do
    tipo_atividade = tipo_atividade_fixture()
    %{tipo_atividade: tipo_atividade}
  end
end
