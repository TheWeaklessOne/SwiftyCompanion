//
//  Throwable.swift
//  Swifty Companion
//
//  Created by Тетерин Даниил Владимирович on 13.04.2022.
//

import Foundation

struct Throwable<T: Decodable>: Decodable {
	let result: Result<T, Error>

	init(from decoder: Decoder) throws {
		result = Result(catching: { try T(from: decoder) })
	}
}
