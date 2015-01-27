//
//  TilemapObjectType.swift
//  SwiftTilemap
//
//  Created by bryn austin bellomy on 2015 Jan 2.
//  Copyright (c) 2014 bryn austin bellomy. All rights reserved.
//

import SwiftConfig


public enum TilemapObjectType: String, IConfigInitable
{
    case Rectangle = "Rectangle"
    case Ellipse = "Ellipse"
    case Polyline = "Polyline"
    case Polygon = "Polygon"

    public init(config:Config)
    {
        if TilemapObjectType.isEllipse(config) {
            self = .Ellipse
        }
        else if TilemapObjectType.isPolyline(config) {
            self = .Polyline
        }
        else if TilemapObjectType.isPolygon(config) {
            self = .Polygon
        }
        else {
            self = .Rectangle
        }
    }


    public static func isEllipse (config:Config) -> Bool {
        let ellipseFlag = config.get("ellipse") as Int?
        return ellipseFlag == 1
    }


    public static func isPolygon (config:Config) -> Bool
    {
        let asdf = config.get(TilemapPolygonObject.pointsConfigKey) as String?
        return asdf != nil
    }


    public static func isPolyline (config:Config) -> Bool
    {
        let asdf = config.get(TilemapPolylineObject.pointsConfigKey) as String?
        return asdf != nil
    }
}
