//
//  NetworkService.swift
//  Swifty Companion
//
//  Created by Тетерин Даниил Владимирович on 08.03.2022.
//

import OAuth2
import Foundation

final class NetworkService: ObservableObject {

	// MARK: Publisher
	
	@Published @MainActor
	private(set) var isSessionActive = false
	
	// MARK: Private Properties

	private let intraSecret = Bundle.main.object(forInfoDictionaryKey: "INTRA_SECRET") as! String? ?? ""
	private let intraUid = Bundle.main.object(forInfoDictionaryKey: "INTRA_UID") as! String? ?? ""
	private let pathConstant = "https://api.intra.42.fr"
	private let decoder = JSONDecoder()

	private let oauth: OAuth2

	// MARK: Initialize

	init() {
		let oauthSettings: [String: Any] = [
			"client_id": intraUid,
			"client_secret": intraSecret,
			"authorize_uri": "https://api.intra.42.fr/oauth/authorize",
			"token_uri": "https://api.intra.42.fr/oauth/token",
			"redirect_uris": ["swifty-companion://oauth-callback"],
			"secret_in_body": true
		]

		oauth = OAuth2CodeGrant(settings: oauthSettings)
		oauth.logger = OAuth2DebugLogger(.trace)
	}

	// MARK: Internal Methods

	func handleRedirectURL(for url: URL) throws {
		do {
			try oauth.handleRedirectURL(url)
		} catch {
			throw error
		}
	}

	typealias AuthorizeCompletion = ((OAuth2JSON?, OAuth2Error?) -> Void)

	@discardableResult
	func authorize(params: OAuth2StringDict? = nil) async -> OAuth2JSON? {
		await withCheckedContinuation { continuation in
			oauth.authorize(params: params) { json, error in
				let result = json != nil && error == nil

				DispatchQueue.main.async {
					self.isSessionActive = result
				}
				continuation.resume(returning: json)
			}
		}
	}

	func logout() {
		oauth.forgetTokens()

		DispatchQueue.main.async {
			self.isSessionActive = self.oauth.isAuthorizing
		}
	}

	func apiCall<T: Decodable>(for endpoint: String, with params: [String: String]? = nil) async -> T? {
		guard await updateAccessTokenIfNeeded() == true,
			  let url = URL(string: pathConstant + endpoint) else {
			DispatchQueue.main.async {
				self.isSessionActive = false
			}
			return nil
		}

		var request = self.oauth.request(forURL: url)

		params?.forEach {
			request.addValue($0.value, forHTTPHeaderField: $0.key)
		}

		return await withCheckedContinuation { continuation in
			oauth.session.dataTask(with: request) { data, response, error in
				if let data = data {
					let object = try? self.decoder.decode(T.self, from: data)
					continuation.resume(returning: object)
				}
			}.resume()
		}
	}

	@discardableResult
	func updateAccessTokenIfNeeded() async -> Bool {
		return await withCheckedContinuation { continuation in
			oauth.tryToObtainAccessTokenIfNeeded { json, error in
				let result = json != nil && error == nil

				DispatchQueue.main.async {
					self.isSessionActive = result
				}
				continuation.resume(returning: result)
			}
		}
	}
}
