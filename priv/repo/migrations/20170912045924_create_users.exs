defmodule HelloHipsterStack.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, prefix: "accounts") do
      add :email, :string, null: False
      add :display_name, :string, null: False
      add :password, :string, null: False

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:email], prefix: "accounts")
  end
end
