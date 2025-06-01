//
//  PreviousComplainView.swift
//  LNMHOSTEL
//
//  Created by kavya khandelwal  on 27/05/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct UserComplaint : Identifiable{
    let id : String
    let complaintype : String
    var status : String
}

struct PreviousComplainView: View {
    @State private var userComplaints : [UserComplaint] = []
    var body: some View {
        NavigationStack{
            
            ZStack{
                Color(.white)
                    .ignoresSafeArea()
                
                VStack{
                    Text("Previous Complaints")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                    
                    List(userComplaints){
                        complaint in
                        NavigationLink(destination: ComplaintdetailsView(compalint: complaint)){
                            PreviousComplaintDetailsCell(complaint: complaint)
                        }
                    }.onAppear{
                        fetchUserDetails()
                    }
                    
                                
                }
            }
        }
    }
    
    func fetchUserDetails(){
        guard let userId = Auth.auth().currentUser?.uid else{
            return
        }
        
        Firestore.firestore().collection("Complaints").whereField("userId", isEqualTo: userId).getDocuments{
            querysnapshot , error in
            
            if let error = error {
                print("Error fetching user complaints: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querysnapshot?.documents else{
                return
            }
            
            var userComplaints : [UserComplaint] = []
            
            for document in documents {
                let complaintData = document.data()

                let userComplaint = UserComplaint(
                    id: document.documentID,
                    complaintype: complaintData["complaintType"] as? String ?? "",
                    status: complaintData["status"] as? String ?? ""
                    
                )

                userComplaints.append(userComplaint)
            }

            self.userComplaints = userComplaints
        }
        
    }
    
   
}



struct ComplaintdetailsView : View {
    var compalint : UserComplaint
    var body: some View {
        VStack{
            
            
            Text("Type : \(compalint.complaintype)")
                .font(.headline)
                .fontWeight(.medium)
                .padding()
            
            Text("Status : \(compalint.status)")
                .font(.headline)
                .fontWeight(.medium)
                .padding()
            
            Spacer()
        }.padding()
            .shadow(radius: 5)
            .navigationTitle("Complaint Details")
    }
}

struct PreviousComplaintDetailsCell : View {
    let complaint : UserComplaint
    var body: some View {
        VStack(alignment: .leading) {
            Text("Type: \(complaint.complaintype)")
                .font(.headline)
                .foregroundColor(.black)
                .lineLimit(2) // Truncate long text
                .truncationMode(.tail) // Add ellipsis
            Text("Status: \(complaint.status)")
                .foregroundColor(complaint.status == "Pending" ? .orange : .teal)
                .font(.subheadline)
                .padding(.top, 5)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.horizontal)
        
    }
}



#Preview {
    PreviousComplainView()
}
