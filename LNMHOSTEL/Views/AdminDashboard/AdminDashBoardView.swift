//
//  AdminDashBoardView.swift
//  LNMHOSTEL
//
//  Created by kavya khandelwal  on 23/05/25.
//

import SwiftUI
import FirebaseAuth

struct AdminDashBoardView: View {
    @State private var selectedTab: Int = 0
    @State private var showLogin = false
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack{
            
            TabView(selection: $selectedTab){
                
                BookingAdminView()
                    .tabItem{
                        Label("Booking Requests",systemImage: "envelope")
                    }.tag(0)
                
                ComplainAdminView()
                    .tabItem{
                        Label("Complain Requests",systemImage: "flag")
                    }.tag(1)
                
                LeaveformAdminView()
                    .tabItem{
                        Label("Leave Form Requests",systemImage: "list.bullet.clipboard")
                    }.tag(2)
            }
        }.animation(.bouncy)
        .navigationBarBackButtonHidden(true)
            .navigationBarItems(trailing: Button("Sign Out"){
                sign_out()
            })
    }
    
    func sign_out(){
        do{
           try Auth.auth().signOut()
            showLogin = true
            dismiss()
        } catch{
            print(error.localizedDescription)
        }
    }
}

#Preview {
    AdminDashBoardView()
}
