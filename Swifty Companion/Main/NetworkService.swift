//
//  NetworkService.swift
//  Swifty Companion
//
//  Created by Тетерин Даниил Владимирович on 08.03.2022.
//

import OAuth2
import Foundation

final class NetworkService: ObservableObject {
	private let intraSecret = Bundle.main.object(forInfoDictionaryKey: "INTRA_SECRET") as! String? ?? ""
	private let intraUid = Bundle.main.object(forInfoDictionaryKey: "INTRA_UID") as! String? ?? ""
	private let pathConstant = "https://api.intra.42.fr"
	private let decoder = JSONDecoder()

	private let oauth: OAuth2

	var isAuthorized: Bool {
		oauth.refreshToken != nil
	}

	init() {
		let oauthSettings: [String: Any] = [
			"client_id": intraUid,
			"client_secret": intraSecret,
			"authorize_uri": "https://api.intra.42.fr/oauth/authorize",
			"token_uri": "https://api.intra.42.fr/oauth/token",
			"redirect_uris": ["swifty-companion://oauth-callback"],
		]

		oauth = OAuth2CodeGrant(settings: oauthSettings)
		oauth.logger = OAuth2DebugLogger(.trace)
	}

	func handleRedirectURL(for url: URL) throws {
		do {
			try oauth.handleRedirectURL(url)
		} catch {
			throw error
		}
	}

	typealias AuthorizeCompletion = ((OAuth2JSON?, OAuth2Error?) -> Void)

	func authorize(params: OAuth2StringDict? = nil) async -> OAuth2JSON? {
		await withCheckedContinuation { continuation in
			oauth.authorize(params: params) { json, _ in
				continuation.resume(returning: json)
			}
		}
	}

	func logout() {
		oauth.forgetTokens()
	}

	func apiCall<T: Decodable>(for endpoint: String, with params: [String: String]? = nil) async -> T? {
		var request = self.oauth.request(forURL: URL(string: pathConstant + endpoint)!)

		params?.forEach {
			request.addValue($0.value, forHTTPHeaderField: $0.key)
		}

		return await withCheckedContinuation { continuation in
			print(request)

			oauth.session.dataTask(with: request) { data, response, error in
				if let data = data {
					let object = try? self.decoder.decode(T.self, from: data)
					continuation.resume(returning: object)
				}
			}.resume()
		}
	}
}
