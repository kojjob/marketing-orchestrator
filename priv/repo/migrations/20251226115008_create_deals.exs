defmodule GrowthOs.Repo.Migrations.CreateDeals do
  use Ecto.Migration

  def change do
    create table(:deals, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :amount, :integer
      add :currency, :string
      add :stage, :string
      add :tenant_id, references(:tenants, on_delete: :nothing, type: :binary_id)
      add :company_id, references(:companies, on_delete: :nothing, type: :binary_id)
      add :contact_id, references(:contacts, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:deals, [:tenant_id])
    create index(:deals, [:company_id])
    create index(:deals, [:contact_id])
  end
end
