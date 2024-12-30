//
//  NicknameSettingView.swift
//  EUMMEYO
//
//  Created by 김동현 on 12/30/24.
//

import SwiftUI

struct NicknameSettingView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var nickname: String = ""
    
    var body: some View {
        VStack(spacing: 10) {
            Text("음메요")
                .font(.system(size: 30, weight: .bold))
                .padding(.bottom, 30)
            
            Text("회원가입에 필요한 정보를 입력해주세요")
                .font(.system(size: 24, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading) // 좌측 정렬
                
            Text("닉네임은 언제든 바꿀 수 있어요")
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading) // 좌측 정렬
                .padding(.bottom, 30)
            
            Text("닉네임")
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextField("2자 이상 20자 이하로 입력해주세요", text: $nickname)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 1.5)
                        .foregroundColor(.black)
                )
                .padding(.bottom, 30)

            
            Spacer()
            
            Button {
                authViewModel.send(action: .updateUserNickname(nickname))
            } label: {
                Text("완료")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(Color.white)
                    .background(!nickname.isEmpty ? Color.mainBlack : Color.gray)
                    .cornerRadius(10)
            }
            .disabled(nickname.isEmpty)
            
            
        }.padding(.horizontal, 25)
    }
}

#Preview {
    NicknameSettingView()
}
