defmodule Sgarh.Contas do
  @moduledoc """
  The Contas context.
  """

  import Ecto.Query, warn: false
  alias Sgarh.Repo

  alias Sgarh.Contas.{Usuario, UsuarioToken, UsuarioNotifier}

  ## Database getters

  @doc """
  Gets a usuario by email.

  ## Examples

      iex> get_usuario_by_email("foo@example.com")
      %Usuario{}

      iex> get_usuario_by_email("unknown@example.com")
      nil

  """
  def get_usuario_by_email(email) when is_binary(email) do
    Repo.get_by(Usuario, email: email)
  end

  @doc """
  Gets a usuario by email and password.

  ## Examples

      iex> get_usuario_by_email_and_password("foo@example.com", "correct_password")
      %Usuario{}

      iex> get_usuario_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_usuario_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    usuario = Repo.get_by(Usuario, email: email)
    if Usuario.valid_password?(usuario, password), do: usuario
  end

  @doc """
  Gets a single usuario.

  Raises `Ecto.NoResultsError` if the Usuario does not exist.

  ## Examples

      iex> get_usuario!(123)
      %Usuario{}

      iex> get_usuario!(456)
      ** (Ecto.NoResultsError)

  """
  def get_usuario!(id), do: Repo.get!(Usuario, id)

  ## Usuario registration

  @doc """
  Registers a usuario.

  ## Examples

      iex> register_usuario(%{field: value})
      {:ok, %Usuario{}}

      iex> register_usuario(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_usuario(attrs) do
    %Usuario{}
    |> Usuario.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking usuario changes.

  ## Examples

      iex> change_usuario_registration(usuario)
      %Ecto.Changeset{data: %Usuario{}}

  """
  def change_usuario_registration(%Usuario{} = usuario, attrs \\ %{}) do
    Usuario.registration_changeset(usuario, attrs, hash_password: false)
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the usuario email.

  ## Examples

      iex> change_usuario_email(usuario)
      %Ecto.Changeset{data: %Usuario{}}

  """
  def change_usuario_email(usuario, attrs \\ %{}) do
    Usuario.email_changeset(usuario, attrs)
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_usuario_email(usuario, "valid password", %{email: ...})
      {:ok, %Usuario{}}

      iex> apply_usuario_email(usuario, "invalid password", %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  def apply_usuario_email(usuario, password, attrs) do
    usuario
    |> Usuario.email_changeset(attrs)
    |> Usuario.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the usuario email using the given token.

  If the token matches, the usuario email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  def update_usuario_email(usuario, token) do
    context = "change:#{usuario.email}"

    with {:ok, query} <- UsuarioToken.verify_change_email_token_query(token, context),
         %UsuarioToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(usuario_email_multi(usuario, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp usuario_email_multi(usuario, email, context) do
    changeset =
      usuario
      |> Usuario.email_changeset(%{email: email})
      |> Usuario.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:usuario, changeset)
    |> Ecto.Multi.delete_all(:tokens, UsuarioToken.usuario_and_contexts_query(usuario, [context]))
  end

  @doc """
  Delivers the update email instructions to the given usuario.

  ## Examples

      iex> deliver_update_email_instructions(usuario, current_email, &Routes.usuario_update_email_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_update_email_instructions(%Usuario{} = usuario, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, usuario_token} = UsuarioToken.build_email_token(usuario, "change:#{current_email}")

    Repo.insert!(usuario_token)
    UsuarioNotifier.deliver_update_email_instructions(usuario, update_email_url_fun.(encoded_token))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the usuario password.

  ## Examples

      iex> change_usuario_password(usuario)
      %Ecto.Changeset{data: %Usuario{}}

  """
  def change_usuario_password(usuario, attrs \\ %{}) do
    Usuario.password_changeset(usuario, attrs, hash_password: false)
  end

  @doc """
  Updates the usuario password.

  ## Examples

      iex> update_usuario_password(usuario, "valid password", %{password: ...})
      {:ok, %Usuario{}}

      iex> update_usuario_password(usuario, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  def update_usuario_password(usuario, password, attrs) do
    changeset =
      usuario
      |> Usuario.password_changeset(attrs)
      |> Usuario.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:usuario, changeset)
    |> Ecto.Multi.delete_all(:tokens, UsuarioToken.usuario_and_contexts_query(usuario, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{usuario: usuario}} -> {:ok, usuario}
      {:error, :usuario, changeset, _} -> {:error, changeset}
    end
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_usuario_session_token(usuario) do
    {token, usuario_token} = UsuarioToken.build_session_token(usuario)
    Repo.insert!(usuario_token)
    token
  end

  @doc """
  Gets the usuario with the given signed token.
  """
  def get_usuario_by_session_token(token) do
    {:ok, query} = UsuarioToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_session_token(token) do
    Repo.delete_all(UsuarioToken.token_and_context_query(token, "session"))
    :ok
  end

  ## Confirmation

  @doc """
  Delivers the confirmation email instructions to the given usuario.

  ## Examples

      iex> deliver_usuario_confirmation_instructions(usuario, &Routes.usuario_confirmation_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_usuario_confirmation_instructions(confirmed_usuario, &Routes.usuario_confirmation_url(conn, :edit, &1))
      {:error, :already_confirmed}

  """
  def deliver_usuario_confirmation_instructions(%Usuario{} = usuario, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if usuario.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, usuario_token} = UsuarioToken.build_email_token(usuario, "confirm")
      Repo.insert!(usuario_token)
      UsuarioNotifier.deliver_confirmation_instructions(usuario, confirmation_url_fun.(encoded_token))
    end
  end

  @doc """
  Confirms a usuario by the given token.

  If the token matches, the usuario account is marked as confirmed
  and the token is deleted.
  """
  def confirm_usuario(token) do
    with {:ok, query} <- UsuarioToken.verify_email_token_query(token, "confirm"),
         %Usuario{} = usuario <- Repo.one(query),
         {:ok, %{usuario: usuario}} <- Repo.transaction(confirm_usuario_multi(usuario)) do
      {:ok, usuario}
    else
      _ -> :error
    end
  end

  defp confirm_usuario_multi(usuario) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:usuario, Usuario.confirm_changeset(usuario))
    |> Ecto.Multi.delete_all(:tokens, UsuarioToken.usuario_and_contexts_query(usuario, ["confirm"]))
  end

  ## Reset password

  @doc """
  Delivers the reset password email to the given usuario.

  ## Examples

      iex> deliver_usuario_reset_password_instructions(usuario, &Routes.usuario_reset_password_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_usuario_reset_password_instructions(%Usuario{} = usuario, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, usuario_token} = UsuarioToken.build_email_token(usuario, "reset_password")
    Repo.insert!(usuario_token)
    UsuarioNotifier.deliver_reset_password_instructions(usuario, reset_password_url_fun.(encoded_token))
  end

  @doc """
  Gets the usuario by reset password token.

  ## Examples

      iex> get_usuario_by_reset_password_token("validtoken")
      %Usuario{}

      iex> get_usuario_by_reset_password_token("invalidtoken")
      nil

  """
  def get_usuario_by_reset_password_token(token) do
    with {:ok, query} <- UsuarioToken.verify_email_token_query(token, "reset_password"),
         %Usuario{} = usuario <- Repo.one(query) do
      usuario
    else
      _ -> nil
    end
  end

  @doc """
  Resets the usuario password.

  ## Examples

      iex> reset_usuario_password(usuario, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %Usuario{}}

      iex> reset_usuario_password(usuario, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  def reset_usuario_password(usuario, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:usuario, Usuario.password_changeset(usuario, attrs))
    |> Ecto.Multi.delete_all(:tokens, UsuarioToken.usuario_and_contexts_query(usuario, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{usuario: usuario}} -> {:ok, usuario}
      {:error, :usuario, changeset, _} -> {:error, changeset}
    end
  end
end
