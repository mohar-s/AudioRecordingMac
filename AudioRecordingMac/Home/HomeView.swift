//
//  HomeView.swift
//  AudioRecordingMac
//
//  Created by Mohar on 29/04/25.
//


import SwiftUI
import CoreData
import GoogleSignIn

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    @State private var path = NavigationPath()
    @StateObject var authViewModel = AuthenticationViewModel()
    
    var body: some View {
        
        NavigationStack(path: $path) {
            LoginView(path: $path)
                        .navigationDestination(for: Page.self) { page in
                            switch page {
                            case .microphonePermission:
                                AppPermissionView(path: $path)
                            case .recording:
                                RecordingListView(path: $path)
                            case .newRecording:
                                NewRecordingView(title: "", path: $path)
                            case .playRecording:
                                EqualizerVisualizerView(path: $path, fileName: "")
                            }
                        }
                }
        .onAppear {
          GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let user = user {
              self.authViewModel.state = .signedIn(user)
                print("User logged in automatically: \(user)")
                SharedUtils.shared.user = user
                path.append(Page.microphonePermission)
            } else if let error = error {
              self.authViewModel.state = .signedOut
              print("There was an error restoring the previous sign-in: \(error)")
            } else {
              self.authViewModel.state = .signedOut
                print("User not signed in automatically.")
            }
          }
        }
        .onOpenURL { url in
          GIDSignIn.sharedInstance.handle(url)
        }
        
    }

}


//#Preview {
//    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//}

enum Page: Hashable {
    case microphonePermission
    case recording
    case newRecording
    case playRecording
}
