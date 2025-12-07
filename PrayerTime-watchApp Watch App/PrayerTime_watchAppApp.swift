//
//  PrayerTime_watchAppApp.swift
//  PrayerTime-watchApp Watch App
//
//  Created by Linda on 04/12/2025.
//

import SwiftUI

@main
struct PrayerTime_watchApp_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


struct ContentView: View {
    @StateObject var viewModel = PrayerViewModel()
    
    var body: some View {
        NavigationStack {
            PrayerTimesView_WatchOS(viewModel: viewModel)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
