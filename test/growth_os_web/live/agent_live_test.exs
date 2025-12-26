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

  test "saves new agent", %{conn: conn} do
    scope = user_scope_fixture()
    tenant_fixture(scope)
    conn = log_in_user(conn, scope.user)

    {:ok, index_live, _html} = live(conn, ~p"/agents")

    assert index_live |> element("a", "Hire Agent") |> render_click() =~
             "New Agent"

    assert_patch(index_live, ~p"/agents/new")

    assert index_live
           |> form("#agent-form", agent_profile: %{name: "New Sales Agent", role: "sales", model: "gpt-4-turbo", system_prompt: "You sell things."})
           |> render_submit()

    # Wait for the patch after submit
    assert_patch(index_live, ~p"/agents")

    html = render(index_live)
    assert html =~ "New Sales Agent"
  end
end
