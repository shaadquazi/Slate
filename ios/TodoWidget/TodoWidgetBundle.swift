//
//  TodoWidgetBundle.swift
//  TodoWidget
//
//  Created by Shaad Quazi on 2/10/26.
//

import WidgetKit
import SwiftUI

@main
struct TodoWidgetBundle: WidgetBundle {
    var body: some Widget {
        TodoWidget()
        TodoWidgetControl()
        TodoWidgetLiveActivity()
    }
}
