defmodule GrowthOsWeb.WebhookControllerTest do
  use GrowthOsWeb.ConnCase

  import GrowthOs.IntegrationsFixtures
  import GrowthOs.TenancyFixtures
  import GrowthOs.AutomationFixtures
  import GrowthOs.CrmFixtures
  alias GrowthOs.Crm

  test "POST /api/webhooks/:id triggers workflow", %{conn: conn} do
    # 1. Setup
    scope = user_scope_fixture()
    tenant = tenant_fixture(scope)

    # Create Webhook
    webhook = webhook_fixture(scope, %{tenant_id: tenant.id, provider: "stripe"})

    # Create Contact (to be updated)
    {:ok, contact} = Crm.create_contact(scope, %{
      first_name: "Test",
      last_name: "Payer",
      email: "payer@example.com",
      tenant_id: tenant.id,
      properties: %{}
    })

    # Create Workflow triggered by "stripe"
    {:ok, workflow} = GrowthOs.Automation.create_workflow(scope, %{
      name: "Stripe Payment",
      description: "Handles payment events",
      trigger_type: "webhook_received",
      trigger_config: %{"source" => "stripe"},
      tenant_id: tenant.id,
      is_active: true
    })

    # Add Step: Update CRM
    {:ok, _step} = GrowthOs.Automation.create_step(scope, %{
      name: "update_payer",
      type: "crm_update",
      order: 1,
      workflow_id: workflow.id,
      tenant_id: tenant.id,
      config: %{
        "entity" => "contact",
        "id_field" => "email",
        "fields_map" => %{"last_transaction_amount" => "amount"} # Map context "amount" to CRM "last_transaction_amount"
      }
    })

    # 2. Trigger
    payload = %{"email" => "payer@example.com", "amount" => 100}
    conn = post(conn, ~p"/api/webhooks/#{webhook.id}", payload)
    assert json_response(conn, 200) == %{"status" => "received"}

    # 3. Verify Side Effect
    # Since Ingestion runs in Task, we need to wait/poll.
    # We can use Process.sleep in test or retry loop.
    Process.sleep(200) # Simple wait

    updated_contact = Crm.get_contact!(scope, contact.id)
    assert updated_contact.properties["last_transaction_amount"] == 100
  end

  test "POST /api/webhooks/:id returns 404 for missing webhook", %{conn: conn} do
    conn = post(conn, ~p"/api/webhooks/00000000-0000-0000-0000-000000000000", %{})
    assert json_response(conn, 404)
  end
end
