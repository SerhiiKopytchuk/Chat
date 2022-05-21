//
//  LoginView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 14.05.2022.
//

import SwiftUI
import Firebase

struct SignInView: View {
    
    @State var email:String = ""
    @State var password:String = ""
    
    @State var isButtonDisabled: Bool = true
    @State var isShowingPassword:Bool = false
    @State var canLoginUser = false

    @State var isShowAlert = false
    
    @EnvironmentObject var viewModel: AppViewModel

    
    //    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    private func updateButton() {
        let time:Double = 0.3
        //check if enable button
        
        withAnimation(.easeInOut(duration: time)) {
            if email.isEmpty || password.isEmpty{
                isButtonDisabled = true
            }else{
                if password.count >= 8{
                    if email.contains("@gmail.com") || email.contains("@email.com"){
                        isButtonDisabled = false
                    }else{
                        isButtonDisabled = true
                    }
                }else{
                    isButtonDisabled = true
                }
            }
        }
    }
    
    
    var body: some View {
//        NavigationView{
            ZStack{
                VStack(spacing: 30){
                    Text("Log In")
                        .font(.system(.largeTitle, design: .rounded))
                        .fontWeight(.bold)
                        .padding(.leading, 10)
                        .padding()
                        .foregroundColor(.orange)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack{
                        Group {
                            HStack{
                                Image(systemName: "mail")
                                    .foregroundColor(.gray)
                                TextField("Email", text: $email)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                    .onChange(of: email) { _ in
                                        updateButton()
                                    }
                            }
                            
                            HStack{
                                Image(systemName: "lock")
                                    .foregroundColor(.gray)
                                if self.isShowingPassword{
                                    
                                    TextField("Password", text: $password)
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                        .onChange(of: password) { _ in
                                            updateButton()
                                        }
                                    Button {
                                        self.isShowingPassword.toggle()
                                    } label: {
                                        Image(systemName: "eye.slash")
                                            .foregroundColor(.gray)
                                    }
                                }else{
                                    SecureField("Password", text: $password)
                                        .disableAutocorrection(true)
                                        .onChange(of: password) { _ in
                                            updateButton()
                                        }
                                    Button {
                                        self.isShowingPassword.toggle()
                                    } label: {
                                        Image(systemName: "eye")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        .padding()
                        .padding(.horizontal, 20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.gray, lineWidth: 1)
                                .padding(.leading, 10)
                                .padding(.trailing, 20)
                                .padding(5)
                        )
                    }
                    
                    VStack {
                        Button("Log in") {
                            //how to automaticly change prop
                            if isButtonDisabled{
                                withAnimation (.easeInOut){
                                    isShowAlert.toggle()
                                }
                            }else{
                                viewModel.signIn(email: self.email, password: self.password)
                            }
                        }
                        .foregroundColor(.white)
                        .padding(.leading, 80)
                        .padding(.trailing, 80)
                        .padding()
                        .background(isButtonDisabled ? Color.gray : Color.orange)
                        .cornerRadius(30)
    //                    .disabled(isButtonDisabled)
                        .shadow(color:isButtonDisabled ? .gray : .orange, radius: isButtonDisabled ? 0 : 8, x: 0, y: 0)
                        
                        Text("OR")
                            .padding(.top, 50)
                            .font(.system(.title3, design: .rounded))
                            .foregroundColor(.gray)
                        
                        
                        //add google photo
                        Button {
                            
                        } label: {
                            Image("google")
                                .resizable()
                                .frame(width: 32, height: 32)
                        }
                        .foregroundColor(.brown)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 35)
                                .stroke(Color.brown, lineWidth: 2)
                        )
                        .background(.clear)
                        
                        .cornerRadius(35)
                        .padding(.top, 50)

                        
                        
                    }
                    Spacer()
                }
                if isShowAlert{
                    GeometryReader{ geometry in
                        customAlert(show: $isShowAlert)
                            .position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).midY)
                            
                    }.background(Color.white.opacity(0.65))
                        .edgesIgnoringSafeArea(.all)
                    
                }
            }
//        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}


