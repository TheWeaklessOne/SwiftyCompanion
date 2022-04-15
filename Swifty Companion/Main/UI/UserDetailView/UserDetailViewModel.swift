//
//  UserDetailViewModel.swift
//  Swifty Companion
//
//  Created by Тетерин Даниил Владимирович on 14.04.2022.
//

import Foundation

// MARK: - UserDetailView + ViewModel

extension UserDetailView {

	@MainActor
	final class ViewModel: ObservableObject {

		// MARK: Internal Properties

		let user: UserDetailItem

		var selectedCursusSkills: [UserDetail.CursusUser.Skill] = []

		// MARK: Internal Published Properties

		@Published
		var isErrorAlertPresented = false

		@Published
		var presentSkillsSheet = false

		// MARK: Initialize

		init(
			user: UserDetailItem
		) {
			self.user = user
		}
	}
}
