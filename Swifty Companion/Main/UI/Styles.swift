//
//  Styles.swift
//  Swifty Companion
//
//  Created by Тетерин Даниил Владимирович on 08.03.2022.
//

import SwiftUI

// MARK: Styling Data Structures

struct IntraMain: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.foregroundColor(.white)
			.frame(maxWidth: .infinity, minHeight: 48)
			.background(configuration.isPressed ? Color.intraMainPressed : Color.intraMain)
			.cornerRadius(24)
			.padding(.horizontal, 24)
			.font(.custom("Proxima Soft", size: 16).bold())
	}
}

struct GaugeProgressStyle: ProgressViewStyle {
	var strokeColor = Color.blue
	var strokeWidth = 3

	func makeBody(configuration: Configuration) -> some View {
		let fractionCompleted = configuration.fractionCompleted ?? 0

		return ZStack {
			Circle()
				.trim(from: 0, to: CGFloat(fractionCompleted))
				.stroke(strokeColor, style: StrokeStyle(lineWidth: CGFloat(strokeWidth), lineCap: .round))
				.rotationEffect(.degrees(-90))
		}
	}
}

struct RoundedButtonStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.frame(height: 48)
			.frame(maxWidth: .infinity)
			.foregroundColor(.black)
			.background(Color.white)
			.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
			.padding(.horizontal, 36)
			.opacity(configuration.isPressed ? 0.6 : 1)
	}
}


// MARK: Styling Extensions

extension Color {
	static let intraMain = Color(red: 0x52 / 255, green: 0xB7 / 255, blue: 0xBA / 255)
	static let intraMainPressed = Color(red: 0x3A / 255, green: 0x86 / 255, blue: 0x88 / 255)

	static let intraGray = Color(red: 0x2A / 255, green: 0x2D / 255, blue: 0x38 / 255)
	static let intraDark = Color(red: 0x1E / 255, green: 0x21 / 255, blue: 0x29 / 255)
}

extension LinearGradient {

	static let darkGradient = LinearGradient(colors: [.intraGray, .intraDark], startPoint: .top, endPoint: .bottom)
}

extension Double {

	func asFormattedString() -> String {
		String(format: "%.2f", self)
	}
}
