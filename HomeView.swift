//
//  HomeView.swift
//  BookNotesNewDesignC2
//

import SwiftUI

struct HomeView: View {
    let onOpenLibrary: () -> Void

    @State private var slideOffset: CGFloat = 0

    // Stacking entrance animation
    @State private var card1Visible = false
    @State private var card2Visible = false
    @State private var card3Visible = false

    // Slide hint animation
    @State private var hintOffset: CGFloat = -20
    @State private var hintOpacity: Double = 0

    // Write button press
    @State private var writePressed = false

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 0) {
                topHeroSection
                    .padding(.top, 6)

                Spacer(minLength: 24)

                bottomCalloutSection
            }
        }
    }

    private var topHeroSection: some View {
        VStack(spacing: 0) {
            ZStack {
                // Card 1 — Red (back left)
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.91, green: 0.53, blue: 0.56),
                                Color(red: 0.88, green: 0.47, blue: 0.47)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 130, height: 170)
                    .blur(radius: 0.3)
                    .rotationEffect(.degrees(-10))
                    .offset(x: -42, y: card1Visible ? 18 : 80)
                    .shadow(color: .black.opacity(0.20), radius: 18, x: -8, y: 16)
                    .opacity(card1Visible ? 1 : 0)

                // Card 2 — Blue (back right)
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.78, green: 0.88, blue: 1.0),
                                Color(red: 0.50, green: 0.70, blue: 0.95)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 150, height: 190)
                    .blur(radius: 0.3)
                    .rotationEffect(.degrees(8))
                    .offset(x: 44, y: card2Visible ? 30 : 100)
                    .shadow(color: .black.opacity(0.18), radius: 18, x: 8, y: 16)
                    .opacity(card2Visible ? 1 : 0)

                // Card 3 — Note card (front center)
                noteCard
                    .offset(y: card3Visible ? 6 : 90)
                    .opacity(card3Visible ? 1 : 0)
            }
            .frame(height: 274)
            .onAppear {
                withAnimation(.spring(response: 0.55, dampingFraction: 0.72).delay(0.05)) {
                    card1Visible = true
                }
                withAnimation(.spring(response: 0.55, dampingFraction: 0.72).delay(0.18)) {
                    card2Visible = true
                }
                withAnimation(.spring(response: 0.60, dampingFraction: 0.70).delay(0.32)) {
                    card3Visible = true
                }
            }

            HStack(spacing: 0) {
                Text("Slide to find your ")
                    .font(.system(size: 18, weight: .light))
                    .foregroundStyle(Color.black.opacity(0.28))

                Text("Insight")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.black)

                Text(" \u{2192}")
                    .font(.system(size: 26, weight: .light))
                    .foregroundStyle(Color.blue)
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .padding(.top, 16)
            .offset(x: slideOffset + hintOffset)
            .opacity(hintOpacity)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 8)
                    .onChanged { value in
                        slideOffset = max(0, min(value.translation.width, 90))
                    }
                    .onEnded { value in
                        if value.translation.width > 72 {
                            withAnimation(.spring(response: 0.26, dampingFraction: 0.82)) {
                                slideOffset = 92
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                                slideOffset = 0
                                onOpenLibrary()
                            }
                        } else {
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                                slideOffset = 0
                            }
                        }
                    }
            )
            .onAppear {
                // Fade + slide in from left
                withAnimation(.spring(response: 0.52, dampingFraction: 0.72).delay(0.5)) {
                    hintOffset = 0
                    hintOpacity = 1
                }
                // Repeating rightward bounce hint
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    repeatHintBounce()
                }
            }
        }
    }

    private func repeatHintBounce() {
        // Nudge right with bounce
        withAnimation(.spring(response: 0.30, dampingFraction: 0.50)) {
            hintOffset = 16
        }
        // Bounce back
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.36) {
            withAnimation(.spring(response: 0.38, dampingFraction: 0.58)) {
                hintOffset = 0
            }
        }
        // Repeat every 3.2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
            repeatHintBounce()
        }
    }

    private var noteCard: some View {


        ZStack {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(.white.opacity(0.22))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .stroke(Color.white.opacity(0.35), lineWidth: 1)
                )
                .frame(width: 150, height: 190)

            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Self-Development")
                        .font(.system(size: 5.8, weight: .black))
                        .foregroundStyle(Color.black.opacity(0.62))

                    Spacer()

                    Text("TODAY")
                        .font(.system(size: 5.8, weight: .black))
                        .foregroundStyle(Color.black.opacity(0.42))
                }

                Text("Perubahan kecil (1%) yang konsisten itu\njauh lebih powerful daripada\nperubahan besar yang sporadis.")
                    .font(.system(size: 7.9, weight: .regular, design: .serif))
                    .foregroundStyle(Color.black.opacity(0.78))
                    .lineSpacing(1.6)
                    .padding(.top, 4)

                Text("#FinancialFreedom - Hal 13")
                    .font(.system(size: 5.8, weight: .medium))
                    .foregroundStyle(Color.black.opacity(0.58))
                    .padding(.top, 2)

                Rectangle()
                    .fill(Color.black.opacity(0.38))
                    .frame(height: 0.8)
                    .padding(.top, 1)

                HStack(spacing: 4) {
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 7))
                        .foregroundStyle(Color.black.opacity(0.55))

                    Text("Atomic Habits - James Clear")
                        .font(.system(size: 6.3, weight: .regular, design: .serif))
                        .foregroundStyle(Color.black.opacity(0.63))
                }
                .padding(.top, 1)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 17)
            .frame(width: 150, height: 190, alignment: .topLeading)
        }
    }

    private var bottomCalloutSection: some View {
        ZStack {
            UnevenRoundedRectangle(
                topLeadingRadius: 46,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 46,
                style: .continuous
            )
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.58, green: 0.75, blue: 0.96),
                        Color(red: 0.53, green: 0.71, blue: 0.93)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .ignoresSafeArea(edges: .bottom)

            VStack(spacing: 0) {
                Spacer()

                Text("Your Insight, captured.")
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)

                Text("Capture insights as you read, find them anytime.")
                    .font(.system(size: 13, weight: .medium, design: .serif))
                    .italic()
                    .foregroundStyle(Color.black.opacity(0.78))
                    .padding(.top, 14)

                NavigationLink(value: InsightRoute.writeInsight) {
                    Text("Write It Down")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 160, height: 50)
                        .background(
                            Capsule(style: .continuous)
                                .fill(Color(red: 0.03, green: 0.53, blue: 0.97))
                        )
                        .scaleEffect(writePressed ? 0.93 : 1.0)
                        .shadow(color: Color(red: 0.11, green: 0.45, blue: 0.90).opacity(writePressed ? 0.10 : 0.28), radius: 18, x: 0, y: 10)
                }
                .buttonStyle(.plain)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            guard !writePressed else { return }
                            withAnimation(.spring(response: 0.18, dampingFraction: 0.65)) {
                                writePressed = true
                            }
                        }
                        .onEnded { _ in
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.55)) {
                                writePressed = false
                            }
                        }
                )
                .padding(.top, 26)

                Spacer()
            }
            .padding(.top, 50)
            .padding(.bottom, 50)
            .padding(.horizontal, 28)
        }
        .frame(height: 388)
    }
}
#Preview {
    HomeView(onOpenLibrary: {})
}
