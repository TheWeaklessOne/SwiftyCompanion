//
//  SearchLogins.swift
//  Swifty Companion
//
//  Created by Тетерин Даниил Владимирович on 02.02.2022.
//

import SwiftUI

struct SearchLogins: View {
	@EnvironmentObject var networkService: NetworkService
	@Environment(\.dismiss) var dismiss

	@State private var login = ""
	@State var users: [UserItem] = []

	let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13 ,14 ,15]

	var body: some View {
		NavigationView {
			ZStack {
				LinearGradient.darkGradient.ignoresSafeArea()

				VStack(alignment: .leading) {
					HStack {
						Spacer()

						TextField("42 login", text: $login)
							.textFieldStyle(.roundedBorder)
							.foregroundColor(.black)
							.padding()
							.onChange(of: login) { _ in
								fetchLogins()
							}
							.onSubmit {
								fetchLogins()
							}

						Button("Logout") {
							networkService.logout()

							dismiss()
						}
						.frame(height: 35)
						.padding(.horizontal, 4)
						.foregroundColor(.black)
						.background(Color.white)
						.clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
						.padding(.trailing, 8)

						Spacer()
					}

					Rectangle()
						.frame(width: UIScreen.main.bounds.width, height: 4)
						.foregroundColor(.white)
						.padding(.bottom)

					ScrollView {
						ForEach(users) { user in
							UserItemRepresentation(user: user.data)
								.padding()
						}
					}
				}
			}
			.navigationTitle("Search logins")
			.onAppear {
				fetchLogins()
			}
			.navigationBarHidden(true)
		}
	}

	struct UserItemRepresentation: View {
		let user: User

		var body: some View {
			NavigationLink(
				destination: {
					UserInfo(id: user.id, login: user.login)
				},
				label: {
					HStack(spacing: 0) {
						AsyncImage(url: user.image_url) { image in
								image
									.resizable()
									.scaledToFill()
							} placeholder: {
								ProgressView()
							}
							.frame(width: 48, height: 48)
							.background(Color.gray)
							.clipShape(Circle())

						Text(user.login)
							.padding(.leading, 24)

						Spacer()

						Text(user.pool_month + ", " + user.pool_year)
							.padding(.trailing, 12)
					}
					.foregroundColor(.white)
					.background(Color.white.opacity(0.2))
					.clipShape(Capsule())
				}
			)
		}
	}

	private func fetchLogins() {
		Task(priority: .high) {
			guard let response: [User] = await networkService.apiCall(
				for: "/v2/users?range[login]=\(login.lowercased()),\(login.lowercased() + "z")"
			) else {
				return
			}

			users = response.map {
				UserItem(data: $0)
			}
		}
	}
}

struct UserItem: Identifiable {
	let data: User
	let id = UUID()
}

struct User: Decodable {
	let id: Int
	let login: String
	let image_url: URL?
	let pool_month: String
	let pool_year: String
}
