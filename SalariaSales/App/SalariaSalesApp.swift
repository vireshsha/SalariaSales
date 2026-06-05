import SwiftUI

@main
struct SalariaSalesApp: App {
    private let container = AppContainer.live

    var body: some Scene {
        WindowGroup {
            JobListView(viewModel: container.makeJobListViewModel())
        }
    }
}
