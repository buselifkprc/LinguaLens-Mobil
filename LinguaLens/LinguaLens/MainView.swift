//
//  MainView.swift
//  LinguaLens
//
//  Created by Elif Buse Köprücü on 20.04.2025.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .padding(.top, 10)
                    .shadow(radius: 5)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                NavigationLink(destination: PhotoOCRView()) {
                    Text("📸 Fotoğraf Yükle ve Tanı")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

             //   NavigationLink(destination: TranslateView()) {
                    Text("🌍 Çeviri Sonuçları")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
             //   } 
                NavigationLink(destination: RestaurantInfoView()) {
                    Text("🍴 Restoran Bilgisi")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                NavigationLink(destination: LoginView()) {
                    Text("🔑 Giriş Ekranı")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.indigo)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                NavigationLink(destination: RegisterView()) {
                    Text("🆕 Kayıt Ekranı")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
            .navigationTitle("")
        }
    }
}

