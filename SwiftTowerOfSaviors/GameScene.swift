//
//  GameScene.swift
//  SwiftTowerOfSaviors
//
//  Created by Willy Liu on 2014/7/7.
//  Copyright (c) 2014年 Willy Liu. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
	var level: Level!
	let TileWidth: CGFloat = 53.0
	let TileHeight: CGFloat = 53.0
	
	let gameLayer = SKNode()
	let runeStonesLayer = SKNode()
	
	var movingStone: RuneStone?
	
	var swipeHandler: ((Swap) -> ())?
	var matchesHandler: (() -> ())?
	var touchBeginTime: NSTimeInterval = 0.0
	let progressBar = ProgressBar()
	
	required init(coder aDecoder: NSCoder!) {
		super.init(coder: aDecoder)
	}
	
	override init(size: CGSize) {
		super.init(size: size)
		
		anchorPoint = CGPoint(x: 0.0, y: 0.0)
		
		addChild(gameLayer)
		
		let layerPosition = CGPoint(
			x: 0.0,
			y: 0.0)
		
		runeStonesLayer.position = layerPosition
		gameLayer.addChild(runeStonesLayer)
		gameLayer.hidden = true
		movingStone = nil
		SKLabelNode(fontNamed: "GillSans-BoldItalic")
	}
	
	func addSpritesForRuneStones(stones: Set<RuneStone>) {
		for stone in stones {
			let texture = RuneStoneType.textureForRuneStoneType(stone.runeStoneType)
			let sprite = SKSpriteNode(texture: texture)
			assert(sprite.size != CGSizeZero, "Sprite size must not be zero")
			sprite.position = pointForColumn(stone.column, row:stone.row)
			runeStonesLayer.addChild(sprite)
			stone.sprite = sprite
		}
	}
	
	func removeAllRuneStoneSprites() {
		runeStonesLayer.removeAllChildren()
	}
 
	func pointForColumn(column: Int, row: Int) -> CGPoint {
		return CGPoint(
			x: CGFloat(column)*TileWidth + TileWidth/2,
			y: CGFloat(row)*TileHeight + TileHeight/2)
	}
	
	func convertPoint(point: CGPoint) -> (success: Bool, column: Int, row: Int) {
		if point.x >= 0 && point.x < CGFloat(NumColumns)*TileWidth &&
			point.y >= 0 && point.y < CGFloat(NumRows)*TileHeight {
				return (true, Int(point.x / TileWidth), Int(point.y / TileHeight))
		} else {
			return (false, 0, 0)  // invalid location
		}
	}
	
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
		let touch = touches.anyObject() as UITouch
		let location = touch.locationInNode(runeStonesLayer)
		let (success, column, row) = convertPoint(location)
		if success {
			if let stone = level.stoneAtColumn(column, row: row) {
				movingStone = stone
			}
		}
    }
	
	override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {
		if movingStone == nil { return }

		let touch = touches.anyObject() as UITouch
		let location = touch.locationInNode(runeStonesLayer)
		
		movingStone!.sprite!.position = location
		movingStone!.sprite!.zPosition = 100

		let (success, column, row) = convertPoint(location)
		if success {
			var horzDelta = 0, vertDelta = 0
			if column < movingStone!.column {          // swipe left
				horzDelta = -1
			} else if column > movingStone!.column {   // swipe right
				horzDelta = 1
			} else if row < movingStone!.row {         // swipe down
				vertDelta = -1
			} else if row > movingStone!.row {         // swipe up
				vertDelta = 1
			}

			if horzDelta != 0 || vertDelta != 0 {
				let (swappable, toColumn, toRow) = trySwapHorizontal(horzDelta, vertical: vertDelta)
			}
		}
	}
	
	func trySwapHorizontal(horzDelta: Int, vertical vertDelta: Int) -> (Bool, Int, Int) {
		if movingStone == nil { return (false, 0, 0) }
		let toColumn = movingStone!.column + horzDelta
		let toRow = movingStone!.row + vertDelta
		
		if toColumn < 0 || toColumn >= NumColumns { return (false, 0, 0)}
		if toRow < 0 || toRow >= NumRows { return (false, 0, 0)}

		if let toStone = level.stoneAtColumn(toColumn, row: toRow) {
			if let fromStone = movingStone {
//				println("*** swapping movingStone:\(movingStone) with \(toStone)")
				if let handler = swipeHandler {
					let swap = Swap(stoneA: fromStone, stoneB: toStone)
					handler(swap)
					return (true, toColumn, toRow)
				}
			}
		}
		return (false, 0, 0)
	}
	
	func animateSwap(swap: Swap, completion: () -> ()) {
		var anotherStone: RuneStone! = swap.stoneA	// the stone that is not the moving stone
		if anotherStone === movingStone {
			anotherStone = swap.stoneB
		}
		
		// when running here, the column and row is alread updated, but position is not updated yet,
		// so we have to update another stone's position to position corresponding to its column and row
		
		let sprite = anotherStone.sprite!
		sprite.zPosition = 90
		
		let Duration: NSTimeInterval = 0.3
		let position = pointForColumn(anotherStone.column, row:anotherStone.row)
		let move = SKAction.moveTo(position, duration: Duration)
		move.timingMode = .EaseOut
		sprite.runAction(move, completion: completion)
	}
	
	func animateMatchedRuneStones(chains: Set<Chain>, completion: () -> ()) {
		for chain in chains {
			animateScoreForChain(chain)
			for stone in chain.runeStones {
				if let sprite = stone.sprite {
					if sprite.actionForKey("removing") == nil {
						let scaleAction = SKAction.scaleTo(0.1, duration: 0.3)
						scaleAction.timingMode = .EaseOut
						sprite.runAction(SKAction.sequence([scaleAction, SKAction.removeFromParent()]),
							withKey:"removing")
					}
				}
			}
		}
//		runAction(matchSound)
		runAction(SKAction.waitForDuration(0.3), completion: completion)
	}
	
	func animateFallingRuneStones(columns: Array<Array<RuneStone>>, completion: () -> ()) {
		// 1
		var longestDuration: NSTimeInterval = 0
		for array in columns {
			for (idx, stone) in enumerate(array) {
				let newPosition = pointForColumn(stone.column, row: stone.row)
				// 2
				let delay = 0.05 + 0.15*NSTimeInterval(idx)
				// 3
				let sprite = stone.sprite!
				let duration = NSTimeInterval(((sprite.position.y - newPosition.y) / TileHeight) * 0.1)
				// 4
				longestDuration = max(longestDuration, duration + delay)
				// 5
				let moveAction = SKAction.moveTo(newPosition, duration: duration)
				moveAction.timingMode = .EaseOut
				sprite.runAction(
					SKAction.sequence([
						SKAction.waitForDuration(delay),
//						SKAction.group([moveAction, fallingCookieSound])]))
						SKAction.group([moveAction])]))
			}
		}
		// 6
		runAction(SKAction.waitForDuration(longestDuration), completion: completion)
	}
	
	func animateNewRuneStones(columns: Array<Array<RuneStone>>, completion: () -> ()) {
		// 1
		var longestDuration: NSTimeInterval = 0
			
		for array in columns {
			// 2
			let startRow = array[0].row + 1

			for (idx, stone) in enumerate(array) {
				// 3
				let spriteName = stone.runeStoneType.spriteName
				let texture = RuneStoneType.textureForRuneStoneType(stone.runeStoneType)
				let sprite = SKSpriteNode(texture: texture)
				assert(sprite.size != CGSizeZero, "Sprite size must not be zero")
				sprite.position = pointForColumn(stone.column, row: startRow)
				runeStonesLayer.addChild(sprite)
				stone.sprite = sprite
				// 4
				let delay = 0.1 + 0.2 * NSTimeInterval(array.count - idx - 1)
				// 5
				let duration = NSTimeInterval(startRow - stone.row) * 0.1
				longestDuration = max(longestDuration, duration + delay)
				// 6
				let newPosition = pointForColumn(stone.column, row: stone.row)
				let moveAction = SKAction.moveTo(newPosition, duration: duration)
				moveAction.timingMode = .EaseOut
				sprite.alpha = 0
				sprite.runAction(
					SKAction.sequence([
						SKAction.waitForDuration(delay),
						SKAction.group([
							SKAction.fadeInWithDuration(0.05),
							moveAction])
//							moveAction,
//							addCookieSound])
						]))
			}
		}
		// 7
		runAction(SKAction.waitForDuration(longestDuration), completion: completion)
	}
	
	func animateScoreForChain(chain: Chain) {
		// Figure out what the midpoint of the chain is.
		var centerPosition = CGPoint()
		if chain.chainType != .HorizontalAndVertical {
			let firstSprite = chain.firstRuneStone().sprite!
			let lastSprite = chain.lastRuneStone().sprite!
			centerPosition = CGPoint(
				x: (firstSprite.position.x + lastSprite.position.x)/2,
				y: (firstSprite.position.y + lastSprite.position.y)/2 - 8)
		}
		else {
			if let pivotStone = chain.pivotRuneStone {
				let sprite = pivotStone.sprite!
				centerPosition = CGPoint(
					x: CGRectGetMidX(sprite.frame),
					y: CGRectGetMidY(sprite.frame) - 8)
			}
			else {
				// fallback to third rune stone
				let thirdSprite = chain.runeStones[2].sprite!
				centerPosition = CGPoint(
					x: CGRectGetMidX(thirdSprite.frame),
					y: CGRectGetMidY(thirdSprite.frame) - 8)
			}
		}
		
		// Add a label for the score that slowly floats up.
		let scoreLabel = SKLabelNode(fontNamed: "GillSans-BoldItalic")
		scoreLabel.fontSize = 16
		scoreLabel.text = NSString(format: "%ld", chain.score)
		scoreLabel.position = centerPosition
		scoreLabel.zPosition = 300
		runeStonesLayer.addChild(scoreLabel)
			
		let moveAction = SKAction.moveBy(CGVector(dx: 0, dy: 3), duration: 0.7)
		moveAction.timingMode = .EaseOut
		scoreLabel.runAction(SKAction.sequence([moveAction, SKAction.removeFromParent()]))
	}
	
	func animateGameOver(completion: () -> ()) {
		let action = SKAction.moveBy(CGVector(dx: 0, dy: -size.height), duration: 0.3)
		action.timingMode = .EaseIn
		gameLayer.runAction(action, completion: completion)
	}
 
	func animateBeginGame(completion: () -> ()) {
		gameLayer.hidden = false
		gameLayer.position = CGPoint(x: 0, y: size.height)
		let action = SKAction.moveBy(CGVector(dx: 0, dy: -size.height), duration: 0.3)
		action.timingMode = .EaseOut
		gameLayer.runAction(action, completion: completion)
	}
	
	override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
		handleTouchEnded()
	}
	
	func handleTouchEnded() {
		if let stone = movingStone {
			stone.sprite!.position = pointForColumn(stone.column, row:stone.row)
			stone.sprite!.zPosition = 90
			movingStone = nil
		}
		touchBeginTime = 0.0
		resetProgressBar()
		if let handler = matchesHandler {
			handler()
		}
	}
 
	override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
		handleTouchEnded()
	}
	
	func resetProgressBar() {
		let scaleAction = SKAction.scaleTo(0.1, duration: 0.3)
		scaleAction.timingMode = .EaseOut
		progressBar.runAction(SKAction.sequence([scaleAction, SKAction.hide()]), completion:{
			self.progressBar.xScale = 1.0
			self.progressBar.yScale = 1.0
		})
	}
	
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
		if movingStone != nil {
			if touchBeginTime == 0.0 {
				touchBeginTime = currentTime
				if !progressBar.parent {
					let y = TileHeight * (CGFloat)(level!.rowsCount)
					progressBar.position = CGPoint(x:0, y:y + 10)
					runeStonesLayer.addChild(progressBar)
				}
				progressBar.removeAllActions()
				progressBar.runAction(SKAction.unhide())
			}
			
			let timeSinceTouchBegin = currentTime - touchBeginTime
			let kMoveRuneStoneTimeLimit = 10.0
			let timeLeft = kMoveRuneStoneTimeLimit - timeSinceTouchBegin
			let progress = timeLeft/kMoveRuneStoneTimeLimit
			progressBar.progress = CGFloat(progress)
			if timeLeft < 0 {
				handleTouchEnded()
			}
		}
    }
}
