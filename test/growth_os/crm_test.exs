defmodule GrowthOs.CrmTest do
  use GrowthOs.DataCase

  alias GrowthOs.Crm

  describe "contacts" do
    alias GrowthOs.Crm.Contact

    import GrowthOs.TenancyFixtures
    import GrowthOs.CrmFixtures

    @invalid_attrs %{first_name: nil, last_name: nil, email: nil, properties: nil}

    test "list_contacts/1 returns all scoped contacts" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      contact = contact_fixture(scope)
      other_contact = contact_fixture(other_scope)
      assert Crm.list_contacts(scope) == [contact]
      assert Crm.list_contacts(other_scope) == [other_contact]
    end

    test "get_contact!/2 returns the contact with given id" do
      scope = user_scope_fixture()
      contact = contact_fixture(scope)
      other_scope = user_scope_fixture()
      assert Crm.get_contact!(scope, contact.id) == contact
      assert_raise Ecto.NoResultsError, fn -> Crm.get_contact!(other_scope, contact.id) end
    end

    test "create_contact/2 with valid data creates a contact" do
      scope = user_scope_fixture()
      tenant = tenant_fixture(scope)
      valid_attrs = %{first_name: "some first_name", last_name: "some last_name", email: "some email", properties: %{}, tenant_id: tenant.id}

      assert {:ok, %Contact{} = contact} = Crm.create_contact(scope, valid_attrs)
      assert contact.first_name == "some first_name"
      assert contact.last_name == "some last_name"
      assert contact.email == "some email"
      assert contact.properties == %{}
      assert contact.tenant_id == tenant.id
    end

    test "create_contact/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Crm.create_contact(scope, @invalid_attrs)
    end

    test "update_contact/3 with valid data updates the contact" do
      scope = user_scope_fixture()
      contact = contact_fixture(scope)
      update_attrs = %{first_name: "some updated first_name", last_name: "some updated last_name", email: "some updated email", properties: %{}}

      assert {:ok, %Contact{} = contact} = Crm.update_contact(scope, contact, update_attrs)
      assert contact.first_name == "some updated first_name"
      assert contact.last_name == "some updated last_name"
      assert contact.email == "some updated email"
      assert contact.properties == %{}
    end

    test "update_contact/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      contact = contact_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Crm.update_contact(scope, contact, @invalid_attrs)
      assert contact == Crm.get_contact!(scope, contact.id)
    end

    test "delete_contact/2 deletes the contact" do
      scope = user_scope_fixture()
      contact = contact_fixture(scope)
      assert {:ok, %Contact{}} = Crm.delete_contact(scope, contact)
      assert_raise Ecto.NoResultsError, fn -> Crm.get_contact!(scope, contact.id) end
    end

    test "change_contact/2 returns a contact changeset" do
      scope = user_scope_fixture()
      contact = contact_fixture(scope)
      assert %Ecto.Changeset{} = Crm.change_contact(scope, contact)
    end
  end

  describe "companies" do
    alias GrowthOs.Crm.Company

    import GrowthOs.TenancyFixtures
    import GrowthOs.CrmFixtures

    @invalid_attrs %{name: nil, domain: nil, properties: nil}

    test "list_companies/1 returns all scoped companies" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      company = company_fixture(scope)
      other_company = company_fixture(other_scope)
      assert Crm.list_companies(scope) == [company]
      assert Crm.list_companies(other_scope) == [other_company]
    end

    test "get_company!/2 returns the company with given id" do
      scope = user_scope_fixture()
      company = company_fixture(scope)
      other_scope = user_scope_fixture()
      assert Crm.get_company!(scope, company.id) == company
      assert_raise Ecto.NoResultsError, fn -> Crm.get_company!(other_scope, company.id) end
    end

    test "create_company/2 with valid data creates a company" do
      scope = user_scope_fixture()
      tenant = tenant_fixture(scope)
      valid_attrs = %{name: "some name", domain: "some domain", properties: %{}, tenant_id: tenant.id}

      assert {:ok, %Company{} = company} = Crm.create_company(scope, valid_attrs)
      assert company.name == "some name"
      assert company.domain == "some domain"
      assert company.properties == %{}
      assert company.tenant_id == tenant.id
    end

    test "create_company/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Crm.create_company(scope, @invalid_attrs)
    end

    test "update_company/3 with valid data updates the company" do
      scope = user_scope_fixture()
      company = company_fixture(scope)
      update_attrs = %{name: "some updated name", domain: "some updated domain", properties: %{}}

      assert {:ok, %Company{} = company} = Crm.update_company(scope, company, update_attrs)
      assert company.name == "some updated name"
      assert company.domain == "some updated domain"
      assert company.properties == %{}
    end

    test "update_company/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      company = company_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Crm.update_company(scope, company, @invalid_attrs)
      assert company == Crm.get_company!(scope, company.id)
    end

    test "delete_company/2 deletes the company" do
      scope = user_scope_fixture()
      company = company_fixture(scope)
      assert {:ok, %Company{}} = Crm.delete_company(scope, company)
      assert_raise Ecto.NoResultsError, fn -> Crm.get_company!(scope, company.id) end
    end

    test "change_company/2 returns a company changeset" do
      scope = user_scope_fixture()
      company = company_fixture(scope)
      assert %Ecto.Changeset{} = Crm.change_company(scope, company)
    end
  end

  describe "deals" do
    alias GrowthOs.Crm.Deal

    import GrowthOs.TenancyFixtures
    import GrowthOs.CrmFixtures

    @invalid_attrs %{name: nil, currency: nil, amount: nil, stage: nil}

    test "list_deals/1 returns all scoped deals" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      deal = deal_fixture(scope)
      other_deal = deal_fixture(other_scope)
      assert Crm.list_deals(scope) == [deal]
      assert Crm.list_deals(other_scope) == [other_deal]
    end

    test "get_deal!/2 returns the deal with given id" do
      scope = user_scope_fixture()
      deal = deal_fixture(scope)
      other_scope = user_scope_fixture()
      assert Crm.get_deal!(scope, deal.id) == deal
      assert_raise Ecto.NoResultsError, fn -> Crm.get_deal!(other_scope, deal.id) end
    end

    test "create_deal/2 with valid data creates a deal" do
      scope = user_scope_fixture()
      tenant = tenant_fixture(scope)
      valid_attrs = %{name: "some name", currency: "some currency", amount: 42, stage: "some stage", tenant_id: tenant.id}

      assert {:ok, %Deal{} = deal} = Crm.create_deal(scope, valid_attrs)
      assert deal.name == "some name"
      assert deal.currency == "some currency"
      assert deal.amount == 42
      assert deal.stage == "some stage"
      assert deal.tenant_id == tenant.id
    end

    test "create_deal/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Crm.create_deal(scope, @invalid_attrs)
    end

    test "update_deal/3 with valid data updates the deal" do
      scope = user_scope_fixture()
      deal = deal_fixture(scope)
      update_attrs = %{name: "some updated name", currency: "some updated currency", amount: 43, stage: "some updated stage"}

      assert {:ok, %Deal{} = deal} = Crm.update_deal(scope, deal, update_attrs)
      assert deal.name == "some updated name"
      assert deal.currency == "some updated currency"
      assert deal.amount == 43
      assert deal.stage == "some updated stage"
    end

    test "update_deal/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      deal = deal_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Crm.update_deal(scope, deal, @invalid_attrs)
      assert deal == Crm.get_deal!(scope, deal.id)
    end

    test "delete_deal/2 deletes the deal" do
      scope = user_scope_fixture()
      deal = deal_fixture(scope)
      assert {:ok, %Deal{}} = Crm.delete_deal(scope, deal)
      assert_raise Ecto.NoResultsError, fn -> Crm.get_deal!(scope, deal.id) end
    end

    test "change_deal/2 returns a deal changeset" do
      scope = user_scope_fixture()
      deal = deal_fixture(scope)
      assert %Ecto.Changeset{} = Crm.change_deal(scope, deal)
    end
  end

  describe "activities" do
    alias GrowthOs.Crm.Activity

    import GrowthOs.TenancyFixtures
    import GrowthOs.CrmFixtures

    @invalid_attrs %{type: nil, description: nil, occurred_at: nil}

    test "list_activities/1 returns all scoped activities" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      activity = activity_fixture(scope)
      other_activity = activity_fixture(other_scope)
      assert Crm.list_activities(scope) == [activity]
      assert Crm.list_activities(other_scope) == [other_activity]
    end

    test "get_activity!/2 returns the activity with given id" do
      scope = user_scope_fixture()
      activity = activity_fixture(scope)
      other_scope = user_scope_fixture()
      assert Crm.get_activity!(scope, activity.id) == activity
      assert_raise Ecto.NoResultsError, fn -> Crm.get_activity!(other_scope, activity.id) end
    end

    test "create_activity/2 with valid data creates a activity" do
      scope = user_scope_fixture()
      tenant = tenant_fixture(scope)
      valid_attrs = %{type: "some type", description: "some description", occurred_at: ~U[2025-12-25 11:50:00Z], tenant_id: tenant.id}

      assert {:ok, %Activity{} = activity} = Crm.create_activity(scope, valid_attrs)
      assert activity.type == "some type"
      assert activity.description == "some description"
      assert activity.occurred_at == ~U[2025-12-25 11:50:00Z]
      assert activity.tenant_id == tenant.id
    end

    test "create_activity/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Crm.create_activity(scope, @invalid_attrs)
    end

    test "update_activity/3 with valid data updates the activity" do
      scope = user_scope_fixture()
      activity = activity_fixture(scope)
      update_attrs = %{type: "some updated type", description: "some updated description", occurred_at: ~U[2025-12-26 11:50:00Z]}

      assert {:ok, %Activity{} = activity} = Crm.update_activity(scope, activity, update_attrs)
      assert activity.type == "some updated type"
      assert activity.description == "some updated description"
      assert activity.occurred_at == ~U[2025-12-26 11:50:00Z]
    end

    test "update_activity/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      activity = activity_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Crm.update_activity(scope, activity, @invalid_attrs)
      assert activity == Crm.get_activity!(scope, activity.id)
    end

    test "delete_activity/2 deletes the activity" do
      scope = user_scope_fixture()
      activity = activity_fixture(scope)
      assert {:ok, %Activity{}} = Crm.delete_activity(scope, activity)
      assert_raise Ecto.NoResultsError, fn -> Crm.get_activity!(scope, activity.id) end
    end

    test "change_activity/2 returns a activity changeset" do
      scope = user_scope_fixture()
      activity = activity_fixture(scope)
      assert %Ecto.Changeset{} = Crm.change_activity(scope, activity)
    end
  end
end
