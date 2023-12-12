defmodule DarkWorldsServer.AutoBattler.Bot.BotSupervisor do
  use DynamicSupervisor
  alias DarkWorldsServer.AutoBattler.Bot
  alias DarkWorldsServer.AutoBattler.RunnerSupervisor.Runner

  def start_link(args) do
    DynamicSupervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def start_bots(runner_pid, config, broadcast_topic) do
    Enum.map(1..10, fn player_id ->
      {:ok, child_pid} = DynamicSupervisor.start_child(__MODULE__, {Bot, %{config: config, runner_pid: runner_pid, broadcast_topic: broadcast_topic}})
      Bot.add_bot(child_pid, player_id)
      Runner.join(runner_pid, player_id, "muflus")
      child_pid
    end)
  end

  @impl true
  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
