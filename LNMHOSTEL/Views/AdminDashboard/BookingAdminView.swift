//
//  BookingAdminView.swift
//  LNMHOSTEL
//
//  Created by kavya khandelwal  on 26/05/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct BookingAdminView: View {
    @State private var bookingRequests : [Booking] = []
    @State private var showAddRoomSheet : Bool = false
    
    var body: some View {
        NavigationStack{
            ZStack{
                List(bookingRequests){
                    booking in
                    NavigationLink(destination: BookingRequestExitView(booking: booking)){
                        BookingRequestCellView(booking : booking)
                    }
                }.onAppear{
                    fetchBookingRequests()
                }
                
                VStack{
                    Spacer()
                    
                    HStack{
                        Spacer()
                        
                        Button{
                            showAddRoomSheet = true
                        }label: {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 50 , height: 50)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .clipShape(.circle)
                                .shadow(radius: 5)
                        }
                        .padding()
                        .sheet(isPresented: $showAddRoomSheet){
                            AddNewRoomView{
                                addroom in
                                AddRoomToHostel(hostelId: addroom.hostelId, room: addroom.roomNumber)
                                showAddRoomSheet = false
                            }
                        }
                        Spacer()
                    }
                }
            }.navigationTitle("Booking Requests")
        }
    }
    
    private func fetchBookingRequests(){
        let bookingRef = Firestore.firestore().collection("Bookings")
        bookingRef.whereField("bookingStatus", isEqualTo: "pending").getDocuments{
            
            querySnapshot , error in
            
            if let error = error {
                print("error fetching bookings : \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else{
                return
            }
            
            var bookingRequests : [Booking] = []
            for document in  documents {
                print("DEBUG: Document ID = \(document.documentID)")
                
                let bookingsData = document.data()
                let debug = bookingsData["studentID"] as? String ?? ""
                print("student debug :\(debug)")
                let booking = Booking(id: document.documentID, studentId: bookingsData["studentID"] as? String ?? "", hostel: bookingsData["hostel"] as? String ?? "", room: bookingsData["room"] as? String ?? "" , rollNo: bookingsData["rollNo"] as? String ?? "", studentName: bookingsData["studentName"] as? String ?? "", bookingStatus: bookingsData["bookingStatus"] as? String ?? "")
                
                bookingRequests.append(booking)
            }
            
            self.bookingRequests = bookingRequests
            
        }
    }
    
    private func AddRoomToHostel(hostelId: String , room: String){
        let hostelRef = Firestore.firestore().collection("Hostels")
        hostelRef.whereField("hostelId", isEqualTo: hostelId).getDocuments{
            querySnapshot , error in
            
            if let error = error {
                print("Error fetching hostel : \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else{
                return
            }
            
           if let hostelDoc = documents.first{
               var availableRooms = hostelDoc.data()["availableRooms"] as? [String] ?? []
               availableRooms.append(room)
               
               hostelRef.document(hostelDoc.documentID).updateData(["availableRooms":availableRooms])
            }
        }
    }
    
    struct AddNewRoomView : View {
        let hostels = ["BH1","BH2","BH3","GH"]
        @State private var selectedHostel = "BH1"
        @State private var room : String =   ""
        
        var addRoom : (AddedRoom) -> Void
        
        var body: some View {
            
            VStack{
                
                Picker("Select Hostel", selection: $selectedHostel){
                    ForEach(hostels, id: \.self){
                        hostel in
                        Text(hostel)
                    }
                }.pickerStyle(MenuPickerStyle())
                
                TextField("Enter Room", text: $room)
                    .keyboardType(.numberPad)
                    .padding()
                    .textFieldStyle(.roundedBorder)
                
                Button{
                    let addedRoom = AddedRoom(hostelId: selectedHostel, roomNumber: room)
                    addRoom(addedRoom)
                }label: {
                    Text("Add Room")
                        .frame(width: 100,height: 50)
                        .foregroundStyle(.white)
                        .background(.blue)
                        .clipShape(.rect(cornerRadius: 50))
                }
                
            }.padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 0.5)
            
        }
    }
    
    struct AddedRoom{
        let hostelId : String
        let roomNumber : String
    }
    
   
    
    struct BookingRequestCellView : View {
        let booking : Booking
        @State private var showBookingDetails : Bool = false
        
        var body : some View {
           
            
           
            VStack{
                
                HStack{
                    
                    VStack{
                        
                        Text(booking.studentName)
                        
                        Text(booking.hostel)
                    }
                    
                    Spacer()
                  
                    
                }
               
            }.padding()
                .frame(maxWidth: .infinity)
                .shadow(radius: 5)
                .padding(.horizontal)
            
            
        }
    }
}

#Preview {
    BookingAdminView()
}
