import Foundation

/**
 Represents a silent waypoint along the `RouteLeg`.

 See `RouteLeg.viaWaypoints` for more details.
 */
public struct SilentWaypoint: Codable, Equatable {
    public enum CodingKeys: String, CodingKey {
        case waypointIndex = "waypoint_index"
        case distanceFromStart = "distance_from_start"
        case shapeCoordinateIndex = "geometry_index"
    }

    /// The associated waypoint index in `RouteResponse.waypoints`, excluding the origin (index 0) and destination.
    public var waypointIndex: Int

    /// The calculated distance, in meters, from the leg origin.
    public var distanceFromStart: Double

    /// The associated `Route` shape index of the silent waypoint location.
    public var shapeCoordinateIndex: Int

    public init(waypointIndex: Int, distanceFromStart: Double, shapeCoordinateIndex: Int) {
        self.waypointIndex = waypointIndex
        self.distanceFromStart = distanceFromStart
        self.shapeCoordinateIndex = shapeCoordinateIndex
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        waypointIndex = try container.decode(Int.self, forKey: .waypointIndex)
        distanceFromStart = try container.decode(Double.self, forKey: .distanceFromStart)
        shapeCoordinateIndex = try container.decode(Int.self, forKey: .shapeCoordinateIndex)
    }
}
