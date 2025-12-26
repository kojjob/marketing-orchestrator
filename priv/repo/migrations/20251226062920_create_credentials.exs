defmodule GrowthOs.Repo.Migrations.CreateCredentials do
  use Ecto.Migration

  def change do
    create table(:credentials, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :encrypted_blob, :binary
      add :rotated_at, :utc_datetime
      add :tenant_id, references(:tenants, on_delete: :nothing, type: :binary_id)
      add :integration_id, references(:integrations, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:credentials, [:tenant_id])
    create index(:credentials, [:integration_id])
  end
end
