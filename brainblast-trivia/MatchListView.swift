import SwiftUI

struct MatchListView: View {
    @ObservedObject var gameState: GameState
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var cloudKit: CloudKitManager
    @State private var userNames: [String: String] = [:]
    @State private var showingDeleteConfirmation = false
    @State private var isDeleting = false

    var body: some View {
        NavigationView {
            List(gameState.availableMatches) { match in
                Button(action: {
                    Task {
                        do {
                            try await gameState.joinMatch(match)
                            presentationMode.wrappedValue.dismiss()
                        } catch {
                            print("Error joining match: \(error)")
                        }
                    }
                }) {
                    HStack {
                        if match.player1ID == cloudKit.currentUser?.id {
                            Text("Your game")
                                .foregroundColor(.blue)
                        } else {
                            Text(userNames[match.player1ID] ?? "Loading...")
                                .foregroundColor(.green)
                        }
                        Spacer()
                        Text("Round \(match.currentRound)")
                            .foregroundColor(.gray)
                    }
                }
                .disabled(isDeleting)
            }
            .navigationTitle("Available Matches")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showingDeleteConfirmation = true
                    }) {
                        Text("Delete All")
                            .foregroundColor(.red)
                    }
                    .disabled(isDeleting)
                }
            }
            .alert("Delete All Matches?", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task {
                        isDeleting = true
                        do {
                            try await cloudKit.deleteAllMatches()
                            gameState.availableMatches = []
                        } catch {
                            print("Error deleting matches: \(error)")
                        }
                        isDeleting = false
                    }
                }
            } message: {
                Text("This will delete all matches in the game. This action cannot be undone.")
            }
            .task {
                // Load all matches and usernames when view appears
                do {
                    let matches = try await cloudKit.fetchOpenMatches()
                    gameState.availableMatches = matches
                    
                    for match in matches {
                        if userNames[match.player1ID] == nil {
                            if let name = await cloudKit.getUserName(for: match.player1ID) {
                                userNames[match.player1ID] = name
                            }
                        }
                    }
                } catch {
                    print("Error loading matches: \(error)")
                }
            }
        }
    }
}
