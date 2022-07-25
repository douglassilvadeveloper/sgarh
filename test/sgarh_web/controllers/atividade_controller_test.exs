defmodule SgarhWeb.AtividadeControllerTest do
  use SgarhWeb.ConnCase

  import Sgarh.AtividadesFixtures

  @create_attrs %{data_base: ~D[2022-07-23], data_final: ~D[2022-07-23], encerrada: true, titulo: "some titulo"}
  @update_attrs %{data_base: ~D[2022-07-24], data_final: ~D[2022-07-24], encerrada: false, titulo: "some updated titulo"}
  @invalid_attrs %{data_base: nil, data_final: nil, encerrada: nil, titulo: nil}

  describe "index" do
    test "lists all atividades", %{conn: conn} do
      conn = get(conn, Routes.atividade_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Atividades"
    end
  end

  describe "new atividade" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.atividade_path(conn, :new))
      assert html_response(conn, 200) =~ "New Atividade"
    end
  end

  describe "create atividade" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.atividade_path(conn, :create), atividade: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.atividade_path(conn, :show, id)

      conn = get(conn, Routes.atividade_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Atividade"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.atividade_path(conn, :create), atividade: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Atividade"
    end
  end

  describe "edit atividade" do
    setup [:create_atividade]

    test "renders form for editing chosen atividade", %{conn: conn, atividade: atividade} do
      conn = get(conn, Routes.atividade_path(conn, :edit, atividade))
      assert html_response(conn, 200) =~ "Edit Atividade"
    end
  end

  describe "update atividade" do
    setup [:create_atividade]

    test "redirects when data is valid", %{conn: conn, atividade: atividade} do
      conn = put(conn, Routes.atividade_path(conn, :update, atividade), atividade: @update_attrs)
      assert redirected_to(conn) == Routes.atividade_path(conn, :show, atividade)

      conn = get(conn, Routes.atividade_path(conn, :show, atividade))
      assert html_response(conn, 200) =~ "some updated titulo"
    end

    test "renders errors when data is invalid", %{conn: conn, atividade: atividade} do
      conn = put(conn, Routes.atividade_path(conn, :update, atividade), atividade: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Atividade"
    end
  end

  describe "delete atividade" do
    setup [:create_atividade]

    test "deletes chosen atividade", %{conn: conn, atividade: atividade} do
      conn = delete(conn, Routes.atividade_path(conn, :delete, atividade))
      assert redirected_to(conn) == Routes.atividade_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.atividade_path(conn, :show, atividade))
      end
    end
  end

  defp create_atividade(_) do
    atividade = atividade_fixture()
    %{atividade: atividade}
  end
end
