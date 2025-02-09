import MapKit
import SwiftUI

struct FlashingMarker: View {
    @State private var scale: CGFloat = 1.0

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 20, height: 20)
                .shadow(radius: 3)
            Circle()
                .fill(Color.black)
                .frame(width: 16, height: 16)
                .scaleEffect(scale)
                .animation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true), value: scale)
        }
        .onAppear {
            if scale == 1.0 {
                scale = 0.6
            }
        }
    }
}

struct CarAnnotation: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
}

struct TitleOverlay: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: geometry.size.width * 0.5, y: 0))
                    path.addLine(to: CGPoint(x: geometry.size.width * 0.4, y: 50))
                    path.addLine(to: CGPoint(x: 0, y: 50))
                }
                .fill(LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.99), Color.black.opacity(1)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .shadow(color: .white.opacity(0.3), radius: 5, x: 0, y: 5)

                Text("Sync Map")
                    .font(.custom("Helvetica Neue", size: 24)) // Helvetica Neueフォント
                    .fontWeight(.bold) // 太字
                    .foregroundColor(.white)
                    .padding(.leading, 20)
                    .padding(.top, 10)
            }
        }
        .frame(height: 50)
        .padding(.top, 44) // ステータスバーの高さ分を調整
    }
}

struct MiniScrollView: View {
    let images: [String] = ["display", "iphone", "applelogo", "app.fill", "macbook", "ipad", "airpodspro"]

    @State private var dragOffsets: [CGFloat] = Array(repeating: 0, count: 7)
    @State private var isExpanded: [Bool] = Array(repeating: false, count: 7)

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(images.indices, id: \.self) { index in
                    ZStack {
                        RoundedRectangle(cornerRadius: isExpanded[index] ? 20 : 10)
                            .fill(Color.white)
                            .frame(width: isExpanded[index] ? UIScreen.main.bounds.width * 0.9 : 60,
                                   height: isExpanded[index] ? UIScreen.main.bounds.height * 0.7 : 100)
                            .overlay(
                                Image(systemName: images[index])
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .padding(isExpanded[index] ? 30 : 10)
                                    .foregroundColor(.black)
                            )
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 5, y: 0)
                            .offset(y: dragOffsets[index])
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        if !isExpanded[index] {
                                            dragOffsets[index] = max(value.translation.height, -150)
                                        }
                                    }
                                    .onEnded { value in
                                        if value.translation.height < -80 {
                                            // 一定以上スワイプしたら最大化
                                            withAnimation(.spring()) {
                                                isExpanded[index] = true
                                                dragOffsets[index] = -UIScreen.main.bounds.height * 0.4
                                            }

                                            // 2秒後に元に戻す
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                withAnimation(.spring()) {
                                                    isExpanded[index] = false
                                                    dragOffsets[index] = 0
                                                }
                                            }
                                        } else {
                                            // 元の位置に戻す
                                            withAnimation(.spring()) {
                                                dragOffsets[index] = 0
                                            }
                                        }
                                    }
                            )
                    }
                }
            }
            .padding(.horizontal, 10)
        }
        .frame(width: 230, height: 120)
        .background(Color.black.opacity(1))
        .cornerRadius(15)
    }
}

struct DigitalDisplay: View {
    let title: String
    let value: String
    let unit: String

    var body: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(title)
                .font(.system(size: 12, weight: .regular, design: .monospaced))
                .foregroundColor(.gray)
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                Text(unit)
                    .font(.system(size: 10, weight: .regular, design: .monospaced))
            }
            .foregroundColor(.white)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var eventData: SharedEventData

    @State private var region: MKCoordinateRegion
    @State private var carAnnotation: CarAnnotation
    @State private var estimatedArrivalTime: String = "--:--"
    @State private var isMenuOpen: Bool = false // ハンバーガーメニューの開閉状態

    init() {
        let initialCoordinate = CLLocationCoordinate2D(latitude: 35.681_236, longitude: 139.767_125) // 初期位置（例: 東京駅）
        _region = State(initialValue: MKCoordinateRegion(center: initialCoordinate,
                                                         span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
        _carAnnotation = State(initialValue: CarAnnotation(coordinate: initialCoordinate))
    }

    var body: some View {
        ZStack {
            // 地図の表示
            Map(coordinateRegion: $region, annotationItems: [carAnnotation]) { item in
                MapAnnotation(coordinate: item.coordinate) {
                    FlashingMarker()
                }
            }
            .edgesIgnoringSafeArea(.all)

            // タイトル
            VStack {
                TitleOverlay()
                Spacer()

                HStack(alignment: .center, spacing: 20) {
                    MiniScrollView()

                    VStack(alignment: .trailing, spacing: 10) {
                        DigitalDisplay(title: "予想到着時刻", value: estimatedArrivalTime, unit: "")
                        DigitalDisplay(title: "現在の速度", value: String(format: "%.0f", eventData.velocity * 1), unit: "km/h")
                    }
                    .padding()
                    .background(Color.black.opacity(0.9))
                    .cornerRadius(15)
                }
                .padding()
            }

            // 右上のハンバーガーメニューアイコン
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            isMenuOpen.toggle()
                        }
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .font(.title)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .clipShape(Circle())
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 50) // ステータスバーの高さを考慮
                }
                Spacer()
            }

            // ハンバーガーメニューの表示
            if isMenuOpen {
                VStack {
                    VStack(spacing: 15) {
                        Button("オプション1") { print("オプション1選択") }
                        Button("オプション2") { print("オプション2選択") }
                        Button("閉じる") {
                            withAnimation {
                                isMenuOpen = false
                            }
                        }
                    }
                    .frame(maxWidth: 200)
                    .padding()
                    .background(Color.black.opacity(0.85))
                    .cornerRadius(15)
                    .foregroundColor(.white)
                    .padding()
                    Spacer()
                        .frame(height: 400)
                }
                .transition(.move(edge: .trailing))
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onAppear {
            eventData.startEventSubscription(clientId: "test-client")
            // 仮の到着時刻を設定
            let arrivalDate = Date().addingTimeInterval(3_600) // 1時間後
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            estimatedArrivalTime = formatter.string(from: arrivalDate)
            updateCarAnnotation() // 車の現在地を更新
        }
        .onChange(of: eventData.latitude) { _ in updateCarAnnotation() }
        .onChange(of: eventData.longitude) { _ in updateCarAnnotation() }
    }

    private func updateCarAnnotation() {
        withAnimation {
            let newCoordinate = CLLocationCoordinate2D(latitude: eventData.latitude, longitude: eventData.longitude)
            carAnnotation.coordinate = newCoordinate
            region.center = newCoordinate
        }
    }
}
