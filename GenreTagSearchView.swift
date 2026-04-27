//  GenreTagSearchView.swift
//  BookNotesNewDesignC2

import SwiftUI
import SwiftData

struct GenreTagSearchView: View {
    let genre: BookGenre
    @Query private var books: [BookRecord]
    @State private var searchText: String = ""

    private var genreTags: [String] {
        genre.tagKeywords
    }

    private var filteredEntries: [(book: BookRecord, insight: InsightDraft)] {
        let lowercasedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return books
            .filter { $0.genre == genre }
            .flatMap { book in
                book.insights.compactMap { insight -> (book: BookRecord, insight: InsightDraft)? in
                    let matchesQuery = lowercasedSearch.isEmpty || [
                        insight.keyInsight,
                        insight.whyItMatters,
                        insight.tagOrComment,
                        insight.page,
                        insight.tags.joined(separator: " ")
                    ]
                    .joined(separator: " ")
                    .lowercased()
                    .contains(lowercasedSearch)
                    
                    if matchesQuery {
                        return (book: book, insight: insight)
                    } else {
                        return nil
                    }
                }
            }
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Results for ")
                    .font(.title3)
                Text(genre.displayTitle)
                    .font(.title3.bold())
                Spacer()
            }
            .padding(.top, 10)
            .padding(.horizontal, 20)

            SearchBar(text: $searchText, placeholder: "Cari hashtag di genre ini")
                .padding(.horizontal, 20)
                .padding(.vertical, 8)

            if filteredEntries.isEmpty {
                Spacer()
                Text("Tidak ditemukan catatan dengan hashtag genre ini.")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 14) {
                        ForEach(filteredEntries, id: \.insight.id) { entry in
                            InsightNoteCardView(
                                insight: entry.insight,
                                title: entry.book.title,
                                author: entry.book.author
                            )
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 8)
                    .padding(.bottom, 30)
                }
            }
        }
        .background(Color(red: 0.95, green: 0.95, blue: 0.96).ignoresSafeArea())
        .navigationTitle("Tag Genre: \(genre.rawValue)")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct SearchBar: View {
    @Binding var text: String
    let placeholder: String
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#if DEBUG
struct GenreTagSearchView_Previews: PreviewProvider {
    static var previews: some View {
        GenreTagSearchView(genre: .coreKnowledge)
    }
}
#endif
