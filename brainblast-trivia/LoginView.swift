import SwiftUI

struct LoginView: View {
    @StateObject private var cloudKit = CloudKitManager.shared
    @State private var username = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @FocusState private var isUsernameFocused: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: UIScreen.main.bounds.width * 0.8)
                .padding(.top, 50)
            
            Text("Welcome to BrainBlast Trivia!")
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.rainbowGradient)
            
            if let status = cloudKit.containerStatus {
                Text(status)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    TextField("", text: $username)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.rainbowGradient, lineWidth: 2)
                        )
                        .overlay(alignment: .leading) {
                            Text(username.isEmpty ? "Enter your name" : "")
                                .foregroundColor(.gray)
                                .padding(.leading)
                        }
                        .focused($isUsernameFocused)
                }
                
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Button("Continue") {
                        login()
                    }
                    .disabled(username.isEmpty)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(username.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .padding(.horizontal)
                }
            }
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            isUsernameFocused = true
        }
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
