defmodule Topologies do
  def getNumNodesForGrids(numNodes, topology) do
    case topology do
      "rand2D" -> :math.sqrt(numNodes) |> :math.ceil() |> :math.pow(2) |> trunc()
      "3Dtorus" -> :math.pow(numNodes, 1 / 3) |> :math.ceil() |> :math.pow(3) |> trunc()
      "honeycomb" ->
        width = :math.sqrt(numNodes) |> trunc()
        r = rem(numNodes, width)
        if r == 0, do: numNodes, else: numNodes + width - r
      "honeycombr" ->
        width = :math.sqrt(numNodes) |> trunc()
        r = rem(numNodes, width)
        if r == 0, do: numNodes, else: numNodes + width - r
      _ -> numNodes
    end
  end

  def getNeighbors(i, numNodes, topology) do
    range = 1..numNodes

    case topology do
      "full" -> Enum.reject(range, fn x -> x == i end)
      "line" -> Enum.filter(range, fn x -> x == i + 1 || x == i - 1 end)
      "rand2D" -> getRand2DNeighbors(i, numNodes)
      "3Dtorus" -> get3DTorusNeighbours(i, numNodes)
      "honeycomb" -> getHoneycombNeighbours(i, numNodes)
      "honeycombr" -> getHoneycombWithRandomNeighbours(i, numNodes)
    end
  end

  def getRand2DNeighbors(i, numNodes) do
    range = 1..numNodes
    randomGrid = Enum.shuffle(range) |> Enum.with_index(1)

    length = numNodes |> :math.sqrt() |> trunc()
    k = (length / 10) |> :math.ceil() |> trunc()

    top = Enum.map(1..k, fn x -> i - x * length end) |> Enum.filter(fn x -> x > 0 end)
    bottom = Enum.map(1..k, fn x -> i + x * length end) |> Enum.filter(fn x -> x <= numNodes end)

    right =
      if rem(i, length) == 0,
        do: [],
      else: Enum.take_while((i + 1)..(i + k), fn x -> rem(x, length) != 1..k end)

    left =
      if rem(i, length) == 1,
        do: [],
      else: Enum.take_while((i - 1)..(i - k), fn x -> rem(x, length)
      != Enum.map(length-k..length, fn x -> rem(x, length) end) end)

    neighborIndex = top ++ bottom ++ right ++ left |> Enum.map(fn x -> trunc(x) end)

    Enum.filter(randomGrid, fn x -> Enum.member?(neighborIndex, elem(x, 1)) end)
    |> Enum.map(fn x -> elem(x, 0) end)
  end

  def get3DTorusNeighbours(i, numNodes) do
    sideLength = :math.pow(numNodes, 1/3) |> trunc()
    nodesPerSide = sideLength * sideLength
    top =
      if i <= nodesPerSide,
      do: [numNodes - nodesPerSide + i], else: [i - nodesPerSide]
    bottom =
      if i > numNodes - nodesPerSide,
      do: [(if rem(i,nodesPerSide)==0, do: rem(i,nodesPerSide), else: nodesPerSide)],
      else: [i + nodesPerSide]
    left =
      if rem(i, nodesPerSide) |> rem(sideLength) == 1,
      do: [i + sideLength - 1], else: [i - 1]
    right =
      if rem(i, nodesPerSide) |> rem(sideLength) == 0,
      do: [i - sideLength + 1], else: [i + 1]
    front =
      if (rem(i, nodesPerSide) < nodesPerSide && rem(i, nodesPerSide) > nodesPerSide-sideLength)
      || (rem(i, nodesPerSide) == 0),
      do: [(if rem(i,nodesPerSide) == 0, do: i - nodesPerSide + sideLength,
    else: (i/nodesPerSide |> trunc())*nodesPerSide + (rem(i, nodesPerSide) |> rem(sideLength)))],
      else: [i + sideLength]
    back =
      cond do
        rem(i, nodesPerSide) == 0 -> [i - sideLength]
        rem(i, nodesPerSide) <= sideLength -> [(i/nodesPerSide |> trunc())*nodesPerSide + nodesPerSide - sideLength + i]
        true -> [i - sideLength]
      end

      top ++ bottom ++ right ++ left ++ front ++ back
  end

  def getHoneycombNeighbours(i, numNodes) do
    #Rotating the honeycomb by 90degrees and flattening it will give us a grid
    #similar to a 2D grid
    width = :math.sqrt(numNodes) |> trunc()
    r = rem(numNodes, width)
    numNodes = if r == 0, do: numNodes, else: numNodes + width - r

    top =
      cond do
        i <= width ->
          []
        (i/width |> trunc |> rem(2) == 0) && (rem(i, width) |> rem(2) == 0) ->
          [i-width]
        (i/width |> trunc |> rem(2) == 1) && (rem(i, width) |> rem(2) == 1) ->
          [i-width]
        true ->
          []
      end
    bottom =
      cond do
        i + width > numNodes ->
          []
        (i/width |> trunc |> rem(2) == 0) && (rem(i, width) |> rem(2) == 1) ->
          [i + width]
        (i/width |> trunc |> rem(2) == 1) && (rem(i, width) |> rem(2) == 0) ->
          [i + width]
        true ->
          []
      end
    right = if rem(i, width) == 0, do: [], else: [i + 1]
    left = if rem(i, width) == 1, do: [], else: [i - 1]

    top ++ bottom ++ right ++ left
  end

  def getHoneycombWithRandomNeighbours(i, numNodes) do
    neighbours = getHoneycombNeighbours(i, numNodes)
    rest = Enum.to_list(1..numNodes) -- neighbours
    neighbours ++ [Enum.random(rest)]
  end
end
