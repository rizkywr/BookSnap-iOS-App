//
//  BookNotesNewDesignC2App.swift
//  BookNotesNewDesignC2
//
//  Created by Rizky Wahyu Ramadhan on 23/04/26.
//

import SwiftUI
import SwiftData

@main
struct BookNotesNewDesignC2App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: BookRecord.self)
    }
}
