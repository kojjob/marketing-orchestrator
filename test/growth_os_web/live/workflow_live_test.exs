defmodule GrowthOsWeb.WorkflowLiveTest do
  use GrowthOsWeb.ConnCase

  import Phoenix.LiveViewTest
  import GrowthOs.TenancyFixtures
  import GrowthOs.AutomationFixtures

  test "lists workflows", %{conn: conn} do
    scope = user_scope_fixture()
    tenant_fixture(scope) # Ensure tenant exists
    conn = log_in_user(conn, scope.user)

    workflow = workflow_fixture(scope, %{name: "My First Workflow"})

    {:ok, _index_live, html} = live(conn, ~p"/workflows")
    assert html =~ "Workflows"
    assert html =~ workflow.name
  end

  test "saves new workflow", %{conn: conn} do
    scope = user_scope_fixture()
    tenant_fixture(scope)
    conn = log_in_user(conn, scope.user)

    {:ok, index_live, _html} = live(conn, ~p"/workflows")

    assert index_live |> element("a", "New Workflow") |> render_click() =~
             "New Workflow"

    assert_patch(index_live, ~p"/workflows/new")

    assert index_live
           |> form("#workflow-form", workflow: %{name: "New Automation", trigger_type: "manual"})
           |> render_submit()

    # assert_patch(index_live, ~p"/workflows")

    html = render(index_live)
    assert html =~ "New Automation"
  end

  test "shows workflow details", %{conn: conn} do
    scope = user_scope_fixture()
    tenant_fixture(scope)
    conn = log_in_user(conn, scope.user)

    workflow = workflow_fixture(scope)
    step = step_fixture(scope, %{workflow_id: workflow.id, name: "Step 1"})

    {:ok, show_live, html} = live(conn, ~p"/workflows/#{workflow}")

    assert html =~ workflow.name
    assert html =~ step.name
  end
end
