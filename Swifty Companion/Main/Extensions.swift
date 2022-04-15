//
//  Extensions.swift
//  Swifty Companion
//
//  Created by Тетерин Даниил Владимирович on 13.04.2022.
//

import Foundation

extension Array where Element: Hashable {
	func removingDuplicates() -> [Element] {
		var addedDict = [Element: Bool]()

		return filter {
			addedDict.updateValue(true, forKey: $0) == nil
		}
	}

	mutating func removeDuplicates() {
		self = self.removingDuplicates()
	}
}
