//
//  Set.swift
//  SwiftTowerOfSaviors
//
//  Created by Willy Liu on 2014/7/7.
//  Copyright (c) 2014年 Willy Liu. All rights reserved.
//

import Foundation

class Set<T: Hashable>: SequenceType, Printable {
	var dictionary = Dictionary<T, Bool>()  // private
 
	func addElement(newElement: T) {
		dictionary[newElement] = true
	}
 
	func removeElement(element: T) {
		dictionary[element] = nil
	}
 
	func containsElement(element: T) -> Bool {
		return dictionary[element] != nil
	}
 
	func allElements() -> [T] {
		return Array(dictionary.keys)
	}
 
	var count: Int {
	return dictionary.count
	}
 
	func unionSet(otherSet: Set<T>) -> Set<T> {
		var combined = Set<T>()
		
		for obj in dictionary.keys {
			combined.dictionary[obj] = true
		}
		
		for obj in otherSet.dictionary.keys {
			combined.dictionary[obj] = true
		}
		
		return combined
	}
 
	func generate() -> IndexingGenerator<Array<T>> {
		return allElements().generate()
	}
 
	var description: String {
	return dictionary.description
	}
}