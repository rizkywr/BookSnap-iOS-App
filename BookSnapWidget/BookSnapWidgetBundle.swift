//
//  BookSnapWidgetBundle.swift
//  BookSnapWidget
//
//  Created by Rizky Wahyu Ramadhan on 27/04/26.
//

import WidgetKit
import SwiftUI

@main
struct BookSnapWidgetBundle: WidgetBundle {
    var body: some Widget {
        BookSnapWidget()
        BookSnapWidgetControl()
        BookSnapWidgetLiveActivity()
    }
}
