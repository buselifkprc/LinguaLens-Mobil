//
//  RegisterView.swift
//  LinguaLens
//
//  Created by Elif Buse Köprücü on 20.04.2025.
//

import SwiftUI

struct RegisterView: View {
    @State private var name: String = ""
    @State private var surname: String = ""
    @State private var email: String = ""
    @State private var password: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("📝 Kayıt Ol")
                .font(.largeTitle)
                .bold()

            TextField("Ad", text: $name)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)

            TextField("Soyad", text: $surname)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)

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
                print("Hesap Oluştur butonuna basıldı")
            }) {
                Text("✅ Hesap Oluştur")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Divider()

            Text("Zaten hesabınız var mı? Giriş yapın")
                .foregroundColor(.gray)
                .font(.footnote)

            Spacer()
        }
        NavigationLink(destination: LoginView()) {
            Text("Zaten hesabınız var mı? Giriş yapın")
                .foregroundColor(.blue)
                .font(.footnote)
        }

        .padding()
        .navigationTitle("Kayıt")
    }
}
