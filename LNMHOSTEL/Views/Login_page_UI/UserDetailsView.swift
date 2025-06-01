//
//  UserDetailsView.swift
//  LNMHOSTEL
//
//  Created by kavya khandelwal  on 23/05/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct UserDetailsView: View {
    @State private var email = ""
    @State private var name = ""
    @State private var fathername = ""
    @State private var RollNo = ""
    @State private var contact = ""
    @State private var hostel = "N/A"
    @State private var roomNo = "N/A"
    @State private var PresentUserDashBoard = false
    @State private var DataStored = false
    
    var body: some View {
        Form{
            
            Section(header: Text("User Details")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.black)
                ){
                
                TextField("Name",text:
                            Binding(
                                get: {self.name},
                                set: {self.name = $0.filter{!$0.isNumber}}))
                .submitLabel(.done)
                
                TextField("Father Name",text:
                            Binding(
                                get: {self.fathername},
                                set: {self.fathername = $0.filter{!$0.isNumber}}))
                .submitLabel(.done)
                
                TextField("Roll Number",text: $RollNo)
                    .submitLabel(.done)
                
                TextField("Contact Number", text: $contact)
                    .keyboardType(.numberPad)
                    .submitLabel(.done)
            }
            
            Section{
                Button{
                    SaveUserDetails()
                }label: {
                    Text("Sumbit")
                }.disabled(!isFormFill())
            }
        }.navigationTitle("Enter User Details")
            .alert(isPresented: $DataStored){
                Alert(title: Text("Success"),message: Text("Data is succesffully stored"),dismissButton: .default(Text("OK")){
                    PresentUserDashBoard = true                    
                    
                })
                
                
            }.background(
                NavigationLink(destination: UserDashBoardView(), isActive: $PresentUserDashBoard){
                    EmptyView()
                }
            )
    }
    
    func SaveUserDetails(){
        
        guard let currentUser = Auth.auth().currentUser else {
                print("No current user found")
                return
            }
        
        let userDetails = [
            "email": currentUser.email ?? "",
            "studentId": Auth.auth().currentUser!.uid,
            "name":name,            
            "fatherName":fathername,
            "rollno":RollNo,
            "contact":contact,
            "hostel":hostel,
            "room":roomNo            
        ]
        
        Firestore.firestore().collection("user_details").document(Auth.auth().currentUser!.uid).setData(userDetails){
            error in
            if let error = error{
                print(error.localizedDescription)
                return
            }else{
                print("Data is stored")
                DataStored = true
            }
        }
    }
    
    
    
    func isFormFill()->Bool{
        
        if name.isEmpty || fathername.isEmpty || RollNo.isEmpty || contact.isEmpty{
            return false
        }
        return true
    }
}

#Preview {
    UserDetailsView()
}
