defmodule Sgarh.ContasTest do
  use Sgarh.DataCase

  alias Sgarh.Contas

  import Sgarh.ContasFixtures
  alias Sgarh.Contas.{Usuario, UsuarioToken}

  describe "get_usuario_by_email/1" do
    test "does not return the usuario if the email does not exist" do
      refute Contas.get_usuario_by_email("unknown@example.com")
    end

    test "returns the usuario if the email exists" do
      %{id: id} = usuario = usuario_fixture()
      assert %Usuario{id: ^id} = Contas.get_usuario_by_email(usuario.email)
    end
  end

  describe "get_usuario_by_email_and_password/2" do
    test "does not return the usuario if the email does not exist" do
      refute Contas.get_usuario_by_email_and_password("unknown@example.com", "hello world!")
    end

    test "does not return the usuario if the password is not valid" do
      usuario = usuario_fixture()
      refute Contas.get_usuario_by_email_and_password(usuario.email, "invalid")
    end

    test "returns the usuario if the email and password are valid" do
      %{id: id} = usuario = usuario_fixture()

      assert %Usuario{id: ^id} =
               Contas.get_usuario_by_email_and_password(usuario.email, valid_usuario_password())
    end
  end

  describe "get_usuario!/1" do
    test "raises if id is invalid" do
      assert_raise Ecto.NoResultsError, fn ->
        Contas.get_usuario!("11111111-1111-1111-1111-111111111111")
      end
    end

    test "returns the usuario with the given id" do
      %{id: id} = usuario = usuario_fixture()
      assert %Usuario{id: ^id} = Contas.get_usuario!(usuario.id)
    end
  end

  describe "register_usuario/1" do
    test "requires email and password to be set" do
      {:error, changeset} = Contas.register_usuario(%{})

      assert %{
               password: ["can't be blank"],
               email: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "validates email and password when given" do
      {:error, changeset} = Contas.register_usuario(%{email: "not valid", password: "not valid"})

      assert %{
               email: ["must have the @ sign and no spaces"],
               password: ["should be at least 12 character(s)"]
             } = errors_on(changeset)
    end

    test "validates maximum values for email and password for security" do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Contas.register_usuario(%{email: too_long, password: too_long})
      assert "should be at most 160 character(s)" in errors_on(changeset).email
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates email uniqueness" do
      %{email: email} = usuario_fixture()
      {:error, changeset} = Contas.register_usuario(%{email: email})
      assert "has already been taken" in errors_on(changeset).email

      # Now try with the upper cased email too, to check that email case is ignored.
      {:error, changeset} = Contas.register_usuario(%{email: String.upcase(email)})
      assert "has already been taken" in errors_on(changeset).email
    end

    test "registers usuarios with a hashed password" do
      email = unique_usuario_email()
      {:ok, usuario} = Contas.register_usuario(valid_usuario_attributes(email: email))
      assert usuario.email == email
      assert is_binary(usuario.hashed_password)
      assert is_nil(usuario.confirmed_at)
      assert is_nil(usuario.password)
    end
  end

  describe "change_usuario_registration/2" do
    test "returns a changeset" do
      assert %Ecto.Changeset{} = changeset = Contas.change_usuario_registration(%Usuario{})
      assert changeset.required == [:password, :email]
    end

    test "allows fields to be set" do
      email = unique_usuario_email()
      password = valid_usuario_password()

      changeset =
        Contas.change_usuario_registration(
          %Usuario{},
          valid_usuario_attributes(email: email, password: password)
        )

      assert changeset.valid?
      assert get_change(changeset, :email) == email
      assert get_change(changeset, :password) == password
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "change_usuario_email/2" do
    test "returns a usuario changeset" do
      assert %Ecto.Changeset{} = changeset = Contas.change_usuario_email(%Usuario{})
      assert changeset.required == [:email]
    end
  end

  describe "apply_usuario_email/3" do
    setup do
      %{usuario: usuario_fixture()}
    end

    test "requires email to change", %{usuario: usuario} do
      {:error, changeset} = Contas.apply_usuario_email(usuario, valid_usuario_password(), %{})
      assert %{email: ["did not change"]} = errors_on(changeset)
    end

    test "validates email", %{usuario: usuario} do
      {:error, changeset} =
        Contas.apply_usuario_email(usuario, valid_usuario_password(), %{email: "not valid"})

      assert %{email: ["must have the @ sign and no spaces"]} = errors_on(changeset)
    end

    test "validates maximum value for email for security", %{usuario: usuario} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Contas.apply_usuario_email(usuario, valid_usuario_password(), %{email: too_long})

      assert "should be at most 160 character(s)" in errors_on(changeset).email
    end

    test "validates email uniqueness", %{usuario: usuario} do
      %{email: email} = usuario_fixture()

      {:error, changeset} =
        Contas.apply_usuario_email(usuario, valid_usuario_password(), %{email: email})

      assert "has already been taken" in errors_on(changeset).email
    end

    test "validates current password", %{usuario: usuario} do
      {:error, changeset} =
        Contas.apply_usuario_email(usuario, "invalid", %{email: unique_usuario_email()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "applies the email without persisting it", %{usuario: usuario} do
      email = unique_usuario_email()
      {:ok, usuario} = Contas.apply_usuario_email(usuario, valid_usuario_password(), %{email: email})
      assert usuario.email == email
      assert Contas.get_usuario!(usuario.id).email != email
    end
  end

  describe "deliver_update_email_instructions/3" do
    setup do
      %{usuario: usuario_fixture()}
    end

    test "sends token through notification", %{usuario: usuario} do
      token =
        extract_usuario_token(fn url ->
          Contas.deliver_update_email_instructions(usuario, "current@example.com", url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert usuario_token = Repo.get_by(UsuarioToken, token: :crypto.hash(:sha256, token))
      assert usuario_token.usuario_id == usuario.id
      assert usuario_token.sent_to == usuario.email
      assert usuario_token.context == "change:current@example.com"
    end
  end

  describe "update_usuario_email/2" do
    setup do
      usuario = usuario_fixture()
      email = unique_usuario_email()

      token =
        extract_usuario_token(fn url ->
          Contas.deliver_update_email_instructions(%{usuario | email: email}, usuario.email, url)
        end)

      %{usuario: usuario, token: token, email: email}
    end

    test "updates the email with a valid token", %{usuario: usuario, token: token, email: email} do
      assert Contas.update_usuario_email(usuario, token) == :ok
      changed_usuario = Repo.get!(Usuario, usuario.id)
      assert changed_usuario.email != usuario.email
      assert changed_usuario.email == email
      assert changed_usuario.confirmed_at
      assert changed_usuario.confirmed_at != usuario.confirmed_at
      refute Repo.get_by(UsuarioToken, usuario_id: usuario.id)
    end

    test "does not update email with invalid token", %{usuario: usuario} do
      assert Contas.update_usuario_email(usuario, "oops") == :error
      assert Repo.get!(Usuario, usuario.id).email == usuario.email
      assert Repo.get_by(UsuarioToken, usuario_id: usuario.id)
    end

    test "does not update email if usuario email changed", %{usuario: usuario, token: token} do
      assert Contas.update_usuario_email(%{usuario | email: "current@example.com"}, token) == :error
      assert Repo.get!(Usuario, usuario.id).email == usuario.email
      assert Repo.get_by(UsuarioToken, usuario_id: usuario.id)
    end

    test "does not update email if token expired", %{usuario: usuario, token: token} do
      {1, nil} = Repo.update_all(UsuarioToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Contas.update_usuario_email(usuario, token) == :error
      assert Repo.get!(Usuario, usuario.id).email == usuario.email
      assert Repo.get_by(UsuarioToken, usuario_id: usuario.id)
    end
  end

  describe "change_usuario_password/2" do
    test "returns a usuario changeset" do
      assert %Ecto.Changeset{} = changeset = Contas.change_usuario_password(%Usuario{})
      assert changeset.required == [:password]
    end

    test "allows fields to be set" do
      changeset =
        Contas.change_usuario_password(%Usuario{}, %{
          "password" => "new valid password"
        })

      assert changeset.valid?
      assert get_change(changeset, :password) == "new valid password"
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "update_usuario_password/3" do
    setup do
      %{usuario: usuario_fixture()}
    end

    test "validates password", %{usuario: usuario} do
      {:error, changeset} =
        Contas.update_usuario_password(usuario, valid_usuario_password(), %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{usuario: usuario} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Contas.update_usuario_password(usuario, valid_usuario_password(), %{password: too_long})

      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates current password", %{usuario: usuario} do
      {:error, changeset} =
        Contas.update_usuario_password(usuario, "invalid", %{password: valid_usuario_password()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "updates the password", %{usuario: usuario} do
      {:ok, usuario} =
        Contas.update_usuario_password(usuario, valid_usuario_password(), %{
          password: "new valid password"
        })

      assert is_nil(usuario.password)
      assert Contas.get_usuario_by_email_and_password(usuario.email, "new valid password")
    end

    test "deletes all tokens for the given usuario", %{usuario: usuario} do
      _ = Contas.generate_usuario_session_token(usuario)

      {:ok, _} =
        Contas.update_usuario_password(usuario, valid_usuario_password(), %{
          password: "new valid password"
        })

      refute Repo.get_by(UsuarioToken, usuario_id: usuario.id)
    end
  end

  describe "generate_usuario_session_token/1" do
    setup do
      %{usuario: usuario_fixture()}
    end

    test "generates a token", %{usuario: usuario} do
      token = Contas.generate_usuario_session_token(usuario)
      assert usuario_token = Repo.get_by(UsuarioToken, token: token)
      assert usuario_token.context == "session"

      # Creating the same token for another usuario should fail
      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%UsuarioToken{
          token: usuario_token.token,
          usuario_id: usuario_fixture().id,
          context: "session"
        })
      end
    end
  end

  describe "get_usuario_by_session_token/1" do
    setup do
      usuario = usuario_fixture()
      token = Contas.generate_usuario_session_token(usuario)
      %{usuario: usuario, token: token}
    end

    test "returns usuario by token", %{usuario: usuario, token: token} do
      assert session_usuario = Contas.get_usuario_by_session_token(token)
      assert session_usuario.id == usuario.id
    end

    test "does not return usuario for invalid token" do
      refute Contas.get_usuario_by_session_token("oops")
    end

    test "does not return usuario for expired token", %{token: token} do
      {1, nil} = Repo.update_all(UsuarioToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Contas.get_usuario_by_session_token(token)
    end
  end

  describe "delete_session_token/1" do
    test "deletes the token" do
      usuario = usuario_fixture()
      token = Contas.generate_usuario_session_token(usuario)
      assert Contas.delete_session_token(token) == :ok
      refute Contas.get_usuario_by_session_token(token)
    end
  end

  describe "deliver_usuario_confirmation_instructions/2" do
    setup do
      %{usuario: usuario_fixture()}
    end

    test "sends token through notification", %{usuario: usuario} do
      token =
        extract_usuario_token(fn url ->
          Contas.deliver_usuario_confirmation_instructions(usuario, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert usuario_token = Repo.get_by(UsuarioToken, token: :crypto.hash(:sha256, token))
      assert usuario_token.usuario_id == usuario.id
      assert usuario_token.sent_to == usuario.email
      assert usuario_token.context == "confirm"
    end
  end

  describe "confirm_usuario/1" do
    setup do
      usuario = usuario_fixture()

      token =
        extract_usuario_token(fn url ->
          Contas.deliver_usuario_confirmation_instructions(usuario, url)
        end)

      %{usuario: usuario, token: token}
    end

    test "confirms the email with a valid token", %{usuario: usuario, token: token} do
      assert {:ok, confirmed_usuario} = Contas.confirm_usuario(token)
      assert confirmed_usuario.confirmed_at
      assert confirmed_usuario.confirmed_at != usuario.confirmed_at
      assert Repo.get!(Usuario, usuario.id).confirmed_at
      refute Repo.get_by(UsuarioToken, usuario_id: usuario.id)
    end

    test "does not confirm with invalid token", %{usuario: usuario} do
      assert Contas.confirm_usuario("oops") == :error
      refute Repo.get!(Usuario, usuario.id).confirmed_at
      assert Repo.get_by(UsuarioToken, usuario_id: usuario.id)
    end

    test "does not confirm email if token expired", %{usuario: usuario, token: token} do
      {1, nil} = Repo.update_all(UsuarioToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Contas.confirm_usuario(token) == :error
      refute Repo.get!(Usuario, usuario.id).confirmed_at
      assert Repo.get_by(UsuarioToken, usuario_id: usuario.id)
    end
  end

  describe "deliver_usuario_reset_password_instructions/2" do
    setup do
      %{usuario: usuario_fixture()}
    end

    test "sends token through notification", %{usuario: usuario} do
      token =
        extract_usuario_token(fn url ->
          Contas.deliver_usuario_reset_password_instructions(usuario, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert usuario_token = Repo.get_by(UsuarioToken, token: :crypto.hash(:sha256, token))
      assert usuario_token.usuario_id == usuario.id
      assert usuario_token.sent_to == usuario.email
      assert usuario_token.context == "reset_password"
    end
  end

  describe "get_usuario_by_reset_password_token/1" do
    setup do
      usuario = usuario_fixture()

      token =
        extract_usuario_token(fn url ->
          Contas.deliver_usuario_reset_password_instructions(usuario, url)
        end)

      %{usuario: usuario, token: token}
    end

    test "returns the usuario with valid token", %{usuario: %{id: id}, token: token} do
      assert %Usuario{id: ^id} = Contas.get_usuario_by_reset_password_token(token)
      assert Repo.get_by(UsuarioToken, usuario_id: id)
    end

    test "does not return the usuario with invalid token", %{usuario: usuario} do
      refute Contas.get_usuario_by_reset_password_token("oops")
      assert Repo.get_by(UsuarioToken, usuario_id: usuario.id)
    end

    test "does not return the usuario if token expired", %{usuario: usuario, token: token} do
      {1, nil} = Repo.update_all(UsuarioToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Contas.get_usuario_by_reset_password_token(token)
      assert Repo.get_by(UsuarioToken, usuario_id: usuario.id)
    end
  end

  describe "reset_usuario_password/2" do
    setup do
      %{usuario: usuario_fixture()}
    end

    test "validates password", %{usuario: usuario} do
      {:error, changeset} =
        Contas.reset_usuario_password(usuario, %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{usuario: usuario} do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Contas.reset_usuario_password(usuario, %{password: too_long})
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "updates the password", %{usuario: usuario} do
      {:ok, updated_usuario} = Contas.reset_usuario_password(usuario, %{password: "new valid password"})
      assert is_nil(updated_usuario.password)
      assert Contas.get_usuario_by_email_and_password(usuario.email, "new valid password")
    end

    test "deletes all tokens for the given usuario", %{usuario: usuario} do
      _ = Contas.generate_usuario_session_token(usuario)
      {:ok, _} = Contas.reset_usuario_password(usuario, %{password: "new valid password"})
      refute Repo.get_by(UsuarioToken, usuario_id: usuario.id)
    end
  end

  describe "inspect/2" do
    test "does not include password" do
      refute inspect(%Usuario{password: "123456"}) =~ "password: \"123456\""
    end
  end
end
