defmodule GrowthOs.Repo.Migrations.CreateIntegrations do
  use Ecto.Migration

  def change do
    create table(:integrations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :provider, :string
      add :status, :string
      add :config, :map
      add :tenant_id, references(:tenants, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:integrations, [:tenant_id])
  end
end
