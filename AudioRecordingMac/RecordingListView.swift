//
//  ContentView.swift
//  AudioRecordingMac
//
//  Created by Mohar on 23/04/25.
//

import CoreData
import GoogleSignIn
import SwiftUI

struct RecordingListView: View {

    @EnvironmentObject var authViewModel: AuthenticationViewModel
    private var user: GIDGoogleUser? {
        return GIDSignIn.sharedInstance.currentUser
    }

    @State var recordingList = SharedUtils.shared.getAllObjects()

    @State private var isShowingAlert = false
    @State private var inputText = ""
    @State private var resultText = ""

    @State private var navigateTo: String? = nil
    @Binding var path: NavigationPath

    var body: some View {
        VStack {
            VStack {
                if recordingList.isEmpty {
                    Spacer()
                    Text("Recodings not found, Click on + Add New to start recording")
                        .font(.largeTitle)
                        .bold()
                    Spacer()
                        
                } else {
                    List(recordingList, id: \.uuid) { item in
                        VStack(alignment: .leading, ) {
                            Text("Title: \(item.name)").font(.headline).bold()
                            Text("Date: \(item.date)")
                        }.padding()
                            .contentShape(Rectangle())
                            .onTapGesture {
                                SharedUtils.shared.selectedRecoding = item
                                self.path.append(Page.playRecording)
                            }
                    }
                }
            }

            Spacer()

            HStack {
                VStack {
                    Button(action: {
                        isShowingAlert = true
                    }) {
                        Text(" + Add New")
                    }.background(.green)
                        .foregroundColor(.white)

                    Button(action: {
                        recordingList = SharedUtils.shared.getAllObjects()
                    }) {
                        Text("Refresh")
                    }.background(.green)
                        .foregroundColor(.white)
                }
                Spacer()
                if let userProfile = user?.profile {
                    VStack(spacing: 10) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading) {
                                Text(userProfile.name)
                                    .font(.headline)
                                Text(userProfile.email)
                            }
                        }
                        Button(
                            NSLocalizedString(
                                "Sign Out",
                                comment: "Sign out button"
                            ),
                            action: signOut
                        )
                        .background(Color.blue)
                        .foregroundColor(Color.white)
                        .cornerRadius(5)

                        Spacer()
                    }
                }
            }.frame(height: 80)
                .padding()
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("All Recordings")
        .sheet(isPresented: $isShowingAlert) {
            InputAlertView(
                inputText: $inputText,
                isPresented: $isShowingAlert,
                onSubmit: {
                    resultText = inputText
                    SharedUtils.shared.createNewRecoding(name: resultText)
                    resultText = ""
                    inputText = ""

                    path.append(Page.newRecording)

                }
            )
        }
        .onAppear {
            recordingList = SharedUtils.shared.getAllObjects()
        }
    }

    //            .toolbar {
    //                ToolbarItem {
    //                    HStack {
    //
    //                        Button {
    //                            isShowingAlert = true
    //                        } label: {
    //                            Text("Add New")
    //                        }
    //
    //                    }
    //                }
    //            }
    //            Text("Select an item")

    //
    //                .navigationDestination(for: String.self) { value in
    //                    NewRecordingView(title: value)
    //                }

    //        }

    //        .onChange(of: selectedItem) { newValue in
    //                    print("Selected item: \(newValue ?? "None")")
    //                }

    func signOut() {
        SharedUtils.shared.clearAllData()
        authViewModel.signOut()
        path.removeLast(path.count)
    }

}

private func addItem(fileName: String) {

    //        withAnimation {
    //            let newItem = Item(context: viewContext)
    //            newItem.timestamp = Date()
    //            newItem.title = fileName
    //
    //            do {
    //                try viewContext.save()
    //            } catch {
    //                // Replace this implementation with code to handle the error appropriately.
    //                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
    //                let nsError = error as NSError
    //                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    //            }
    //        }
}

private func deleteItems(offsets: IndexSet) {
    //        withAnimation {
    //            offsets.map { items[$0] }.forEach(viewContext.delete)
    //
    //            do {
    //                try viewContext.save()
    //            } catch {
    //                // Replace this implementation with code to handle the error appropriately.
    //                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
    //                let nsError = error as NSError
    //                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    //            }
    //        }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct InputAlertView: View {
    @Binding var inputText: String
    @Binding var isPresented: Bool
    var onSubmit: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Enter Recording title:")
                .font(.headline)
            TextField("Type here...", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 250)
            HStack {
                Spacer()
                Button("Cancel") {
                    isPresented = false
                }
                Spacer()
                Button("OK") {
                    onSubmit()
                    isPresented = false
                }
                Spacer()
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 300)
    }
}
