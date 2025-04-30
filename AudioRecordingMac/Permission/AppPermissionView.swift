//
//  AppPermissionView.swift
//  AudioRecordingMac
//
//  Created by Mohar on 29/04/25.
//

import SwiftUI

struct AppPermissionView : View {
    
    var viewModel = AppPermissionViewModel()
    
    @Binding var path: NavigationPath
    
    var body: some View {
        
        VStack{
            Spacer()
            Text("App Permission Required")
                .font(.largeTitle)
                .bold()
            
            Button("Request Permission") {
                print("Request Permission")
                self.viewModel.requestTheVoiceRecordingPermission()
                path.append(Page.recording)
                
            }
            
            Spacer()
            Text("Application need Audio Recording permission to work, click on the button to allow the permission")
                .font(.system(size: 10))
            Spacer()
            
        }
        .padding()
        
        
    }
}

//#Preview {
//    AppPermissionView()
//}
