defmodule PushsumActor do

  def start_link(node_id, neighbors) do
    GenServer.start_link(__MODULE__, [node_id, neighbors], name: Utility.saveTuple(node_id))
  end

  def init([node_id, neighbors]) do
    receive do
      {_, s, w} -> start(node_id, neighbors, s, w)
    end

    {:ok, node_id}
  end

  def start(node_id, neighbors, s, w) do
    {:ok, callingPid} = Task.start(fn -> call_neighbor(node_id, neighbors) end)
    listen(0, s + node_id, w + 1, node_id, callingPid)
  end

  def call_neighbor(node_id, neighbors) do
    receive do
      {:call_neigh, s, w} ->
        Enum.random(neighbors) |> Utility.getPid() |> send_pushsum(s, w)
    end

    call_neighbor(node_id, neighbors)
  end

  def listen(count, s, w, oldRatio, callingPid) do
    newRatio = s / w
    count = if abs(newRatio - oldRatio) > :math.pow(10, -10), do: 0, else: count + 1
    checkForConvergence(count, callingPid, s, w, newRatio)
  end

  def checkForConvergence(count, callingPid, _s, _w, _ratio) when count >= 3 do
    Utility.kill(callingPid)
  end

  def checkForConvergence(count, callingPid, s, w, ratio) when count < 3 do
    s = s / 2
    w = w / 2
    send(callingPid, {:call_neigh, s, w})

    receive do
      {:newVal, newS, newW} -> listen(count, newS + s, newW + w, ratio, callingPid)
    after
      100 -> listen(count, s, w, ratio, callingPid)
    end
  end

  def send_pushsum(pid, s, w) do
    if pid != nil do
      send(pid, {:newVal, s, w})
    end
  end
end
