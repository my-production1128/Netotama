import SwiftUI

struct TutorialView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            Color(red: 0.79, green: 0.95, blue: 0.99)
                .ignoresSafeArea()
            
            // スライド部分
            TabView(selection: $currentPage) {
                // スライド 1
                slideView(imageName: "tutrial_N01")
                    .tag(0)
                
                // スライド 2
                slideView(imageName: "tutrial_N02")
                    .tag(1)
                
                // スライド 3
                slideView(imageName: "tutrial_N03")
                    .tag(2)
                
                // スライド 4
                slideView(imageName: "tutrial_N04")
                    .tag(3)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            .ignoresSafeArea()
            
            // 上部の閉じるボタン
            VStack {
                HStack {
                    Spacer()
                    Button("×") {
                        dismiss()
                    }
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.3))
                    .clipShape(Circle())
                }
                .padding()
                Spacer()
            }
        }
    }
    
    // スライドビューを作成する関数
    func slideView(imageName: String) -> some View {
        Image(imageName)
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .ignoresSafeArea()
    }
}
