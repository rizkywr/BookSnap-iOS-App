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
        }
    }

    private var homeView: some View {
        HomeView(onOpenLibrary: viewModel.openLibrary)
    }

    @ViewBuilder
    private func destinationView(for route: InsightRoute) -> some View {
        switch route {
        case .writeInsight:
            WriteInsightView()
        case .insightLibrary:
            InsightLibraryView()
        case .taggedGenre(let genre):
            GenreTagSearchView(genre: genre)
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
}
