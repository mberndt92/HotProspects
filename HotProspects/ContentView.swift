//
//  ContentView.swift
//  HotProspects
//
//  Created by Maximilian Berndt on 2023/04/30.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var prospects = Prospects()
    
    var body: some View {
        TabView {
            ProspectsView()
                .tabItem {
                    Label("Everyone", systemImage: "person.3")
                }
            ProspectsView(filter: .contacted)
                .tabItem {
                    Label("Contacted", systemImage: "checkmark.circle")
                }
            ProspectsView(filter: .uncontacted)
                .tabItem {
                    Label("Uncontacted", systemImage: "questionmark.square")
                }
            MeView()
                .tabItem {
                    Label("Me", systemImage: "person.crop.square")
                }
        }
        .environmentObject(prospects)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
