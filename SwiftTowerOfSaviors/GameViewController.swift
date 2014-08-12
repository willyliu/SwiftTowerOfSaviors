//
//  GameViewController.swift
//  SwiftTowerOfSaviors
//
//  Created by Willy Liu on 2014/7/7.
//  Copyright (c) 2014年 Willy Liu. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
	var scene: GameScene!
	var level: Level!
	var movesLeft: Int = 0
	var score: Int = 0
	var tapGestureRecognizer: UITapGestureRecognizer!
 
	@IBOutlet var scoreLabel: UILabel!
	@IBOutlet var gameOverPanel: UIView!
	
	init(coder aDecoder: NSCoder!) {
		super.init(coder: aDecoder)
	}
	
	init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
	}
	
	func beginGame() {
		scene.userInteractionEnabled = false
		score = 0
		updateLabels()
		scene.animateBeginGame() {
			self.scene.userInteractionEnabled = true
		}
		shuffle()
	}
 
	func shuffle() {
		scene.removeAllRuneStoneSprites()
		let newStones = level.shuffle()
		scene.addSpritesForRuneStones(newStones)
	}
	
	func handleSwipe(swap: Swap) {
		view.userInteractionEnabled = false
		
//		println("Before level.performSwap(), stoneA:\(swap.stoneA), stoneA.pos:\(swap.stoneA.sprite!.position), stoneB:\(swap.stoneB), stoneB.pos:\(swap.stoneB.sprite!.position)")
		
		level.performSwap(swap)

//		println("After level.performSwap(), stoneA:\(swap.stoneA), stoneA.pos:\(swap.stoneA.sprite!.position), stoneB:\(swap.stoneB), stoneB.pos:\(swap.stoneB.sprite!.position)")
		
		scene.animateSwap(swap) {
//			self.view.userInteractionEnabled = true
//			println("After animateSwap(), stoneA:\(swap.stoneA), stoneA.pos:\(swap.stoneA.sprite!.position), stoneB:\(swap.stoneB), stoneB.pos:\(swap.stoneB.sprite!.position)")
		}
	}
	
	func handleMatches() {
		let chains = level.removeMatches()
		if chains.count == 0 {
			beginNextTurn()
			return
		}
		scene.animateMatchedRuneStones(chains) {
			for chain in chains {
				self.score += chain.score
			}
			self.updateLabels()
			let columns = self.level.fillHoles()
			self.scene.animateFallingRuneStones(columns) {
				let columns = self.level.topUpRuneStones()
				self.scene.animateNewRuneStones(columns) {
					self.handleMatches()
				}
			}
		}
	}
	func beginNextTurn() {
		view.userInteractionEnabled = true
		if score >= level.targetScore {
			showGameOver()
		}
	}
	
	func updateLabels() {
		scoreLabel.text = NSString(format: "%ld", score)
	}
	
	func showGameOver() {
		gameOverPanel.hidden = false
		scene.userInteractionEnabled = false
			
		scene.animateGameOver() {
			self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "hideGameOver")
			self.view.addGestureRecognizer(self.tapGestureRecognizer)
		}
	}

	func hideGameOver() {
		view.removeGestureRecognizer(tapGestureRecognizer)
		tapGestureRecognizer = nil

		gameOverPanel.hidden = true
		scene.userInteractionEnabled = true

		beginGame()
	}
 
	override func prefersStatusBarHidden() -> Bool {
		return true
	}
 
	override func shouldAutorotate() -> Bool {
		return true
	}
 
	override func supportedInterfaceOrientations() -> Int {
		return Int(UIInterfaceOrientationMask.AllButUpsideDown.toRaw())
	}
 
	override func viewDidLoad() {
		super.viewDidLoad()
		
		gameOverPanel.hidden = true
		
		// Configure the view.
		let skView = view as SKView
		skView.multipleTouchEnabled = false
		
		// Create and configure the scene.
		scene = GameScene(size: skView.bounds.size)
		scene.scaleMode = .AspectFill
		scene.swipeHandler = handleSwipe
		scene.matchesHandler = handleMatches
		
		// Present the scene.
		skView.presentScene(scene)
		
		level = Level()
		scene.level = level
		
		beginGame()
	}
}