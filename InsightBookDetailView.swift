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
    @State private var selectedInsight: InsightDraft?

    private var displayedInsights: [InsightDraft] {
        let sortedInsights: [InsightDraft]
        switch sortOrder {
        case .newestFirst:
            sortedInsights = book.insights.sorted { $0.createdAt > $1.createdAt }
        case .oldestFirst:
            sortedInsights = book.insights.sorted { $0.createdAt < $1.createdAt }
        case .pageAscending:
            sortedInsights = book.insights.sorted { lhs, rhs in
                comparePages(lhs.page, rhs.page, ascending: true)
            }
        case .pageDescending:
            sortedInsights = book.insights.sorted { lhs, rhs in
                comparePages(lhs.page, rhs.page, ascending: false)
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

    var body: some View {
        List {
            ForEach(displayedInsights) { insight in
                InsightNoteCardView(
                    insight: insight,
                    title: book.title,
                    author: book.author,
                    shareText: shareText(for: insight)
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedInsight = insight
                }
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

            }
        }
        .sheet(isPresented: $showWriteNote) {
            WriteInsightForBookView(book: book)
        }
        .navigationDestination(item: $selectedInsight) { insight in
            EditInsightNoteView(
                insight: insight,
                bookTitle: book.title,
                author: book.author
            )
        }
    }

    private func shareText(for insight: InsightDraft) -> String {
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

    private func comparePages(_ lhs: String, _ rhs: String, ascending: Bool) -> Bool {
        let leftPage = pageSortValue(for: lhs, ascending: ascending)
        let rightPage = pageSortValue(for: rhs, ascending: ascending)

        if leftPage == rightPage {
            return ascending
                ? lhs.localizedStandardCompare(rhs) == .orderedAscending
                : lhs.localizedStandardCompare(rhs) == .orderedDescending
        }

        return ascending ? leftPage < rightPage : leftPage > rightPage
    }

    private func pageSortValue(for page: String, ascending: Bool) -> Int {
        guard let firstNumber = firstPageNumber(in: page) else {
            return ascending ? Int.max : Int.min
        }

        return firstNumber
    }

    private func firstPageNumber(in page: String) -> Int? {
        let components = page.split(whereSeparator: { !$0.isNumber })
        guard let firstDigits = components.first else {
            return nil
        }

        return Int(firstDigits)
    }
}

private enum InsightSortOrder: CaseIterable {
    case newestFirst
    case oldestFirst
    case pageAscending
    case pageDescending

    var title: String {
        switch self {
        case .newestFirst:
            return "Newest First"
        case .oldestFirst:
            return "Oldest First"
        case .pageAscending:
            return "Page: Smallest First"
        case .pageDescending:
            return "Page: Largest First"
        }
    }
}

struct InsightNoteCardView: View {
    let insight: InsightDraft
    let title: String
    let author: String
    let shareText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    if !headerLine.isEmpty {
                        Text(headerLine)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Color.black.opacity(0.68))
                    }

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

                ShareLink(item: shareText) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.black.opacity(0.5))
                        .frame(width: 34, height: 34)
                        .background(Color.black.opacity(0.05))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("\(title) - \(author)")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.black.opacity(0.72))

                HStack(spacing: 12) {
                    if !insight.page.isEmpty {
                        Text("Hal \(insight.page)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.black.opacity(0.62))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(Color.black.opacity(0.06))
                            )
                    }

                    Text(insight.createdAt.formatted(date: .long, time: .omitted))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.black.opacity(0.4))
                        .lineLimit(1)
                        .minimumScaleFactor(0.9)
                }
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
        insight.tags.joined(separator: " ")
    }
}
