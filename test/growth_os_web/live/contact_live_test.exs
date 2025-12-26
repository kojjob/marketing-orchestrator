defmodule GrowthOsWeb.ContactLiveTest do
  use GrowthOsWeb.ConnCase

  import Phoenix.LiveViewTest
  import GrowthOs.TenancyFixtures
  import GrowthOs.CrmFixtures

  test "lists contacts", %{conn: conn} do
    scope = user_scope_fixture()
    tenant = tenant_fixture(scope)
    conn = log_in_user(conn, scope.user)
    
    contact = contact_fixture(scope, %{tenant_id: tenant.id, first_name: "Alice", last_name: "Doe"})

    {:ok, _index_live, html} = live(conn, ~p"/contacts")
    assert html =~ "Contacts"
    assert html =~ "Alice Doe"
  end
end
