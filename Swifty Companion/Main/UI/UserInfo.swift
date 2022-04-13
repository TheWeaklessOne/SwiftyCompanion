//
//  UserInfo.swift
//  Swifty Companion
//
//  Created by Тетерин Даниил Владимирович on 09.03.2022.
//

import SwiftUI

struct UserInfo: View {

	@EnvironmentObject var networkService: NetworkService
	@State var isErrorAlertPresented = false
	@State var user: FullUserItem?

	let id: Int
	let login: String

	var body: some View {
		ZStack {
			LinearGradient.darkGradient.ignoresSafeArea()

			if let user = user {
				VStack {
					HStack {
						AsyncImage(url: user.imageURL) { image in
								image
									.resizable()
									.scaledToFill()
							} placeholder: {
								ProgressView()
							}
							.frame(width: 200, height: 200)
							.background(Color.gray)
							.onTapGesture {
								UIApplication.shared.open(URL(string: "swifty-companion://oauth-callback")!)
							}

						Spacer()

						VStack {
							Text(user.displayname)

							Text(user.selectedTitle)
						}
					}
					.padding()

					Spacer()
				}
				.foregroundColor(.white)
			}
		}
		.onAppear {
			Task(priority: .high) {
				guard let response: FullUser = await networkService.apiCall(for: "/v2/users/\(id)") else {
					isErrorAlertPresented.toggle()

					return
				}

				user = .init(user: response)
			}
		}
		.alert("Что-то пошло не так", isPresented: $isErrorAlertPresented) {
			Button("Жаль", role: .cancel) { }
		}
		.navigationBarTitleDisplayMode(.inline)
		.navigationTitle(login)
		.foregroundColor(.white)
	}
}

struct FullUserItem {
	let imageURL: URL
	let displayname: String

	let titles: [String]
	let selectedTitle: String

	init(user: FullUser) {
		imageURL = user.image_url
		displayname = user.displayname

		titles = user.titles.map {
			$0.name
		}

		let selectedID = user.titles_users.first(where: { $0.selected })?.title_id ?? -1
		selectedTitle = user.titles.first(where: { $0.id == selectedID })?.name ?? ""
	}
}

struct FullUser: Decodable {
	let displayname: String
	let image_url: URL

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
}
