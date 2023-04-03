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
import PhotosUI
import _AuthenticationServices_SwiftUI

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
    @State private var alertText: String?
    @State private var isShowingImagePicker = false
    @State private var image: UIImage?

    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case usernameField
        case emailField
        case passwordField
        case retryPasswordField
    }

    private var signInTransition = AnyTransition.asymmetric(
        insertion: .push(from: .trailing),
        removal: .push(from: .leading)
    )

    @EnvironmentObject var viewModel: UserViewModel
    @EnvironmentObject var chattingViewModel: ChattingViewModel
    @EnvironmentObject private var presenceViewModel: PresenceViewModel
    @EnvironmentObject private var imageViewModel: ImageViewModel

    @EnvironmentObject var channelViewModel: ChannelViewModel

    @Environment(\.colorScheme) var colorScheme

    private var isButtonsWhite: Bool {
        return colorScheme == .dark
    }

    // MARK: - Body
    var body: some View {
        if !isPresentSignInView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 30) {

                    Text("Sign Up")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(.largeTitle, design: .rounded))
                        .fontWeight(.bold)
                        .padding(.leading, 10)
                        .padding()
                        .foregroundColor(.primary.opacity(0.6))

                    userImage

                    fields
                        .padding(.top, 10)

                    // MARK: buttons
                    VStack {

                        createAccountButton

                        Button("Sign In") {
                            withAnimation {
                                self.isPresentSignInView = true
                            }
                        }
                        .foregroundColor(.brown)

                        Text("OR")
                            .padding(.top, 5)
                            .font(.system(.title3, design: .rounded))
                            .foregroundColor(.gray)

                        authButtons

                    }

                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    self.clearPreviousDataBeforeSignIn()
                }
                .navigationBarHidden(true)
                .sheet(isPresented: $isShowingImagePicker, content: {
                    CustomImagePicker(onSelect: { assets in
                        parseImages(with: assets)
                    },
                                      isPresented: $isShowingImagePicker,
                                      maxAmountOfImages: 1,
                                      imagePickerModel: ImagePickerViewModel())
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.hidden)
                })
                .padding(.bottom)
            }
            .overlay {
                customAlertView
            }
            .overlay {
                loader
            }
            .background {
                Color.background
                    .ignoresSafeArea()
            }

        } else {
            SignInView(isPresented: $isPresentSignInView)
                .transition(signInTransition)
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
                        .focused($focusedField, equals: .usernameField)
                        .submitLabel(.next)
                        .keyboardType(.namePhonePad)
                        .textContentType(.name)
                        .autocorrectionDisabled()
                        .onSubmit({
                            focusedField = .emailField
                        })
                }
                HStack {
                    Image(systemName: "mail")
                        .foregroundColor(.gray)

                    TextField("Email", text: $email)
                        .focused($focusedField, equals: .emailField)
                        .submitLabel(.next)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .onSubmit({
                            focusedField = .passwordField
                        })
                }

                HStack {
                    Image(systemName: "lock")
                        .foregroundColor(.gray)
                    if self.isShowingPassword {
                        TextField("Password", text: $password)
                            .focused($focusedField, equals: .passwordField)
                            .textContentType(.password)
                            .submitLabel(.next)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                            .onSubmit {
                                focusedField = .retryPasswordField
                            }
                        Button {
                            self.isShowingPassword.toggle()
                        } label: {
                            Image(systemName: "eye.slash")
                                .foregroundColor(.gray)
                        }
                    } else {
                        SecureField("Password", text: $password)
                            .focused($focusedField, equals: .passwordField)
                            .submitLabel(.next)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                            .onSubmit {
                                focusedField = .retryPasswordField
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
                            .focused($focusedField, equals: .retryPasswordField)
                            .textContentType(.password)
                            .submitLabel(.done)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                            .onSubmit {
                                focusedField = nil
                            }

                        Button {
                            self.isShowingRetryPassword.toggle()
                        } label: {
                            Image(systemName: "eye.slash")
                                .foregroundColor(.gray)
                        }
                    } else {
                        SecureField("Re-enter", text: $retryPassword)
                            .focused($focusedField, equals: .retryPasswordField)
                            .submitLabel(.done)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                            .onSubmit({
                                focusedField = nil
                            })

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
                ZStack(alignment: .bottomTrailing) {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                        .addLightShadow()
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

    @ViewBuilder private var createAccountButton: some View {
        Button {
            createAccountTapped()
        } label: {
            Text("Create Account")
                .toButtonGradientStyle()
                .padding(.horizontal, 40)
                .opacity(isButtonDisabled ? 0.6 : 1)
                .cornerRadius(30)
                .frame(height: 60)
        }
        .onChange(of: fullName, perform: { _ in
            updateButton()
        })
        .onChange(of: email, perform: { _ in
            updateButton()
        })
        .onChange(of: password, perform: { _ in
            updateButton()
        })
        .onChange(of: retryPassword) { _ in
            updateButton()
        }
    }

    @ViewBuilder private var authButtons: some View {
        Group {
            appleButton
            googleButton
        }
        .frame(height: 60)
        .padding(.horizontal, 80)
        .padding(.bottom, 10)
    }

    @ViewBuilder private var appleButton: some View {
        VStack(spacing: 0) {
            if isButtonsWhite {
                SignInWithAppleButton(.signUp) { request in
                    let nonce =  viewModel.randomNonceString()
                    viewModel.currentNonce = nonce
                    request.requestedScopes = [.fullName, .email]
                    request.nonce = viewModel.sha256(nonce)
                } onCompletion: { result in
                    viewModel.signInWithApple(result: result) { user in
                        handleSuccessAuth(for: user)
                    }
                }
                .signInWithAppleButtonStyle(.white)
            } else {
                SignInWithAppleButton(.signUp) { request in
                    let nonce =  viewModel.randomNonceString()
                    viewModel.currentNonce = nonce
                    request.requestedScopes = [.fullName, .email]
                    request.nonce = viewModel.sha256(nonce)
                } onCompletion: { result in
                    viewModel.signInWithApple(result: result) { user in
                        handleSuccessAuth(for: user)
                    }
                }
                .signInWithAppleButtonStyle(.black)
            }
        }
    }

    @ViewBuilder private var googleButton: some View {
        CustomSocialButton(image: "google", text: "Sign up with Google", color: .secondPrimary) {
            googleButtonTapped()
        }
    }

    @ViewBuilder private var customAlertView: some View {
        if viewModel.alertText != nil {
            CustomAlert(text: $viewModel.alertText, type: .failure)
        } else if alertText != nil {
            CustomAlert(text: $alertText, type: .failure)
        }
    }

    @ViewBuilder private var loader: some View {
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

    // MARK: - functions

    private func createAccountTapped() {
        focusedField = nil
        if isButtonDisabled {
            withAnimation(.easeInOut) {
                if fullName.isEmpty {
                    alertText = "Please, type your username. (Username must be at least 4 characters long)."
                } else if fullName.count < 4 {
                    alertText = "Username must be at least 4 characters long."
                } else if email.isEmpty || !email.contains("@gmail.com") {
                    alertText = "Please, type correctly your email address. We need it to authenticate you."
                } else if password.count < 8 {
                    alertText = "Your password must be at least 8 characters long."
                } else if password != retryPassword {
                    alertText = "Your passwords aren't matching."
                }
            }
        } else {
            viewModel.signUp(username: self.fullName, email: self.email, password: self.password) { user in
                imageViewModel.saveProfileImage(image: self.image, userId: user.id)
                handleSuccessAuth(for: user)
                presenceViewModel.startSetup(user: user)
                Haptics.shared.notify(.success)
            }
        }
    }

    private func googleButtonTapped() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        let config = GIDConfiguration(clientID: clientID)

        GIDSignIn.sharedInstance.signIn(with: config, presenting: getRootViewController()) {[self] user, error in

            if error != nil {
                print("failed to signIn with google: \(error?.localizedDescription ?? "")")
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

            viewModel.signIn(credential: credential) { user in
                handleSuccessAuth(for: user)
            }

        }
    }

    private func updateButton() {
        withAnimation(.easeInOut(duration: 0.3)) {

            if fullName.isEmpty || email.isEmpty || password.isEmpty || retryPassword.isEmpty {
                isButtonDisabled = true
            } else {
                if password == retryPassword,
                   password.count >= 8,
                   email.contains("@gmail.com") || email.contains("@email.com"),
                   fullName.isValidateLengthOfName() {
                    isButtonDisabled = false
                } else {
                    isButtonDisabled = true
                }
            }
        }
    }

    private func clearPreviousDataBeforeSignIn() {
        self.viewModel.clearPreviousDataBeforeSignIn()
        self.channelViewModel.clearPreviousDataBeforeSignIn()
        self.chattingViewModel.clearDataBeforeSingIn()
    }

    func parseImages(with assets: [PHAsset]) {
        guard !assets.isEmpty else { return }
        isShowingImagePicker = false

        let manager = PHCachingImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = true

        DispatchQueue.global(qos: .userInteractive).async {
            manager.requestImage(for: assets.first ?? PHAsset(),
                                 targetSize: .init(),
                                 contentMode: .default,
                                 options: options) { image, _ in
                guard let image else { return }
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }
    }

    private func handleSuccessAuth(for user: User) {
        chattingViewModel.currentUser = user
        chattingViewModel.getChats()
        channelViewModel.currentUser = user
        channelViewModel.getChannels()
        Haptics.shared.notify(.success)
    }
}
