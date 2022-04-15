//
//  DataStructures.swift
//  Swifty Companion
//
//  Created by Тетерин Даниил Владимирович on 14.04.2022.
//

import Foundation

// MARK: - UserDetailView + Data Structures

extension UserDetailView {

	struct UserDetail: Decodable {
		let login: String
		let displayname: String
		let image_url: URL
		let correction_point: Int
		let wallet: Int

		let titles: [Title]
		struct Title: Decodable {
			let id: Int
			let name: String
		}

		let titles_users: [TitlesUsers]
		struct TitlesUsers: Decodable {
			let title_id: Int
			let selected: Bool
		}

		let cursus_users: [CursusUser]
		struct CursusUser: Decodable, Equatable {
			let level: Double

			let cursus: Cursus
			struct Cursus: Decodable, Equatable {
				let name: String
			}

			let skills: [Skill]
			struct Skill: Decodable, Equatable {
				let name: String
				let level: Double
			}
		}

		let projects_users: [ProjectUser]
		struct ProjectUser: Decodable, Equatable, Hashable {
			let id: Int
			let final_mark: Int?
			let validated: Bool?

			let status: ProjectUserStatus
			enum ProjectUserStatus: String, Decodable {
				case finished
				case creating_group
				case searching_a_group
				case waiting_for_correction
				case in_progress
				case parent

				static func < (lhs: Self, rhs: Self) -> Bool {
					lhs.toInt() < rhs.toInt()
				}

				func toInt() -> Int {
					switch self {
					case .finished:
						return 3
					case .creating_group, .searching_a_group:
						return 2
					case .waiting_for_correction:
						return 0
					case .in_progress:
						return 1
					case .parent:
						return 4
					}
				}
			}

			let project: Project
			struct Project: Decodable, Equatable {
				let name: String
			}

			func hash(into hasher: inout Hasher) {
				hasher.combine(id)
			}

			enum CodingKeys: String, CodingKey {
				case id
				case final_mark
				case validated = "validated?"
				case status
				case project
			}
		}
	}

	struct UserDetailItem: Equatable {
		let login: String
		let imageURL: URL
		let displayname: String
		let correctionPoints: Int
		let wallet: Int

		let titles: [String]
		let selectedTitle: String

		let cursuses: [UserDetail.CursusUser]
		let projects: [UserDetail.ProjectUser]

		init(user: UserDetail) {
			login = user.login
			imageURL = user.image_url
			displayname = user.displayname
			correctionPoints = user.correction_point
			wallet = user.wallet

			titles = user.titles.map {
				$0.name.replacingOccurrences(of: "%login", with: user.login)
			}.removingDuplicates()

			let selectedID = user.titles_users.first(where: { $0.selected })?.title_id ?? -1
			selectedTitle = user.titles.first(where: { $0.id == selectedID })?.name ?? ""

			cursuses = user.cursus_users

			projects = user.projects_users.filter { $0.status != .parent }.sorted { first, second in
				if first.status != second.status {
					return first.status < second.status
				}

				if first.final_mark != second.final_mark {
					return first.final_mark ?? -1 > second.final_mark ?? -1
				}

				return first.id < second.id
			}.removingDuplicates()
		}
	}
}
