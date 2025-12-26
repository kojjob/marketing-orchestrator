defmodule GrowthOs.AutomationFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `GrowthOs.Automation` context.
  """

  import GrowthOs.TenancyFixtures

  @doc """
  Generate a workflow.
  """
  def workflow_fixture(scope, attrs \\ %{}) do
    tenant_id = attrs[:tenant_id] || tenant_fixture(scope).id
    attrs =
      Enum.into(attrs, %{
        description: "some description",
        is_active: true,
        name: "some name",
        trigger_config: %{},
        trigger_type: "some trigger_type",
        tenant_id: tenant_id
      })

    {:ok, workflow} = GrowthOs.Automation.create_workflow(scope, attrs)
    workflow
  end

  @doc """
  Generate a step.
  """
  def step_fixture(scope, attrs \\ %{}) do
    tenant_id = attrs[:tenant_id] || tenant_fixture(scope).id
    workflow_id = attrs[:workflow_id] || workflow_fixture(scope, %{tenant_id: tenant_id}).id
    
    attrs =
      Enum.into(attrs, %{
        config: %{},
        name: "some name",
        order: 42,
        type: "some type",
        workflow_id: workflow_id,
        tenant_id: tenant_id
      })

    {:ok, step} = GrowthOs.Automation.create_step(scope, attrs)
    step
  end

  @doc """
  Generate a execution.
  """
  def execution_fixture(scope, attrs \\ %{}) do
    tenant_id = attrs[:tenant_id] || tenant_fixture(scope).id
    workflow_id = attrs[:workflow_id] || workflow_fixture(scope, %{tenant_id: tenant_id}).id

    attrs =
      Enum.into(attrs, %{
        completed_at: ~U[2025-12-25 12:40:00Z],
        context: %{},
        started_at: ~U[2025-12-25 12:40:00Z],
        status: "some status",
        workflow_id: workflow_id,
        tenant_id: tenant_id
      })

    {:ok, execution} = GrowthOs.Automation.create_execution(scope, attrs)
    execution
  end
end
