defmodule GrowthOs.Repo.Migrations.CreateSteps do
  use Ecto.Migration

  def change do
    create table(:steps, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :type, :string
      add :config, :map
      add :order, :integer
      add :workflow_id, references(:workflows, on_delete: :nothing, type: :binary_id)
      add :tenant_id, references(:tenants, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:steps, [:workflow_id])
    create index(:steps, [:tenant_id])
  end
end
