defmodule Sgarh.Atividades do
  @moduledoc """
  The Atividades context.
  """

  import Ecto.Query, warn: false
  alias Sgarh.Repo

  alias Sgarh.Atividades.TipoAtividade

  @doc """
  Returns the list of tipos_atividades.

  ## Examples

      iex> list_tipos_atividades()
      [%TipoAtividade{}, ...]

  """
  def list_tipos_atividades do
    Repo.all(TipoAtividade)
  end

  @doc """
  Gets a single tipo_atividade.

  Raises `Ecto.NoResultsError` if the Tipo atividade does not exist.

  ## Examples

      iex> get_tipo_atividade!(123)
      %TipoAtividade{}

      iex> get_tipo_atividade!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tipo_atividade!(id), do: Repo.get!(TipoAtividade, id)

  @doc """
  Creates a tipo_atividade.

  ## Examples

      iex> create_tipo_atividade(%{field: value})
      {:ok, %TipoAtividade{}}

      iex> create_tipo_atividade(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tipo_atividade(attrs \\ %{}) do
    %TipoAtividade{}
    |> TipoAtividade.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a tipo_atividade.

  ## Examples

      iex> update_tipo_atividade(tipo_atividade, %{field: new_value})
      {:ok, %TipoAtividade{}}

      iex> update_tipo_atividade(tipo_atividade, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tipo_atividade(%TipoAtividade{} = tipo_atividade, attrs) do
    tipo_atividade
    |> TipoAtividade.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a tipo_atividade.

  ## Examples

      iex> delete_tipo_atividade(tipo_atividade)
      {:ok, %TipoAtividade{}}

      iex> delete_tipo_atividade(tipo_atividade)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tipo_atividade(%TipoAtividade{} = tipo_atividade) do
    Repo.delete(tipo_atividade)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tipo_atividade changes.

  ## Examples

      iex> change_tipo_atividade(tipo_atividade)
      %Ecto.Changeset{data: %TipoAtividade{}}

  """
  def change_tipo_atividade(%TipoAtividade{} = tipo_atividade, attrs \\ %{}) do
    TipoAtividade.changeset(tipo_atividade, attrs)
  end

  alias Sgarh.Atividades.Atividade

  @doc """
  Returns the list of atividades.

  ## Examples

      iex> list_atividades()
      [%Atividade{}, ...]

  """
  def list_atividades do
    Repo.all(Atividade)
  end

  @doc """
  Gets a single atividade.

  Raises `Ecto.NoResultsError` if the Atividade does not exist.

  ## Examples

      iex> get_atividade!(123)
      %Atividade{}

      iex> get_atividade!(456)
      ** (Ecto.NoResultsError)

  """
  def get_atividade!(id), do: Repo.get!(Atividade, id)

  @doc """
  Creates a atividade.

  ## Examples

      iex> create_atividade(%{field: value})
      {:ok, %Atividade{}}

      iex> create_atividade(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_atividade(attrs \\ %{}) do
    %Atividade{}
    |> Atividade.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a atividade.

  ## Examples

      iex> update_atividade(atividade, %{field: new_value})
      {:ok, %Atividade{}}

      iex> update_atividade(atividade, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_atividade(%Atividade{} = atividade, attrs) do
    atividade
    |> Atividade.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a atividade.

  ## Examples

      iex> delete_atividade(atividade)
      {:ok, %Atividade{}}

      iex> delete_atividade(atividade)
      {:error, %Ecto.Changeset{}}

  """
  def delete_atividade(%Atividade{} = atividade) do
    Repo.delete(atividade)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking atividade changes.

  ## Examples

      iex> change_atividade(atividade)
      %Ecto.Changeset{data: %Atividade{}}

  """
  def change_atividade(%Atividade{} = atividade, attrs \\ %{}) do
    Atividade.changeset(atividade, attrs)
  end
end
