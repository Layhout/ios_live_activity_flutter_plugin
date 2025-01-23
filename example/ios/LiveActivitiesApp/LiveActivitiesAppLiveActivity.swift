//
//  LiveActivitiesAppLiveActivity.swift
//  LiveActivitiesApp
//
//  Created by Layhout Chea on 21/1/25.
//

import ActivityKit
import SwiftUI
import WidgetKit

struct LiveActivitiesAppAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var dataJsonString: String
    }

    // Fixed non-changing properties about your activity go here!
    var id: String = UUID().uuidString
}

struct LiveActivitiesAppLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivitiesAppAttributes.self) {
            context in
            // Lock screen/banner UI goes here

            let title: String = DataProcess.string(
                jsonString: context.state.dataJsonString, key: "title")
            let description: String = DataProcess.string(
                jsonString: context.state.dataJsonString, key: "description")
            let step: Int = DataProcess.int(
                jsonString: context.state.dataJsonString, key: "step")
            let distance: Int = DataProcess.int(
                jsonString: context.state.dataJsonString, key: "distance")

            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                        Text(description)
                            .font(.system(size: 16, weight: .light))
                            .foregroundStyle(.white)
                            .opacity(0.7)
                    }.frame(maxWidth: .infinity, alignment: .leading)
                    Image("coffee_hub").resizable()
                        .frame(width: 42, height: 42)
                        .clipShape(.rect(cornerRadius: 8))

                }
                ProgressView(
                    value: CGFloat(step),
                    total: CGFloat(distance),
                    label: {
                        EmptyView()
                    },
                    currentValueLabel: { EmptyView() }
                ).progressViewStyle(LinearWithImageProgressStyle())
            }
            .padding(12)
            .activityBackgroundTint(Color.black.opacity(0.5))
            .activitySystemActionForegroundColor(Color.white)

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
                    Text("Bottom")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T")
            } minimal: {
                Text("M")
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension LiveActivitiesAppAttributes {
    fileprivate static var preview: LiveActivitiesAppAttributes {
        LiveActivitiesAppAttributes()
    }
}

extension LiveActivitiesAppAttributes.ContentState {
    fileprivate static var placed: LiveActivitiesAppAttributes.ContentState {
        LiveActivitiesAppAttributes.ContentState(
            dataJsonString: """
                {
                  "step": 0,
                  "distance": 3,
                  "title": "Order Placed",
                  "description": "Your order has been placed"
                }
                """
        )
    }

    fileprivate static var prepare: LiveActivitiesAppAttributes.ContentState {
        LiveActivitiesAppAttributes.ContentState(
            dataJsonString: """
                {
                  "step": 1,
                  "distance": 3,
                  "title": "Preparing Placed",
                  "description": "We are preparing your order"
                }
                """
        )
    }

    fileprivate static var delivering: LiveActivitiesAppAttributes.ContentState
    {
        LiveActivitiesAppAttributes.ContentState(
            dataJsonString: """
                {
                  "step": 2,
                  "distance": 3,
                  "title": "Delivering Order",
                  "description": "Delivering by 12:30 PM"
                }
                """
        )
    }

    fileprivate static var completed: LiveActivitiesAppAttributes.ContentState {
        LiveActivitiesAppAttributes.ContentState(
            dataJsonString: """
                {
                  "step": 3,
                  "distance": 3,
                  "title": "Completed",
                  "description": "Thank you for ordering with us! Enjoy!"
                }
                """
        )
    }
}

#Preview(
    "Notification", as: .content, using: LiveActivitiesAppAttributes.preview
) {
    LiveActivitiesAppLiveActivity()
} contentStates: {
    LiveActivitiesAppAttributes.ContentState.placed
    LiveActivitiesAppAttributes.ContentState.prepare
    LiveActivitiesAppAttributes.ContentState.delivering
    LiveActivitiesAppAttributes.ContentState.completed
}

struct LinearWithImageProgressStyle: ProgressViewStyle {
    let markerImage: some View = Image("moto_delivery").resizable().frame(
        width: 42, height: 32)
    let goalImage: some View = Image("location_marker").resizable().frame(
        width: 24, height: 24)

    func makeBody(configuration: Configuration) -> some View {
        let fractionCompleted = configuration.fractionCompleted ?? 0

        VStack {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Image("moto_delivery").resizable().frame(
                        width: 42, height: 32
                    ).frame(
                        width: geometry.size.width
                            * min(0.93, max(0.1, fractionCompleted)),
                        alignment: .trailing
                    )
                    Image("location_marker").resizable().frame(
                        width: 24, height: 24
                    ).frame(maxWidth: .infinity, alignment: .trailing)
                }
            }.frame(height: 32)
            ProgressView(value: configuration.fractionCompleted).tint(
                Color("Brand"))
        }
    }
}

// Data Model
struct LiveActivityData: Decodable {
    var step: Int?
    var distance: Int?
    var title: String?
    var description: String?

    subscript(key: String) -> Any? {
        get {
            switch key {
            case "step":
                return self.step
            case "distance":
                return self.distance
            case "title":
                return self.title
            case "description":
                return self.description
            default:
                return nil
            }
        }
    }
}

// Json parser
struct DataProcess {
    static func int(jsonString: String, key: String) -> Int {
        if let jsonData = jsonString.data(using: .utf8) {
            let data: LiveActivityData? = try? JSONDecoder().decode(
                LiveActivityData.self, from: jsonData)

            return data?[key] as? Int ?? 0
        } else {
            return 0
        }
    }

    static func string(jsonString: String, key: String) -> String {
        if let jsonData = jsonString.data(using: .utf8) {
            let data: LiveActivityData? = try? JSONDecoder().decode(
                LiveActivityData.self, from: jsonData)

            return data?[key] as? String ?? ""
        } else {
            return ""
        }
    }
}
