import SwiftUI

struct LoginView: View {
    @StateObject private var cloudKit = CloudKitManager.shared
    @State private var username = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to BrainBlast Trivia!")
                .font(.title)
                .multilineTextAlignment(.center)
            
            Text(cloudKit.containerStatus)
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.bottom)
            
            TextField("Enter your name", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            if isLoading {
                ProgressView()
            } else {
                Button("Continue") {
                    login()
                }
                .disabled(username.isEmpty)
                .padding()
                .background(username.isEmpty ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }
        }
        .padding()
    }
    
    private func login() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                _ = try await CloudKitManager.shared.authenticate(name: username)
            } catch {
                DispatchQueue.main.async {
                    errorMessage = error.localizedDescription
                }
            }
            
            DispatchQueue.main.async {
                isLoading = false
            }
        }
    }
}
