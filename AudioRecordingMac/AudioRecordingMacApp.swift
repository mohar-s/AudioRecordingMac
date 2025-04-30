//
//  AudioRecordingMacApp.swift
//  AudioRecordingMac
//
//  Created by Mohar on 23/04/25.
//

import SwiftUI
import GoogleSignIn

@main
struct AudioRecordingMacApp: App {
    let persistenceController = PersistenceController.shared
      @StateObject var authViewModel = AuthenticationViewModel()
    
    var body: some Scene {
        WindowGroup {
            
            HomeView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(authViewModel)
                    
            }
        
        
    }
}
