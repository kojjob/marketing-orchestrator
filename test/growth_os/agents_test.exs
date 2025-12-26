defmodule GrowthOs.AgentsTest do
  use GrowthOs.DataCase

  alias GrowthOs.Agents

  describe "agent_profiles" do
    alias GrowthOs.Agents.AgentProfile

    import GrowthOs.TenancyFixtures
    import GrowthOs.AgentsFixtures

    @invalid_attrs %{name: nil, config: nil, role: nil, model: nil, system_prompt: nil}

    test "list_agent_profiles/1 returns all scoped agent_profiles" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      agent_profile = agent_profile_fixture(scope)
      other_agent_profile = agent_profile_fixture(other_scope)
      assert Agents.list_agent_profiles(scope) == [agent_profile]
      assert Agents.list_agent_profiles(other_scope) == [other_agent_profile]
    end

    test "get_agent_profile!/2 returns the agent_profile with given id" do
      scope = user_scope_fixture()
      agent_profile = agent_profile_fixture(scope)
      other_scope = user_scope_fixture()
      assert Agents.get_agent_profile!(scope, agent_profile.id) == agent_profile
      assert_raise Ecto.NoResultsError, fn -> Agents.get_agent_profile!(other_scope, agent_profile.id) end
    end

    test "create_agent_profile/2 with valid data creates a agent_profile" do
      scope = user_scope_fixture()
      tenant = tenant_fixture(scope)
      valid_attrs = %{name: "some name", config: %{}, role: "some role", model: "some model", system_prompt: "some system_prompt", tenant_id: tenant.id}

      assert {:ok, %AgentProfile{} = agent_profile} = Agents.create_agent_profile(scope, valid_attrs)
      assert agent_profile.name == "some name"
      assert agent_profile.config == %{}
      assert agent_profile.role == "some role"
      assert agent_profile.model == "some model"
      assert agent_profile.system_prompt == "some system_prompt"
      assert agent_profile.tenant_id == tenant.id
    end

    test "create_agent_profile/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Agents.create_agent_profile(scope, @invalid_attrs)
    end

    test "update_agent_profile/3 with valid data updates the agent_profile" do
      scope = user_scope_fixture()
      agent_profile = agent_profile_fixture(scope)
      update_attrs = %{name: "some updated name", config: %{}, role: "some updated role", model: "some updated model", system_prompt: "some updated system_prompt"}

      assert {:ok, %AgentProfile{} = agent_profile} = Agents.update_agent_profile(scope, agent_profile, update_attrs)
      assert agent_profile.name == "some updated name"
      assert agent_profile.config == %{}
      assert agent_profile.role == "some updated role"
      assert agent_profile.model == "some updated model"
      assert agent_profile.system_prompt == "some updated system_prompt"
    end



    test "update_agent_profile/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      agent_profile = agent_profile_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Agents.update_agent_profile(scope, agent_profile, @invalid_attrs)
      assert agent_profile == Agents.get_agent_profile!(scope, agent_profile.id)
    end

    test "delete_agent_profile/2 deletes the agent_profile" do
      scope = user_scope_fixture()
      agent_profile = agent_profile_fixture(scope)
      assert {:ok, %AgentProfile{}} = Agents.delete_agent_profile(scope, agent_profile)
      assert_raise Ecto.NoResultsError, fn -> Agents.get_agent_profile!(scope, agent_profile.id) end
    end



    test "change_agent_profile/2 returns a agent_profile changeset" do
      scope = user_scope_fixture()
      agent_profile = agent_profile_fixture(scope)
      assert %Ecto.Changeset{} = Agents.change_agent_profile(scope, agent_profile)
    end
  end

  describe "agent_tasks" do
    alias GrowthOs.Agents.AgentTask

    import GrowthOs.TenancyFixtures
    import GrowthOs.AgentsFixtures

    @invalid_attrs %{input: nil, output: nil, status: nil}

    test "list_agent_tasks/1 returns all scoped agent_tasks" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      agent_task = agent_task_fixture(scope)
      other_agent_task = agent_task_fixture(other_scope)
      assert Agents.list_agent_tasks(scope) == [agent_task]
      assert Agents.list_agent_tasks(other_scope) == [other_agent_task]
    end

    test "get_agent_task!/2 returns the agent_task with given id" do
      scope = user_scope_fixture()
      agent_task = agent_task_fixture(scope)
      other_scope = user_scope_fixture()
      assert Agents.get_agent_task!(scope, agent_task.id) == agent_task
      assert_raise Ecto.NoResultsError, fn -> Agents.get_agent_task!(other_scope, agent_task.id) end
    end

    test "create_agent_task/2 with valid data creates a agent_task" do
      scope = user_scope_fixture()
      tenant = tenant_fixture(scope)
      agent_profile = agent_profile_fixture(scope, %{tenant_id: tenant.id})
      valid_attrs = %{input: "some input", output: "some output", status: "some status", agent_profile_id: agent_profile.id, tenant_id: tenant.id}

      assert {:ok, %AgentTask{} = agent_task} = Agents.create_agent_task(scope, valid_attrs)
      assert agent_task.input == "some input"
      assert agent_task.output == "some output"
      assert agent_task.status == "some status"
      assert agent_task.tenant_id == tenant.id
    end

    test "create_agent_task/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Agents.create_agent_task(scope, @invalid_attrs)
    end

    test "update_agent_task/3 with valid data updates the agent_task" do
      scope = user_scope_fixture()
      agent_task = agent_task_fixture(scope)
      update_attrs = %{input: "some updated input", output: "some updated output", status: "some updated status"}

      assert {:ok, %AgentTask{} = agent_task} = Agents.update_agent_task(scope, agent_task, update_attrs)
      assert agent_task.input == "some updated input"
      assert agent_task.output == "some updated output"
      assert agent_task.status == "some updated status"
    end



    test "update_agent_task/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      agent_task = agent_task_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Agents.update_agent_task(scope, agent_task, @invalid_attrs)
      assert agent_task == Agents.get_agent_task!(scope, agent_task.id)
    end

    test "delete_agent_task/2 deletes the agent_task" do
      scope = user_scope_fixture()
      agent_task = agent_task_fixture(scope)
      assert {:ok, %AgentTask{}} = Agents.delete_agent_task(scope, agent_task)
      assert_raise Ecto.NoResultsError, fn -> Agents.get_agent_task!(scope, agent_task.id) end
    end



    test "change_agent_task/2 returns a agent_task changeset" do
      scope = user_scope_fixture()
      agent_task = agent_task_fixture(scope)
      assert %Ecto.Changeset{} = Agents.change_agent_task(scope, agent_task)
    end
  end
end
