//
//  Tilemap.swift
//  SwiftTilemap
//
//  Created by bryn austin bellomy on 2014 Sep 30.
//  Copyright (c) 2014 bryn austin bellomy. All rights reserved.
//

import Foundation
import SpriteKit
import Funky
import JSTilemap


/**
 * MARK: - protocol ITilemapLayerType -
 */

public protocol ITilemapLayerType
{
    var tmxLayerName : String { get }
    init?(tmxLayerName:String)
}


public typealias TMXDictionary = [String: AnyObject]


//
// MARK: - class Tilemap -
//

public class Tilemap <LayerType: ITilemapLayerType, ObjectGroupType: ITilemapLayerType>
{

    public let tilemapNode = SKNode()
    public let gameObjectsLayerNode = SKNode()

    public var gridSize: CGSize { return tilemap.mapSize }
    public var tileSize: CGSize { return tilemap.tileSize }


    private typealias ObjectGroupKeyType = String
    private var objectGroups = [ObjectGroupKeyType: TilemapObjectGroup<ObjectGroupType>]()
    private let tilemap: JSTileMap


    //
    // MARK: - Lifecycle
    //

    public init(filename:String)
    {
        tilemap = JSTileMap(named:filename)
        objectGroups = parseTilemapObjectGroups(tilemap)

        gameObjectsLayerNode.zPosition = 1.0

        tilemapNode.addChild(tilemap)
        tilemap.addChild(gameObjectsLayerNode)
    }


    //
    // MARK: - Public API
    //

    /**
         Retrieves a parsed, initialized object group from the tilemap.

         :param: group The identifier/key for the object group to retrieve.
         :returns: The specified tilemap object group if it is present in the tilemap.
     */
    public func objectGroup(group:ObjectGroupType) -> TilemapObjectGroup<ObjectGroupType>? {
        return objectGroups[group.tmxLayerName]
    }


    /**
         Retrieves a parsed, initialized tile layer from the tilemap.

         :param: group The identifier/key for the tile layer to retrieve.
         :returns: The specified tilemap layer if it is present in the tilemap or `nil` if it is not.
     */
    public func tileLayer(layer:LayerType) -> TMXLayer? {
        return tilemap.layerNamed(layer.tmxLayerName)
    }


    //
    // MARK: - Private methods
    //

    private func parseTilemapObjectGroups(tilemap:JSTileMap) -> [ObjectGroupKeyType : TilemapObjectGroup<ObjectGroupType>]
    {
        return tilemap.objectGroupsArray |> mapFilter       { TilemapObjectGroup<ObjectGroupType>(tmxObjectGroup:$0) }
                                         |> mapToDictionary { ($0.groupID.tmxLayerName, $0) }

    }
}


internal extension JSTileMap
{
    var objectGroupsArray: [TMXObjectGroup] {
        let obj = Array(objectGroups)
        let tmxObjectGroups = obj as [TMXObjectGroup]
        return tmxObjectGroups
    }
}





