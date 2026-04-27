//
//  WriteInsightView.swift
//  BookNotesNewDesignC2
//

import SwiftUI
import SwiftData

struct WriteInsightView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var keyInsight = ""
    @State private var whyItMatters = ""
    @State private var tagOrComment = ""
    @State private var page = ""
    @State private var savedDraft: InsightDraft?

    var body: some View {
        ZStack {
            Color(red: 0.95, green: 0.95, blue: 0.96)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                backButton
                    .padding(.top, 16)
                    .padding(.leading, 18)

//                Text("Your Insight")
//                    .font(.system(size: 22, weight: .bold))
//                    .foregroundStyle(.black)
//                    .padding(.top, 18)
//                    .padding(.horizontal, 22)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 8) {
                        insightCard(
                            title: "Key Insight",
                            subtitle: "What's the one idea you don't want to forget?",
                            text: $keyInsight,
                            height: 290
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

                    Button(action: saveInsight) {
                        Text("Save My Insight")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 148, height: 50)
                            .background(
                                Capsule(style: .continuous)
                                    .fill(Color(red: 0.03, green: 0.53, blue: 0.97))
                            )
                    }
                    .buttonStyle(.plain)
                    .shadow(color: Color(red: 0.11, green: 0.45, blue: 0.90).opacity(0.28), radius: 18, x: 0, y: 10)
                    .padding(.top, 14)
                    .padding(.bottom, 34)
                    .frame(maxWidth: .infinity)
                    .disabled(keyInsight.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(keyInsight.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.72 : 1)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(item: $savedDraft) { draft in
            InsightSavedView(draft: draft)
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
        let draft = InsightDraft(
            keyInsight: keyInsight.trimmingCharacters(in: .whitespacesAndNewlines),
            whyItMatters: whyItMatters.trimmingCharacters(in: .whitespacesAndNewlines),
            tagOrComment: trimmedTagOrComment,
            page: page.trimmingCharacters(in: .whitespacesAndNewlines),
            tags: extractTags(from: trimmedTagOrComment),
            createdAt: Date()
        )

        modelContext.insert(draft)
        savedDraft = draft
    }

    private func extractTags(from text: String) -> [String] {
        let words = text.split(whereSeparator: \.isWhitespace)
        let tags = words.compactMap { word -> String? in
            guard word.hasPrefix("#") else {
                return nil
            }

            let cleaned = word
                .trimmingCharacters(in: .punctuationCharacters)
                .replacingOccurrences(of: "#", with: "")

            guard !cleaned.isEmpty else {
                return nil
            }

            return "#\(cleaned)"
        }

        return Array(NSOrderedSet(array: tags)) as? [String] ?? tags
    }
}

