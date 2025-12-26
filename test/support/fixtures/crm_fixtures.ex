defmodule GrowthOs.CrmFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `GrowthOs.Crm` context.
  """

  import GrowthOs.TenancyFixtures

  @doc """
  Generate a contact.
  """
  def contact_fixture(scope, attrs \\ %{}) do
    tenant_id = attrs[:tenant_id] || tenant_fixture(scope).id
    attrs =
      Enum.into(attrs, %{
        email: "some email",
        first_name: "some first_name",
        last_name: "some last_name",
        properties: %{},
        tenant_id: tenant_id
      })

    {:ok, contact} = GrowthOs.Crm.create_contact(scope, attrs)
    contact
  end

  @doc """
  Generate a company.
  """
  def company_fixture(scope, attrs \\ %{}) do
    tenant_id = attrs[:tenant_id] || tenant_fixture(scope).id
    attrs =
      Enum.into(attrs, %{
        domain: "some domain",
        name: "some name",
        properties: %{},
        tenant_id: tenant_id
      })

    {:ok, company} = GrowthOs.Crm.create_company(scope, attrs)
    company
  end

  @doc """
  Generate a deal.
  """
  def deal_fixture(scope, attrs \\ %{}) do
    tenant_id = attrs[:tenant_id] || tenant_fixture(scope).id
    company_id = attrs[:company_id] || company_fixture(scope, %{tenant_id: tenant_id}).id
    contact_id = attrs[:contact_id] || contact_fixture(scope, %{tenant_id: tenant_id}).id

    attrs =
      Enum.into(attrs, %{
        amount: 42,
        currency: "some currency",
        name: "some name",
        stage: "some stage",
        tenant_id: tenant_id,
        company_id: company_id,
        contact_id: contact_id
      })

    {:ok, deal} = GrowthOs.Crm.create_deal(scope, attrs)
    deal
  end

  @doc """
  Generate a activity.
  """
  def activity_fixture(scope, attrs \\ %{}) do
    tenant_id = attrs[:tenant_id] || tenant_fixture(scope).id
    contact_id = attrs[:contact_id] || contact_fixture(scope, %{tenant_id: tenant_id}).id
    deal_id = attrs[:deal_id] || deal_fixture(scope, %{tenant_id: tenant_id, contact_id: contact_id}).id

    attrs =
      Enum.into(attrs, %{
        description: "some description",
        occurred_at: ~U[2025-12-25 11:50:00Z],
        type: "some type",
        tenant_id: tenant_id,
        contact_id: contact_id,
        deal_id: deal_id
      })

    {:ok, activity} = GrowthOs.Crm.create_activity(scope, attrs)
    activity
  end
end
