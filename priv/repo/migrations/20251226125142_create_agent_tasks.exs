defmodule GrowthOs.Repo.Migrations.CreateAgentTasks do
  use Ecto.Migration

  def change do
    create table(:agent_tasks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :input, :text
      add :output, :text
      add :status, :string
      add :agent_profile_id, references(:agent_profiles, on_delete: :nothing, type: :binary_id)
      add :tenant_id, references(:tenants, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:agent_tasks, [:agent_profile_id])
    create index(:agent_tasks, [:tenant_id])
  end
end
