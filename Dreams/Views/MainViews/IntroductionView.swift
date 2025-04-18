//
//  IntroductionView.swift
//  Dreams
//
//  Created by Felix Kircher on 04.04.25.
//

import SwiftUI

struct IntroductionView: View {
    @Binding var isFirstStart: Bool
   
    var body: some View {
        var onAppear: Bool = false
        Spacer()
            .frame(height: 200)
        Image(systemName: "moon")
            .resizable()
            .frame(width: 150, height: 150)
            .foregroundColor(.accent)
            .rotationEffect(.degrees(onAppear ? 180: 0))
            .onAppear {
                onAppear = false
            }
        Spacer()
            .frame(height: 60)
        Text("Willkommen zu Dreams!")
            .font(.title)
            .bold()
        Spacer()
            .frame(height: 250)
        Button() {
            isFirstStart.toggle()
            print(isFirstStart)
        } label: {
            Text("Starte dein Traumabenteuer!")
                .foregroundColor(.black)
                .bold()
                .frame(width: 300, height: 50)
                .background() {
                    Capsule()
                        
                }
        }
    }
}

#Preview {
    IntroductionView(isFirstStart: .constant(true))
}
