defmodule Xandra.Registry do
  @moduledoc false

  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, nil, [name: __MODULE__])
  end

  def associate(pid, value) do
    GenServer.call(__MODULE__, {:associate, pid, value})
  end

  def lookup(name) do
    if pid = GenServer.whereis(name) do
      :ets.lookup_element(__MODULE__, pid, 3)
    else
      raise "could not lookup #{inspect(name)} because it was not started or it does not exist"
    end
  end

  @impl true
  def init(nil) do
    table = :ets.new(__MODULE__, [:named_table, read_concurrency: true])
    {:ok, table}
  end

  @impl true
  def handle_call({:associate, pid, value}, _from, table) do
    ref = Process.monitor(pid)
    :ets.insert(table, {pid, ref, value})
    {:reply, :ok, table}
  end

  @impl true
  def handle_info({:DOWN, ref, _type, pid, _reason}, table) do
    [{^pid, ^ref, _}] = :ets.lookup(table, pid)
    :ets.delete(table, pid)
    {:noreply, table}
  end
end
