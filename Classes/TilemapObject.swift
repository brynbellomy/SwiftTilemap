//
//  TilemapObject.swift
//  SwiftTilemap
//
//  Created by bryn austin bellomy on 2014 Oct 6.
//  Copyright (c) 2014 bryn austin bellomy. All rights reserved.
//

import Foundation
import CoreGraphics
import SwiftConfig
import Funky
import LlamaKit
import SwiftLogger
import BrynSwift


public protocol ITilemapObject
{
    var properties: TMXDictionary { get }
    var name:       String?       { get }
    var position:   CGPoint       { get }

    /** The size of the object (in points). For poly objects the size is the bounding box of the polygon/polyline. */
    var size: CGSize { get }

    /** The object's outline as a CGRect.  For non-rectangular objects, this is the object's bounding rect. */
    var rect: CGRect { get }

    /** The object's outline as a CGPath. */
    var path: CGPath { get }
}



/**
 * Initializes an array of `CGPoint` values from a `String` of the format: `"0,0 -80,80 -80,160 0,200 80,200"`
 *
 * :param: string The string encoded list of points to be converted to a points array.
 */
public func parseTMXPointString(string:String) -> [CGPoint]
{
    return split(string) { $0 == " " }
        |> mapr {
               var point = NSPointFromString("{\($0)}")
               point.y *= -1 // accommodate for difference between TMX and SpriteKit coordinate spaces
               return point
           }
}




/**
   Represents a single object from an object layer of a TMX tilemap file.  Has subclasses for rectangles, circles, polylines, and polygons.
 */
public class TilemapObject: ITilemapObject
{
    /** The object's properties. */
    public private(set) var properties = TMXDictionary()

    /** Name of the object. */
    public private(set) var name : String?

    /** The position of the object (in tile coordinates). For polygons and polylines this refers to the first point of the polygon/polyline. */
    public var position: CGPoint { return CGPointZero }

    /** The size of the object (in points). For poly objects the size is the bounding box of the polygon/polyline. */
    public var size: CGSize { return CGSizeZero }

    /** This property must be overridden by subclasses in a way that is meaningful with respect to the shape in question.  Rectangular shapes simply return `CGRect`s, while other shapes generally return bounding boxes. */
    public var rect: CGRect { preconditionFailure("TilemapObject's 'rect' property must be overridden by subclasses.") }

    /** The object's outline as a CGPath. */
    public var path: CGPath { preconditionFailure("TilemapObject's 'path' property must be overridden by subclasses.") }

//    /** The type of object assigned by the user. The type is editable in Tiled from an object's properties dialog. */
//    public private(set) var type : String = ""
//
//    /** The subtype (or variant) of the object, assigned by the user with the "subtype" key. The type is editable in Tiled from an object's properties dialog. */
//    public private(set) var subtype : String?



    //
    // MARK: - Lifecycle
    //

    public init(name n:String?, properties prop:TMXDictionary?)
    {
        name = n

        if let prop = prop {
            properties = prop
        }
    }
}

extension String: Printable {
    public var description: String { return self }
}


extension TilemapObject: Printable, DebugPrintable
{
    public var description: String {
        let dict = [
            "name": name ?? "(nil)",
            "position": position.bk_shortDescription,
            "size": size.bk_shortDescription,
            "properties": describe(properties),
        ]

        return "<TilemapObject: \(describe(dict))>"
    }

    public var debugDescription: String { return description }
}


//
// MARK: - TilemapObject subclasses -
//

//
// MARK: - class TilemapRectangleObject
//

/** A rectangle object, usually referred to as simply "object" in Tiled.  It has no points, just position and size. */
public class TilemapRectangleObject: TilemapObject
{
    /** The rectangle as CGRect, for convenience. Rect origin is the same as position, rect size the same as size. */
    internal var storedRect: CGRect

    override public var position: CGPoint { return storedRect.origin }
    override public var size:     CGSize  { return storedRect.size   }
    override public var rect:     CGRect  { return storedRect }
    override public var path:     CGPath  { return CGPathCreateWithRect(CGRect(origin:CGPointZero, size:size), nil) }

    public init(name:String?, properties:TMXDictionary?, position:CGPoint, size:CGSize)
    {
        storedRect = CGRect(origin:position, size:size)
        super.init(name:name, properties:properties)
    }
}



//
// MARK: - class TilemapEllipseObject
//

public class TilemapEllipseObject: TilemapRectangleObject
{
    /** The ellipse's path.  Note that the origin of the returned path is set to `CGPointZero`. */
    override public var path: CGPath { return CGPathCreateWithEllipseInRect(CGRect(origin:CGPointZero, size:size), nil) }

    /** The ellipse's bounding box as a CGRect. */
    override public var rect: CGRect { return CGRect(origin:position, size:size) }
}



//
// MARK: - class TilemapPolylineObject
//

/**
    A polyline made up of points.  Polylines are not closed by default, whereas polygons are implicitly closed. It has no size and position is its first point.
*/
public class TilemapPolylineObject : TilemapObject
{
    /** Array of CGPoints.  The first point identical to the object's `position`, meaning that the points are essentially absolute coordinates in the coordinate space of the tilemap. */
    public let points: [CGPoint]

    /** The polyline's position is equal to the first point in `points`.  Correspondingly, its `path` is centered at (0, 0). */
    override public var position: CGPoint { return storedPosition }

    /** The backing variable for the public `position` property. */
    private var storedPosition: CGPoint

    /** The size of the polyline's bounding box. */
    override public var size: CGSize { return rect.size }

    private var storedPath: CGPath = CGPathCreateMutable()

    /** The polyline's path, centered at (0, 0).  The first point of `path` is equal to the polyline's `position`.  */
    override public var path: CGPath {
        get { return storedPath }
        set { storedPath = newValue }
    }

    /** The rectangle as CGRect, for convenience. Rect origin is the same as position, rect size the same as size. */
    override public var rect: CGRect { return CGPathGetBoundingBox(path) }

    /**
        The designated initializer.
    
        :param: name The `name` property from the object in the TMX file.
        :param: properties The entire `properties` dictionary from the object in the TMX file.
        :param: points An array of `CGPoint` values describing the polyline's path.
        :param: position The point at which to center the polyline in its parent coordinate space.
    */
    public init(name n:String?, properties prop:TMXDictionary?, points pts:[CGPoint], position:CGPoint)
    {
        storedPosition = position

        var ptsStr = ", ".join(pts.map { $0.bk_shortDescription })
        points = pts
        if points.count <= 0 {
            fatalError("TilemapPolylineObject cannot be initialized with an empty array of points.")
        }

        super.init(name:n, properties:prop)

        storedPath = CGPath.fromPoints(pts, closePath: self.dynamicType.closed)
    }

    /** Returns the string key used to retrieve the points from the TMX object dictionary.  The respective keys for polylines and polygons are different.  */
    internal class var pointsConfigKey:  String { return "polylinePoints" }

    /** Indicates whether or not the line's first point should be automatically connected to its last point.  A polyline is not closed, while a polygon is. */
    internal class var closed: Bool   { return false }
}


//
// MARK: - class TilemapPolygonObject
//

/** A closed polygon made up of points. It has no size and position is its first point. */
public class TilemapPolygonObject: TilemapPolylineObject
{
    /** Returns the string key used to retrieve the points from the TMX object dictionary.  The respective keys for polylines and polygons are different.  */
    override internal class var pointsConfigKey: String { return "polygonPoints" }

    /** Indicates whether or not the line's first point should be automatically connected to its last point.  A polyline is not closed, while a polygon is. */
    override internal class var closed: Bool { return true }
}




