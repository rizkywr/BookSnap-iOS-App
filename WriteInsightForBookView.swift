//
//  WriteInsightForBookView.swift
//  BookNotesNewDesignC2
//

import SwiftUI
import SwiftData

struct WriteInsightForBookView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let book: BookRecord

    @State private var keyInsight = ""
    @State private var whyItMatters = ""
    @State private var tagOrComment = ""
    @State private var page = ""

    private var canSave: Bool {
        !keyInsight.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.95, green: 0.95, blue: 0.96)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 8) {
                        // Book context header
                        HStack(spacing: 14) {
                            if let data = book.coverImageData,
                               let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 36, height: 52)
                                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                            } else {
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(Color.black.opacity(0.08))
                                    .frame(width: 36, height: 52)
                                    .overlay(
                                        Image(systemName: "book.closed")
                                            .font(.system(size: 16))
                                            .foregroundStyle(Color.black.opacity(0.25))
                                    )
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(book.title)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.black)
                                    .lineLimit(1)
                                Text(book.author)
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundStyle(Color.black.opacity(0.45))
                                    .lineLimit(1)
                            }

                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                        .padding(.bottom, 8)

                        insightCard(
                            title: "Key Insight",
                            subtitle: "What's the one idea you don't want to forget?",
                            text: $keyInsight,
                            height: 260
                        )

                        insightCard(
                            title: "Why It Matters?",
                            subtitle: "Make it personal — why does this actually matter to you?",
                            text: $whyItMatters,
                            height: 76,
                            isCompact: true
                        )

                        insightCard(
                            title: "Add Hashtag",
                            subtitle: "Use keywords your future self would search for",
                            text: $tagOrComment,
                            height: 76,
                            isCompact: true
                        )

                        insightCard(
                            title: "Pages",
                            subtitle: "Mark the page to revisit the original context",
                            text: $page,
                            height: 76,
                            isCompact: true
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Write Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveInsight()
                    }
                    .fontWeight(.bold)
                    .disabled(!canSave)
                }
            }
        }
    }

    @ViewBuilder
    private func insightCard(
        title: String,
        subtitle: String,
        text: Binding<String>,
        height: CGFloat,
        isCompact: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.black)
                .padding(.leading, 4)

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color.white.opacity(0.92))

                ZStack(alignment: .topLeading) {
                    TextEditor(text: text)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .font(.system(size: 18, weight: .regular, design: .serif))
                        .foregroundStyle(Color.black.opacity(0.82))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)

                    if text.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text(subtitle)
                            .font(.system(size: 16,))
                            .foregroundStyle(Color.black.opacity(0.25))
                            .allowsHitTesting(false)
                            .padding(.top, 8)
                            .padding(.leading, 4)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
            .frame(height: height)
        }
        .padding(.bottom, 6)
    }

    private func saveInsight() {
        let trimmedTagOrComment = tagOrComment.trimmingCharacters(in: .whitespacesAndNewlines)
        let newInsight = InsightDraft(
            keyInsight: keyInsight.trimmingCharacters(in: .whitespacesAndNewlines),
            whyItMatters: whyItMatters.trimmingCharacters(in: .whitespacesAndNewlines),
            tagOrComment: trimmedTagOrComment,
            page: page.trimmingCharacters(in: .whitespacesAndNewlines),
            tags: extractTags(from: trimmedTagOrComment),
            createdAt: Date()
        )

        modelContext.insert(newInsight)
        book.insights.append(newInsight)
        dismiss()
    }

    private func extractTags(from text: String) -> [String] {
        let words = text.split(whereSeparator: \.isWhitespace)
        let tags = words.compactMap { word -> String? in
            guard word.hasPrefix("#") else { return nil }
            let cleaned = word
                .trimmingCharacters(in: .punctuationCharacters)
                .replacingOccurrences(of: "#", with: "")
            guard !cleaned.isEmpty else { return nil }
            return "#\(cleaned)"
        }
        return Array(NSOrderedSet(array: tags)) as? [String] ?? tags
    }
}
