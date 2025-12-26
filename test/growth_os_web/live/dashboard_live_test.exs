defmodule GrowthOsWeb.DashboardLiveTest do
  use GrowthOsWeb.ConnCase

  import Phoenix.LiveViewTest
  import GrowthOs.TenancyFixtures
  import GrowthOs.CrmFixtures

  test "disconnected and connected render", %{conn: conn} do
    scope = user_scope_fixture()
    conn = log_in_user(conn, scope.user)
    
    tenant = tenant_fixture(scope)
    activity = activity_fixture(scope, %{tenant_id: tenant.id})

    {:ok, dashboard_live, html} = live(conn, ~p"/dashboard")
    assert html =~ "Dashboard"
    assert render(dashboard_live) =~ activity.description
  end
end
