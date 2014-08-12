//
//  Level.swift
//  SwiftTowerOfSaviors
//
//  Created by Willy Liu on 2014/7/7.
//  Copyright (c) 2014年 Willy Liu. All rights reserved.
//

import Foundation

let NumColumns = 6
let NumRows = 5

class Level {
	let runeStones = Array2D<RuneStone>(columns: NumColumns, rows: NumRows)  // private
	let rowsCount = NumRows
	let columnsCount = NumColumns
	let targetScore = 100
	
	func stoneAtColumn(column: Int, row: Int) -> RuneStone? {
		assert(column >= 0 && column < NumColumns)
		assert(row >= 0 && row < NumRows)
		return runeStones[column, row]
	}
	
	func shuffle() -> Set<RuneStone> {
		return createInitialStones()
	}
 
	func createInitialStones() -> Set<RuneStone> {
		var set = Set<RuneStone>()
		for row in 0 ..< NumRows {
			for column in 0 ..< NumColumns {
				// makes sure we don't create combo initially
				var runeStoneType: RuneStoneType
				do {
					runeStoneType = RuneStoneType.random()
				}
				while (column >= 2 &&
					runeStones[column - 1, row]?.runeStoneType == runeStoneType &&
					runeStones[column - 2, row]?.runeStoneType == runeStoneType)
					|| (row >= 2 &&
						runeStones[column, row - 1]?.runeStoneType == runeStoneType &&
						runeStones[column, row - 2]?.runeStoneType == runeStoneType)
				let runeStone = RuneStone(column: column, row: row, runeStoneType: runeStoneType)
				runeStones[column, row] = runeStone
				set.addElement(runeStone)
			}
		}
		return set
	}
	
	func performSwap(swap: Swap) {
		let columnA = swap.stoneA.column
		let rowA = swap.stoneA.row
		let columnB = swap.stoneB.column
		let rowB = swap.stoneB.row
			
		runeStones[columnA, rowA] = swap.stoneB
		swap.stoneB.column = columnA
		swap.stoneB.row = rowA
			
		runeStones[columnB, rowB] = swap.stoneA
		swap.stoneA.column = columnB
		swap.stoneA.row = rowB
	}
	
	func detectHorizontalMatches() -> Set<Chain> {
		// 1
		let set = Set<Chain>()
		// 2
		for row in 0..<NumRows {
			for var column = 0; column < NumColumns - 2 ; {
				// 3
				if let stone = runeStones[column, row] {
					let matchType = stone.runeStoneType
					// 4
					if runeStones[column + 1, row]?.runeStoneType == matchType &&
						runeStones[column + 2, row]?.runeStoneType == matchType {
							// 5
							let chain = Chain(chainType: .Horizontal)
							do {
								chain.addRuneStone(runeStones[column, row]!)
								++column
							}
							while column < NumColumns && runeStones[column, row]?.runeStoneType == matchType
							
							set.addElement(chain)
							continue
					}
				}
				// 6
				++column
			}
		}
		return set
	}
	
	func detectVerticalMatches() -> Set<Chain> {
		let set = Set<Chain>()
			
		for column in 0..<NumColumns {
			for var row = 0; row < NumRows - 2; {
				if let stone = runeStones[column, row] {
					let matchType = stone.runeStoneType
					
					if runeStones[column, row + 1]?.runeStoneType == matchType &&
						runeStones[column, row + 2]?.runeStoneType == matchType {
							
							let chain = Chain(chainType: .Vertical)
							do {
								chain.addRuneStone(runeStones[column, row]!)
								++row
							}
								while row < NumRows && runeStones[column, row]?.runeStoneType == matchType
							
							set.addElement(chain)
							continue
					}
				}
				++row
			}
		}
		return set
	}
	
	func removeMatches() -> Set<Chain> {
		let horizontalChains = detectHorizontalMatches()
		let verticalChains = detectVerticalMatches()
		var allChains = horizontalChains.unionSet(verticalChains)

		// detect intersected chains
		for hChain in horizontalChains {
			for vChain in verticalChains {
				if hChain.isIntersectedWith(vChain) {
					allChains.removeElement(hChain)
					allChains.removeElement(vChain)
					allChains.addElement(hChain.unionChainWith(vChain))
				}
			}
		}
		
		calculateScores(allChains)
		removeRuneStones(allChains)
		
		return allChains
	}
	
	func removeRuneStones(chains: Set<Chain>) {
		for chain in chains {
			for stone in chain.runeStones {
				runeStones[stone.column, stone.row] = nil
			}
		}
	}
	
	func fillHoles() -> Array<Array<RuneStone>> {
		var columns = Array<Array<RuneStone>>()
		// 1
		for column in 0..<NumColumns {
			var array = Array<RuneStone>()
			for row in 0..<NumRows {
				// 2
				if runeStones[column, row] == nil {
					// 3
					for lookup in (row + 1)..<NumRows {
						if let stone = runeStones[column, lookup] {
							// 4
							runeStones[column, lookup] = nil
							runeStones[column, row] = stone
							stone.row = row
							// 5
							array.append(stone)
							// 6
							break
						}
					}
				}
			}
			// 7
			if !array.isEmpty {
				columns.append(array)
			}
		}
		return columns
	}
	
	func topUpRuneStones() -> Array<Array<RuneStone>> {
		var columns = Array<Array<RuneStone>>()
		var runeStoneType: RuneStoneType = .Unknown
			
		for column in 0..<NumColumns {
			var array = Array<RuneStone>()
			// 1
			for var row = NumRows - 1; row >= 0 && runeStones[column, row] == nil; --row {
				// 3
				var newRuneStoneType: RuneStoneType
				do {
					newRuneStoneType = RuneStoneType.random()
				} while newRuneStoneType == runeStoneType
				runeStoneType = newRuneStoneType
				// 4
				let stone = RuneStone(column: column, row: row, runeStoneType: runeStoneType)
				runeStones[column, row] = stone
				array.append(stone)
			}
			// 5
			if !array.isEmpty {
				columns.append(array)
			}
		}
		assert(!isRuneStonesContainingHoles(), "Rune stones must not contain holes")
		return columns
	}
	
	func isRuneStonesContainingHoles() -> Bool {
		for column in 0 ..< NumColumns {
			for row in 0 ..< NumRows {
				if runeStones[column, row] == nil {
					return true
				}
			}
		}
		return false
	}
	
	func calculateScores(chains: Set<Chain>) {
		// 3-chain is 60 pts, 4-chain is 120, 5-chain is 180, and so on
		for chain in chains {
//			chain.score = 60 * (chain.length - 2)
			chain.score = chain.length
		}
	}
}