//
//  SearchLogins.swift
//  Swifty Companion
//
//  Created by Тетерин Даниил Владимирович on 02.02.2022.
//

import SwiftUI

struct SearchLogins: View {
	@EnvironmentObject var networkService: NetworkService

	@State private var login = ""

	let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13 ,14 ,15]

	var body: some View {
		ZStack {
			LinearGradient.darkGradient.ignoresSafeArea()
			VStack {
				HStack {
					Spacer()

					TextField("Логин 42", text: $login)
						.textFieldStyle(.roundedBorder)
						.foregroundColor(.red)
						.padding()
						.onChange(of: login) { _ in
							fetchLogins()
						}

					Spacer()
				}
				Rectangle()
					.frame(width: UIScreen.main.bounds.width, height: 4)
					.foregroundColor(.white)
					.padding(.bottom)

//				ScrollView {
//					ForEach(numbers, id: \.self) { number in
//						Rectangle()
//							.foregroundColor(.intraMain)
//							.frame(width: 300, height: 300)
//					}
//				}

				Spacer()
			}
		}
	}

	private func fetchLogins() {
		Task {
			let response: [User]? = await networkService.apiCall(
				for: "/v2/users?range[login]=\(login.lowercased()),wstygg"
			)

			print("---------------- \(login) ------------------")
			print(response)
		}
	}
}

struct User: Decodable {
	let id: Int
	let login: String
//	let url: URL
}

struct SearchLogin_Previews: PreviewProvider {
	static var previews: some View {
		SearchLogins()
	}
}
