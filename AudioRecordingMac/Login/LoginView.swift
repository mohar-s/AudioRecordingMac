//
//  LoginView.swift
//  AudioRecordingMac
//
//  Created by Mohar on 23/04/25.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct LoginView: View {
    
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @ObservedObject var vm = GoogleSignInButtonViewModel()
    
    @Binding var path: NavigationPath
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Login using your google Account!")
                .font(.largeTitle)
                .bold()

            GoogleSignInButton(viewModel: vm, action: authViewModel.signIn)
              .accessibilityIdentifier("GoogleSignInButton")
              .accessibility(hint: Text("Sign in with Google button."))
              .padding()
              .frame(width: 250, height: 50)
        }
        .padding()
        .frame(minWidth: 400, minHeight: 300)
        
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
//    LoginView(authViewModel: .init(), path: .init(.constant(.none)) ?? .constant(.init()))
//}
