//
//  LoginView.swift
//  LNMHOSTEL
//
//  Created by kavya khandelwal  on 21/05/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import GoogleSignInSwift

struct LoginView: View {
    @State private var email : String = ""
    @State private var password : String = ""
    @State private var showingerror : Bool = false
    @State private var alertmessage = ""
    @State private var PresentAdminDashBoard = false
    @State private var PresentUserDashBoard = false
    @State private var FirstLogin = false
    
    var body: some View {
        ZStack{
            Color("BgColor")
                .ignoresSafeArea(.all)
            
            Spacer()
            
            VStack{
                Text("Login")
                    .font(.largeTitle)
                    .padding()
                
                Button{
                    
                    signin_with_google()
                    
                }label: {
                    GLoginButton(image: Image("google"), text: Text("Signup with Google"))
                }
                
                Text("Email")
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .padding()
                    .font(Montserrat.medium.font(size: 25))
                
                TextField("Email Address",text: $email)
                    .padding()
                    .font(.title3)
                    .frame(maxWidth: .infinity)
                    .background(.white)
                    .shadow(color: Color.black.opacity(0.1),radius: 60,x: 0,y: 16)
                    .padding(.vertical)
                    .submitLabel(.done)
                
                Text("Password")
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .padding()
                    .font(Montserrat.medium.font(size: 25))
                
                TextField("Password",text: $password)
                    .padding()
                    .font(.title3)
                    .frame(maxWidth: .infinity)
                    .background(.white)
                    .shadow(color: Color.black.opacity(0.1),radius: 60,x: 0,y: 16)
                    .padding(.vertical)
                    .submitLabel(.done)
                
                Button{
                    
                    login_user()
                    
                }label: {
                    Text("Login")
                        .font(Montserrat.medium.font(size: 28))
                        .foregroundStyle(.white)
                        .frame(width: 200)
                        .padding()
                        .background(Color("blue2").cornerRadius(50))
                        
                }.alert(isPresented: $showingerror){
                    Alert(title: Text("Error"),message: Text(alertmessage),dismissButton: .default(Text("OK")))
                }
                
                NavigationLink{
                    
                    RegistrationView()
                    
                }label: {
                    Text("New User, Register!")
                        .font(Montserrat.medium.font(size: 17))
                        .foregroundStyle(.blue2)
                    
                        
                }
                
                NavigationLink(destination: UserDetailsView(), isActive: $FirstLogin){
                    EmptyView()
                }
                
                NavigationLink(destination: AdminDashBoardView(), isActive: $PresentAdminDashBoard){
                    EmptyView()
                }
                
                NavigationLink(destination: UserDashBoardView(), isActive: $PresentUserDashBoard){
                    EmptyView()
                }
                
                Spacer()
                Divider()
                Spacer()
                
                Text("You are completely safe.")
                Text("Read our Terms & Conditions.")
                    .foregroundColor(Color("blue2"))
                Spacer()
            }
        }.onAppear{
            resetState()
        }
       
    }
    
    // gmail and password login
    
   private func user_isadmin(completion: @escaping(Bool) -> Void){
        
       guard let user = Auth.auth().currentUser else{
           completion(false)
           return
       }
       
       let db = Firestore.firestore()
       let userDocref = db.collection("user_details").document(user.uid)
       
       userDocref.getDocument{
           document , error in
           
           if let error = error {
               print("Error Fecting user document : \(error.localizedDescription)")
               completion(false)
               return
           }
           
           guard let document = document , document.exists,
                 let data = document.data(),
                 let role = data["role"] as? String else{
               completion(false)
               return
           }
           
           if role == "admin"{
               completion(true)
           }else{
               completion(false)
           }
       }
        
    }
    
    func checkRoleAndNavigate(isAdmin:Bool) {
        if isAdmin {
            PresentAdminDashBoard = true
            PresentUserDashBoard = false
        }else{
            PresentUserDashBoard = true
            PresentAdminDashBoard = false
        }
    }
    
    func login_user(){
        Auth.auth().signIn(withEmail: email, password: password){
            result,error in
                if let error = error {
                    self.alertmessage = error.localizedDescription
                    self.showingerror = true
                    return
                }else{
                    user_isadmin{
                        isAdmin in
                        checkRoleAndNavigate(isAdmin: isAdmin)
                        
                    }
                }
            }
        }
    
    //google sign in
    
    func signin_with_google() {
        PresentUserDashBoard = false
        PresentAdminDashBoard = false
        
        guard let clientId = FirebaseApp.app()?.options.clientID else{
            return
        }
        
        let config = GIDConfiguration(clientID: clientId)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: Application_utility.rootViewController){
            user , error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let user = user?.user,
                    let idToken = user.idToken else{
                return
            }
            
            let accesToken = user.accessToken
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accesToken.tokenString)
            
            Auth.auth().signIn(with: credential){
                res,error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                guard let user = res?.user else{
                    return
                }
                
                print(user)
                
                if let user = Auth.auth().currentUser{
                    checkAdmin(user: user)
                }
            }
        }
    }
    
    func checkAdmin(user: User){
        
        PresentUserDashBoard = false
        PresentAdminDashBoard = false
          
        Firestore.firestore().collection("user_details").document(user.uid).getDocument{
            document ,error in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }else{
                if let document = document ,document.exists,let data = document.data(), let role = data["role"] as? String{
                    if role == "admin"{
                        PresentAdminDashBoard = true
                    } else{
                        PresentUserDashBoard = true
                    }
                }else {
                    
                    Firestore.firestore().collection("user_details").document(user.uid).getDocument{
                        result,error in
                        
                        if let document = document , document.exists{
                            FirstLogin = false
                            PresentUserDashBoard = true
                        }else{
                            FirstLogin = true
                            PresentUserDashBoard = false
                            PresentAdminDashBoard = false
                        }
                    }
                }
            }
            
        }
    }
    
    // google sign in end
    
    
    private func resetState(){
        email = ""
        password = ""
        alertmessage = ""
        showingerror = false
    }
    
}






struct GLoginButton : View {
    
    var image : Image
    var text : Text
    var body: some View {
        HStack{
            image
                .padding(.horizontal)
            
            text
                .font(.title2)
        }.padding()
            .frame(maxWidth: .infinity)
            .background(.white)
            .cornerRadius(30)
            .shadow(color: Color.black.opacity(0.1),radius: 60,x: 0,y: 16)
    }
}

#Preview {
    LoginView()
}
