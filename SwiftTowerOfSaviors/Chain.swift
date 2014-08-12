//
//  Chain.swift
//  SwiftTowerOfSaviors
//
//  Created by Willy Liu on 2014/7/8.
//  Copyright (c) 2014年 Willy Liu. All rights reserved.
//

import Foundation

class Chain: Hashable, Printable {
	var runeStones = Array<RuneStone>()  // private
	var score: Int = 0
	var pivotRuneStone: RuneStone? = nil
 
	enum ChainType: Printable {
		case Horizontal
		case Vertical
		case HorizontalAndVertical
		
		var description: String {
		switch self {
		case .Horizontal: return "Horizontal"
		case .Vertical: return "Vertical"
		case .HorizontalAndVertical: return "HorizontalAndVertical"
			}
		}
	}
 
	var chainType: ChainType
 
	init(chainType: ChainType) {
		self.chainType = chainType
	}
 
	func addRuneStone(stone: RuneStone) {
		runeStones.append(stone)
	}
 
	func firstRuneStone() -> RuneStone {
		return runeStones[0]
	}
 
	func lastRuneStone() -> RuneStone {
		return runeStones[runeStones.count - 1]
	}
 
	var length: Int {
	return runeStones.count
	}
 
	var description: String {
	return "type:\(chainType) runeStones:\(runeStones)"
	}
 
	var hashValue: Int {
	return reduce(runeStones, 0) { $0.hashValue ^ $1.hashValue }
	}
	
	func isIntersectedWith(anotherChain: Chain) -> Bool {
		for stone in runeStones {
			for anotherStone in anotherChain.runeStones {
				if (stone.row == anotherStone.row && stone.column == anotherStone.column) {
					return true
				}
			}
		}
		return false
	}
	
	func unionChainWith(anotherChain: Chain) -> Chain! {
		if !isIntersectedWith(anotherChain) {
			return nil
		}
		let resultChain = Chain(chainType: .HorizontalAndVertical)
		for stone in runeStones {
			resultChain.runeStones.append(stone)
		}
		for stone in anotherChain.runeStones {
			if let foundIndex = find(resultChain.runeStones, stone) {
				resultChain.pivotRuneStone = resultChain.runeStones[foundIndex]
			}
			else {
				resultChain.runeStones.append(stone)
			}
		}
		return resultChain
	}
}

func ==(lhs: Chain, rhs: Chain) -> Bool {
	return lhs.runeStones == rhs.runeStones
}