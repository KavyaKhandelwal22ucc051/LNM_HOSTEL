//
//  BookingRequestExitView.swift
//  LNMHOSTEL
//
//  Created by kavya khandelwal  on 26/05/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct BookingRequestExitView: View {
    let booking : Booking
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack{
            Spacer()
            
            VStack(alignment: .leading,spacing: 12){
                 
               
                
                Text("Student Name : \(booking.studentName)")
                Text("Student Roll Number : \(booking.rollNo)")
                Text("Hostel : \(booking.hostel)")
                Text("Room : \(booking.room)")
                
                
            }.font(.headline)
                .padding()
            
            Spacer()
            
            HStack(spacing: 10){
                
                Button{
                    approvBookingRequest(booking: booking)
                }label: {
                    Text("APPROV")
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.blue)
                        .cornerRadius(10)
                }.buttonStyle(PlainButtonStyle())
                
                Button{
                    rejectBookingRoom(booking: booking)
                }label: {
                    Text("REJECT")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.red)
                        .cornerRadius(10)
                }.buttonStyle(PlainButtonStyle())
            }.padding()
            
            
            
        }.background(Color.white)
            .cornerRadius(20)
            .padding()
            .shadow(radius: 5)
    }
    
    private func approvBookingRequest(booking : Booking){
        let bookRef = Firestore.firestore().collection("Bookings").document(booking.id)
        bookRef.updateData(["bookingStatus" : "approved"]) {
            error in
            if let error = error {
                print("Error in fetching Booking : \(error.localizedDescription)")
                return
            }
            
            print("Booking request approved successfully")
            
            // Update the user_details database
            print(booking.room)
            
            _ = Auth.auth().currentUser?.uid ?? ""
            
            Firestore.firestore().collection("user_details").document(booking.studentId).updateData(["room": booking.room,"hostel": booking.hostel]){
                error in
                if let error = error {
                    print("Error in updating details : \(error.localizedDescription)")
                    return
                }
                
                print("Details of student update succesfully")
            }
            
            presentationMode.wrappedValue.dismiss()
        }
        
    }
    
    private func rejectBookingRoom(booking:Booking){
        
        Firestore.firestore().collection("Bookings").document(booking.id).updateData(["bookingStatus":"rejected"]){
            error in
            if let error = error {
                print("Error in updating booking : \(error.localizedDescription)")
                return
            }
            
            print("Booking request rejected successfully")
            
            dismiss()
        }
    }
    
    
}

#Preview {
    BookingRequestExitView(booking: Booking(id: "abc", studentId: "Test", hostel: "TestHostel", room: "TestRoom", rollNo: "TestRollNo", studentName: "Test", bookingStatus: "h"))
}
