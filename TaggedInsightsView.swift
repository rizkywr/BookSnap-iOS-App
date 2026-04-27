//
//  TaggedInsightsView.swift
//  BookNotesNewDesignC2
//

import SwiftUI
import SwiftData

struct TaggedInsightsView: View {
    @Query private var books: [BookRecord]
    let initialTag: String

    @State private var searchText = ""

    private var normalizedSearch: String {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return query.isEmpty ? initialTag : query
    }

    private var matchingEntries: [InsightDraft] {
        let query = normalizedSearch.lowercased()
        let hashtagQuery = query.hasPrefix("#") ? query : "#\(query)"

        return books.flatMap { book in
            book.insights.filter { insight in
                let matchesHashtag = insight.tags.contains {
                    $0.lowercased() == hashtagQuery || $0.lowercased().contains(query)
                }
                let matchesGenre = book.genre.tagKeywords.contains {
                    $0.lowercased() == hashtagQuery || $0.lowercased().contains(query)
                }
                let matchesSearch = [
                    insight.keyInsight,
                    insight.whyItMatters,
                    insight.tagOrComment,
                    insight.page,
                    insight.tags.joined(separator: " ")
                ]
                .joined(separator: " ")
                .lowercased()
                .contains(query)

                return matchesHashtag || matchesGenre || matchesSearch
            }
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 14) {
                ForEach(matchingEntries) { insight in
                    NavigationLink {
                        EditInsightNoteView(
                            insight: insight,
                            bookTitle: books.first(where: { $0.insights.contains(where: { $0.id == insight.id }) })?.title ?? "",
                            author: books.first(where: { $0.insights.contains(where: { $0.id == insight.id }) })?.author ?? ""
                        )
                    } label: {
                        InsightNoteCardView(
                            insight: insight,
                            title: books.first(where: { $0.insights.contains(where: { $0.id == insight.id }) })?.title ?? "",
                            author: books.first(where: { $0.insights.contains(where: { $0.id == insight.id }) })?.author ?? ""
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 14)
            .padding(.bottom, 36)
        }
        .background(Color(red: 0.95, green: 0.95, blue: 0.96).ignoresSafeArea())
        .navigationTitle(initialTag)
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Search notes")
    }
}
