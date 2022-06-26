defmodule Sgarh.Contas.UsuarioNotifier do
  import Swoosh.Email

  alias Sgarh.Mailer

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"Sgarh", "contact@example.com"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(usuario, url) do
    deliver(usuario.email, "Confirmation instructions", """

    ==============================

    Hi #{usuario.email},

    You can confirm your account by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to reset a usuario password.
  """
  def deliver_reset_password_instructions(usuario, url) do
    deliver(usuario.email, "Reset password instructions", """

    ==============================

    Hi #{usuario.email},

    You can reset your password by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to update a usuario email.
  """
  def deliver_update_email_instructions(usuario, url) do
    deliver(usuario.email, "Update email instructions", """

    ==============================

    Hi #{usuario.email},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end
end
