defmodule GrowthOs.AutomationTest do
  use GrowthOs.DataCase

  alias GrowthOs.Automation

  describe "workflows" do
    alias GrowthOs.Automation.Workflow

    import GrowthOs.TenancyFixtures
    import GrowthOs.AutomationFixtures

    @invalid_attrs %{name: nil, description: nil, is_active: nil, trigger_type: nil, trigger_config: nil}

    test "list_workflows/1 returns all scoped workflows" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      workflow = workflow_fixture(scope)
      other_workflow = workflow_fixture(other_scope)
      assert Automation.list_workflows(scope) == [workflow]
      assert Automation.list_workflows(other_scope) == [other_workflow]
    end

    test "get_workflow!/2 returns the workflow with given id" do
      scope = user_scope_fixture()
      workflow = workflow_fixture(scope)
      other_scope = user_scope_fixture()
      assert Automation.get_workflow!(scope, workflow.id) == workflow
      assert_raise Ecto.NoResultsError, fn -> Automation.get_workflow!(other_scope, workflow.id) end
    end

    test "create_workflow/2 with valid data creates a workflow" do
      scope = user_scope_fixture()
      tenant = tenant_fixture(scope)
      valid_attrs = %{name: "some name", description: "some description", is_active: true, trigger_type: "some trigger_type", trigger_config: %{}, tenant_id: tenant.id}

      assert {:ok, %Workflow{} = workflow} = Automation.create_workflow(scope, valid_attrs)
      assert workflow.name == "some name"
      assert workflow.description == "some description"
      assert workflow.is_active == true
      assert workflow.trigger_type == "some trigger_type"
      assert workflow.trigger_config == %{}
      assert workflow.tenant_id == tenant.id
    end

    test "create_workflow/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Automation.create_workflow(scope, @invalid_attrs)
    end

    test "update_workflow/3 with valid data updates the workflow" do
      scope = user_scope_fixture()
      workflow = workflow_fixture(scope)
      update_attrs = %{name: "some updated name", description: "some updated description", is_active: false, trigger_type: "some updated trigger_type", trigger_config: %{}}

      assert {:ok, %Workflow{} = workflow} = Automation.update_workflow(scope, workflow, update_attrs)
      assert workflow.name == "some updated name"
      assert workflow.description == "some updated description"
      assert workflow.is_active == false
      assert workflow.trigger_type == "some updated trigger_type"
      assert workflow.trigger_config == %{}
    end

    test "update_workflow/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      workflow = workflow_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Automation.update_workflow(scope, workflow, @invalid_attrs)
      assert workflow == Automation.get_workflow!(scope, workflow.id)
    end

    test "delete_workflow/2 deletes the workflow" do
      scope = user_scope_fixture()
      workflow = workflow_fixture(scope)
      assert {:ok, %Workflow{}} = Automation.delete_workflow(scope, workflow)
      assert_raise Ecto.NoResultsError, fn -> Automation.get_workflow!(scope, workflow.id) end
    end

    test "change_workflow/2 returns a workflow changeset" do
      scope = user_scope_fixture()
      workflow = workflow_fixture(scope)
      assert %Ecto.Changeset{} = Automation.change_workflow(scope, workflow)
    end
  end

  describe "steps" do
    alias GrowthOs.Automation.Step

    import GrowthOs.TenancyFixtures
    import GrowthOs.AutomationFixtures

    @invalid_attrs %{name: nil, type: nil, config: nil, order: nil}

    test "list_steps/1 returns all scoped steps" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      step = step_fixture(scope)
      other_step = step_fixture(other_scope)
      assert Automation.list_steps(scope) == [step]
      assert Automation.list_steps(other_scope) == [other_step]
    end

    test "get_step!/2 returns the step with given id" do
      scope = user_scope_fixture()
      step = step_fixture(scope)
      other_scope = user_scope_fixture()
      assert Automation.get_step!(scope, step.id) == step
      assert_raise Ecto.NoResultsError, fn -> Automation.get_step!(other_scope, step.id) end
    end

    test "create_step/2 with valid data creates a step" do
      scope = user_scope_fixture()
      tenant = tenant_fixture(scope)
      workflow = workflow_fixture(scope, %{tenant_id: tenant.id})
      valid_attrs = %{name: "some name", type: "some type", config: %{}, order: 42, tenant_id: tenant.id, workflow_id: workflow.id}

      assert {:ok, %Step{} = step} = Automation.create_step(scope, valid_attrs)
      assert step.name == "some name"
      assert step.type == "some type"
      assert step.config == %{}
      assert step.order == 42
      assert step.tenant_id == tenant.id
    end

    test "create_step/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Automation.create_step(scope, @invalid_attrs)
    end

    test "update_step/3 with valid data updates the step" do
      scope = user_scope_fixture()
      step = step_fixture(scope)
      update_attrs = %{name: "some updated name", type: "some updated type", config: %{}, order: 43}

      assert {:ok, %Step{} = step} = Automation.update_step(scope, step, update_attrs)
      assert step.name == "some updated name"
      assert step.type == "some updated type"
      assert step.config == %{}
      assert step.order == 43
    end

    test "update_step/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      step = step_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Automation.update_step(scope, step, @invalid_attrs)
      assert step == Automation.get_step!(scope, step.id)
    end

    test "delete_step/2 deletes the step" do
      scope = user_scope_fixture()
      step = step_fixture(scope)
      assert {:ok, %Step{}} = Automation.delete_step(scope, step)
      assert_raise Ecto.NoResultsError, fn -> Automation.get_step!(scope, step.id) end
    end

    test "change_step/2 returns a step changeset" do
      scope = user_scope_fixture()
      step = step_fixture(scope)
      assert %Ecto.Changeset{} = Automation.change_step(scope, step)
    end
  end

  describe "executions" do
    alias GrowthOs.Automation.Execution

    import GrowthOs.TenancyFixtures
    import GrowthOs.AutomationFixtures

    @invalid_attrs %{status: nil, context: nil, started_at: nil, completed_at: nil}

    test "list_executions/1 returns all scoped executions" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      execution = execution_fixture(scope)
      other_execution = execution_fixture(other_scope)
      assert Automation.list_executions(scope) == [execution]
      assert Automation.list_executions(other_scope) == [other_execution]
    end

    test "get_execution!/2 returns the execution with given id" do
      scope = user_scope_fixture()
      execution = execution_fixture(scope)
      other_scope = user_scope_fixture()
      assert Automation.get_execution!(scope, execution.id) == execution
      assert_raise Ecto.NoResultsError, fn -> Automation.get_execution!(other_scope, execution.id) end
    end

    test "create_execution/2 with valid data creates a execution" do
      scope = user_scope_fixture()
      tenant = tenant_fixture(scope)
      workflow = workflow_fixture(scope, %{tenant_id: tenant.id})
      valid_attrs = %{status: "some status", context: %{}, started_at: ~U[2025-12-25 12:40:00Z], completed_at: ~U[2025-12-25 12:40:00Z], tenant_id: tenant.id, workflow_id: workflow.id}

      assert {:ok, %Execution{} = execution} = Automation.create_execution(scope, valid_attrs)
      assert execution.status == "some status"
      assert execution.context == %{}
      assert execution.started_at == ~U[2025-12-25 12:40:00Z]
      assert execution.completed_at == ~U[2025-12-25 12:40:00Z]
      assert execution.tenant_id == tenant.id
    end

    test "create_execution/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Automation.create_execution(scope, @invalid_attrs)
    end

    test "update_execution/3 with valid data updates the execution" do
      scope = user_scope_fixture()
      execution = execution_fixture(scope)
      update_attrs = %{status: "some updated status", context: %{}, started_at: ~U[2025-12-26 12:40:00Z], completed_at: ~U[2025-12-26 12:40:00Z]}

      assert {:ok, %Execution{} = execution} = Automation.update_execution(scope, execution, update_attrs)
      assert execution.status == "some updated status"
      assert execution.context == %{}
      assert execution.started_at == ~U[2025-12-26 12:40:00Z]
      assert execution.completed_at == ~U[2025-12-26 12:40:00Z]
    end

    test "update_execution/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      execution = execution_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Automation.update_execution(scope, execution, @invalid_attrs)
      assert execution == Automation.get_execution!(scope, execution.id)
    end

    test "delete_execution/2 deletes the execution" do
      scope = user_scope_fixture()
      execution = execution_fixture(scope)
      assert {:ok, %Execution{}} = Automation.delete_execution(scope, execution)
      assert_raise Ecto.NoResultsError, fn -> Automation.get_execution!(scope, execution.id) end
    end

    test "change_execution/2 returns a execution changeset" do
      scope = user_scope_fixture()
      execution = execution_fixture(scope)
      assert %Ecto.Changeset{} = Automation.change_execution(scope, execution)
    end
  end
end
