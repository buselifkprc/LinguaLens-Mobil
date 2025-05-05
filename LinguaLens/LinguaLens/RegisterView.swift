//
//  RegisterView.swift
//  LinguaLens
//
//  Created by Elif Buse Köprücü on 20.04.2025.
//

import SwiftUI
import FirebaseAuth

struct RegisterView: View {
    @State private var name = ""
    @State private var surname = ""
    @State private var email = ""
    @State private var password = ""
    @State private var registerError: String?
    @State private var isRegistered = false
    @State private var successMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle")
                .resizable()
                .frame(width: 80, height: 80)
                .padding(.top, 50)

            TextField("Ad", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.words)

            TextField("Soyad", text: $surname)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.words)

            TextField("E-posta", text: $email)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                
            SecureField("Şifre", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
               

            if let error = registerError {
                Text(error)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }

            Button("Hesap Oluştur") {
                registerUser()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)

            if let successMessage = successMessage {
                Text(successMessage)
                    .foregroundColor(.green)
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)
            }

            Spacer()

            NavigationLink(destination: LoginView()) {
                Text("Zaten hesabınız var mı? Giriş yapın")
                    .font(.footnote)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .navigationBarTitle("Kayıt Ol", displayMode: .inline)
    }

    func registerUser() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.registerError = "Kayıt başarısız: \(error.localizedDescription)"
                self.successMessage = nil
            } else {
                self.registerError = nil
                self.successMessage = "✅ Kayıt başarılı!"
                self.isRegistered = true
                print("✅ Kayıt başarılı: \(result?.user.email ?? "")")
            }
        }
    }
}
