# Simple Dijkstra's algorithm implementation for shortest path on a weighted graph
require_relative '../application_service'

class Routing::DijkstraService < ApplicationService
  # graph: { node => { neighbor => weight, ... }, ... }
  def initialize(graph:, source:, target:)
    @graph = graph
    @source = source
    @target = target
  end

  def call
    distances = {}
    previous = {}
    nodes = @graph.keys.dup

    nodes.each { |n| distances[n] = Float::INFINITY }
    distances[@source] = 0

    until nodes.empty?
      u = nodes.min_by { |n| distances[n] }
      break if distances[u] == Float::INFINITY
      break if u == @target

      nodes.delete(u)

      (@graph[u] || {}).each do |v, w|
        alt = distances[u] + w
        if alt < distances[v]
          distances[v] = alt
          previous[v] = u
        end
      end
    end

    # Reconstruct path
    path = []
    u = @target
    while previous[u]
      path.unshift(u)
      u = previous[u]
    end
    path.unshift(@source) if distances[@target] != Float::INFINITY

    { path: path, distance: distances[@target] }
  end
end
