//
//  Swifty_CompanionApp.swift
//  Swifty Companion
//
//  Created by Тетерин Даниил Владимирович on 02.02.2022.
//

import SwiftUI

@main
struct Swifty_CompanionApp: App {

	// MARK: Private Properties

	private let networkService = NetworkService()

	// MARK: State Properties

	@State
	private var isErrorAlertPresented = false
	
	@State
	var loggedIn = false

	// MARK: Scene

	var body: some Scene {
		WindowGroup {
			mainScreen
				.onReceive(networkService.$isSessionActive) { isActive in
					self.loggedIn = isActive
				}
				.onOpenURL {
					do {
						try networkService.handleRedirectURL(for: $0)
					} catch {
						isErrorAlertPresented.toggle()
					}
				}
				.onAppear {
					Task {
						 await networkService.updateAccessTokenIfNeeded()
					}
				}
				.alert("Что-то пошло не так", isPresented: $isErrorAlertPresented) {
					Button("Жаль", role: .cancel) { }
				}
				.fullScreenCover(isPresented: $loggedIn) {
					SearchUsersView(
						viewModel: SearchUsersView.ViewModel(networkService: networkService)
					)
				}
		}
	}

	// MARK: View Builders

	var mainScreen: some View {
		ZStack(alignment: .bottom) {
			LinearGradient.darkGradient.ignoresSafeArea()

			VStack(alignment: .center) {
				Spacer()

				Text("Swifty Companion")
					.font(.largeTitle)
					.foregroundColor(.white)

				Spacer()

				Button("Войти".uppercased()) {
					Task {
						await networkService.authorize()
					}
				}
				.buttonStyle(IntraMain())
				.padding(.bottom, 48)
				.disabled(loggedIn)
			}
		}
	}
}
