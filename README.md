# Proj2 Gossip Simulator

## Group members

* Jayanth Shetty, Sagar	[UFID: 4351-7929]
* Mittal, Prakhar 		[UFID: 3909-9969]

## Instructions

* Run the following command:
	./my_program <noOfNodes> <topology> <algorithm>
	If on Windows run:
	escript ./my_program <noOfNodes> <topology> <algorithm>
* Values for <topology> can be any of the following:
	full
	line
	rand2D
	3Dtorus
	honeycomb
	honeycombr
* Values for <algorithm> can be any of the following:
	gossip
	pushsum


## What is working

### Topologies:

* full -Every actor is a neighbour of all other actors. That is, every actor can talk directly to any other actor.
* line - Actors are arranged in a line. Each actor has only 2 neighbors (one left and one right, unless you are the first or last actor).
* Rand2D - Random 2D Grid: Actors are randomly position at x,y coordinnates on a [0-1.0]x[0-1.0] square. Two actors are connected if they are within .1 distance to other actors.
* 3D Torus - Actors form a 3D grid. The actors can only talk to the grid neighbors. And, the actors on outer surface are connected to other actors on opposite side, such that degree of each actor is 6
* Honeycomb - Actors are arranged in form of hexagons. Two actors are connected if they are connected to each other. Each actor can have a degree of 1,2 or 3.
* Honeycomb with a random neighbor - Actors are arranged in form of hexagons (Similar to Honeycomb). The only difference is that every node has one extra connection to a random node in the entire network.

## What is the largest network you managed to deal with for each type of topology and algorithm 

|     Topology     |      Gossip      |     Push Sum     |  
| ---------------- | ---------------- | ---------------- |
|      Full        |        8000      |      10000       |
|      Line        |        7000      |      5000        |
|  	 Random 2D	   |        9000      |      5000        |
|    3D Torus      |       10000      |      10000       |
|    Honeycomb     |       100000     |      50000       |
| Honeycomb with a |       20000      |      10000       |
| random neighbor  |


