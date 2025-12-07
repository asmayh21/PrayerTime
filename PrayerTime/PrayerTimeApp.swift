//
//  PrayerTimeApp.swift
//  PrayerTime
//
//  Created by asma  on 08/06/1447 AH.
//

import SwiftUI
import WatchConnectivity

@main
struct PrayerTimeApp: App {
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
            PrayerTimesView(viewModel: viewModel)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//
//struct ContentView: View {
//    @ObservedObject var viewModel = WatchConnectivityManager.shared
//    @State private var isReachable = "NO"
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                HStack {
//                    Button(action: {
//                    //checks if the session is reachable
//
//                        self.isReachable = self.viewModel.session.isReachable ? "YES": "NO"
//                    }) {
//                        Text("Check")
//                    }
//                    .padding(.leading, 16.0)
//                    Spacer()
//                    Text("isReachable")
//                        .font(.headline)
//                        .padding()
//                    Text(self.isReachable)
//                        .foregroundColor(.gray)
//                        .font(.subheadline)
//                        .padding()
//                }
//                .background(Color.init(.systemGray5))
//                List {
//
//            ForEach(self.viewModel.messagesData, id: \.self) { animal in
//                        MessageRow(animalModel: animal)
//                    }
//                }
//                .listStyle(PlainListStyle())
//                Spacer()
//            }
//            .navigationTitle("Receiver")
//        }
//    }
//}
//
//#Preview {
//    ContentView()
//}
//
//struct MessageRow: View {
//    let animalModel: AnimalModel
//    
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text(animalModel.name)
//                .font(.body)
//                .padding(.vertical, 4.0)
//            Text("Date()")
//                .font(.footnote)
//                .foregroundColor(.gray)
//        }
//    }
//}
//
//#Preview {
//    MessageRow(animalModel: AnimalModel(name: "🐱Cat"))
//}
