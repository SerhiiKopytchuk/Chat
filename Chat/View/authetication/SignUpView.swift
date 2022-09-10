//
//  ContentView.swift
//  Chat
//
//  Created by Serhii Kopytchuk on 13.05.2022.
//

import SwiftUI
import Firebase
import GoogleSignIn
import FirebaseStorage
// Apple HIG
// Apple Human Interface Guidelines

// SF Symbols
struct SignUpView: View {

    // MARK: - vars
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var retryPassword: String = ""

    @State private var isButtonDisabled: Bool = true
    @State private var isPresentSignInView: Bool = false
    @State private var isShowingPassword: Bool = false
    @State private var isShowingRetryPassword: Bool = false
    @State private var isShowAlert = false
    @State private var isShowLoader = false
    @State private var alertText = ""
    @State private var isShowingImagePicker = false
    @State private var image: UIImage?

    @EnvironmentObject var viewModel: UserViewModel
    @EnvironmentObject var chattingViewModel: ChattingViewModel
    @ObservedObject private var editProfileViewModel = EditProfileViewModel()
    @ObservedObject private var imageViewModel = ImageViewModel()

    @EnvironmentObject var channelViewModel: ChannelViewModel

    // MARK: - Body
    var body: some View {

        ZStack {
            VStack(spacing: 30) {
                Spacer()
                HStack {
                    Text("Sign Up")
                        .font(.system(.largeTitle, design: .rounded))
                        .fontWeight(.bold)
                        .padding(.leading, 10)
                        .padding()
                        .foregroundColor(.primary.opacity(0.6))
                    Spacer()
                }

                userImage

                fields
                    .padding(.top)

                // MARK: buttons
                VStack {
                    createAccountButton

                    Button("Sign In") {
                        self.isPresentSignInView = true
                    }
                    .foregroundColor(.brown)
                    .padding(.top, 20)

                    Text("OR")
                        .padding(.top, 10)
                        .font(.system(.title3, design: .rounded))
                        .foregroundColor(.gray)

                    googleButton

                    Spacer()

                }

            }
            .background {
                NavigationLink(destination: SignInView(), isActive: $isPresentSignInView) { }

                Color.background
                    .ignoresSafeArea()
            }

            if isShowAlert || viewModel.showAlert {
                customAlertView
            }

            if viewModel.isShowLoader {
                withAnimation {
                    GeometryReader { reader in
                        Loader()
                            .position(x: reader.size.width/2, y: reader.size.height/2)
                    }.background {
                        Color.black
                            .opacity(0.65)
                            .edgesIgnoringSafeArea(.all)

                    }
                }
            }

        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $isShowingImagePicker, onDismiss: nil) {
            ImagePicker(image: $image)
        }
    }

    // MARK: - ViewBuilders

    @ViewBuilder var fields: some View {
        VStack {
            Group {
                HStack {
                    Image(systemName: "person")
                        .foregroundColor(.gray)
                    TextField("Full Name", text: $fullName)
                        .disableAutocorrection(true)
                        .onChange(of: fullName) { _ in
                            updateButton()
                        }
                }
                HStack {
                    Image(systemName: "mail")
                        .foregroundColor(.gray)
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .onChange(of: email) { _ in
                            updateButton()
                        }
                }
                HStack {
                    Image(systemName: "lock")
                        .foregroundColor(.gray)
                    if self.isShowingPassword {

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
                    } else {
                        SecureField("Password", text: $password)
                            .autocapitalization(.none)
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
                HStack {
                    Image(systemName: "lock")
                        .foregroundColor(.gray)
                    if self.isShowingRetryPassword {

                        TextField("Re-enter", text: $retryPassword)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .onChange(of: retryPassword) { _ in
                                updateButton()
                            }
                        Button {
                            self.isShowingRetryPassword.toggle()
                        } label: {
                            Image(systemName: "eye.slash")
                                .foregroundColor(.gray)
                        }
                    } else {
                        SecureField("Re-enter", text: $retryPassword)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .onChange(of: retryPassword) { _ in
                                updateButton()
                            }
                        Button {
                            self.isShowingRetryPassword.toggle()
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
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray, lineWidth: 1)
                    .padding(.leading, 10)
                    .padding(.trailing, 20)
                    .padding(5)
            )
        }
    }

    @ViewBuilder var userImage: some View {
        Button {
            isShowingImagePicker.toggle()
        } label: {
            if let image = self.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .cornerRadius(50)
                    .addLightShadow()
            } else {
                ZStack {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                        .addLightShadow()
                    VStack(alignment: .trailing) {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(systemName: "photo.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .background(Color.background)
                                .foregroundColor(.gray)
                                .cornerRadius(15)
                        }
                    }

                }
            }
        }.frame(width: 100, height: 100)
    }

    @ViewBuilder private var createAccountButton: some View {
        Button {
            if isButtonDisabled {
                withAnimation(.easeInOut) {
                    alertText = "Fill all fields properly!"
                    isShowAlert.toggle()
                }
            } else {
                if isValidatedName() {
                    viewModel.signUp(username: self.fullName, email: self.email, password: self.password) { user in
                        imageViewModel.saveProfileImage(image: self.image ?? UIImage(), userId: user.id)
                        chattingViewModel.currentUser = user
                        chattingViewModel.getChats()
                        channelViewModel.currentUser = user
                        channelViewModel.getChannels()
                    }
                }
            }
        } label: {
            Text("Create Account")
                .toButtonGradientStyle()
        }
        .padding(.horizontal, 80)
        .opacity(isButtonDisabled ? 0.6 : 1)
        .cornerRadius(30)
    }

    @ViewBuilder private var googleButton: some View {
        Button {

            guard let clientID = FirebaseApp.app()?.options.clientID else { return }

            let config = GIDConfiguration(clientID: clientID)

            GIDSignIn.sharedInstance.signIn(with: config, presenting: getRootViewController()) {[self] user, error in

                if error != nil {
                   return
                 }

                 guard
                   let authentication = user?.authentication,
                   let idToken = authentication.idToken
                 else {
                   return
                 }

                let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                                 accessToken: authentication.accessToken)

                self.clearPreviousDataBeforeSignIn()

                viewModel.signIn(credential: credential) { user in
                    chattingViewModel.currentUser = user
                    chattingViewModel.getChats()
                    channelViewModel.currentUser = user
                    channelViewModel.getChannels()
                }

            }
        } label: {
            Image("google")
                .resizable()
                .frame(width: 32, height: 32)
                .foregroundColor(.brown)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 35)
                        .stroke(Color.brown, lineWidth: 2)
                )
                .background(.clear)
                .cornerRadius(35)
                .padding(.top, 10)
        }
    }

    @ViewBuilder private var customAlertView: some View {
        GeometryReader { geometry in
            if viewModel.showAlert {
                CustomAlert(show: $isShowAlert, text: viewModel.alertText)
                    .position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).midY)
                    .frame(maxWidth: geometry.frame(in: .local).width - 20)
            } else {
                CustomAlert(show: $isShowAlert, text: alertText)
                    .position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).midY)
                    .frame(maxWidth: geometry.frame(in: .local).width - 20)
            }

        }.background(Color.black.opacity(0.65))
            .edgesIgnoringSafeArea(.all)
    }

    // MARK: - functions

    private func updateButton() {
        let time: Double = 0.3

        withAnimation(.easeInOut(duration: time)) {

            if fullName.isEmpty || email.isEmpty || password.isEmpty || retryPassword.isEmpty {
                isButtonDisabled = true
            } else {
                if password == retryPassword {
                    if password.count >= 8 {
                        if email.contains("@gmail.com") || email.contains("@email.com") {
                            if fullName.isValidateLengthOfName() {
                                isButtonDisabled = false
                            } else {
                                isButtonDisabled = true
                            }
                        } else {
                            isButtonDisabled = true
                        }
                    } else {
                        isButtonDisabled = true
                    }
                } else {
                    isButtonDisabled = true
                }
            }
        }
    }

    private func isValidatedName() -> Bool {
        fullName = fullName.trim()
        updateButton()
        if isButtonDisabled {
            withAnimation(.easeInOut) {
                alertText = "Fill all fields properly!"
                isShowAlert.toggle()
            }
            return false
        }
        return true
    }

    private func clearPreviousDataBeforeSignIn() {
        self.viewModel.clearPreviousDataBeforeSignIn()
        self.channelViewModel.clearPreviousDataBeforeSignIn()
        self.chattingViewModel.clearDataBeforeSingIn()
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView().environmentObject(UserViewModel())
.previewInterfaceOrientation(.portrait)
    }
}
