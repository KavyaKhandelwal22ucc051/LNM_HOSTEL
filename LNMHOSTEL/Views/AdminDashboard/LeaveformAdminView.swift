//
//  LeaveformAdminView.swift
//  LNMHOSTEL
//
//  Created by kavya khandelwal  on 26/05/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct LeaveformAdminView: View {
    @State private var leaveforms : [LeaveForm] = []
    @State private var selectedleaveform : LeaveForm?
    @State private var isError = false
    var body: some View {
        NavigationStack{
            
            List(leaveforms){ leaveform in
                NavigationLink(destination: LeaveFormDetailView(leaveForm: leaveform, onApprov:{
                    approvLeaveForm(leaveform: leaveform)
                }, onReject:{
                    rejectLeaveForm(leaveform: leaveform)
                }, onDismiss: {
                    
                })){
                    LeaveFormRowView(leaveform: leaveform)
                }
            }.onAppear{
                fetchLeaveFormReaquest()
            }
        }
    }
    
    struct LeaveFormDetailView : View {
        var leaveForm : LeaveForm
        var onApprov : () -> Void
        var onReject : () -> Void
        var onDismiss : () -> Void
        var body: some View {
            VStack(spacing: 16){
                
                Text("Leave Form Details")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Text("Reason : \(leaveForm.reason)")
                    .fontWeight(.semibold)
                
                Text("Start Date : \(formattedDate(leaveForm.startDate))")
                Text("End Date : \(formattedDate(leaveForm.endDate))")
                Text("Status : \(leaveForm.status)")
                
                HStack(spacing: 16){
                    Button{
                        onApprov()
                    }label: {
                        Text("Approv")
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue))
                            .foregroundStyle(.white)
                    }
                    
                    Button{
                        onReject()
                    }label: {
                        Text("Reject")
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.red))
                            .foregroundStyle(.white)
                    }
                    
                    Spacer()
                }
            }.padding()
                .background(RoundedRectangle(cornerRadius: 5).fill(Color.white))
                .shadow(radius: 5)
                .onTapGesture {
                    onDismiss()
                }
        }
        
        
    }
    
    func fetchLeaveFormReaquest(){
        
        Firestore.firestore().collection("leaveform").whereField("status", isEqualTo: "pending").getDocuments{
            querydocument , error in
            if let error = error {
                print("error fetching leave form : \(error.localizedDescription)")
                return
            }
            
            guard let documents = querydocument?.documents else{
                return
            }
            
            var leaveforms : [LeaveForm] = []
            for document in documents {
                let data = document.data()
                let leaveform = LeaveForm(id: document.documentID, reason: data["reason"] as? String ?? "", startDate: (data["startDate"] as? Timestamp)?.dateValue() ?? Date(), endDate: (data["endDate"] as? Timestamp)?.dateValue() ?? Date(), status: data["status"] as? String ?? "")
                
                leaveforms.append(leaveform)
            }
            self.leaveforms = leaveforms
        }
    }
    
    func approvLeaveForm(leaveform : LeaveForm){
        
        if let index = leaveforms.firstIndex(where: { $0.id == leaveform.id }) {
            leaveforms[index].status = "Approved"
            
            Firestore.firestore().collection("leaveform").document(leaveform.id).updateData(["status": "Approved"]) { error in
                if let error = error {
                    print("Error updating leave form status in Firestore: \(error.localizedDescription)")
                } else {
                    print("Leave form status updated successfully in Firestore.")
                }
            }
        }
    }
    
    func rejectLeaveForm(leaveform : LeaveForm){
        if let index = leaveforms.firstIndex(where: { $0.id == leaveform.id }) {
            leaveforms[index].status = "Rejected"
            Firestore.firestore().collection("leaveform").document(leaveform.id).updateData(["status": "Rejected"]) { error in
                if let error = error {
                    print("Error updating leave form status in Firestore: \(error.localizedDescription)")
                } else {
                    print("Leave form status updated successfully in Firestore.")
                }
            }
        }
    }
}
    
struct LeaveFormRowView: View {
    var leaveform: LeaveForm
    
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Reason: \(leaveform.reason)")
                .font(.headline)
            Text("Status: \(leaveform.status)")
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
}


func formattedDate( _ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter.string(from: date)
}

#Preview {
    LeaveformAdminView()
}
