//
//  SettingsView.swift
//  MyBooks
//
//  Created by clarafication on 6/26/26.
//


import SwiftUI

struct SettingsView: View {

    var body: some View {

        Form {

            Section("Library") {

                Text("No folder selected")

            }

        }
        .navigationTitle("Settings")

    }

}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
