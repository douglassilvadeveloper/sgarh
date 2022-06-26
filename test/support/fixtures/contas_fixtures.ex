defmodule Sgarh.ContasFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Sgarh.Contas` context.
  """

  def unique_usuario_email, do: "usuario#{System.unique_integer()}@example.com"
  def valid_usuario_password, do: "hello world!"

  def valid_usuario_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_usuario_email(),
      password: valid_usuario_password()
    })
  end

  def usuario_fixture(attrs \\ %{}) do
    {:ok, usuario} =
      attrs
      |> valid_usuario_attributes()
      |> Sgarh.Contas.register_usuario()

    usuario
  end

  def extract_usuario_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
