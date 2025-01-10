//
//  ProfileView.swift
//  EUMMEYO
//
//  Created by 김동현 on 11/27/24.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var container: DIContainer
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject var viewModel: ProfileViewModel
    
    @State private var darkMode = false
    @State private var engMode = false

    
    // 예제 데이터: 날짜별 활동량 (0~5)
    let activityData: [Date: Int] = {
        var data = [Date: Int]()
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -364, to: Date())! // 1년 전부터 시작
        for i in 0..<365 {
            let date = calendar.date(byAdding: .day, value: i, to: startDate)!
            data[date] = Int.random(in: 0...5)
        }
        return data
    }()
    
    // 색상 팔레트: 활동량에 따라 다르게 설정
    func color(for level: Int) -> Color {
        switch level {
        case 0: return Color.gray.opacity(0.2)
        case 1: return Color.green.opacity(0.4)
        case 2: return Color.green.opacity(0.6)
        case 3: return Color.green.opacity(0.8)
        case 4: return Color.green.opacity(0.9)
        default: return Color.green
        }
    }
    
    func convertStringToUIImage(_ base64String: String) -> UIImage? {
        // Decode Base64 string to Data
        guard let imageData = Data(base64Encoded: base64String) else { return nil }
        // Create UIImage from Data
        return UIImage(data: imageData)
    }
    
    // 요일 이름 (월, 화, ...)
    let weekdays = ["월", "화", "수", "목", "금", "토", "일"]
    
    // 날짜 정렬 함수: 일요일부터 시작
    func sortedDates() -> [Date] {
        let calendar = Calendar.current
        return activityData.keys.sorted { $0 < $1 }.filter { calendar.component(.weekday, from: $0) == 1 || true }
    }

    
    var body: some View {
        VStack {
            
            HeaderView()
        }
    }
    
    func HeaderView() -> some View {
        NavigationView {
            VStack(){
                HStack {
                    Button {
                        withAnimation(.spring(duration: 1)) {
                            darkMode.toggle()
                        }
                    } label: {
                        Image(systemName: darkMode ? "sun.max.fill" : "moon")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color.black)
                            .overlay {
                                Circle()
                                    .stroke(lineWidth: 0.5)
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.black)
                            }
                    }
                    
                    
                    Button {
                        withAnimation(.spring(duration: 1)) {
                            engMode.toggle()
                        }
                    } label: {
                        Image(systemName: engMode ? "a.circle.fill" : "swedishkronasign.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 30, height: 30)
                            .foregroundColor(Color.black)
                    }
                    .padding(.leading,10)
                }
                .hTrailing()
                .padding(.trailing, 32)
                .padding(.bottom)
                
                NavigationLink(destination: SetProfileView(viewModel: viewModel, name: viewModel.userInfo?.nickname ?? "이름", img2Str: viewModel.userInfo?.profile ?? "DOGE")) {
                    HStack(alignment: .center, spacing: 10) {
                        Image(uiImage: convertStringToUIImage(viewModel.userInfo?.profile ?? "DOGE") ?? .DOGE)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())

                        VStack(alignment: .trailing) {
                            Text(viewModel.userInfo?.nickname ?? "이름")
                                .font(.system(size: 30))
                                .fontWeight(.bold)

                            Text("음메요와 함께한지 2500일 째")
                                .font(.system(size: 15))
                                .foregroundStyle(Color.black)
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

                
                ShowJandiesView()
                    .padding()
                
                FooterView()
                
                Spacer()
            }
        }
    }
    
    
    func ShowJandiesView() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack {
                VStack(alignment: .leading) {
                    ForEach(weekdays, id: \.self) { day in
                        Text(day)
                            .font(.system(size: 22))
                            .font(.subheadline.bold())
                    }
                    .frame(height: 22)
                }
                
                // 잔디 그리드
                LazyHGrid(rows: Array(repeating: GridItem(.fixed(25), spacing: 4), count: 7), spacing: 4) {
                    ForEach(sortedDates(), id: \.self) { date in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(color(for: activityData[date] ?? 0))
                            .frame(width: 25, height: 25)
                            .onTapGesture {
                                print("Date: \(date), Activity: \(activityData[date] ?? 0)")
                            }
                    }
                }
            }
            
        }
    }
    
    func NotiListView() -> some View {
        Text("Notiview")
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
                    .frame(width: 90, height: 30)
                    .padding(.vertical, 5)
                    .padding(.horizontal,10)
                    .overlay{
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(lineWidth: 1)
                            .foregroundColor(Color.mainBlack)
                    }
                }
                
                NavigationLink(destination: NotiListView()){
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
                    .frame(width: 90, height: 30)
                    .padding(.vertical, 5)
                    .padding(.horizontal,10)
                    .overlay{
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(lineWidth: 1)
                            .foregroundColor(Color.mainBlack)
                    }
                }
                
                Button {
                    
                    //TODO: 고쳐야댐
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
                .frame(width: 90, height: 30)
                .padding(.vertical, 5)
                .padding(.horizontal,10)
                .overlay{
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(lineWidth: 1)
                        .foregroundColor(Color.mainBlack)
                }
            }
            
            Spacer()
            
            Text("음메요 v1.0.0")
                .foregroundColor(Color.mainBlack)
                .font(.system(size: 16))
                .fontWeight(.light)
            
            Button {
                
            } label: {
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

// dimiss 하기위해서는 struct형태의 뷰가 필요
struct SetProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ProfileViewModel
    @State var name: String
    
    @State var img2Str: String = ""
    @State var restored: UIImage? = nil
    @State var image: UIImage = .COW
    @State var color: Color = .black
    var images: [UIImage] = [.DOGE, .COW, .user1, .user2]
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
            
            Image(uiImage: convertStringToUIImage(img2Str) ?? .DOGE)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 200, height: 200)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(lineWidth: 1.5)
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
        ProfileView(viewModel: .init(container: Self.container, userId: "user1_id"))
    }
}

