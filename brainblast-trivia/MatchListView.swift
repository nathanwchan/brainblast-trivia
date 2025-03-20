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
                        if match.player1ID == cloudKit.currentUser?.id && match.player2ID == nil {
                            Text("Waiting on an opponent...")
                                .foregroundColor(.red)
                        } else if match.player1ID == cloudKit.currentUser?.id {
                            Text("You x \(userNames[match.player2ID!] ?? "someone") —\u{00A0}It's \(match.isPlayer1Turn ? "your turn!" : "their turn...")")
                                .foregroundColor(match.isPlayer1Turn ? .green : .blue)
                        } else if match.player2ID == cloudKit.currentUser?.id {
                            Text("You x \(userNames[match.player1ID] ?? "someone") —\u{00A0}It's \(!match.isPlayer1Turn ? "your turn!" : "their turn...")")
                                .foregroundColor(!match.isPlayer1Turn ? .green : .blue)
                        } else {
                            Text("Available to join \(userNames[match.player1ID] ?? "someone")'s match")
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
                do {
                    let matches = try await cloudKit.fetchOpenMatches()
                    gameState.availableMatches = matches
                    
                    for match in matches {
                        if userNames[match.player1ID] == nil {
                            if let name = await cloudKit.getUserName(for: match.player1ID) {
                                print("nate player1ID", name)
                                userNames[match.player1ID] = name
                            }
                        }
                        
                        if let player2ID = match.player2ID, userNames[player2ID] == nil {
                            if let name = await cloudKit.getUserName(for: player2ID) {
                                print("nate player2ID", name)
                                userNames[player2ID] = name
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
