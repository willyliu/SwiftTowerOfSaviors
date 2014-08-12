//
//  Array2D.swift
//  SwiftTowerOfSaviors
//
//  Created by Willy Liu on 2014/7/7.
//  Copyright (c) 2014年 Willy Liu. All rights reserved.
//

import Foundation

class Array2D<T> {
	let columns: Int
	let rows: Int
	var array: [T?]  // private
 
	init(columns: Int, rows: Int) {
		self.columns = columns
		self.rows = rows
		array = Array<T?>(count: rows*columns, repeatedValue: nil)
	}
 
	subscript(column: Int, row: Int) -> T? {
		get {
			return array[row*columns + column]
		}
		set {
			array[row*columns + column] = newValue
		}
	}
}