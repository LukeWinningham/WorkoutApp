//
//  LiveWorkoutLiveActivity.swift
//  LiveWorkout
//
//  Created by Luke Winningham on 3/4/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct LiveWorkoutAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct LiveWorkoutLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveWorkoutAttributes.self) { context in
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
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension LiveWorkoutAttributes {
    fileprivate static var preview: LiveWorkoutAttributes {
        LiveWorkoutAttributes(name: "World")
    }
}

extension LiveWorkoutAttributes.ContentState {
    fileprivate static var smiley: LiveWorkoutAttributes.ContentState {
        LiveWorkoutAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: LiveWorkoutAttributes.ContentState {
         LiveWorkoutAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: LiveWorkoutAttributes.preview) {
   LiveWorkoutLiveActivity()
} contentStates: {
    LiveWorkoutAttributes.ContentState.smiley
    LiveWorkoutAttributes.ContentState.starEyes
}
