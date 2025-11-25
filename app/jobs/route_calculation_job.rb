class RouteCalculationJob < ApplicationJob
  queue_as :default

  def perform(request_id)
    req = Request.find_by(id: request_id)
    return unless req && req.user && req.pet

    # Simple example: build nodes and edges and compute shortest path
    # In production you'd use geocoding and a proper graph from map data
    shelter_node = "shelter_#{req.pet.id}"
    user_node = "user_#{req.user.id}"

    # edges would be constructed from actual distances
    nodes = [shelter_node, user_node]
    edges = [[shelter_node, user_node, 10.0]]

    planner = Routing::RoutePlanner.new(nodes: nodes, edges: edges)
    result = planner.shortest_path(shelter_node, user_node)

    # persist result on request (add columns if needed)
    req.update(route: result[:path].join('->'), route_distance: result[:distance])
  end
end
