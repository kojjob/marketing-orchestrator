defmodule GrowthOsWeb.WorkflowLiveTest do
  use GrowthOsWeb.ConnCase

  import Phoenix.LiveViewTest
  import GrowthOs.TenancyFixtures
  import GrowthOs.AutomationFixtures

  test "disconnected and connected render", %{conn: conn} do
    scope = user_scope_fixture()
    conn = log_in_user(conn, scope.user)
    
    tenant = tenant_fixture(scope)
    workflow = workflow_fixture(scope, %{tenant_id: tenant.id})

    {:ok, workflow_live, html} = live(conn, ~p"/workflows")
    assert html =~ "Workflows"
    assert render(workflow_live) =~ workflow.name
  end
end
