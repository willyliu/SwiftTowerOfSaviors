//
//  Swap.swift
//  SwiftTowerOfSaviors
//
//  Created by Willy Liu on 2014/7/7.
//  Copyright (c) 2014年 Willy Liu. All rights reserved.
//

import Foundation

class Swap: Printable {
	var stoneA: RuneStone
	var stoneB: RuneStone
 
	init(stoneA: RuneStone, stoneB: RuneStone) {
		self.stoneA = stoneA
		self.stoneB = stoneB
	}
 
	var description: String {
		return "swap \(stoneA) with \(stoneB)"
	}
}