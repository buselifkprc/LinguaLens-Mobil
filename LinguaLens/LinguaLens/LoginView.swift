//
//  LoginView.swift
//  LinguaLens
//
//  Created by Elif Buse Köprücü on 20.04.2025.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift
import FirebaseCore
import AuthenticationServices
import CryptoKit
import FirebaseFirestore


struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var loginError: String?
    @State private var isLoggedIn = false
    @State private var loginSuccessMessage: String?
    @State private var currentNonce: String?


    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .padding(.top, 50)

                TextField("E-posta", text: $email)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                SecureField("Şifre", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                if let error = loginError {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }

                Button("Giriş Yap") {
                    loginUser()
                }
                .frame(height: 40)
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(5)
                .padding(.horizontal)
                

                if let successMessage = loginSuccessMessage {
                    Text(successMessage)
                        .foregroundColor(.green)
                        .multilineTextAlignment(.center)
                        .padding(.top, 10)
                }

                Button(action: {
                    handleGoogleSignIn()
                }) {
                    HStack {
                        Image(systemName: "globe")
                        Text("Google ile Giriş Yap")
                    }
                    .frame(height: 40)
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(5)
                    .padding(.horizontal)
                   }
                SignInWithAppleButton(
                    .signIn,
                    onRequest: { request in
                        let nonce = randomNonceString()
                        currentNonce = nonce
                        request.requestedScopes = [.fullName, .email]
                        request.nonce = sha256(nonce)
                    },
                    onCompletion: { result in
                        switch result {
                        case .success(let authResults):
                            if let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential {
                                guard let nonce = currentNonce else {
                                    print("Invalid state: A login callback was received, but no login request was sent.")
                                    return
                                }
                                guard let appleIDToken = appleIDCredential.identityToken else {
                                    print("Unable to fetch identity token")
                                    return
                                }
                                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                                    print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                                    return
                                }

                                let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                                          idToken: idTokenString,
                                                                          rawNonce: nonce)
                                Auth.auth().signIn(with: credential) { (authResult, error) in
                                    if let error = error {
                                        print("Apple Sign In Error: \(error.localizedDescription)")
                                    } else {
                                        print("Apple ile giriş başarılı: \(authResult?.user.email ?? "")")
                                        isLoggedIn = true
                                    }
                                }
                            }
                        case .failure(let error):
                            print("Authorization failed: \(error.localizedDescription)")
                        }
                    }
                )
                .signInWithAppleButtonStyle(.black)
                .frame(height: 40)
                .frame(maxWidth: .infinity)
                .cornerRadius(5)
                .padding(.horizontal)

                Spacer()

                NavigationLink(destination: ForgotPasswordView()) {
                    Text("Şifremi unuttum?")
                        .font(.footnote)
                        .foregroundColor(.red)
                        .padding(.bottom, 20)
                }

                NavigationLink(destination: RegisterView()) {
                    Text("Hesabınız yok mu? Kaydolun")
                        .font(.footnote)
                        .foregroundColor(.blue)
                }

                NavigationLink(destination: MainView(), isActive: $isLoggedIn) {
                    EmptyView()
                }
            }
        }
        .padding()
        .navigationBarTitle("Giriş", displayMode: .inline)
    }
        func loginUser() {
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    self.loginError = "Giriş başarısız: \(error.localizedDescription)"
                    self.loginSuccessMessage = nil
                } else if let user = result?.user {
                    self.loginError = nil
                    self.loginSuccessMessage = "Giriş başarılı!"
                    self.isLoggedIn = true
                    print("Giriş başarılı: \(user.email ?? "")")
                    let db = Firestore.firestore()
                    let userRef = db.collection("users").document(user.uid)

                    userRef.setData([
                        "email": user.email ?? "",
                        "lastLogin": Timestamp(date: Date())
                    ], merge: true)
                }
            }
        }
    
    struct ForgotPasswordView: View {
           @State private var email = ""
           @State private var resetError: String?
           @State private var resetSuccessMessage: String?

           var body: some View {
               VStack(spacing: 20) {
                   Text("Şifremi Unuttum")
                       .font(.title)
                       .padding(.top, 50)

                   TextField("E-posta", text: $email)
                       .autocapitalization(.none)
                       .keyboardType(.emailAddress)
                       .textContentType(.emailAddress)
                       .textFieldStyle(RoundedBorderTextFieldStyle())
                       .padding()

                   if let error = resetError {
                       Text(error)
                           .foregroundColor(.red)
                           .multilineTextAlignment(.center)
                   }

                   if let successMessage = resetSuccessMessage {
                       Text(successMessage)
                           .foregroundColor(.green)
                           .multilineTextAlignment(.center)
                   }

                   Button("Şifreyi Sıfırla") {
                       resetPassword()
                   }
                   .frame(maxWidth: .infinity)
                   .padding()
                   .background(Color.blue)
                   .foregroundColor(.white)
                   .cornerRadius(8)

                   Spacer()
               }
               .padding()
               .navigationBarTitle("", displayMode: .inline)
           }

           func resetPassword() {
               Auth.auth().sendPasswordReset(withEmail: email) { error in
                   if let error = error {
                       self.resetError = "E-posta gönderilemedi: \(error.localizedDescription)"
                       self.resetSuccessMessage = nil
                   } else {
                       self.resetError = nil
                       self.resetSuccessMessage = "Şifre sıfırlama e-postası gönderildi."
                   }
               }
           }
       }
    func handleGoogleSignIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            self.loginError = "Google Giriş için root controller bulunamadı."
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                self.loginError = "Google ile giriş başarısız: \(error.localizedDescription)"
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                self.loginError = "Google token alınamadı."
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    self.loginError = "Firebase Google giriş hatası: \(error.localizedDescription)"
                } else {
                    self.loginSuccessMessage = "Google ile giriş başarılı!"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self.isLoggedIn = true
                    }
                }
            }
        }
    }
   
    private func randomNonceString(length: Int = 32) -> String {
        let charset: [Character] =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms = (0..<16).map { _ in UInt8.random(in: 0...255) }
            for random in randoms {
                if remainingLength == 0 {
                    break
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }

}
