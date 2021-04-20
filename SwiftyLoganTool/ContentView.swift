//
//  ContentView.swift
//  SwiftyLoganTool
//
//  Created by fuyoufang on 2021/4/20.
//

import SwiftUI

enum TabViewType: Int, Identifiable {
    var id: Int { rawValue }
    case encrypt // 加密
    case decrypt // 解密
    
    var title: String {
        switch self {
       
        case .encrypt:
            return "加密"
        case .decrypt:
            return "解密"
        }
    }
}


struct ContentView: View {
    
    @State var tabViewType: TabViewType = .encrypt
    
    let tabs: [TabViewType] = [.encrypt, .decrypt]
    
    var body: some View {
        HStack {
            VStack {
                Spacer()
                ForEach(tabs) { tab in
                    if tabViewType == tab {
                        Button("\(tab.title)") {
                            guard tabViewType != tab else {
                                return
                            }
                            tabViewType = tab
                        }
                        .multilineTextAlignment(.center)
                        .buttonStyle(TabSelectButtonStyle())
                        .padding(EdgeInsets(top: 6, leading: 4, bottom: 6, trailing: 4))
                        .frame(width: 110)
                        
                    } else {
                        Button("\(tab.title)") {
                            guard tabViewType != tab else {
                                return
                            }
                            tabViewType = tab
                        }
                        .frame(width: 110)
                        .multilineTextAlignment(.center)
                        .buttonStyle(TabNormalButtonStyle())
                        .padding(EdgeInsets(top: 10, leading: 4, bottom: 10, trailing: 4))
                    }
                }
                Spacer()
            }
            .frame(width: 120)
            
            switch tabViewType {
            
            case .decrypt:
                DecryptTogView()
            case .encrypt:
                EncryptTogView()
            }
        }
        .frame(minWidth: 1000, idealWidth: 1000, minHeight: 1000, idealHeight: 1000, alignment: .center)
        
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct TabSelectButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Spacer()
            configuration.label.foregroundColor(.black)
            Spacer()
        }
        .padding(EdgeInsets(top: 20, leading: 2, bottom: 20, trailing: 2))
        .background(Color.yellow.cornerRadius(8))
        .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

struct TabNormalButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Spacer()
            configuration.label.foregroundColor(.black)
            Spacer()
        }
        .padding(EdgeInsets(top: 20, leading: 2, bottom: 20, trailing: 2))
        .background(Color.gray.cornerRadius(8))
        .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}
