defmodule GrowthOs.Repo.Migrations.CreateAgentProfiles do
  use Ecto.Migration

  def change do
    create table(:agent_profiles, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :role, :string
      add :model, :string
      add :system_prompt, :text
      add :config, :map
      add :tenant_id, references(:tenants, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:agent_profiles, [:tenant_id])
  end
end
