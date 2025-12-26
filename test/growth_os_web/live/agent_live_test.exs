defmodule GrowthOsWeb.AgentLiveTest do
  use GrowthOsWeb.ConnCase

  import Phoenix.LiveViewTest
  import GrowthOs.TenancyFixtures
  import GrowthOs.AgentsFixtures

  test "disconnected and connected render", %{conn: conn} do
    scope = user_scope_fixture()
    conn = log_in_user(conn, scope.user)
    
    tenant = tenant_fixture(scope)
    agent = agent_profile_fixture(scope, %{tenant_id: tenant.id})

    {:ok, agent_live, html} = live(conn, ~p"/agents")
    assert html =~ "AI Agents"
    assert render(agent_live) =~ agent.name
  end
end
