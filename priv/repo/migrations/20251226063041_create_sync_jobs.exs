defmodule GrowthOs.Repo.Migrations.CreateSyncJobs do
  use Ecto.Migration

  def change do
    create table(:sync_jobs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :status, :string
      add :started_at, :utc_datetime
      add :finished_at, :utc_datetime
      add :stats, :map
      add :tenant_id, references(:tenants, on_delete: :nothing, type: :binary_id)
      add :integration_id, references(:integrations, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:sync_jobs, [:tenant_id])
    create index(:sync_jobs, [:integration_id])
  end
end
