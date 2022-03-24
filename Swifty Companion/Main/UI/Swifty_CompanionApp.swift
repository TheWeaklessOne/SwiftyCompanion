//
//  Swifty_CompanionApp.swift
//  Swifty Companion
//
//  Created by Тетерин Даниил Владимирович on 02.02.2022.
//

import SwiftUI

@main
struct Swifty_CompanionApp: App {
	@StateObject var networkService = NetworkService()

	@State private var isErrorAlertPresented = false

	@State var loggedIn = false

	var body: some Scene {
		WindowGroup {
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
							if let _ = await networkService.authorize() {
								loggedIn.toggle()
							}
						}
					}
					.buttonStyle(IntraMain())
					.padding(.bottom, 48)
					.disabled(loggedIn)
				}
			}
			.onOpenURL {
				do {
					try networkService.handleRedirectURL(for: $0)
				} catch {
					isErrorAlertPresented.toggle()
				}
			}
			.onAppear {
				loggedIn = networkService.isAuthorized
			}
			.alert("Что-то пошло не так", isPresented: $isErrorAlertPresented) {
				Button("Жаль", role: .cancel) { }
			}
			.fullScreenCover(isPresented: $loggedIn, content: UserInfo.init)
			.environmentObject(networkService)
		}
	}
}

struct Jopa {

	
}
