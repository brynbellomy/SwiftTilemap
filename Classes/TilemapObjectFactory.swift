//
//  TilemapObjectFactory.swift
//  SwiftTilemap
//
//  Created by bryn austin bellomy on 2014 Dec 6.
//  Copyright (c) 2014 bryn austin bellomy. All rights reserved.
//

import Foundation
import LlamaKit
import SwiftConfig
import Funky


public struct TilemapObjectFactory //: IConfigurableBuilder
{
    public var name: String?
    public var type: TilemapObjectType?
    public var position: CGPoint?
    public var size: CGSize?
    public var properties: TMXDictionary?

    public var points: [CGPoint]?


    public init() {}


    /**
        Creates a `Config` from the properties dictionary of an object in a TMX file.

        :param: tmxDictionary A dictionary containing the properties of the tilemap object to be initialized.  This is most likely obtained by parsing a TMX file.
        :returns: An initialized `Config` suitable for passing to `configure(_:)`.
     */
    public static func configForTMXDictionary(dict:TMXDictionary) -> Config {
        return Config(dictionary:dict)
    }


    public mutating func configure (tmxDictionary: TMXDictionary)
    {
        var config = Config(dictionary:tmxDictionary)

        type = TilemapObjectType(config:config)
        name = config.get("name")

        if let (x, y) = config.get(keys:"x", "y") as (String?, String?) |> both {
            config.set("x", value:(x as NSString).floatValue)
            config.set("y", value:(y as NSString).floatValue)
        }

        if let (w, h) = config.get(keys:"width", "height") as (String?, String?) |> both {
            config.set("width", value:(w as NSString).floatValue)
            config.set("height", value:(h as NSString).floatValue)
        }

        position = config.pluck("x", "y")
        size     = config.pluck("width", "height")

        // try to parse a TMX points string and add to `points` if the object happens to be a poly[gon,line]
        if let type = type {
            switch type {
                case .Polyline: points = parseTMXPointString <^> config.get(TilemapPolylineObject.pointsConfigKey)
                case .Polygon:  points = parseTMXPointString <^> config.get(TilemapPolygonObject.pointsConfigKey)
                default: break
            }
        }

        // make all properties available as a flat TMXDictionary
        properties = config.flatten()
    }

    /**
        :returns: A `Result` containing the initialized `TilemapObject` or an error.
     */
    public func build() -> Result<TilemapObject>
    {
        return { type in self.buildObject(type) }
                                     -<< (type ?± failure("Could not determine the tilemap object's type."))
    }

    private func buildObject(type:TilemapObjectType) -> Result<TilemapObject>
    {
        switch type {
            case .Rectangle: return buildRectangle(name, properties)
                                        <^> position ?± missingValueFailure("position")
                                        <*> size     ?± missingValueFailure("size")

            case .Ellipse:   return buildEllipse(name, properties)
                                        <^> position ?± missingValueFailure("position")
                                        <*> size     ?± missingValueFailure("size")

            case .Polyline:  return buildPolyline(name, properties)
                                        <^> position ?± missingValueFailure("position")
                                        <*> points ?± missingValueFailure("points")

            case .Polygon:   return buildPolygon(name, properties)
                                        <^> position ?± missingValueFailure("position")
                                        <*> points ?± missingValueFailure("points")

        }
    }

    private func missingValueFailure <T> (value:String) -> Result<T> {
        return failure("Could not get value for required parameter '\(value)'.")
    }
}


private func buildEllipse (name:String?, properties:TMXDictionary?) (position:CGPoint) (size:CGSize) -> TilemapEllipseObject {
    return TilemapEllipseObject(name:name, properties:properties, position:position, size:size)
}

private func buildRectangle (name:String?, properties:TMXDictionary?) (position:CGPoint) (size:CGSize) -> TilemapRectangleObject {
    return TilemapRectangleObject(name:name, properties:properties, position:position, size:size)
}

private func buildPolygon (name:String?, properties:TMXDictionary?) (position:CGPoint) (points:[CGPoint]) -> TilemapPolygonObject {
    return TilemapPolygonObject(name:name, properties:properties, points:points, position:position)
}

private func buildPolyline (name:String?, properties:TMXDictionary?) (position:CGPoint) (points:[CGPoint]) -> TilemapPolylineObject {
    return TilemapPolylineObject(name:name, properties:properties, points:points, position:position)
}


public extension CGPath
{
    public class func fromTMXPointString(pointString:String, closePath:Bool) -> Result<CGPath>
    {
        let points = parseTMXPointString(pointString)
        if points.count <= 0 {
            return failure("TMX point string was empty or couldn't be parsed.")
        }

        return CGPath.fromPoints(points, closePath:closePath) |> success
    }
}


