# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Sgarh.Repo.insert!(%Sgarh.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Sgarh.Repo
alias Sgarh.Contas
alias Sgarh.Contas.Usuario

Repo.delete_all(Usuario)
Contas.register_usuario(%{nome: "Chefe do RH", email: "cheferh@sgarh.com.br", password: "12345678", ativo: true, admin: true})

