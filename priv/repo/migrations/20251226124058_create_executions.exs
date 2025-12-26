defmodule GrowthOs.Repo.Migrations.CreateExecutions do
  use Ecto.Migration

  def change do
    create table(:executions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :status, :string
      add :context, :map
      add :started_at, :utc_datetime
      add :completed_at, :utc_datetime
      add :workflow_id, references(:workflows, on_delete: :nothing, type: :binary_id)
      add :tenant_id, references(:tenants, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:executions, [:workflow_id])
    create index(:executions, [:tenant_id])
  end
end
