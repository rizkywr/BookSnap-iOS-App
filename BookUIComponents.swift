//
//  BookUIComponents.swift
//  BookNotesNewDesignC2
//

import SwiftUI

struct FolderSuccessIllustration: View {
    let isAnimated: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.88),
                            Color.black.opacity(0.58),
                            Color.black.opacity(0.88)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 208, height: 142)
                .offset(y: 6)
                .shadow(color: .black.opacity(0.22), radius: 24, x: 0, y: 18)

            Group {
                paperCard(rotation: -10, offsetX: -34, offsetY: -22)
                paperCard(rotation: 0, offsetX: 2, offsetY: -18)
                paperCard(rotation: 10, offsetX: 40, offsetY: -10)
            }

            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.38),
                            Color.white.opacity(0.08)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                .frame(width: 232, height: 118)
                .offset(y: 22)
                .shadow(color: .white.opacity(0.12), radius: 6, x: 0, y: -1)
                .blur(radius: isAnimated ? 0 : 6)
        }
        .frame(width: 260, height: 200)
    }

    private func paperCard(rotation: Double, offsetX: CGFloat, offsetY: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(Color.white.opacity(0.92))
            .frame(width: 92, height: 116)
            .overlay(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 10) {
                    Capsule()
                        .fill(Color.black.opacity(0.10))
                        .frame(width: 52, height: 7)

                    Capsule()
                        .fill(Color.black.opacity(0.06))
                        .frame(width: 60, height: 5)

                    Capsule()
                        .fill(Color.black.opacity(0.06))
                        .frame(width: 48, height: 5)

                    Capsule()
                        .fill(Color.black.opacity(0.06))
                        .frame(width: 36, height: 5)
                }
                .padding(16)
            }
            .rotationEffect(.degrees(rotation))
            .offset(x: offsetX, y: offsetY)
    }
}

struct BookCoverPreview: View {
    let imageData: Data?

    var body: some View {
        Group {
            if let imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    LinearGradient(
                        colors: [
                            Color(red: 0.22, green: 0.34, blue: 0.55),
                            Color(red: 0.12, green: 0.17, blue: 0.25)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 56, weight: .medium))
                        .foregroundStyle(.white.opacity(0.85))
                }
            }
        }
        .frame(width: 164, height: 222)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .black.opacity(0.18), radius: 24, x: 0, y: 14)
    }
}

struct BookCoverThumbnail: View {
    let imageData: Data?

    var body: some View {
        Group {
            if let imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                LinearGradient(
                    colors: [
                        Color(red: 0.22, green: 0.34, blue: 0.55),
                        Color(red: 0.12, green: 0.17, blue: 0.25)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
        .frame(width: 44, height: 60)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}
