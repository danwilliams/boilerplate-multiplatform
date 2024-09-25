//
//  ContentView.swift
//  Boilerplate
//
//  Created by Dan Williams on 24/09/2024.
//

import SwiftUI
import BoilerplateLibFFI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
			Text(greet(name: "iOS"))
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
