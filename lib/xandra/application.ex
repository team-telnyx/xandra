defmodule Xandra.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Supervisor.Spec.worker(Xandra.Registry, [])
    ]

    options = [strategy: :one_for_one, name: Xandra.Supervisor]
    Supervisor.start_link(children, options)
  end
end
