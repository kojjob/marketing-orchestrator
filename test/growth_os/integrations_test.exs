defmodule GrowthOs.IntegrationsTest do
  use GrowthOs.DataCase

  alias GrowthOs.Integrations
  alias GrowthOs.TenancyFixtures

  import GrowthOs.TenancyFixtures
  import GrowthOs.IntegrationsFixtures

  describe "integrations" do
    alias GrowthOs.Integrations.Integration

    @invalid_attrs %{status: nil, config: nil, provider: nil}

    test "list_integrations/1 returns all scoped integrations" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      integration = integration_fixture(scope)
      other_integration = integration_fixture(other_scope)
      assert Integrations.list_integrations(scope) == [integration]
      assert Integrations.list_integrations(other_scope) == [other_integration]
    end

    test "get_integration!/2 returns the integration with given id" do
      scope = user_scope_fixture()
      integration = integration_fixture(scope)
      other_scope = user_scope_fixture()
      assert Integrations.get_integration!(scope, integration.id) == integration
      assert_raise Ecto.NoResultsError, fn -> Integrations.get_integration!(other_scope, integration.id) end
    end

    test "create_integration/2 with valid data creates a integration" do
      scope = user_scope_fixture()
      tenant = TenancyFixtures.tenant_fixture(scope)
      valid_attrs = %{status: "some status", config: %{}, provider: "some provider", tenant_id: tenant.id}

      assert {:ok, %Integration{} = integration} = Integrations.create_integration(scope, valid_attrs)
      assert integration.status == "some status"
      assert integration.config == %{}
      assert integration.provider == "some provider"
    end

    test "create_integration/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Integrations.create_integration(scope, @invalid_attrs)
    end

    test "update_integration/3 with valid data updates the integration" do
      scope = user_scope_fixture()
      integration = integration_fixture(scope)
      update_attrs = %{status: "some updated status", config: %{}, provider: "some updated provider"}

      assert {:ok, %Integration{} = integration} = Integrations.update_integration(scope, integration, update_attrs)
      assert integration.status == "some updated status"
      assert integration.config == %{}
      assert integration.provider == "some updated provider"
    end

    test "update_integration/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      integration = integration_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Integrations.update_integration(scope, integration, @invalid_attrs)
      assert integration == Integrations.get_integration!(scope, integration.id)
    end

    test "delete_integration/2 deletes the integration" do
      scope = user_scope_fixture()
      integration = integration_fixture(scope)
      assert {:ok, %Integration{}} = Integrations.delete_integration(scope, integration)
      assert_raise Ecto.NoResultsError, fn -> Integrations.get_integration!(scope, integration.id) end
    end

    test "change_integration/2 returns a integration changeset" do
      scope = user_scope_fixture()
      integration = integration_fixture(scope)
      assert %Ecto.Changeset{} = Integrations.change_integration(scope, integration)
    end
  end

  describe "credentials" do
    alias GrowthOs.Integrations.Credential

    import GrowthOs.TenancyFixtures, only: [user_scope_fixture: 0]
    import GrowthOs.IntegrationsFixtures

    @invalid_attrs %{encrypted_blob: nil, rotated_at: nil}

    test "list_credentials/1 returns all scoped credentials" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      credential = credential_fixture(scope)
      other_credential = credential_fixture(other_scope)
      assert Integrations.list_credentials(scope) == [credential]
      assert Integrations.list_credentials(other_scope) == [other_credential]
    end

    test "get_credential!/2 returns the credential with given id" do
      scope = user_scope_fixture()
      credential = credential_fixture(scope)
      other_scope = user_scope_fixture()
      assert Integrations.get_credential!(scope, credential.id) == credential
      assert_raise Ecto.NoResultsError, fn -> Integrations.get_credential!(other_scope, credential.id) end
    end

    test "create_credential/2 with valid data creates a credential" do
      scope = user_scope_fixture()
      integration = integration_fixture(scope)
      valid_attrs = %{encrypted_blob: "some encrypted_blob", rotated_at: ~U[2025-12-25 06:24:00Z], tenant_id: integration.tenant_id, integration_id: integration.id}

      assert {:ok, %Credential{} = credential} = Integrations.create_credential(scope, valid_attrs)
      assert credential.encrypted_blob == "some encrypted_blob"
      assert credential.rotated_at == ~U[2025-12-25 06:24:00Z]
    end

    test "create_credential/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Integrations.create_credential(scope, @invalid_attrs)
    end

    test "update_credential/3 with valid data updates the credential" do
      scope = user_scope_fixture()
      credential = credential_fixture(scope)
      update_attrs = %{encrypted_blob: "some updated encrypted_blob", rotated_at: ~U[2025-12-26 06:24:00Z]}

      assert {:ok, %Credential{} = credential} = Integrations.update_credential(scope, credential, update_attrs)
      assert credential.encrypted_blob == "some updated encrypted_blob"
      assert credential.rotated_at == ~U[2025-12-26 06:24:00Z]
    end

    test "update_credential/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      credential = credential_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Integrations.update_credential(scope, credential, @invalid_attrs)
      assert credential == Integrations.get_credential!(scope, credential.id)
    end

    test "delete_credential/2 deletes the credential" do
      scope = user_scope_fixture()
      credential = credential_fixture(scope)
      assert {:ok, %Credential{}} = Integrations.delete_credential(scope, credential)
      assert_raise Ecto.NoResultsError, fn -> Integrations.get_credential!(scope, credential.id) end
    end

    test "change_credential/2 returns a credential changeset" do
      scope = user_scope_fixture()
      credential = credential_fixture(scope)
      assert %Ecto.Changeset{} = Integrations.change_credential(scope, credential)
    end
  end

  describe "webhooks" do
    alias GrowthOs.Integrations.Webhook

    import GrowthOs.TenancyFixtures, only: [user_scope_fixture: 0]
    import GrowthOs.IntegrationsFixtures

    @invalid_attrs %{status: nil, provider: nil, secret: nil}

    test "list_webhooks/1 returns all scoped webhooks" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      webhook = webhook_fixture(scope)
      other_webhook = webhook_fixture(other_scope)
      assert Integrations.list_webhooks(scope) == [webhook]
      assert Integrations.list_webhooks(other_scope) == [other_webhook]
    end

    test "get_webhook!/2 returns the webhook with given id" do
      scope = user_scope_fixture()
      webhook = webhook_fixture(scope)
      other_scope = user_scope_fixture()
      assert Integrations.get_webhook!(scope, webhook.id) == webhook
      assert_raise Ecto.NoResultsError, fn -> Integrations.get_webhook!(other_scope, webhook.id) end
    end

    test "create_webhook/2 with valid data creates a webhook" do
      scope = user_scope_fixture()
      tenant = TenancyFixtures.tenant_fixture(scope)
      valid_attrs = %{status: "some status", provider: "some provider", secret: "some secret", tenant_id: tenant.id}

      assert {:ok, %Webhook{} = webhook} = Integrations.create_webhook(scope, valid_attrs)
      assert webhook.status == "some status"
      assert webhook.provider == "some provider"
      assert webhook.secret == "some secret"
    end

    test "create_webhook/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Integrations.create_webhook(scope, @invalid_attrs)
    end

    test "update_webhook/3 with valid data updates the webhook" do
      scope = user_scope_fixture()
      webhook = webhook_fixture(scope)
      update_attrs = %{status: "some updated status", provider: "some updated provider", secret: "some updated secret"}

      assert {:ok, %Webhook{} = webhook} = Integrations.update_webhook(scope, webhook, update_attrs)
      assert webhook.status == "some updated status"
      assert webhook.provider == "some updated provider"
      assert webhook.secret == "some updated secret"
    end

    test "update_webhook/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      webhook = webhook_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Integrations.update_webhook(scope, webhook, @invalid_attrs)
      assert webhook == Integrations.get_webhook!(scope, webhook.id)
    end

    test "delete_webhook/2 deletes the webhook" do
      scope = user_scope_fixture()
      webhook = webhook_fixture(scope)
      assert {:ok, %Webhook{}} = Integrations.delete_webhook(scope, webhook)
      assert_raise Ecto.NoResultsError, fn -> Integrations.get_webhook!(scope, webhook.id) end
    end

    test "change_webhook/2 returns a webhook changeset" do
      scope = user_scope_fixture()
      webhook = webhook_fixture(scope)
      assert %Ecto.Changeset{} = Integrations.change_webhook(scope, webhook)
    end
  end

  describe "sync_jobs" do
    alias GrowthOs.Integrations.SyncJob

    import GrowthOs.TenancyFixtures, only: [user_scope_fixture: 0]
    import GrowthOs.IntegrationsFixtures

    @invalid_attrs %{status: nil, started_at: nil, stats: nil, finished_at: nil}

    test "list_sync_jobs/1 returns all scoped sync_jobs" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      sync_job = sync_job_fixture(scope)
      other_sync_job = sync_job_fixture(other_scope)
      assert Integrations.list_sync_jobs(scope) == [sync_job]
      assert Integrations.list_sync_jobs(other_scope) == [other_sync_job]
    end

    test "get_sync_job!/2 returns the sync_job with given id" do
      scope = user_scope_fixture()
      sync_job = sync_job_fixture(scope)
      other_scope = user_scope_fixture()
      assert Integrations.get_sync_job!(scope, sync_job.id) == sync_job
      assert_raise Ecto.NoResultsError, fn -> Integrations.get_sync_job!(other_scope, sync_job.id) end
    end

    test "create_sync_job/2 with valid data creates a sync_job" do
      scope = user_scope_fixture()
      integration = integration_fixture(scope)
      valid_attrs = %{status: "some status", started_at: ~U[2025-12-25 06:30:00Z], stats: %{}, finished_at: ~U[2025-12-25 06:30:00Z], tenant_id: integration.tenant_id, integration_id: integration.id}

      assert {:ok, %SyncJob{} = sync_job} = Integrations.create_sync_job(scope, valid_attrs)
      assert sync_job.status == "some status"
      assert sync_job.started_at == ~U[2025-12-25 06:30:00Z]
      assert sync_job.stats == %{}
      assert sync_job.finished_at == ~U[2025-12-25 06:30:00Z]
    end

    test "create_sync_job/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Integrations.create_sync_job(scope, @invalid_attrs)
    end

    test "update_sync_job/3 with valid data updates the sync_job" do
      scope = user_scope_fixture()
      sync_job = sync_job_fixture(scope)
      update_attrs = %{status: "some updated status", started_at: ~U[2025-12-26 06:30:00Z], stats: %{}, finished_at: ~U[2025-12-26 06:30:00Z]}

      assert {:ok, %SyncJob{} = sync_job} = Integrations.update_sync_job(scope, sync_job, update_attrs)
      assert sync_job.status == "some updated status"
      assert sync_job.started_at == ~U[2025-12-26 06:30:00Z]
      assert sync_job.stats == %{}
      assert sync_job.finished_at == ~U[2025-12-26 06:30:00Z]
    end

    test "update_sync_job/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      sync_job = sync_job_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Integrations.update_sync_job(scope, sync_job, @invalid_attrs)
      assert sync_job == Integrations.get_sync_job!(scope, sync_job.id)
    end

    test "delete_sync_job/2 deletes the sync_job" do
      scope = user_scope_fixture()
      sync_job = sync_job_fixture(scope)
      assert {:ok, %SyncJob{}} = Integrations.delete_sync_job(scope, sync_job)
      assert_raise Ecto.NoResultsError, fn -> Integrations.get_sync_job!(scope, sync_job.id) end
    end

    test "change_sync_job/2 returns a sync_job changeset" do
      scope = user_scope_fixture()
      sync_job = sync_job_fixture(scope)
      assert %Ecto.Changeset{} = Integrations.change_sync_job(scope, sync_job)
    end
  end
end
