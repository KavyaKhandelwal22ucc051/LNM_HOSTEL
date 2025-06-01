//
//  ComplainAdminView.swift
//  LNMHOSTEL
//
//  Created by kavya khandelwal  on 26/05/25.
//

import SwiftUI
import FirebaseFirestore

struct ComplainAdminView: View {
    @State private var complaints : [Complaint] = []
    @State private var selectedComplain : Complaint?
    @State private var isSheetPresented = false
    
    
    var body: some View {
        NavigationStack{
            
            List(complaints){
                complaint in
                NavigationLink(destination: ComplaintDetailsView(complaint: complaint, onMarkAsSolved: {
                    markAsSolved(complaint: complaint)
                }, onDismiss: {
                    selectedComplain = nil
                })){
                    ComplaintRowView(complaint: complaint)
                }
                
            }.onAppear(perform: fetchComplaintDetails)
                .navigationTitle("Complaint Requests")
                .navigationBarBackButtonHidden(true)
        }
    }
    
    
    func fetchComplaintDetails(){
        Firestore.firestore().collection("Complaints").whereField("status", isEqualTo: "pending").getDocuments{
            quesrySnapshot , error in
            
            if let error = error {
                print("error in fetching complaints : \(error.localizedDescription)")
                return
            }
            
            guard let documents = quesrySnapshot?.documents else{
                return
            }
            
            var complaints :[Complaint] = []
            for document in documents {
                let data = document.data()
                let complain = Complaint(id: document.documentID, complaintType: data["complaintType"] as? String ?? "", complaintDetails: data["complaintDetails"] as? String ?? "", userName: data["userName"] as? String ?? "", rollNo: data["rollNo"] as? String ?? "", roomNo: data["room"] as? String ?? "", contact: data["contact"] as? String ?? "", hostel: data["hostel"] as? String ?? "", preferredDate:  (data["preferredDate"] as? Timestamp)?.dateValue() ?? Date(), preferredTimeFrom: (data["preferredTimeFrom"] as? Timestamp)?.dateValue() ?? Date(), preferredTimeTo:  (data["preferredTimeTo"] as? Timestamp)?.dateValue() ?? Date(), status: data["status"] as? String ?? "")
                
                complaints.append(complain)
            }
            
            self.complaints = complaints
        }
    }
    
    func markAsSolved (complaint : Complaint) {
        
        if let index = complaints.firstIndex(where: {
            $0.id == complaint.id}){
            complaints[index].status = "Solved"
            
            Firestore.firestore().collection("Complaints").document(complaint.id).updateData(["status" : "Solved"]) {
                error in
                if let error = error {
                    print("error in fetching complaints : \(error.localizedDescription)")
                    return
                } else {
                    print("Complaint status updated successfully in Firestore.")
                }
            }
        }
        
    }
    
}

struct ComplaintDetailsView: View {
    var complaint: Complaint
        var onMarkAsSolved: () -> Void
        var onDismiss: () -> Void


    var body: some View {
            VStack(spacing: 16) {
                Text("Complaint Type:")
                    .font(.title)
                    
                Text("\(complaint.complaintType)")
                    .fontWeight(.semibold)
                
                Text("Details: \(complaint.complaintDetails)")
                    .multilineTextAlignment(.center)
                Text("Name: \(complaint.userName)")
                Text("Hostel: \(complaint.hostel)")
                Text("Date: \(formattedDate(complaint.preferredDate))")
                Text("Time From: \(formattedTime(complaint.preferredTimeFrom))")
                Text("Time To: \(formattedTime(complaint.preferredTimeTo))")

                Button("Mark as Solved") {
                    onMarkAsSolved()
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue))
                .foregroundColor(.white)

                Spacer()
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 15).fill(Color.white).frame(width: 380))
            .shadow(radius: 5)
            .onTapGesture {
                onDismiss()
            }
        }
    
   

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    func formattedTime(_ time: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }
}

struct ComplaintRowView: View {
    var complaint: Complaint

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Room No: \(complaint.roomNo)")
                .font(.headline)
            Text("Name: \(complaint.userName)")
                .foregroundColor(.secondary)
        }.padding()
            .frame(maxWidth: .infinity)
            .background(Color("BgColor"))
            .cornerRadius(10)
            .shadow(radius: 5)
            .padding(.horizontal)
    }
}

#Preview {
    ComplainAdminView()
}
