defmodule GrowthOs.Repo.Migrations.CreateActivities do
  use Ecto.Migration

  def change do
    create table(:activities, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :type, :string
      add :description, :text
      add :occurred_at, :utc_datetime
      add :tenant_id, references(:tenants, on_delete: :nothing, type: :binary_id)
      add :contact_id, references(:contacts, on_delete: :delete_all, type: :binary_id)
      add :deal_id, references(:deals, on_delete: :delete_all, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:activities, [:tenant_id])
    create index(:activities, [:contact_id])
    create index(:activities, [:deal_id])
  end
end
