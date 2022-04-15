//
//  UserDetailView.swift
//  Swifty Companion
//
//  Created by Тетерин Даниил Владимирович on 09.03.2022.
//

import SwiftUI

// MARK: - UserDetailView

struct UserDetailView: View {

	// MARK: Environment Properties

	@Environment(\.dismiss) var dismiss

	// MARK: Private Properties

	private let profileImageSize: CGFloat = 200
	private let profileTitlesHeight: CGFloat = 100

	@State
	private var cursusSelection = 0

	@State
	private var height: CGFloat = 0

	// MARK: Internal Properties

	@ObservedObject
	var viewModel: ViewModel

	// MARK: View Builders

	var body: some View {
		ZStack(alignment: .top) {
			LinearGradient.darkGradient.ignoresSafeArea()
			
			VStack(alignment: .leading) {
				headerView

				ScrollView(showsIndicators: false) {
					profileImage

					Text(viewModel.user.displayname)
						.font(.title)

					HStack {
						if !viewModel.user.titles.isEmpty {
							profileTitles

							Spacer()
						}

						VStack {
							Text("Wallet: \(viewModel.user.wallet)")
								.font(.body)

							Text("Correction points: \(viewModel.user.correctionPoints)")
								.font(.body)
						}
					}

					cursusesList
						.padding(.top, -48)

					projectsList
				}
			}
			.padding()
			.foregroundColor(.white)
		}
		.alert("Что-то пошло не так", isPresented: $viewModel.isErrorAlertPresented) {
			Button("Жаль", role: .cancel) { }
		}
	}
}

// MARK: UserDetailView + View Builders

extension UserDetailView {

	var headerView: some View {
		HStack {
			Button(action: {
				dismiss.callAsFunction()
			}, label: {
				Image(systemName: "arrow.left")
					.resizable()
					.frame(width: 24, height: 20)
					.padding()
					.foregroundColor(.white)

			})
			.frame(width: 30, height: 30)
		}
	}

	var profileImage: some View {
		AsyncImage(
			url: viewModel.user.imageURL,
			content: { image in
				image
					.resizable()
					.scaledToFill()
			},
			placeholder: {
				ProgressView()
			}
		)
		.frame(width: profileImageSize, height: profileImageSize)
		.background(Color.gray)
		.clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
	}

	var profileTitles: some View {
		ScrollViewReader { proxy in
			ScrollView {
				VStack {
					ForEach(viewModel.user.titles, id: \.hash) { title in
						Text(title)
							.id(title.hashValue)
							.foregroundColor(title == viewModel.user.selectedTitle ? .green : .white)
					}
				}
			}
			.onAppear {
				proxy.scrollTo(viewModel.user.selectedTitle.hashValue)
			}
		}
	}

	var cursusesList: some View {
		TabView(selection : $cursusSelection) {
			ForEach(viewModel.user.cursuses, id: \.cursus.name) { cursus in
				VStack(spacing: 0) {
					Text("Cursus: \(cursus.cursus.name)")
						.font(.headline)

					ZStack {
						ProgressView(
							value: cursus.level.truncatingRemainder(dividingBy: 1),
							total: 1
						)
						.progressViewStyle(GaugeProgressStyle(
							strokeColor: .green, strokeWidth: 2
						))

						Text("Level: \(cursus.level.asFormattedString())")
							.foregroundColor(.white)
					}
					.frame(height: 200)
					.padding()

					Button("Skills") {
						viewModel.selectedCursusSkills = cursus.skills

						viewModel.presentSkillsSheet.toggle()
					}
					.buttonStyle(RoundedButtonStyle())
				}
				.tag(cursus.cursus.name.hashValue)
			}
		}
		.sheet(isPresented: $viewModel.presentSkillsSheet) {
			UserSkillsView(skills: viewModel.selectedCursusSkills)
		}
		.tabViewStyle(.page(indexDisplayMode: .always))
		.frame(height: 400)
	}

	var projectsList: some View {
		ForEach(viewModel.user.projects, id: \.id) { project in
			HStack {
				Text(project.project.name)
					.font(.system(size: 20, weight: .medium))
					.foregroundColor({
						switch project.status {
						case .waiting_for_correction:
							return .cyan
						case .in_progress:
							return .blue
						case .searching_a_group:
							return .purple
						case .finished:
							if project.validated == true {
								return .green
							} else {
								return .red
							}
						default:
							return .white
						}
					}())

				Spacer()

				Text({ () -> String in
					if project.status == .in_progress {
						return "In progress"
					} else if project.status == .searching_a_group {
						return "Searchin a group"
					} else if let mark = project.final_mark {
						return "Final mark: \(mark)"
					}
					return ""
				}())
			}
			.padding()
		}
	}
}

struct UserSkillsView: View {

	let skills: [UserDetailView.UserDetail.CursusUser.Skill]

	var body: some View {
		ZStack {
			LinearGradient.darkGradient.ignoresSafeArea()

			ScrollView {
				VStack {
					ForEach(skills, id: \.name) { skill in
						VStack(alignment: .leading) {
							Text("\(skill.name): \(skill.level.asFormattedString())")

							ProgressView(value: skill.level, total: 20)
						}
						.padding()
					}
				}
			}
		}
	}
}
