defmodule GrowthOs.IntegrationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `GrowthOs.Integrations` context.
  """

  import GrowthOs.TenancyFixtures

  @doc """
  Generate a integration.
  """
  def integration_fixture(scope, attrs \\ %{}) do
    tenant = tenant_fixture(scope)
    attrs =
      Enum.into(attrs, %{
        config: %{},
        provider: "some provider",
        status: "some status",
        tenant_id: tenant.id
      })

    {:ok, integration} = GrowthOs.Integrations.create_integration(scope, attrs)
    integration
  end

  @doc """
  Generate a credential.
  """
  def credential_fixture(scope, attrs \\ %{}) do
    integration = integration_fixture(scope)
    attrs =
      Enum.into(attrs, %{
        encrypted_blob: "some encrypted_blob",
        rotated_at: ~U[2025-12-25 06:24:00Z],
        integration_id: integration.id,
        tenant_id: integration.tenant_id
      })

    {:ok, credential} = GrowthOs.Integrations.create_credential(scope, attrs)
    credential
  end

  @doc """
  Generate a webhook.
  """
  def webhook_fixture(scope, attrs \\ %{}) do
    tenant = tenant_fixture(scope)
    attrs =
      Enum.into(attrs, %{
        provider: "some provider",
        secret: "some secret",
        status: "some status",
        tenant_id: tenant.id
      })

    {:ok, webhook} = GrowthOs.Integrations.create_webhook(scope, attrs)
    webhook
  end

  @doc """
  Generate a sync_job.
  """
  def sync_job_fixture(scope, attrs \\ %{}) do
    integration = integration_fixture(scope)
    attrs =
      Enum.into(attrs, %{
        finished_at: ~U[2025-12-25 06:30:00Z],
        started_at: ~U[2025-12-25 06:30:00Z],
        stats: %{},
        status: "some status",
        integration_id: integration.id,
        tenant_id: integration.tenant_id
      })

    {:ok, sync_job} = GrowthOs.Integrations.create_sync_job(scope, attrs)
    sync_job
  end
end
