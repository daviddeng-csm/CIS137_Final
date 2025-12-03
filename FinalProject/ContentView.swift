//
//  ContentView.swift
//  FinalProject
//
//  Created by David Deng on 12/3/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = PatternGameViewModel()
    
    var body: some View {
        StartView(viewModel: viewModel)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                // Save game when app goes to background
                viewModel.saveCurrentSession()
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
