defmodule GrowthOs.Automation.EngineTest do
  use GrowthOs.DataCase

  alias GrowthOs.Automation.Engine
  import GrowthOs.TenancyFixtures
  import GrowthOs.AutomationFixtures

  describe "engine" do
    test "run_workflow/2 creates an execution" do
      scope = user_scope_fixture()
      tenant = tenant_fixture(scope)
      workflow = workflow_fixture(scope, %{tenant_id: tenant.id})
      
      {:ok, execution} = Engine.run_workflow(workflow, %{"some" => "data"})
      
      assert execution.workflow_id == workflow.id
      assert execution.status == "running"
      assert execution.context == %{"some" => "data"}
      assert execution.tenant_id == tenant.id
    end
  end
end
