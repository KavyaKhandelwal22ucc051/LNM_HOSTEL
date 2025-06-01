//
//  UserDashBoardView.swift
//  LNMHOSTEL
//
//  Created by kavya khandelwal  on 23/05/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct UserDashBoardView: View {
    @State private var selectedTab : Int = 0
    @State private var showLogin  = false
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack{
            
            TabView(selection: $selectedTab){
                
                BookingView()
                    .tabItem{
                        Label("Book Room", systemImage: "bed.double.fill")
                    }.tag(0)
                
                ComplainView()
                    .tabItem{
                        Label("Register Complain",systemImage: "exclamationmark.bubble.fill")
                    }.tag(1)
                
                LeaveFormView()
                    .tabItem{
                        Label("Leave Form",systemImage: "suitcase.fill")
                    }.tag(2)
                
                UserDeatilsShowView()
                    .tabItem{
                        Label("Student Details",systemImage: "person.fill")
                    }.tag(3)
                
                
            }.navigationBarBackButtonHidden(true)
                .navigationBarItems(trailing: Button("Sign Out"){
                    signout()
                })
            
        }
    }
    
    func signout(){
        do{
            try Auth.auth().signOut()
            showLogin = true
            dismiss()
        }catch{
            print(error.localizedDescription)
        }
    }
}

#Preview {
    UserDashBoardView()
}
