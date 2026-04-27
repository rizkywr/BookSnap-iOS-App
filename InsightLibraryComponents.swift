//
//  InsightLibraryComponents.swift
//  BookNotesNewDesignC2
//

import SwiftUI

struct InsightLibraryRowView: View {
    let book: BookRecord

    var body: some View {
        HStack(spacing: 16) {
            BookCoverThumbnail(imageData: book.coverImageData)
                .frame(width: 44, height: 64)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.white)
                )
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(Color.black.opacity(0.06), lineWidth: 0.8)
                )
                .shadow(color: .black.opacity(0.07), radius: 3, x: 0, y: 2)

            VStack(alignment: .leading, spacing: 4) {
                Text("\(book.title) - \(book.author)")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.black.opacity(0.85))
                    .lineLimit(1)

                if let latestInsight = book.insights.sorted(by: { $0.createdAt > $1.createdAt }).first {
                    Text("Last notes \(latestInsight.createdAt.formatted(date: .long, time: .omitted))")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color.black.opacity(0.4))
                        .lineLimit(1)
                }
            }

            Spacer()

            Text(String(format: "%02d", book.insights.count))
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.black.opacity(0.4))

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.black.opacity(0.3))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.white.opacity(0.001))
    }
}

struct InsightTagChip: View {
    let tag: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(tag)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(isSelected ? .white : Color.black.opacity(0.75))
                .padding(.horizontal, 16)
                .frame(height: 36)
                .background(
                    Capsule(style: .continuous)
                        .fill(isSelected ? Color(red: 0.03, green: 0.53, blue: 0.97) : Color.white)
                )
        }
        .buttonStyle(.plain)
    }
}
