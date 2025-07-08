//
//  ContentView.swift
//  Dezitama
//
//  Created by 末廣月渚 on 2025/05/20.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
            NavigationStack {
                ZStack{
                    Color(red: 0.68, green: 0.93, blue: 0.93)
                        .ignoresSafeArea()
                VStack {
                    Spacer()
                    Image("デジたまアイコン仮")
                        .resizable()
                        .frame(width: 500, height: 500)
                        .padding(50)
                    
                    NavigationLink(destination: ChoiceView()) {
                        Text("tap to start")
                    }
                
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
