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
    @State private var selectedInsight: InsightDraft?

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
                    if let book = book(for: insight) {
                        InsightNoteCardView(
                            insight: insight,
                            title: book.title,
                            author: book.author,
                            shareText: shareText(for: insight, in: book)
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedInsight = insight
                        }
                    }
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
        .navigationDestination(item: $selectedInsight) { insight in
            EditInsightNoteView(
                insight: insight,
                bookTitle: book(for: insight)?.title ?? "",
                author: book(for: insight)?.author ?? ""
            )
        }
    }

    private func book(for insight: InsightDraft) -> BookRecord? {
        books.first(where: { $0.insights.contains(where: { $0.id == insight.id }) })
    }

    private func shareText(for insight: InsightDraft, in book: BookRecord) -> String {
        [
            "\(book.title) - \(book.author)",
            insight.tags.joined(separator: " "),
            insight.page.isEmpty ? "" : "Hal \(insight.page)",
            insight.keyInsight,
            insight.whyItMatters.isEmpty ? "" : "Why it matters: \(insight.whyItMatters)",
            insight.createdAt.formatted(date: .long, time: .omitted)
        ]
        .filter { !$0.isEmpty }
        .joined(separator: "\n")
    }
}
