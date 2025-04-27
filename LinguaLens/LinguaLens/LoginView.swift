//
//  LoginView.swift
//  LinguaLens
//
//  Created by Elif Buse Köprücü on 20.04.2025.
//

import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("👤")
                .font(.largeTitle)
                .bold()

            TextField("E-posta", text: $email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.none)
                .autocorrectionDisabled()
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)

            SecureField("Şifre", text: $password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)

            Button(action: {
                print("Giriş Yap butonuna basıldı")
            }) {
                Text("Giriş Yap")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Divider()

            Text("Hesabınız yok mu? Kaydolun")
                .foregroundColor(.gray)
                .font(.footnote)

            Spacer()
            
        }
        NavigationLink(destination: RegisterView()) {
            Text("Hesabınız yok mu? Kaydolun")
                .foregroundColor(.blue)
                .font(.footnote)
        }

        .padding()
        .navigationTitle("Giriş")
    }
}

