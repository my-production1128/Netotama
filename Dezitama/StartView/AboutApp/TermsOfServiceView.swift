import SwiftUI

// MARK: - Terms of Service Views
// 利用規約の各条項を表示するための再利用可能なView
struct TermSectionView: View {
    let title: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .padding(.top)

            Text(content)
                .font(.body)
                .lineSpacing(5)
        }
    }
}

// 利用規約全体を表示するメインのView
struct TermsOfServiceView: View {
    var body: some View {
        ZStack{
            Image("dejitama_startbackground")
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width,
                           height: UIScreen.main.bounds.height)
                .ignoresSafeArea()

        ScrollView{
            VStack(alignment: .center, spacing: 4) {
                Text("利用規約")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("ネトたま～コニーのネット大冒険 ～")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom)

            VStack(alignment:.leading, spacing: 16){

                Text("本規約は、熊本県立大学総合管理学部飯村研究室（以下「本研究室」という。）が提供するスマートフォンアプリケーション「ネトたま～コニーのネット大冒険～」（以下「本アプリ」という。）の利用に関する諸規定を定めるものです。本アプリをインストールする前に本規約をご確認いただき、内容をご理解・ご同意の上で本アプリをご利用ください。")
                    .font(.body)
                    .lineSpacing(5)
                    .padding(.bottom)

                TermSectionView(title: "第1条 ご利用にあたって",
                                content: "利用者は、本規約の定めに従って、本アプリを利用しなければなりません。同意した方に限り、本アプリを利用できるものとします。\n本アプリを利用された場合には、本規約の内容全てに同意したものとみなされます。")

                TermSectionView(title: "第2条 登録について",
                                content: "利用者は、本アプリ所定の手続きに従い利用手続きを行うことで、本アプリの利用が可能になります。\n未成年（小学生・中学生・高校生等）の方が本アプリを利用する場合は、必ず保護者の同意を得た上でご利用ください。")

                TermSectionView(title: "第3条 著作権について",
                                content: "本アプリに係る著作権その他一切の権利は、本研究室に帰属します。\n本利用規約に基づく本アプリの提供は、利用者に対する本アプリの著作権その他いかなる権利の移転または実施権の許諾を伴うものではありません。")

                TermSectionView(title: "第4条 免責事項について",
                                content: "1. 本研究室は、利用者に対し、本アプリの一切の動作保証を行わず、いかなる瑕疵担保責任も負いません\n2. 通信環境の状況、システム障害、メンテナンス、端末の設定等により、本アプリの情報が正しく表示されない場合があります。それにより利用者が損害を被ったとしても、本研究室は一切の責任を負いません。\n3. 利用者に事前に通知することなく、本アプリを変更、中断、終了することがあります。これによって利用者が損害を被ったとしても、本研究室は一切の責任を負いません。\n本アプリの利用により利用者が事故やトラブルに遭遇した場合も、本研究室は責任を負いません。\n4. 本アプリの利用により利用者が事故やトラブルに遭遇した場合も、本研究室は責任を負いません。\n5. 本アプリの利用料金は無料とします。ただし、通信料や端末利用料は利用者が負担するものとします。")

                TermSectionView(title: "第5条 禁止事項について",
                                content: "利用者は、本アプリの利用に際して、以下の行為を行ってはならないものとします。\n1. 本アプリの複製、改変、転用、頒布、リバースエンジニアリング等の行為\n2. 本アプリの運営・提供を妨害する行為\n3. 他の利用者や第三者に迷惑・不利益を与える行為\n4. 法률や公序良俗に反する行為\n5. その他、本研究室が不適切と判断する行為")

                TermSectionView(title: "第6条 本規約の変更について",
                                content: "本規約は、必要に応じて改定する場合があり、利用者はこれを承諾するものとします。本アプリをご利用の際は、アプリ内に記載されている最新の利用規約をご確認下さい。")

                VStack(alignment: .leading, spacing: 8) {
                    Divider().padding(.vertical)
                    Text("最終更新日：2025年11月7日")
                    Text("運営者：熊本県立大学総合管理学部飯村研究室")
                    Text("所在地：〒862-8502 熊本県熊本市東区月出３丁目１−１００")
                    Text("連絡先メール：apps@ilab.pu-kumamoto.ac.jp")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top)
            }
            .padding()
        }
    }
}
}

#Preview {
    TermsOfServiceView()
}
