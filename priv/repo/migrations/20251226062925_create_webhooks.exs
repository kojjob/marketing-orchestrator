defmodule GrowthOs.Repo.Migrations.CreateWebhooks do
  use Ecto.Migration

  def change do
    create table(:webhooks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :provider, :string
      add :secret, :string
      add :status, :string
      add :tenant_id, references(:tenants, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:webhooks, [:tenant_id])
  end
end
