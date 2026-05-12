//
//  AssignBookSheetView.swift
//  BookNotesNewDesignC2
//

import SwiftUI

struct AssignBookSheetView: View {
    let books: [BookRecord]
    let onSelect: (BookRecord) -> Void

    @State private var searchText = ""
    @State private var selectedBookID: UUID?

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
            VStack(spacing: 0) {
                List(filteredBooks) { book in
                    Button(action: { selectedBookID = book.id }) {
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

                            if selectedBookID == book.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(Color(red: 0.03, green: 0.53, blue: 0.97))
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(
                                    selectedBookID == book.id
                                    ? Color(red: 0.03, green: 0.53, blue: 0.97).opacity(0.12)
                                    : Color.clear
                                )
                        )
                    }
                    .buttonStyle(.plain)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .overlay {
                    if filteredBooks.isEmpty {
                        ContentUnavailableView.search(text: searchText)
                    }
                }

                Button(action: assignSelectedBook) {
                    Text("Assign Insight")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            Capsule(style: .continuous)
                                .fill(Color(red: 0.03, green: 0.53, blue: 0.97))
                        )
                }
                .buttonStyle(.plain)
                .disabled(selectedBook == nil)
                .opacity(selectedBook == nil ? 0.45 : 1)
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 20)
                .background(.thinMaterial)
            }
            .navigationTitle("Choose a Book")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search books")
        }
    }

    private var selectedBook: BookRecord? {
        books.first(where: { $0.id == selectedBookID })
    }

    private func assignSelectedBook() {
        guard let selectedBook else {
            return
        }

        onSelect(selectedBook)
    }
}
