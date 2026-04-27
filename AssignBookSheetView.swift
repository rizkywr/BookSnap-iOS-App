//
//  AssignBookSheetView.swift
//  BookNotesNewDesignC2
//

import SwiftUI

struct AssignBookSheetView: View {
    let books: [BookRecord]
    let onSelect: (BookRecord) -> Void

    @State private var searchText = ""

    private var filteredBooks: [BookRecord] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            return books
        }

        return books.filter { book in
            book.title.localizedCaseInsensitiveContains(query) ||
            book.author.localizedCaseInsensitiveContains(query) ||
            book.genre.displayTitle.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        NavigationStack {
            List(filteredBooks) { book in
                Button(action: { onSelect(book) }) {
                    HStack(spacing: 14) {
                        BookCoverThumbnail(imageData: book.coverImageData)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(book.title)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.black)

                            Text(book.author)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color.black.opacity(0.45))

                            Text("\(book.insights.count) insight\(book.insights.count == 1 ? "" : "s")")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color.black.opacity(0.35))
                        }

                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
            }
            .overlay {
                if filteredBooks.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                }
            }
            .navigationTitle("Choose a Book")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search books")
        }
    }
}
