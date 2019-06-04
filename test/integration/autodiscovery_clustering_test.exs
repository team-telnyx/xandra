defmodule AutodiscoveryClusteringTest do
  use XandraTest.IntegrationCase, start_options: [nodes: ["seed"]]

  @moduletag :docker_cluster

  def await_connected(fun, tries \\ 4) do
    fun.()
  rescue
    Xandra.ConnectionError ->
      if tries > 0 do
        Process.sleep(50)
        await_connected(fun, tries - 1)
      else
        raise "exceeded maximum number of attempts"
      end
  end

  describe "autodiscovery" do
    @tag :capture_log
    test "using a single seed node", %{keyspace: keyspace, start_options: start_options} do
      statement = "USE #{keyspace}"

      {:ok, cluster} = Xandra.Cluster.start_link(start_options)

      assert await_connected(fn -> Xandra.Cluster.execute!(cluster, statement) end)

      query = "SELECT host_id FROM system.local"

      host_ids =
        Stream.repeatedly(fn -> Xandra.Cluster.execute!(cluster, query, _params = []) end)
        |> Stream.flat_map(&Enum.to_list/1)
        |> Stream.map(& &1["host_id"])
        |> Stream.take(100)
        |> Stream.uniq()
        |> Enum.take(3)

      assert length(host_ids) == 3
    end
  end
end
