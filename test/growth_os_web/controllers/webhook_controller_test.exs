defmodule GrowthOsWeb.WebhookControllerTest do
  use GrowthOsWeb.ConnCase

  import GrowthOs.IntegrationsFixtures
  import GrowthOs.TenancyFixtures

  test "POST /api/webhooks/:id receives webhook", %{conn: conn} do
    scope = user_scope_fixture()
    tenant = tenant_fixture(scope)
    webhook = webhook_fixture(scope, %{tenant_id: tenant.id, provider: "generic"})

    conn = post(conn, ~p"/api/webhooks/#{webhook.id}", %{some: "data"})
    assert json_response(conn, 200) == %{"status" => "received"}
  end

  test "POST /api/webhooks/:id returns 404 for missing webhook", %{conn: conn} do
    conn = post(conn, ~p"/api/webhooks/00000000-0000-0000-0000-000000000000", %{})
    assert json_response(conn, 404)
  end
end
