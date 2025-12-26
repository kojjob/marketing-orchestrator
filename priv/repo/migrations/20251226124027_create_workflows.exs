defmodule GrowthOs.Repo.Migrations.CreateWorkflows do
  use Ecto.Migration

  def change do
    create table(:workflows, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :description, :text
      add :is_active, :boolean, default: false, null: false
      add :trigger_type, :string
      add :trigger_config, :map
      add :tenant_id, references(:tenants, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:workflows, [:tenant_id])
  end
end
