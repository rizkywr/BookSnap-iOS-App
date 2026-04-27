//
//  EditInsightNoteView.swift
//  BookNotesNewDesignC2
//

import SwiftUI
import SwiftData

struct EditInsightNoteView: View {
    @Environment(\.dismiss) private var dismiss

    let insight: InsightDraft

    let bookTitle: String
    let author: String

    @State private var keyInsight = ""
    @State private var whyItMatters = ""
    @State private var tagOrComment = ""
    @State private var page = ""

    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.95, blue: 0.96)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Text("\(bookTitle) - \(author)")
                    .font(.system(size: 22, weight: .heavy))
                    .foregroundStyle(.black)
                    .padding(.top, 16)
                    .padding(.horizontal, 20)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        editorCard(title: "Add Hashtag", text: $tagOrComment, height: 92, compact: true)
                        editorCard(title: "Pages", text: $page, height: 72, compact: true)
                        editorCard(title: "Key Insight", text: $keyInsight, height: 220, compact: false)
                        editorCard(title: "Why It Matters?", text: $whyItMatters, height: 120, compact: false)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 28)
                }
            }
        }
        .navigationTitle("Edit Note")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    saveChanges()
                }
                .fontWeight(.semibold)
            }
        }
        .onAppear {
            keyInsight = insight.keyInsight
            whyItMatters = insight.whyItMatters
            tagOrComment = insight.tagOrComment
            page = insight.page
        }
    }

    private func editorCard(title: String, text: Binding<String>, height: CGFloat, compact: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.black)
                .padding(.leading, 4)

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.white.opacity(0.94))

                ZStack(alignment: .topLeading) {
                    TextEditor(text: text)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .font(.system(size: compact ? 15 : 18, weight: .regular, design: .serif))
                        .foregroundStyle(Color.black.opacity(0.78))
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
            }
            .frame(height: height)
        }
        .padding(.bottom, 6)
    }

    private func saveChanges() {
        insight.keyInsight = keyInsight.trimmingCharacters(in: .whitespacesAndNewlines)
        insight.whyItMatters = whyItMatters.trimmingCharacters(in: .whitespacesAndNewlines)
        insight.tagOrComment = tagOrComment.trimmingCharacters(in: .whitespacesAndNewlines)
        insight.page = page.trimmingCharacters(in: .whitespacesAndNewlines)
        insight.tags = extractTags(from: insight.tagOrComment)
        dismiss()
    }

    private func extractTags(from text: String) -> [String] {
        let words = text.split(whereSeparator: \.isWhitespace)
        let tags = words.compactMap { word -> String? in
            guard word.hasPrefix("#") else { return nil }
            let cleaned = word.trimmingCharacters(in: .punctuationCharacters).replacingOccurrences(of: "#", with: "")
            guard !cleaned.isEmpty else { return nil }
            return "#\(cleaned)"
        }
        return Array(NSOrderedSet(array: tags)) as? [String] ?? tags
    }
}
