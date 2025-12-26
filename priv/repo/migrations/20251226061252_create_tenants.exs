defmodule GrowthOs.Repo.Migrations.CreateTenants do
  use Ecto.Migration

  def change do
    create table(:tenants, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :slug, :string
      add :plan, :string
      add :status, :string

      timestamps(type: :utc_datetime)
    end
  end
end
