defmodule GrowthOs.AgentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `GrowthOs.Agents` context.
  """

  import GrowthOs.TenancyFixtures

  @doc """
  Generate a agent_profile.
  """
  def agent_profile_fixture(scope, attrs \\ %{}) do
    tenant_id = attrs[:tenant_id] || tenant_fixture(scope).id
    attrs =
      Enum.into(attrs, %{
        config: %{},
        model: "some model",
        name: "some name",
        role: "some role",
        system_prompt: "some system_prompt",
        tenant_id: tenant_id
      })

    {:ok, agent_profile} = GrowthOs.Agents.create_agent_profile(scope, attrs)
    agent_profile
  end

  @doc """
  Generate a agent_task.
  """
  def agent_task_fixture(scope, attrs \\ %{}) do
    tenant_id = attrs[:tenant_id] || tenant_fixture(scope).id
    agent_profile_id = attrs[:agent_profile_id] || agent_profile_fixture(scope, %{tenant_id: tenant_id}).id
    
    attrs =
      Enum.into(attrs, %{
        input: "some input",
        output: "some output",
        status: "some status",
        agent_profile_id: agent_profile_id,
        tenant_id: tenant_id
      })

    {:ok, agent_task} = GrowthOs.Agents.create_agent_task(scope, attrs)
    agent_task
  end
end
