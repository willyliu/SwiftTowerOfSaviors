//
//  SwiftTowerOfSaviorsTests.swift
//  SwiftTowerOfSaviorsTests
//
//  Created by Willy Liu on 2014/7/4.
//  Copyright (c) 2014年 Willy Liu. All rights reserved.
//

import XCTest

class SwiftTowerOfSaviorsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
	
	func testChainIsIntersectedWithSameStone() {
		let stone = RuneStone(column: 0, row: 0, runeStoneType: RuneStoneType.random())
		let chain = Chain(chainType: .Horizontal)
		chain.addRuneStone(stone)
		let chain2 = Chain(chainType: .Vertical)
		chain2.addRuneStone(stone)
		XCTAssertTrue(chain.isIntersectedWith(chain2), "Must be intersected")
	}
	
	func testChainIsIntersectedWithTwoStones() {
		let stone = RuneStone(column: 0, row: 0, runeStoneType: RuneStoneType.random())
		let chain = Chain(chainType: .Horizontal)
		chain.addRuneStone(stone)
		let stone2 = RuneStone(column: 0, row: 1, runeStoneType: RuneStoneType.random())
		let chain2 = Chain(chainType: .Vertical)
		chain2.addRuneStone(stone2)
		XCTAssertFalse(chain.isIntersectedWith(chain2), "Must not be intersected")
	}
	
	func testUnionChainWithSameStone() {
		let stone = RuneStone(column: 0, row: 0, runeStoneType: RuneStoneType.random())
		let chain = Chain(chainType: .Horizontal)
		chain.addRuneStone(stone)
		let chain2 = Chain(chainType: .Vertical)
		chain2.addRuneStone(stone)
		let unionChain = chain.unionChainWith(chain2)
		XCTAssertNotNil(unionChain, "Chian must exist")
		XCTAssertEqual(unionChain.runeStones.count, 1, "Union chain must have one stone")
	}
	
	func testUnionChainWithTwoStones() {
		let stone = RuneStone(column: 0, row: 0, runeStoneType: RuneStoneType.random())
		let chain = Chain(chainType: .Horizontal)
		chain.addRuneStone(stone)
		let stone2 = RuneStone(column: 0, row: 1, runeStoneType: RuneStoneType.random())
		let chain2 = Chain(chainType: .Vertical)
		chain2.addRuneStone(stone2)
		let unionChain = chain.unionChainWith(chain2)
		XCTAssertNil(unionChain, "Chian must not exist")
	}
}
