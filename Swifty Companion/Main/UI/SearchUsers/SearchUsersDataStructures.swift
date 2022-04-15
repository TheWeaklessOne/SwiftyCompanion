//
//  DataStructures.swift
//  Swifty Companion
//
//  Created by Тетерин Даниил Владимирович on 14.04.2022.
//

import Foundation

// MARK: - SearchUsersView + Data Structures

extension SearchUsersView {

	struct User: Decodable {
		let id: Int
		let login: String
		let image_url: URL
		let pool_month: String
		let pool_year: String
	}

	struct UserItem: Identifiable {
		let data: User
		let id = UUID()
	}
}
