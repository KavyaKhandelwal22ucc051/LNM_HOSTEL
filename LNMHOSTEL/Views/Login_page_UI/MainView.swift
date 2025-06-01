//
//  MainView.swift
//  LNMHOSTEL
//
//  Created by kavya khandelwal  on 20/05/25.
//

    import SwiftUI

    struct MainView: View {
        
        @State private var screen = 0
        @State private var create : Bool = false
        @State private var login : Bool = false
        
        var body: some View {
            
            NavigationStack{
                
                ZStack{
                    
                    
                    
                    Color.black.ignoresSafeArea(.all)
                    
                    Circle()
                        .frame(width: 600,height: 600)
                        .foregroundColor(Color("blue1"))
                        .offset(x:0,y: -230)
                    
                    Circle()
                        .frame(width: 550,height: 550)
                        .foregroundColor(Color("blue2"))
                        .offset(x:0,y: -270)
                    
                    CircleView()
                        .offset(x:0,y: -200)
                    
                    TabView(selection: $screen){
                        
                        ForEach(0..<2){
                            index in CardView(card:
                                                testData[index]).tag(index)
                        }
                    }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    
                    if(screen==0){
                        
                        ZStack {
                            
                            Image("login")
                                .resizable()
                                .frame(width: 500,height: 500)
                                .offset(x:75,y: -200)
                            
                        
                        ZStack{
                            
                            Image(systemName: "message.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 70))
                                .scaleEffect(login ? 1:0)
                            
                            Text("Login!")
                                .font(.system(size: 20))
                                .scaleEffect(login ? 1:0)
                                .opacity(login ? 1:0)
                            
                        }.offset(x:100,y: -300)
                            .animation(.easeOut(duration: 2),value: login)
                            .onAppear(perform: {login = true})
                        
                        }
                        
                        NavigationLink{
                            LoginView()
                        } label: {
                            Text("Login")
                                .font(Montserrat.semibold.font(size: 25))
                                .foregroundStyle(.blue1)
                                .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color("blue1"),lineWidth: 3)
                                    .frame(width: 100,height: 40))
                                
                        }.offset(x:0,y:335)
                    }
                    
                    if(screen==1){
                        
                        ZStack {
                            
                            Image("create")
                                .resizable()
                                .frame(width: 500,height: 500)
                                .offset(x:75,y: -200)
                            
                        
                        ZStack{
                            
                            Image(systemName: "message.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 70))
                                .scaleEffect(create ? 1:0)
                            
                            Text("Create")
                                .font(.system(size: 20))
                                .scaleEffect(create ? 1:0)
                                .opacity(create ? 1:0)
                            
                        }.offset(x:100,y: -315)
                            .animation(.easeOut(duration: 2),value: create)
                            .onAppear(perform: {create = true})
                        
                        }
                        
                        NavigationLink{
                            RegistrationView()
                        } label: {
                            Text("Create")
                                .font(Montserrat.semibold.font(size: 25))
                                .foregroundColor(Color("blue2").opacity(1))
                                .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color("blue1"),lineWidth: 3)
                                    .frame(width: 100,height: 40))
                        }.offset(x:0,y:335)
                    }
                }
            }
        }
    }

    #Preview {
        MainView().preferredColorScheme(.light)
    }
