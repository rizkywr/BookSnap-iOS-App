//
//  BookSnapWidgetLiveActivity.swift
//  BookSnapWidget
//
//  Created by Rizky Wahyu Ramadhan on 27/04/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

private let liveActivityHomeURL = URL(string: "booksnap://home")!

struct BookSnapWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct BookSnapWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BookSnapWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(liveActivityHomeURL)
            .keylineTint(Color.red)
        }
    }
}

extension BookSnapWidgetAttributes {
    fileprivate static var preview: BookSnapWidgetAttributes {
        BookSnapWidgetAttributes(name: "World")
    }
}

extension BookSnapWidgetAttributes.ContentState {
    fileprivate static var smiley: BookSnapWidgetAttributes.ContentState {
        BookSnapWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: BookSnapWidgetAttributes.ContentState {
         BookSnapWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: BookSnapWidgetAttributes.preview) {
   BookSnapWidgetLiveActivity()
} contentStates: {
    BookSnapWidgetAttributes.ContentState.smiley
    BookSnapWidgetAttributes.ContentState.starEyes
}
