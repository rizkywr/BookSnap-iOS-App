//
//  ContentView.swift
//  BookNotesNewDesignC2
//
//  Created by Rizky Wahyu Ramadhan on 23/04/26.
//

import Combine
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: ContentViewModel

    init(viewModel: ContentViewModel = ContentViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack(path: $viewModel.path) {
            homeView
                .navigationDestination(for: InsightRoute.self, destination: destinationView)
                .onOpenURL { url in
                    // Menangani URL Scheme dari Widget
                    handleWidgetURL(url)
                }
        }
    }

    private var homeView: some View {
        HomeView(onOpenLibrary: viewModel.openLibrary)
    }

    @ViewBuilder
    private func destinationView(for route: InsightRoute) -> some View {
        switch route {
        case .writeInsight:
            WriteInsightView(onReturnHome: viewModel.goHome)
        case .insightLibrary:
            InsightLibraryView()
        case .taggedGenre(let genre):
            GenreTagSearchView(genre: genre)
        }
    }
    
    // Fungsi tambahan untuk memproses URL
    private func handleWidgetURL(_ url: URL) {
        guard url.scheme == "booksnap" else {
            return
        }

        switch url.host {
        case "write-insight":
            viewModel.path.append(.writeInsight)
        case "home":
            viewModel.goHome()
        default:
            break
        }
    }
}

#Preview {
    ContentView()
}

final class ContentViewModel: ObservableObject {
    @Published var path: [InsightRoute] = []

    func openLibrary() {
        path.append(.insightLibrary)
    }

    func goHome() {
        path.removeAll()
    }
}
