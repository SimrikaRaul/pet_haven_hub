# Higher level route planner that prepares graph from nodes (shelters, addresses)
# and invokes Dijkstra for single-source shortest path
require_relative 'dijkstra_service'

class Routing::RoutePlanner
  def initialize(nodes:, edges:)
    # nodes: array of node ids
    # edges: array of [from, to, weight]
    @nodes = nodes
    @edges = edges
  end

  def shortest_path(source, target)
    graph = build_graph
    Routing::DijkstraService.new(graph: graph, source: source, target: target).call
  end

  private

  def build_graph
    g = Hash.new { |h,k| h[k] = {} }
    @edges.each do |u,v,w|
      g[u][v] = w
      # assume undirected for delivery
      g[v][u] = w
    end
    g
  end
end
