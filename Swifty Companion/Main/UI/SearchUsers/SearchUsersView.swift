//
//  SearchUsersView.swift
//  Swifty Companion
//
//  Created by Тетерин Даниил Владимирович on 02.02.2022.
//

import SwiftUI

// MARK: - SearchUsersView

struct SearchUsersView: View {

	// MARK: Observed Objects

	@ObservedObject
	var viewModel: ViewModel

	// MARK: View Builders

	var body: some View {
		NavigationView {
			ZStack(alignment: .top) {
				LinearGradient.darkGradient.ignoresSafeArea()

				VStack(alignment: .leading) {
					HStack {
						Spacer()

						searchTextField

						logoutButton

						Spacer()
					}

					separator

					ScrollView {
						ForEach(viewModel.users) { user in
							UserItemView(user: user.data, viewModel: viewModel)
								.padding()
						}
					}
				}
			}
			.navigationTitle("Search logins")
			.onAppear {
				viewModel.fetchLogins()
			}
			.navigationBarHidden(true)
			.alert("Что-то пошло не так", isPresented: $viewModel.isErrorAlertPresented) {
				Button("Жаль", role: .cancel) { }
			}
		}
	}
}

// MARK: - SearchUsersView + ViewBuilders

private extension SearchUsersView {

	var searchTextField: some View {
		TextField("42 login", text: $viewModel.login)
			.disableAutocorrection(true)
			.textFieldStyle(.roundedBorder)
			.foregroundColor(.black)
			.background(
				RoundedRectangle(cornerRadius: 12, style: .continuous)
					.foregroundColor(.white)
			)
			.padding()
			.onChange(of: viewModel.login) { _ in
				viewModel.fetchLogins()
			}
			.onSubmit {
				viewModel.fetchLogins()
			}
	}

	var logoutButton: some View {
		Button("Logout") {
			viewModel.logout()
		}
		.frame(height: 35)
		.padding(.horizontal, 4)
		.foregroundColor(.black)
		.background(Color.white)
		.clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
		.padding(.trailing, 8)
	}

	var separator: some View {
		Rectangle()
			.frame(width: UIScreen.main.bounds.width, height: 4)
			.foregroundColor(.white)
			.padding(.bottom)
	}
}

// MARK: - SearchUsersView + UserItemView

private extension SearchUsersView {

	struct UserItemView: View {

		// MARK: Internal Properties

		let user: User

		// MARK: Observed Objects

		@ObservedObject
		var viewModel: SearchUsersView.ViewModel

		// MARK: View Builders

		var body: some View {
			Button(
				action: {
					Task {
						await viewModel.fetchUserDetailInfo(for: user.id)
					}
				},
				label: {
					userItem
				}
			)
			.fullScreenCover(isPresented: $viewModel.presentUserDetailView) {
				UserDetailView(viewModel: .init(user: viewModel.userDetailItem))
			}
		}

		var userItem: some View {
			HStack(spacing: 0) {
				userImage

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

		var userImage: some View {
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
		}
	}
}
