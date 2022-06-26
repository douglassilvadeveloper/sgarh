defmodule Sgarh.Repo do
  use Ecto.Repo,
    otp_app: :sgarh,
    adapter: Ecto.Adapters.Postgres
end
