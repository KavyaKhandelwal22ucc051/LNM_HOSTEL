//
//  UserDeatilsShowView.swift
//  LNMHOSTEL
//
//  Created by kavya khandelwal  on 25/05/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct UserDeatilsShowView: View {
    @State private var name = ""
    @State private var rollno = ""
    @State private var fathername = ""
    @State private var contact = ""
    @State private var room = ""
    @State private var hostel = ""
    @State private var showanimation = false
    var body: some View {
        ScrollView{
            ZStack{
                
                VStack{
                    
                    Text("User Details")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                    
                    Image(systemName: "person.and.background.dotted")
                        .resizable()
                        .frame(width: 120,height: 100)
                        .symbolEffect(.bounce.up.byLayer, options: .repeating, value: showanimation)
                        .padding()
                    
                    Group{
                        DetailRow(title: "Name", value: name)
                            
                        DetailRow(title: "Father's Name", value: fathername)
                        DetailRow(title: "Contact", value: contact)
                        
                        DetailRow(title: "Roll Number", value: rollno)
                        
                        DetailRow(title: "Room", value: room)
                        
                        DetailRow(title: "Hostel", value: hostel)
                    }.padding()
                    
                    Spacer()
                    
                }.onAppear{
                    showanimation.toggle()
                    fetchUserDetails()
                }
            }
        }
    }
    
    func fetchUserDetails(){
        guard let userId = Auth.auth().currentUser?.uid else{
            return
        }
        Firestore.firestore().collection("user_details").document(userId).getDocument{
            document , error in
            if let error = error {
                print("Error fetching user details : \(error.localizedDescription)")
                return
            }
            
            guard let document = document , document.exists else{
                print("Error fetching document: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let data = document.data()
            name = data?["name"] as? String ?? ""
            fathername = data?["fatherName"] as? String ?? ""
            contact = data?["contact"] as? String ?? ""
            rollno = data?["rollno"] as? String ?? ""
            hostel = data?["hostel"] as? String ?? ""
            room = data?["room"] as? String ?? ""
            
        }
    }
    
    struct DetailRow : View {
        var title : String
        var value : String
        var body: some View {
            HStack{
                Text(title)
                    .font(.subheadline)
                Spacer()
                Text(value)
            }
            .foregroundColor(.white)
            .padding()
            .font(Montserrat.bold.font(size: 20))
            .frame(maxWidth: .infinity)
            .background(Color("blue2"))
            .cornerRadius(50)
            .shadow(color: .white.opacity(0.08), radius: 60,x: 0,y: 16)
        }
    }
}

#Preview {
    UserDeatilsShowView()
}
