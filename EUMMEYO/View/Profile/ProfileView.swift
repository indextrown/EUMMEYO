//
//  ProfileView.swift
//  EUMMEYO
//
//  Created by 김동현 on 11/27/24.
//

import SwiftUI
import WebKit

struct ProfileView: View {
    
    @AppStorage("isDarkMode") private var isDarkMode = false    // 다크모드 상태 가져오기
    @EnvironmentObject var container: DIContainer
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject var profileViewModel: ProfileViewModel
    
    // 회원 탈퇴 재확인 알람
    @State private var showDeleteUserAlarm: Bool = false

    var body: some View {
        VStack {
            HeaderView()
        }
        .onAppear {
            profileViewModel.getUserInfo()
        }
    }
    
    func HeaderView() -> some View {
        NavigationView {
            VStack(){
                HStack {
                    Button {
                        withAnimation(.spring(duration: 1)) {
                            isDarkMode.toggle()
                        }
                        
                        // 진동 발생
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        
                    } label: {
                        Image(systemName: isDarkMode ? "sun.max.fill" : "moon")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 20, height: 20)
                            .foregroundColor(.mainBlack)
                            .overlay {
                                Circle()
                                    .stroke(lineWidth: 0.5)
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.mainBlack)
                            }
                    }
                }
                .hTrailing()
                .padding(.trailing, 32)
                .padding(.bottom)
                
                NavigationLink(destination: SetProfileView(viewModel: profileViewModel, name: profileViewModel.userInfo?.nickname ?? "이름", img2Str: profileViewModel.userInfo?.profile ?? "EUMMEYO_0")) {
                    HStack(alignment: .center, spacing: 10) {
                        Image(uiImage: profileViewModel.convertStringToUIImage(profileViewModel.userInfo?.profile ?? "EUMMEYO_0") ?? .EUMMEYO_0)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                        
                        VStack(alignment: .trailing) {
                            Text(profileViewModel.userInfo?.nickname ?? "이름")
                                .font(.system(size: 30))
                                .fontWeight(.bold)
                                .foregroundColor(Color.mainBlack)
                            
                            
                            if let registerDate = profileViewModel.userInfo?.registerDate {
                                Text("음메요와 함께한지 \(profileViewModel.calculateDaySince(registerDate))일 째")
                                    .font(.system(size: 15))
                                    .foregroundStyle(Color.mainBlack)
                            }
                        }
                        .hTrailing()
                        
                    }
                    .foregroundColor(.black)
                    .padding()
                    .padding(.horizontal)
                    .overlay{
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(lineWidth: 1)
                            .foregroundColor(Color.mainBlack)
                    }
                    .padding(.horizontal)
                }
                
                ShowJandiesView(viewModel: profileViewModel)
                //ShowJandiesView()
                    .padding()
                
                FooterView()
                
                Spacer()
            }
        }
        .alert(isPresented: $showDeleteUserAlarm) {
            Alert(
                title: Text("계정 삭제"),
                message: Text("정말로 계정울 삭제하시겠습니까?"),
                primaryButton: .destructive(Text("삭제")) {
                    authViewModel.send(action: .deleteUser)
                },
                secondaryButton: .cancel()
            )
        }
    }

    func FooterView() -> some View {
        VStack {
            HStack(spacing: 20) {
                NavigationLink(destination: OnboardingView(onboardingViewModel: .init())) {
                    HStack {
                        Image(systemName: "info.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20)
                            .foregroundColor(Color.mainBlack)
                        Text("앱설명")
                            .foregroundColor(Color.mainBlack)
                            .font(.subheadline.bold())
                    }
                    .profileButtonStyle()
                }
                
                NavigationLink(destination: webView(url: profileViewModel.infoUrl)){
                    HStack {
                        Image(systemName: "bell.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20)
                            .foregroundColor(Color.mainBlack)
                        
                        Text("공지사항")
                            .foregroundColor(Color.mainBlack)
                            .font(.subheadline.bold())
                    }
                    .profileButtonStyle()
                }
                
                Button {
                    authViewModel.send(action: .logout)
                } label: {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20)
                        .foregroundColor(Color.mainBlack)
                    
                    
                    Text("로그아웃")
                        .foregroundColor(Color.mainBlack)
                        .font(.subheadline.bold())
                }
                .profileButtonStyle()
            }
            
            Spacer()
                .frame(height: 10)
            
            Button {
                showDeleteUserAlarm.toggle()
            } label: {
                Image(systemName: "trash")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20)
                    .foregroundColor(Color.mainBlack)
                
                
                Text("회원탈퇴")
                    .foregroundColor(Color.mainBlack)
                    .font(.subheadline.bold())
            }
            .profileButtonStyle()
            
            Spacer()
            
            Text("음메요 v1.0.0")
                .foregroundColor(Color.mainBlack)
                .font(.system(size: 16))
                .fontWeight(.light)
            
            
            NavigationLink(destination: webView(url: profileViewModel.policyUrl)){
                Text("개인정보처리방침")
                    .foregroundColor(Color.mainBlack)
                    .underline()
                    .font(.system(size: 16))
                    .fontWeight(.light)
            }
            
            Spacer()
        }
    }
}

struct ShowJandiesView: View {
    @ObservedObject var viewModel: ProfileViewModel
    // 요일 이름 (월, 화, ...)
    let weekdays = ["Tue", "Thu", "Sat"]

    var body: some View {
        HStack {
            VStack {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.subheadline.bold())
                        .padding(.bottom ,25)
                }
            }
            ScrollView(.horizontal) {
                LazyHGrid(rows: Array(repeating: GridItem(.fixed(25), spacing: 3), count: 7), spacing: 3) {
                    ForEach(0..<100, id: \.self) { col in
                        ForEach(0..<100, id: \.self) { row in
                            if row < 7, col < 53 {
                                let date = viewModel.sortedJandies[row][col]
                                let userJandies = viewModel.userJandies[date]
                                let color = viewModel.color(for: userJandies ?? 0)
                                
                                Rectangle()
                                    .fill(color)
                                    .frame(width: 25, height: 25)
                                    .cornerRadius(2)
                                    .onTapGesture {
                                        print("\(date) : \(userJandies ?? 0)")
                                    }
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }
}

struct webView: UIViewRepresentable {
    
    var url: String
    
    func makeUIView(context: Context) -> WKWebView {
        // unwrapping
        guard let url = URL(string:  self.url) else {
            return WKWebView()
        }
        
        // webview instance
        let webview = WKWebView()
        // webview load
        webview.load(URLRequest(url: url))
        
        return webview
    }
    
    // update UIView
    func updateUIView(_ uiView: WKWebView, context: Context) {
        
    }
}


// dimiss 하기위해서는 struct형태의 뷰가 필요
struct SetProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ProfileViewModel
    @State var name: String
    
    @State var img2Str: String = ""
    @State var restored: UIImage? = nil
    @State var image: UIImage = .EUMMEYO_0
    @State var color: Color = .black
    var images: [UIImage] = [.EUMMEYO_0, .EUMMEYO_1, .EUMMEYO_2, .EUMMEYO_3, .EUMMEYO_4]
    var colors: [Color] = [.red, .orange, .yellow, .green, .blue, .indigo, .purple, .pink, .brown, .cyan]
    
    func convertUIImageToString(_ image: UIImage) -> String? {
        // Convert UIImage to JPEG data with compression quality
        guard let imageData = image.jpegData(compressionQuality: 1.0) else { return nil }
        // Encode Data to Base64 string
        let base64String = imageData.base64EncodedString()
        return base64String
    }
    func convertStringToUIImage(_ base64String: String) -> UIImage? {
        // Decode Base64 string to Data
        guard let imageData = Data(base64Encoded: base64String) else { return nil }
        // Create UIImage from Data
        return UIImage(data: imageData)
    }
    
    var body: some View {
        VStack() {
            
            Image(uiImage: convertStringToUIImage(img2Str) ?? .EUMMEYO_0)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 200, height: 200)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(lineWidth: 3)
                        .foregroundColor(color)
                }
            
            TextField("이름", text: $name)
                .frame(width: 50,height: 50,alignment: .center)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 0.1)
                        .foregroundColor(Color.mainBlack)
                }
                .padding(.bottom, 50)
            
            Rectangle()
                .stroke(lineWidth: 0.2)
                .frame(height: 1)
                .foregroundColor(Color.mainBlack)
            
            
            Text("캐릭터")
                .font(.headline)
                .hLeading()
                .padding(10)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(images, id: \.self) { num in
                        Image(uiImage: num)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100, alignment: .leading)
                            .clipShape(Circle())
                            .onTapGesture {
                                image = num
                                img2Str = convertUIImageToString(image) ?? ""
                                
                            }
                    }
                    .overlay{
                        Circle()
                            .stroke(lineWidth: 0.1)
                    }
                    
                }
            }
            .padding(.leading, 15)
            
            Text("테두리")
                .font(.headline)
                .hLeading()
                .padding(10)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(colors, id: \.self) { num in
                        Circle()
                            .frame(width: 35, height: 35, alignment: .leading)
                            .foregroundColor(num)
                            .onTapGesture {
                                color = num
                            }
                    }
                    .overlay{
                        Circle()
                            .stroke(lineWidth: 0.1)
                    }
                }
            }
            .padding(.leading, 15)
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.updateUserProfile(nick: name, photo: img2Str)
                    dismiss()
                }
                label: {
                    Text("완료")
                        .font(.system(size: 16))
                        .foregroundColor(Color.mainBlack)
                    
                }
            }
        }
        
    }
}

//#Preview {
//    ProfileView(authViewModel: AuthenticationViewModel(container: DIContainer(services: Services())))

struct ProfileView_Previews: PreviewProvider {
    static let container: DIContainer = .stub
    
    static var previews: some View {
        ProfileView(profileViewModel: .init(container: Self.container, userId: "user1_id"))
            .environmentObject(Self.container)
    }
}


// MARK: - Index
extension View {
    func profileButtonStyle() -> some View {
        self
            .frame(width: 90, height: 30)
            .padding(.vertical, 5)
            .padding(.horizontal,10)
            .overlay{
                RoundedRectangle(cornerRadius: 15)
                    .stroke(lineWidth: 1)
                    .foregroundColor(Color.mainBlack)
            }
    }
}
