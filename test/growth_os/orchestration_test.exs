defmodule GrowthOs.OrchestrationTest do
  use GrowthOs.DataCase

  alias GrowthOs.Automation.Engine
  alias GrowthOs.Automation

  import GrowthOs.TenancyFixtures
  import GrowthOs.AgentsFixtures

  describe "workflow orchestration" do
    test "executes a full workflow with agent and crm steps" do
      # 1. Setup Tenant & User
      scope = user_scope_fixture()
      tenant = tenant_fixture(scope)

      # 1b. Create Contact to be updated
      {:ok, contact} = GrowthOs.Crm.create_contact(scope, %{
        first_name: "Test",
        last_name: "Lead",
        email: "test@example.com",
        properties: %{},
        tenant_id: tenant.id
      })

      # 2. Setup Agent
      agent_profile = agent_profile_fixture(scope, %{
        tenant_id: tenant.id,
        role: "analyst",
        name: "Data Analyst"
      })

      # 3. Create Workflow
      {:ok, workflow} = Automation.create_workflow(scope, %{
        name: "Analyze Lead",
        description: "Analyzes incoming leads and updates CRM",
        is_active: true,
        trigger_type: "webhook_received",
        trigger_config: %{"source" => "landing_page"},
        tenant_id: tenant.id
      })

      # 4. Add Steps
      # Step 1: Agent Analysis
      {:ok, _step1} = Automation.create_step(scope, %{
        name: "analysis",
        type: "agent",
        order: 1,
        config: %{
          "agent_profile_id" => agent_profile.id,
          "input_template" => "Analyze this lead: {{email}}"
        },
        workflow_id: workflow.id,
        tenant_id: tenant.id
      })

      # Step 2: CRM Update
      {:ok, _step2} = Automation.create_step(scope, %{
        name: "update_crm",
        type: "crm_update",
        order: 2,
        config: %{
          "entity" => "contact",
          "id_field" => "email"
        },
        workflow_id: workflow.id,
        tenant_id: tenant.id
      })

      # 5. Trigger Engine
      payload = %{"source" => "landing_page", "email" => "test@example.com"}
      assert :ok = Engine.evaluate("webhook_received", payload)

      # 6. Verify Execution
      # Wait a bit for async (though currently it's synchronous in the test environment usually)
      # But wait, Engine.evaluate spawns? No, my implementation is synchronous Enum.each for now.

      executions = Automation.list_executions(GrowthOs.Tenancy.Scope.for_tenant(tenant.id))
      assert length(executions) == 1

      execution = List.first(executions)
      assert execution.status == "completed"
      assert execution.workflow_id == workflow.id

      # 7. Verify Context Data
      assert execution.context["email"] == "test@example.com"

      # Agent output should be present
      assert execution.context["analysis"] =~ "Recommendation: Double down"

      # CRM update result should be present
      assert execution.context["update_crm"]["status"] == "updated"
      assert execution.context["update_crm"]["id"] == contact.id

      # Verify DB update
      updated_contact = GrowthOs.Crm.get_contact!(scope, contact.id)
      assert updated_contact.properties["ai_notes"] =~ "Recommendation: Double down"
    end
  end
end
