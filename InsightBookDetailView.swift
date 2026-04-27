//
//  InsightBookDetailView.swift
//  BookNotesNewDesignC2
//

import SwiftUI
import SwiftData

struct InsightBookDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let book: BookRecord

    @State private var sortOrder: InsightSortOrder = .newestFirst
    @State private var searchText = ""
    @State private var showWriteNote = false

    private var displayedInsights: [InsightDraft] {
        let sortedInsights: [InsightDraft]
        switch sortOrder {
        case .newestFirst:
            sortedInsights = book.insights.sorted { $0.createdAt > $1.createdAt }
        case .oldestFirst:
            sortedInsights = book.insights.sorted { $0.createdAt < $1.createdAt }
        case .hashtagFirst:
            sortedInsights = book.insights.sorted { lhs, rhs in
                if lhs.tags.count == rhs.tags.count {
                    return lhs.createdAt > rhs.createdAt
                }

                return lhs.tags.count > rhs.tags.count
            }
        }

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            return sortedInsights
        }

        return sortedInsights.filter { insight in
            [
                insight.tags.joined(separator: " "),
                insight.page,
                insight.keyInsight,
                insight.whyItMatters,
                insight.tagOrComment,
                insight.createdAt.formatted(date: .long, time: .omitted)
            ]
            .joined(separator: " ")
            .localizedCaseInsensitiveContains(query)
        }
    }

    private var shareText: String {
        let body = displayedInsights.map { insight in
            [
                insight.tags.joined(separator: " "),
                insight.page.isEmpty ? "" : "Hal \(insight.page)",
                insight.keyInsight,
                insight.whyItMatters.isEmpty ? "" : "Why it matters: \(insight.whyItMatters)",
                insight.createdAt.formatted(date: .long, time: .omitted)
            ]
            .filter { !$0.isEmpty }
            .joined(separator: "\n")
        }
        .joined(separator: "\n\n")

        return "\(book.title) - \(book.author)\n\n\(body)"
    }

    var body: some View {
        List {
            ForEach(displayedInsights) { insight in
                InsightNoteCardView(
                    insight: insight,
                    title: book.title,
                    author: book.author
                )
                .background(
                    NavigationLink("", destination: EditInsightNoteView(
                        insight: insight,
                        bookTitle: book.title,
                        author: book.author
                    ))
                    .opacity(0)
                )
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
            .onDelete { indexSet in
                for index in indexSet {
                    modelContext.delete(displayedInsights[index])
                }
            }
        }
        .listStyle(.plain)
        .background(Color(red: 0.95, green: 0.95, blue: 0.96))
        .navigationTitle(book.title)
        .navigationBarTitleDisplayMode(.large)
        .safeAreaInset(edge: .top, spacing: 0) {
            HStack(spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Color.black.opacity(0.6))

                    TextField("Search", text: $searchText)
                        .textFieldStyle(.plain)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(.black)
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

                Button(action: { showWriteNote = true }) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Color.black.opacity(0.6))
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.72))
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(red: 0.95, green: 0.95, blue: 0.96))
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Menu {
                    ForEach(InsightSortOrder.allCases, id: \.self) { order in
                        Button(order.title) {
                            sortOrder = order
                        }
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }

                ShareLink(item: shareText) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showWriteNote) {
            WriteInsightForBookView(book: book)
        }
    }

    private func deleteInsight(_ insightID: UUID) {
        if let insight = book.insights.first(where: { $0.id == insightID }) {
            modelContext.delete(insight)
        }
    }
}

private enum InsightSortOrder: CaseIterable {
    case newestFirst
    case oldestFirst
    case hashtagFirst

    var title: String {
        switch self {
        case .newestFirst:
            return "Newest First"
        case .oldestFirst:
            return "Oldest First"
        case .hashtagFirst:
            return "Hashtag Priority"
        }
    }
}

struct InsightNoteCardView: View {
    let insight: InsightDraft
    let title: String
    let author: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(headerLine)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color.black.opacity(0.68))

                    Text(insight.keyInsight)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundStyle(Color.black.opacity(0.85))
                        .lineSpacing(4)
                        .padding(.top, 4)

                    if !insight.whyItMatters.isEmpty {
                        Text(insight.whyItMatters)
                            .font(.system(size: 15, weight: .medium, design: .serif))
                            .italic()
                            .foregroundStyle(Color.black.opacity(0.6))
                            .padding(.top, 8)
                    }
                }
                
                Spacer(minLength: 16)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("\(title) - \(author)")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.black.opacity(0.72))

                Text(insight.createdAt.formatted(date: .long, time: .omitted))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.black.opacity(0.4))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.black.opacity(0.04))
            )
            .padding(.top, 16)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
        )
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
    }

    private var headerLine: String {
        let hashtagText = insight.tags.joined(separator: " ")
        if insight.page.isEmpty {
            return hashtagText
        }

        if hashtagText.isEmpty {
            return "Hal \(insight.page)"
        }

        return "\(hashtagText) - Hal \(insight.page)"
    }
}
