defmodule GrowthOs.TenancyFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `GrowthOs.Tenancy` context.
  """

  import Ecto.Query

  alias GrowthOs.Tenancy
  alias GrowthOs.Tenancy.Scope

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email()
    })
  end

  def unconfirmed_user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Tenancy.register_user()

    user
  end

  def user_fixture(attrs \\ %{}) do
    user = unconfirmed_user_fixture(attrs)

    token =
      extract_user_token(fn url ->
        Tenancy.deliver_login_instructions(user, url)
      end)

    {:ok, {user, _expired_tokens}} =
      Tenancy.login_user_by_magic_link(token)

    user
  end

  def user_scope_fixture do
    user = user_fixture()
    user_scope_fixture(user)
  end

  def user_scope_fixture(user) do
    Scope.for_user(user)
  end

  def set_password(user) do
    {:ok, {user, _expired_tokens}} =
      Tenancy.update_user_password(user, %{password: valid_user_password()})

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end

  def override_token_authenticated_at(token, authenticated_at) when is_binary(token) do
    GrowthOs.Repo.update_all(
      from(t in Tenancy.UserToken,
        where: t.token == ^token
      ),
      set: [authenticated_at: authenticated_at]
    )
  end

  def generate_user_magic_link_token(user) do
    {encoded_token, user_token} = Tenancy.UserToken.build_email_token(user, "login")
    GrowthOs.Repo.insert!(user_token)
    {encoded_token, user_token.token}
  end

  def offset_user_token(token, amount_to_add, unit) do
    dt = DateTime.add(DateTime.utc_now(:second), amount_to_add, unit)

    GrowthOs.Repo.update_all(
      from(ut in Tenancy.UserToken, where: ut.token == ^token),
      set: [inserted_at: dt, authenticated_at: dt]
    )
  end

  @doc """
  Generate a tenant.
  """
  def tenant_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        name: "some name",
        plan: "some plan",
        slug: "some slug",
        status: "some status"
      })

    {:ok, tenant} = GrowthOs.Tenancy.create_tenant(scope, attrs)
    tenant
  end

  @doc """
  Generate a membership.
  """
  def membership_fixture(scope, attrs \\ %{}) do
    tenant = tenant_fixture(scope)
    # tenant_fixture creates an "owner" membership automatically.
    # We retrieve it.
    [membership] = GrowthOs.Tenancy.list_memberships(scope) |> Enum.filter(&(&1.tenant_id == tenant.id))

    if attrs != %{} do
      {:ok, membership} = GrowthOs.Tenancy.update_membership(scope, membership, attrs)
      membership
    else
      membership
    end
  end
end
