defmodule DarkWorldsServer.AutoBattler.RunnerSupervisor do
  @moduledoc """
  Game Runner Supervisor
  """
  use DynamicSupervisor

  alias DarkWorldsServer.AutoBattler.RunnerSupervisor.Runner
  alias DarkWorldsServer.RunnerSupervisor.PlayerTracker
  alias DarkWorldsServer.RunnerSupervisor.RequestTracker

  def start_link(args) do
    DynamicSupervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  # teams_config is like %{player1char1, player1char2, player2char1...}
  def start_child() do
    {:ok, game_config_json} = Application.app_dir(:dark_worlds_server, "priv/config.json") |> File.read()
    config = Jason.decode!(game_config_json)

    DynamicSupervisor.start_child(
      __MODULE__,
      {Runner, config}
    )
  end

  @impl true
  def init(_opts) do
    RequestTracker.create_table()
    PlayerTracker.create_table()
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def list_runners_pids() do
    __MODULE__
    |> DynamicSupervisor.which_children()
    |> Enum.filter(fn children ->
      case children do
        {:undefined, pid, :worker, [Runner]} when is_pid(pid) -> true
        _ -> false
      end
    end)
    |> Enum.map(fn {_, pid, _, _} -> pid end)
  end
end
