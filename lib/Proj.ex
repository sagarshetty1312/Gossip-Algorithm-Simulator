defmodule Proj do
  def main(argumentList) do
    [numNodes, topology, algo] = argumentList
    Registry.start_link(keys: :unique, name: :registry)

    start(algo, String.to_integer(numNodes), topology)
  end

  def start(algo, numNodes, topology) do
    start_time = System.system_time(:millisecond)
    numNodes = Topologies.getNumNodesForGrids(numNodes, topology)
    for i <- 1..numNodes do
      case algo do
        "gossip" -> spawn(fn -> GossipActor.start_link(i, Topologies.getNeighbors(i, numNodes, topology)) end)
                    |> Process.monitor()
        "pushsum" -> spawn(fn -> PushsumActor.start_link(i, Topologies.getNeighbors(i, numNodes, topology)) end)
                      |> Process.monitor()
      end
    end

    case algo do
        "gossip" -> Utility.initiateAlgorithm(numNodes, :gossip)
        "pushsum" -> Utility.initiateAlgorithm(numNodes, {:pushsum, 0, 0})
    end

    time_diff = System.system_time(:millisecond) - start_time
    IO.puts("Time taken : #{time_diff} milliseconds")
  end
end

defmodule Utility do
  def initiateAlgorithm(numNodes, msg) do
    convTaskPid = Task.async(fn -> listenforConvergence(numNodes) end)
    :global.register_name(:convTaskPid, convTaskPid.pid)
    startRandomNode(numNodes, msg)
    Task.await(convTaskPid, :infinity)
  end

  def listenforConvergence(numNodes) do
    if(numNodes > 0) do
      receive do
        {:converged, _pid} ->
          IO.puts("Convergence success, #{numNodes} nodes left")
          listenforConvergence(numNodes - 1)
      after
        1000 ->
          IO.puts("Convergence failed for a node, #{numNodes} nodes left")
          listenforConvergence(numNodes - 1)
      end
    end
  end

  def startRandomNode(numNodes, msg) do
    node_pid = numNodes |> :rand.uniform() |> getPid()

    if node_pid != nil do
      send(node_pid, msg)
    else
      startRandomNode(numNodes, msg)
    end
  end

  def saveTuple(node_id), do: {:via, Registry, {:registry, node_id}}

  def getPid(node_id) do
    case Registry.lookup(:registry, node_id) do
      [{pid, _}] -> pid
      [] -> nil
    end
  end

  def kill(pid) do
    send(:global.whereis_name(:convTaskPid), {:converged, self()})
    Task.shutdown(pid, :kill)
  end
end
