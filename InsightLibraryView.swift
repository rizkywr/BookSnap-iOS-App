//
//  InsightLibraryView.swift
//  BookNotesNewDesignC2
//

import SwiftUI
import SwiftData

struct InsightLibraryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query private var books: [BookRecord]

    @State private var searchText = ""
    @State private var selectedTag: String?

    private var allTags: [String] {
        let tags = books.flatMap { book in
            book.insights.flatMap(\.tags) + book.genre.tagKeywords
        }

        let uniqueTags = Array(NSOrderedSet(array: tags)) as? [String] ?? tags
        return uniqueTags.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }

    private var filteredTags: [String] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            return allTags
        }

        return allTags.filter { $0.localizedCaseInsensitiveContains(query) }
    }

    private var filteredBooks: [BookRecord] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            return books
        }

        return books
            .compactMap { book -> (book: BookRecord, score: Int)? in
                let score = searchScore(for: book, query: query)
                guard score > 0 else {
                    return nil
                }

                return (book: book, score: score)
            }
            .sorted { (lhs: (book: BookRecord, score: Int), rhs: (book: BookRecord, score: Int)) in
                if lhs.score == rhs.score {
                    return lhs.book.title.localizedCaseInsensitiveCompare(rhs.book.title) == .orderedAscending
                }

                return lhs.score > rhs.score
            }
            .map(\.book)
    }

    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.95, blue: 0.96)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                backButton
                    .padding(.top, 16)
                    .padding(.leading, 18)

                Text("Your Insight Library")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.black)
                    .padding(.top, 18)
                    .padding(.horizontal, 20)

                searchBar
                    .padding(.top, 16)
                    .padding(.horizontal, 20)

                Text("Tags")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.black)
                    .padding(.top, 24)
                    .padding(.horizontal, 20)

                tagsCard
                    .padding(.top, 10)
                    .padding(.horizontal, 16)

                libraryCard
                    .padding(.top, 24)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(item: $selectedTag) { tag in
            TaggedInsightsView(initialTag: tag)
        }
    }

    private var backButton: some View {
        Button(action: { dismiss() }) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .medium))

                Text("Back")
                    .font(.system(size: 15, weight: .medium))
            }
            .foregroundStyle(Color.black.opacity(0.6))
            .padding(.horizontal, 14)
            .frame(height: 36)
            .background(Color.white.opacity(0.72))
            .clipShape(Capsule(style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var libraryCard: some View {
        Group {
            if filteredBooks.isEmpty {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.96))
                    .shadow(color: .black.opacity(0.10), radius: 10, x: 0, y: 5)
                    .overlay {
                        VStack(spacing: 10) {
                            Image(systemName: "books.vertical")
                                .font(.system(size: 26, weight: .light))
                                .foregroundStyle(Color.black.opacity(0.18))

                            Text("No insight library yet")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color.black.opacity(0.28))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(filteredBooks) { book in
                        InsightLibraryRowView(book: book)
                            .background(
                                NavigationLink("", destination: InsightBookDetailView(book: book))
                                    .opacity(0)
                            )
                            .listRowSeparator(.visible)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.white.opacity(0.96))
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            modelContext.delete(filteredBooks[index])
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color.white.opacity(0.96))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: .black.opacity(0.10), radius: 10, x: 0, y: 5)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    private var tagsCard: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(Color.white.opacity(0.96))
            .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
            .overlay(alignment: .leading) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(filteredTags, id: \.self) { tag in
                            InsightTagChip(
                                tag: tag,
                                isSelected: searchText.caseInsensitiveCompare(tag) == .orderedSame
                            ) {
                                selectedTag = tag
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                }
            }
            .frame(height: 64)
    }

    private var searchBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color.black.opacity(0.6))

                TextField("Search", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(.black)
                    .onSubmit(openTagSearchIfNeeded)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)

                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 17))
                            .foregroundStyle(Color.black.opacity(0.4))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 44)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.white.opacity(0.72))
            )

            Button(action: { searchText = "" }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.black.opacity(0.6))
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.72))
                    )
            }
            .buttonStyle(.plain)
        }
    }

    private func searchableContent(for book: BookRecord) -> String {
        let insightContent = book.insights.map { insight in
            [
                insight.keyInsight,
                insight.whyItMatters,
                insight.tagOrComment,
                insight.page,
                insight.tags.joined(separator: " "),
                insight.createdAt.formatted(date: .abbreviated, time: .omitted)
            ]
            .joined(separator: " ")
        }
        .joined(separator: " ")

        return [
            book.title,
            book.author,
            book.genre.rawValue,
            book.genre.displayTitle,
            book.genre.options.joined(separator: " "),
            book.genre.tagKeywords.joined(separator: " "),
            insightContent
        ]
        .joined(separator: " ")
    }

    private func searchScore(for book: BookRecord, query: String) -> Int {
        let normalizedQuery = query.lowercased()
        let hashtagQuery = normalizedQuery.hasPrefix("#") ? normalizedQuery : "#\(normalizedQuery)"

        var score = 0

        if book.title.lowercased().contains(normalizedQuery) {
            score += 50
        }

        if book.author.lowercased().contains(normalizedQuery) {
            score += 45
        }

        if book.genre.rawValue.lowercased().contains(normalizedQuery) || book.genre.displayTitle.lowercased().contains(normalizedQuery) {
                score += 110
            }

        for insight in book.insights {
            if insight.tags.contains(where: { $0.lowercased() == hashtagQuery || $0.lowercased().contains(normalizedQuery) }) {
                score += 140
            }

            if insight.tagOrComment.lowercased().contains(normalizedQuery) {
                score += 90
            }

            if insight.keyInsight.lowercased().contains(normalizedQuery) {
                score += 80
            }

            if insight.whyItMatters.lowercased().contains(normalizedQuery) {
                score += 65
            }

            if insight.page.lowercased().contains(normalizedQuery) {
                score += 25
            }

            if insight.createdAt.formatted(date: .abbreviated, time: .omitted).lowercased().contains(normalizedQuery) {
                score += 20
            }
        }

        if score == 0, searchableContent(for: book).lowercased().contains(normalizedQuery) {
            score += 10
        }

        return score
    }

    private func openTagSearchIfNeeded() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            return
        }

        let hashtagQuery = query.hasPrefix("#") ? query.lowercased() : "#\(query.lowercased())"

        if let matchedTag = allTags.first(where: { $0.lowercased() == hashtagQuery || $0.lowercased().contains(query.lowercased()) }) {
            selectedTag = matchedTag
        }
    }
}
