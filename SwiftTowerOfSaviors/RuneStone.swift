//
//  File.swift
//  SwiftTowerOfSaviors
//
//  Created by Willy Liu on 2014/7/4.
//  Copyright (c) 2014年 Willy Liu. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

enum RuneStoneType: Int, Printable {
	case Unknown = 0
	case Water
	case Fire
	case Wood
	case Light
	case Dark
	case Heart
	static var texturesForRuneStoneType:[String: SKTexture] = Dictionary<String, SKTexture>()
	
	static func random() -> RuneStoneType {
		return RuneStoneType.fromRaw(Int(arc4random_uniform(6)) + 1)!
	}

	static func textureForRuneStoneType(runeStoneType: RuneStoneType) -> SKTexture {
		if texturesForRuneStoneType[runeStoneType.spriteName] == nil {
			texturesForRuneStoneType[runeStoneType.spriteName] = SKTexture(imageNamed: runeStoneType.spriteName)
		}
		return texturesForRuneStoneType[runeStoneType.spriteName]!
	}
	
	var spriteName: String {
		let spriteNames = [
			"Water",
			"Fire",
			"Wood",
			"Light",
			"Dark",
			"Heart"]
		
		return spriteNames[toRaw() - 1]
	}
	
	var description: String {
	return spriteName
	}
	
	var debugDescription: String {
	return description
	}
}

func ==(lhs: RuneStone, rhs: RuneStone) -> Bool {
	return lhs.column == rhs.column && lhs.row == rhs.row
}

class RuneStone : Printable, Hashable {
	var column: Int
	var row: Int
	let runeStoneType: RuneStoneType
	var sprite: SKSpriteNode?
	
	init(column: Int, row: Int, runeStoneType: RuneStoneType) {
		self.column = column
		self.row = row
		self.runeStoneType = runeStoneType
	}
	
	var description: String {
	return "type:\(runeStoneType) square:(\(column),\(row))"
	}
	
	var hashValue: Int {
	return row*10 + column
	}
}