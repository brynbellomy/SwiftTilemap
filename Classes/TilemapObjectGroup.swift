//
//  TilemapObjectGroup.swift
//  SwiftTilemap
//
//  Created by bryn austin bellomy on 2014 Oct 7.
//  Copyright (c) 2014 bryn austin bellomy. All rights reserved.
//

import Foundation
import SwiftLogger
import Funky
import JSTilemap


/**
    A wrapper class for the `TMXObjectGroup` class that automatically creates `TilemapObject` objects for each object in the object group.
 */
public class TilemapObjectGroup<ObjectGroupType : ITilemapLayerType>: Printable
{
    public let groupID: ObjectGroupType
    public let tmxObjectGroup: TMXObjectGroup

    private let objects: [String: TilemapObject]

    public var description: String { return "<TilemapObjectGroup: objects = {\n\(objects.description)\n}>" }


    /** Returns the name of the object group, which is drawn from the tilemap. */
    public var groupName: String { return tmxObjectGroup.groupName }

    /** Returns an array containing all of the tilemap objects in this group. */
    public var allObjects: [TilemapObject] { return Array(objects.values) }


    //
    // MARK: - Lifecycle
    //

    public init(tmxObjectGroup g:TMXObjectGroup)
    {
        tmxObjectGroup = g
        if let group = ObjectGroupType(tmxLayerName:tmxObjectGroup.groupName)
        {
            if let objectsInGroup = tmxObjectGroup.objects
            {
                let objectsArray = NSArray(array:objectsInGroup) as [Dictionary<String, AnyObject>]
                objects = objectsArray //|> mapFilter { TilemapObjectFactory.configForTMXDictionary($0).buildWith(TilemapObjectFactory()) }
                                       |> mapFilter {
                                            var fac = TilemapObjectFactory()
                                            fac.configure($0)
                                            return fac.build()
                                        }
                                       |> rejectFailuresAndDispose { lllog(.Error, "[failure] \($0.localizedDescription)") }
                                       |> mapToDictionaryKeys { $0.name ?? NSUUID().UUIDString }

                groupID = group
            }
            else {
                lllog(.Error, "couldn't get objects array for tilemap object group layer '\(tmxObjectGroup.groupName)'")
                fatalError("couldn't get objects array for tilemap object group layer.")
            }
        }
        else {
            lllog(.Error, "couldn't find Tilemap.ObjectGroup enum value for tilemap object group layer '\(tmxObjectGroup.groupName)'")
            fatalError("couldn't find Tilemap.ObjectGroup enum value for tilemap object group layer.")
        }
    }



    //
    // MARK: - Public API
    //

    /**
      :param: name The name of the object to retrieve.
      :returns: The tilemap object with the provided name (or nil if it was not found).
    */
    public func objectNamed(name:String) -> TilemapObject? {
        return objects[name]
    }
}


