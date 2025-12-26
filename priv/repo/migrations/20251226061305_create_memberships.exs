defmodule GrowthOs.Repo.Migrations.CreateMemberships do
  use Ecto.Migration

  def change do
    create table(:memberships, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :role, :string
      add :tenant_id, references(:tenants, on_delete: :delete_all, type: :binary_id)
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:memberships, [:user_id])

    create index(:memberships, [:tenant_id])
  end
end
