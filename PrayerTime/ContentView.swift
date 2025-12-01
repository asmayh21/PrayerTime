import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = PrayerViewModel()
    
    var body: some View {
        PrayerTimesView(viewModel: viewModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
