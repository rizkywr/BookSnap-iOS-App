//
//  BookSnapWidget.swift
//  BookSnapWidget
//
//  Created by Rizky Wahyu Ramadhan on 27/04/26.
//


import WidgetKit
import SwiftUI

private enum WidgetDeepLink {
    static let home = URL(string: "booksnap://home")!
    static let writeInsight = URL(string: "booksnap://write-insight")!
}

// MARK: - 1. Provider & Entry Model
struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        return Timeline(entries: [entry], policy: .atEnd)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

// MARK: - 2. Main Entry View (Switcher)
// MARK: - 2. Main Entry View (Switcher)
struct BookSnapWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                SmallWidgetView(entry: entry)
            case .systemMedium:
                MediumWidgetView(entry: entry)
            case .systemLarge:
                LargeWidgetView(entry: entry)
            default:
                SmallWidgetView(entry: entry)
            }
        }
        // MENGUBAH BACKGROUND MENJADI GLASS WHITE
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.6),
                    Color.white.opacity(0.2)
                ],
                startPoint: .bottomLeading,
                endPoint: .topLeading
            )
            .background(.ultraThinMaterial) // Menambahkan blur di belakang gradasi
            }
        }
    }


// MARK: - 3. Small Widget Layout
struct SmallWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(alignment: .leading) {
            WidgetIcon(size: 36)
            Spacer()
            VStack(alignment: .leading, spacing: 2) {
                Text("BookSnap")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.white.opacity(0.6))
                Text("Quick Insight")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .padding(16)
        .widgetURL(WidgetDeepLink.home)
    }
}

// MARK: - 4. Medium Widget Layout (Improved)
struct MediumWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        
        HStack(spacing: 16) {
            // Sisi Kiri: Info
            VStack(alignment: .center, spacing: 8) {
                WidgetIcon(size: 38)
//                Spacer()
                VStack(alignment: .leading, spacing: 2) {
                    Text("BookSnap")
                        .font(.system(size: 11, weight: .black))
                        .foregroundStyle(.black.opacity(0.6))
                    
                }
            }
            
            Spacer()
            
            
            // Sisi Kanan: Action Button
            VStack {
                // Button fungsional untuk membuka app atau menjalankan action
                Text("Your Insight,captured")
                    .font(.system(size: 16, weight: .thin))
                    .foregroundStyle(.black)
                    .lineLimit(10)
                Link(destination: WidgetDeepLink.writeInsight) {
                        Text("Write it Down")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.gradient)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                .buttonStyle(.plain) // Penting agar style custom tidak ditimpa default button style
            }
        }
        .padding(18)
        .widgetURL(WidgetDeepLink.home)
    }
}

// MARK: - 5. Large Widget Layout
struct LargeWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                WidgetIcon(size: 48)
                Spacer()
                Text(entry.date, style: .date)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white.opacity(0.4))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Your Library Insights")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.6))
                Text("Transform your reading journey into actionable knowledge.")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.white)
            }
            
            Spacer()
            
            VStack(spacing: 10) {
                ActionRow(title: "Add New Insight", icon: "plus", color: .blue)
                ActionRow(title: "Browse Books", icon: "books.vertical.fill", color: .white.opacity(0.1))
                ActionRow(title: "Recent Notes", icon: "clock.fill", color: .white.opacity(0.1))
            }
        }
        .padding(24)
        .widgetURL(WidgetDeepLink.home)
    }
}

// MARK: - 6. Reusable Components
struct WidgetIcon: View {
    let size: CGFloat
    
    var body: some View {
        Image("SnapBook3") // Pastikan nama ini persis dengan yang ada di Assets.xcassets
            .resizable() // Wajib agar gambar bisa di-resize
            .aspectRatio(contentMode: .fit) // Menjaga logo tidak gepeng/terdistorsi
//            .padding(size * 0.2) // Memberikan ruang napas di dalam box logo
            .frame(width: 50, height: 50)
//            .background(Color.blue.gradient)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.3, style: .continuous))
    }
}

struct ActionRow: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(title)
            Spacer()
            Image(systemName: "chevron.right").font(.system(size: 10)).opacity(0.3)
        }
        .font(.system(size: 14, weight: .semibold))
        .foregroundStyle(.white)
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 7. Main Widget Config
struct BookSnapWidget: Widget {
    let kind: String = "BookSnapWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            BookSnapWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("BookSnap")
        .description("Quick shortcuts for your book notes.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - 8. Hex Support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}

// MARK: - 9. Preview Support
#Preview("Small", as: .systemSmall) { BookSnapWidget() } timeline: { SimpleEntry(date: .now, configuration: ConfigurationAppIntent()) }
#Preview("Medium", as: .systemMedium) { BookSnapWidget() } timeline: { SimpleEntry(date: .now, configuration: ConfigurationAppIntent()) }
#Preview("Large", as: .systemLarge) { BookSnapWidget() } timeline: { SimpleEntry(date: .now, configuration: ConfigurationAppIntent()) }
