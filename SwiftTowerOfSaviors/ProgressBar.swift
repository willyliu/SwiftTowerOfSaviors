//
//  ProgressBar.swift
//  SwiftTowerOfSaviors
//
//  Created by Willy Liu on 2014/7/9.
//  Copyright (c) 2014年 Willy Liu. All rights reserved.
//

import Foundation
import SpriteKit

class ProgressBar: SKCropNode {
	var progress: CGFloat {
	get {
		return self.maskNode.xScale
	}
	set {
		self.maskNode.xScale = newValue
	}
	}
	required init(coder aDecoder: NSCoder!) {
		super.init(coder: aDecoder)
	}
	override init() {
		super.init()
		let maskNode = SKSpriteNode(color: UIColor.whiteColor(), size: CGSizeMake(UIScreen.mainScreen().bounds.size.width, 5))
		maskNode.anchorPoint = CGPoint(x:0.0,y:0.0)
		self.maskNode = maskNode
		let sprite = SKSpriteNode(color: UIColor.greenColor(), size: CGSizeMake(UIScreen.mainScreen().bounds.size.width, 5))
		sprite.anchorPoint = CGPoint(x:0.0,y:0.0)
		addChild(sprite)
	}
}