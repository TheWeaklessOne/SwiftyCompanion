//
//  SearchUsersViewModel.swift
//  Swifty Companion
//
//  Created by Тетерин Даниил Владимирович on 14.04.2022.
//

import Foundation

// MARK: - SearchUsersView + ViewModel

extension SearchUsersView {

	@MainActor
	final class ViewModel: ObservableObject {

		// MARK: Private Properties

		private var networkService: NetworkService

		// MARK: Internal Published Properties

		@Published
		var login = ""

		@Published
		var presentUserDetailView = false

		@Published
		var isErrorAlertPresented = false

		// MARK: Private(set) Published Properties

		@Published
		private(set) var users: [UserItem] = []

		// MARK: Internal Properties

		var userDetailItem: UserDetailView.UserDetailItem!

		// MARK: Initialize

		init(
			networkService: NetworkService
		) {
			self.networkService = networkService
		}

		// MARK: Internal Methods

		func fetchLogins() {
			Task(priority: .high) {
				guard let response: [Throwable<User>] = await networkService.apiCall(
					for: "/v2/users?range[login]=\(login.lowercased()),\(login.lowercased() + "z")"
				) else {
//					await MainActor.run {
//						isErrorAlertPresented.toggle()
//					}
					return
				}

				await MainActor.run {
					users = response.compactMap {
						if let data = try? $0.result.get() {
							return UserItem(data: data)
						} else {
							return nil
						}
					}
				}
			}
		}

		func fetchUserDetailInfo(for id: Int) async {
			guard let result: UserDetailView.UserDetail = await networkService.apiCall(for: "/v2/users/\(id)") else {
				await MainActor.run {
					isErrorAlertPresented.toggle()
				}
				return
			}

			userDetailItem = .init(user: result)

			await MainActor.run {
				presentUserDetailView.toggle()
			}
		}

		func logout() {
			networkService.logout()
		}
	}
}
