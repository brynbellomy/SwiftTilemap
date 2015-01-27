//
//  TilemapObjectNodeFactory.swift
//  SwiftTilemap
//
//  Created by bryn austin bellomy on 2014 Dec 3.
//  Copyright (c) 2014 bryn austin bellomy. All rights reserved.
//

import Foundation
import SpriteKit
import LlamaKit

import SwiftConfig
import SwiftTilemap
import Funky
import SwiftLogger


public protocol ITilemapObjectNodeConfigBuilder {
    func buildNodeConfig(#tilemapObject:TilemapObject) -> Config
}


public class TilemapObjectNodeFactory<NodeBuilder : IConfigurableBuilder where NodeBuilder.BuiltType == SKNode>
{
    public var configBuilder: ITilemapObjectNodeConfigBuilder

    public init(configBuilder b:ITilemapObjectNodeConfigBuilder) {
        configBuilder = b
    }

    public func build(tilemapObject: TilemapObject) -> Result<SKNode> {
        return configBuilder.buildNodeConfig(tilemapObject:tilemapObject).buildWith(NodeBuilder())
    }
}









