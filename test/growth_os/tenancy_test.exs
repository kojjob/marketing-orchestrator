defmodule GrowthOs.TenancyTest do
  use GrowthOs.DataCase

  alias GrowthOs.Tenancy

  import GrowthOs.TenancyFixtures
  alias GrowthOs.Tenancy.{User, UserToken}

  describe "get_user_by_email/1" do
    test "does not return the user if the email does not exist" do
      refute Tenancy.get_user_by_email("unknown@example.com")
    end

    test "returns the user if the email exists" do
      %{id: id} = user = user_fixture()
      assert %User{id: ^id} = Tenancy.get_user_by_email(user.email)
    end
  end

  describe "get_user_by_email_and_password/2" do
    test "does not return the user if the email does not exist" do
      refute Tenancy.get_user_by_email_and_password("unknown@example.com", "hello world!")
    end

    test "does not return the user if the password is not valid" do
      user = user_fixture() |> set_password()
      refute Tenancy.get_user_by_email_and_password(user.email, "invalid")
    end

    test "returns the user if the email and password are valid" do
      %{id: id} = user = user_fixture() |> set_password()

      assert %User{id: ^id} =
               Tenancy.get_user_by_email_and_password(user.email, valid_user_password())
    end
  end

  describe "get_user!/1" do
    test "raises if id is invalid" do
      assert_raise Ecto.NoResultsError, fn ->
        Tenancy.get_user!("11111111-1111-1111-1111-111111111111")
      end
    end

    test "returns the user with the given id" do
      %{id: id} = user = user_fixture()
      assert %User{id: ^id} = Tenancy.get_user!(user.id)
    end
  end

  describe "register_user/1" do
    test "requires email to be set" do
      {:error, changeset} = Tenancy.register_user(%{})

      assert %{email: ["can't be blank"]} = errors_on(changeset)
    end

    test "validates email when given" do
      {:error, changeset} = Tenancy.register_user(%{email: "not valid"})

      assert %{email: ["must have the @ sign and no spaces"]} = errors_on(changeset)
    end

    test "validates maximum values for email for security" do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Tenancy.register_user(%{email: too_long})
      assert "should be at most 160 character(s)" in errors_on(changeset).email
    end

    test "validates email uniqueness" do
      %{email: email} = user_fixture()
      {:error, changeset} = Tenancy.register_user(%{email: email})
      assert "has already been taken" in errors_on(changeset).email

      # Now try with the uppercased email too, to check that email case is ignored.
      {:error, changeset} = Tenancy.register_user(%{email: String.upcase(email)})
      assert "has already been taken" in errors_on(changeset).email
    end

    test "registers users without password" do
      email = unique_user_email()
      {:ok, user} = Tenancy.register_user(valid_user_attributes(email: email))
      assert user.email == email
      assert is_nil(user.hashed_password)
      assert is_nil(user.confirmed_at)
      assert is_nil(user.password)
    end
  end

  describe "sudo_mode?/2" do
    test "validates the authenticated_at time" do
      now = DateTime.utc_now()

      assert Tenancy.sudo_mode?(%User{authenticated_at: DateTime.utc_now()})
      assert Tenancy.sudo_mode?(%User{authenticated_at: DateTime.add(now, -19, :minute)})
      refute Tenancy.sudo_mode?(%User{authenticated_at: DateTime.add(now, -21, :minute)})

      # minute override
      refute Tenancy.sudo_mode?(
               %User{authenticated_at: DateTime.add(now, -11, :minute)},
               -10
             )

      # not authenticated
      refute Tenancy.sudo_mode?(%User{})
    end
  end

  describe "change_user_email/3" do
    test "returns a user changeset" do
      assert %Ecto.Changeset{} = changeset = Tenancy.change_user_email(%User{})
      assert changeset.required == [:email]
    end
  end

  describe "deliver_user_update_email_instructions/3" do
    setup do
      %{user: user_fixture()}
    end

    test "sends token through notification", %{user: user} do
      token =
        extract_user_token(fn url ->
          Tenancy.deliver_user_update_email_instructions(user, "current@example.com", url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert user_token = Repo.get_by(UserToken, token: :crypto.hash(:sha256, token))
      assert user_token.user_id == user.id
      assert user_token.sent_to == user.email
      assert user_token.context == "change:current@example.com"
    end
  end

  describe "update_user_email/2" do
    setup do
      user = unconfirmed_user_fixture()
      email = unique_user_email()

      token =
        extract_user_token(fn url ->
          Tenancy.deliver_user_update_email_instructions(%{user | email: email}, user.email, url)
        end)

      %{user: user, token: token, email: email}
    end

    test "updates the email with a valid token", %{user: user, token: token, email: email} do
      assert {:ok, %{email: ^email}} = Tenancy.update_user_email(user, token)
      changed_user = Repo.get!(User, user.id)
      assert changed_user.email != user.email
      assert changed_user.email == email
      refute Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not update email with invalid token", %{user: user} do
      assert Tenancy.update_user_email(user, "oops") ==
               {:error, :transaction_aborted}

      assert Repo.get!(User, user.id).email == user.email
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not update email if user email changed", %{user: user, token: token} do
      assert Tenancy.update_user_email(%{user | email: "current@example.com"}, token) ==
               {:error, :transaction_aborted}

      assert Repo.get!(User, user.id).email == user.email
      assert Repo.get_by(UserToken, user_id: user.id)
    end

    test "does not update email if token expired", %{user: user, token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])

      assert Tenancy.update_user_email(user, token) ==
               {:error, :transaction_aborted}

      assert Repo.get!(User, user.id).email == user.email
      assert Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "change_user_password/3" do
    test "returns a user changeset" do
      assert %Ecto.Changeset{} = changeset = Tenancy.change_user_password(%User{})
      assert changeset.required == [:password]
    end

    test "allows fields to be set" do
      changeset =
        Tenancy.change_user_password(
          %User{},
          %{
            "password" => "new valid password"
          },
          hash_password: false
        )

      assert changeset.valid?
      assert get_change(changeset, :password) == "new valid password"
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "update_user_password/2" do
    setup do
      %{user: user_fixture()}
    end

    test "validates password", %{user: user} do
      {:error, changeset} =
        Tenancy.update_user_password(user, %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{user: user} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Tenancy.update_user_password(user, %{password: too_long})

      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "updates the password", %{user: user} do
      {:ok, {user, expired_tokens}} =
        Tenancy.update_user_password(user, %{
          password: "new valid password"
        })

      assert expired_tokens == []
      assert is_nil(user.password)
      assert Tenancy.get_user_by_email_and_password(user.email, "new valid password")
    end

    test "deletes all tokens for the given user", %{user: user} do
      _ = Tenancy.generate_user_session_token(user)

      {:ok, {_, _}} =
        Tenancy.update_user_password(user, %{
          password: "new valid password"
        })

      refute Repo.get_by(UserToken, user_id: user.id)
    end
  end

  describe "generate_user_session_token/1" do
    setup do
      %{user: user_fixture()}
    end

    test "generates a token", %{user: user} do
      token = Tenancy.generate_user_session_token(user)
      assert user_token = Repo.get_by(UserToken, token: token)
      assert user_token.context == "session"
      assert user_token.authenticated_at != nil

      # Creating the same token for another user should fail
      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%UserToken{
          token: user_token.token,
          user_id: user_fixture().id,
          context: "session"
        })
      end
    end

    test "duplicates the authenticated_at of given user in new token", %{user: user} do
      user = %{user | authenticated_at: DateTime.add(DateTime.utc_now(:second), -3600)}
      token = Tenancy.generate_user_session_token(user)
      assert user_token = Repo.get_by(UserToken, token: token)
      assert user_token.authenticated_at == user.authenticated_at
      assert DateTime.compare(user_token.inserted_at, user.authenticated_at) == :gt
    end
  end

  describe "get_user_by_session_token/1" do
    setup do
      user = user_fixture()
      token = Tenancy.generate_user_session_token(user)
      %{user: user, token: token}
    end

    test "returns user by token", %{user: user, token: token} do
      assert {session_user, token_inserted_at} = Tenancy.get_user_by_session_token(token)
      assert session_user.id == user.id
      assert session_user.authenticated_at != nil
      assert token_inserted_at != nil
    end

    test "does not return user for invalid token" do
      refute Tenancy.get_user_by_session_token("oops")
    end

    test "does not return user for expired token", %{token: token} do
      dt = ~N[2020-01-01 00:00:00]
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: dt, authenticated_at: dt])
      refute Tenancy.get_user_by_session_token(token)
    end
  end

  describe "get_user_by_magic_link_token/1" do
    setup do
      user = user_fixture()
      {encoded_token, _hashed_token} = generate_user_magic_link_token(user)
      %{user: user, token: encoded_token}
    end

    test "returns user by token", %{user: user, token: token} do
      assert session_user = Tenancy.get_user_by_magic_link_token(token)
      assert session_user.id == user.id
    end

    test "does not return user for invalid token" do
      refute Tenancy.get_user_by_magic_link_token("oops")
    end

    test "does not return user for expired token", %{token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Tenancy.get_user_by_magic_link_token(token)
    end
  end

  describe "login_user_by_magic_link/1" do
    test "confirms user and expires tokens" do
      user = unconfirmed_user_fixture()
      refute user.confirmed_at
      {encoded_token, hashed_token} = generate_user_magic_link_token(user)

      assert {:ok, {user, [%{token: ^hashed_token}]}} =
               Tenancy.login_user_by_magic_link(encoded_token)

      assert user.confirmed_at
    end

    test "returns user and (deleted) token for confirmed user" do
      user = user_fixture()
      assert user.confirmed_at
      {encoded_token, _hashed_token} = generate_user_magic_link_token(user)
      assert {:ok, {^user, []}} = Tenancy.login_user_by_magic_link(encoded_token)
      # one time use only
      assert {:error, :not_found} = Tenancy.login_user_by_magic_link(encoded_token)
    end

    test "raises when unconfirmed user has password set" do
      user = unconfirmed_user_fixture()
      {1, nil} = Repo.update_all(User, set: [hashed_password: "hashed"])
      {encoded_token, _hashed_token} = generate_user_magic_link_token(user)

      assert_raise RuntimeError, ~r/magic link log in is not allowed/, fn ->
        Tenancy.login_user_by_magic_link(encoded_token)
      end
    end
  end

  describe "delete_user_session_token/1" do
    test "deletes the token" do
      user = user_fixture()
      token = Tenancy.generate_user_session_token(user)
      assert Tenancy.delete_user_session_token(token) == :ok
      refute Tenancy.get_user_by_session_token(token)
    end
  end

  describe "deliver_login_instructions/2" do
    setup do
      %{user: unconfirmed_user_fixture()}
    end

    test "sends token through notification", %{user: user} do
      token =
        extract_user_token(fn url ->
          Tenancy.deliver_login_instructions(user, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert user_token = Repo.get_by(UserToken, token: :crypto.hash(:sha256, token))
      assert user_token.user_id == user.id
      assert user_token.sent_to == user.email
      assert user_token.context == "login"
    end
  end

  describe "inspect/2 for the User module" do
    test "does not include password" do
      refute inspect(%User{password: "123456"}) =~ "password: \"123456\""
    end
  end

  describe "tenants" do
    alias GrowthOs.Tenancy.Tenant

    import GrowthOs.TenancyFixtures, only: [user_scope_fixture: 0]
    import GrowthOs.TenancyFixtures

    @invalid_attrs %{name: nil, status: nil, plan: nil, slug: nil}

    test "list_tenants/1 returns all scoped tenants" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      tenant = tenant_fixture(scope)
      other_tenant = tenant_fixture(other_scope)
      assert Tenancy.list_tenants(scope) == [tenant]
      assert Tenancy.list_tenants(other_scope) == [other_tenant]
    end

    test "get_tenant!/2 returns the tenant with given id" do
      scope = user_scope_fixture()
      tenant = tenant_fixture(scope)
      other_scope = user_scope_fixture()
      assert Tenancy.get_tenant!(scope, tenant.id) == tenant
      assert_raise Ecto.NoResultsError, fn -> Tenancy.get_tenant!(other_scope, tenant.id) end
    end

    test "create_tenant/2 with valid data creates a tenant" do
      valid_attrs = %{name: "some name", status: "some status", plan: "some plan", slug: "some slug"}
      scope = user_scope_fixture()

      assert {:ok, %Tenant{} = tenant} = Tenancy.create_tenant(scope, valid_attrs)
      assert tenant.name == "some name"
      assert tenant.status == "some status"
      assert tenant.plan == "some plan"
      assert tenant.slug == "some slug"
    end

    test "create_tenant/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Tenancy.create_tenant(scope, @invalid_attrs)
    end

    test "update_tenant/3 with valid data updates the tenant" do
      scope = user_scope_fixture()
      tenant = tenant_fixture(scope)
      update_attrs = %{name: "some updated name", status: "some updated status", plan: "some updated plan", slug: "some updated slug"}

      assert {:ok, %Tenant{} = tenant} = Tenancy.update_tenant(scope, tenant, update_attrs)
      assert tenant.name == "some updated name"
      assert tenant.status == "some updated status"
      assert tenant.plan == "some updated plan"
      assert tenant.slug == "some updated slug"
    end

    test "update_tenant/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      tenant = tenant_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Tenancy.update_tenant(scope, tenant, @invalid_attrs)
      assert tenant == Tenancy.get_tenant!(scope, tenant.id)
    end

    test "delete_tenant/2 deletes the tenant" do
      scope = user_scope_fixture()
      tenant = tenant_fixture(scope)
      assert {:ok, %Tenant{}} = Tenancy.delete_tenant(scope, tenant)
      assert_raise Ecto.NoResultsError, fn -> Tenancy.get_tenant!(scope, tenant.id) end
    end

    test "change_tenant/2 returns a tenant changeset" do
      scope = user_scope_fixture()
      tenant = tenant_fixture(scope)
      assert %Ecto.Changeset{} = Tenancy.change_tenant(scope, tenant)
    end
  end

  describe "memberships" do
    alias GrowthOs.Tenancy.Membership

    import GrowthOs.TenancyFixtures, only: [user_scope_fixture: 0]
    import GrowthOs.TenancyFixtures

    @invalid_attrs %{role: nil}

    test "list_memberships/1 returns all scoped memberships" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      membership = membership_fixture(scope)
      other_membership = membership_fixture(other_scope)
      assert Tenancy.list_memberships(scope) == [membership]
      assert Tenancy.list_memberships(other_scope) == [other_membership]
    end

    test "get_membership!/2 returns the membership with given id" do
      scope = user_scope_fixture()
      membership = membership_fixture(scope)
      other_scope = user_scope_fixture()
      assert Tenancy.get_membership!(scope, membership.id) == membership
      assert_raise Ecto.NoResultsError, fn -> Tenancy.get_membership!(other_scope, membership.id) end
    end

    test "create_membership/2 with valid data creates a membership" do
      scope = user_scope_fixture()
      tenant = tenant_fixture(scope)
      valid_attrs = %{role: "some role", tenant_id: tenant.id, user_id: scope.user.id}

      assert {:ok, %Membership{} = membership} = Tenancy.create_membership(scope, valid_attrs)
      assert membership.role == "some role"
      assert membership.user_id == scope.user.id
    end

    test "create_membership/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Tenancy.create_membership(scope, @invalid_attrs)
    end

    test "update_membership/3 with valid data updates the membership" do
      scope = user_scope_fixture()
      membership = membership_fixture(scope)
      update_attrs = %{role: "some updated role"}

      assert {:ok, %Membership{} = membership} = Tenancy.update_membership(scope, membership, update_attrs)
      assert membership.role == "some updated role"
    end

    test "update_membership/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      membership = membership_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Tenancy.update_membership(scope, membership, @invalid_attrs)
      assert membership == Tenancy.get_membership!(scope, membership.id)
    end

    test "delete_membership/2 deletes the membership" do
      scope = user_scope_fixture()
      membership = membership_fixture(scope)
      assert {:ok, %Membership{}} = Tenancy.delete_membership(scope, membership)
      assert_raise Ecto.NoResultsError, fn -> Tenancy.get_membership!(scope, membership.id) end
    end

    test "change_membership/2 returns a membership changeset" do
      scope = user_scope_fixture()
      membership = membership_fixture(scope)
      assert %Ecto.Changeset{} = Tenancy.change_membership(scope, membership)
    end
  end
end
