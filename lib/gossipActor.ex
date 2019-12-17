defmodule GossipActor do

  def start_link(node_id, neighbors) do
    GenServer.start_link(__MODULE__, [node_id, neighbors], name: Utility.saveTuple(node_id))
  end

  def init([node_id, neighbors]) do
    receive do
      :gossip ->
        gossipingTask = Task.start(fn -> startGossip(node_id, neighbors) end)

        listen(1, gossipingTask)
    end

    {:ok, node_id}
  end

  def listen(count, gossipingTask) when count < 10 do
    receive do
      :gossip -> listen(count + 1, gossipingTask)
    end
  end

  def listen(count, gossipingTask) when count >= 10 do
    Utility.kill(gossipingTask)
  end

  def startGossip(node_id, neighbors) do
    Enum.random(neighbors) |> Utility.getPid() |> sendGossip

    Process.sleep(100)
    startGossip(node_id, neighbors)
  end

  defp sendGossip(pid) do
    if pid != nil do
      send(pid, :gossip)
    end
  end
end
