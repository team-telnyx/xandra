defmodule ClusteringTest do
  use XandraTest.IntegrationCase

  import ExUnit.CaptureLog

  def await_connected(cluster, fun, tries \\ 4) do
    try do
      Xandra.run(cluster, fun)
    rescue
      Xandra.ConnectionError ->
        if tries > 0 do
          Process.sleep(50)
          await_connected(cluster, fun, tries - 1)
        else
          raise "exceeded maximum number of attempts"
        end
    end
  end

  test "basic interactions", %{keyspace: keyspace} do
    statement = "USE #{keyspace}"

    log = capture_log(fn ->
      start_options = [
        nodes: ["127.0.0.1", "127.0.0.1", "127.0.0.2"],
        name: TestCluster,
        pool: Xandra.Cluster,
        load_balancing: :random,
      ]
      {:ok, cluster} = Xandra.start_link(start_options)

      assert await_connected(cluster, &Xandra.execute!(&1, statement))
    end)
    assert log =~ "received request to start another connection pool to the same address"

    assert Xandra.execute!(TestCluster, statement)
  end

  test "priority load balancing", %{keyspace: keyspace} do
    start_options = [
      pool: Xandra.Cluster,
      load_balancing: :priority
    ]
    {:ok, cluster} = Xandra.start_link(start_options)

    assert await_connected(cluster, &Xandra.execute!(&1, "USE #{keyspace}"))
  end
end
