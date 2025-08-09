import SwiftUI

// MARK: - Протоколы для улучшения расширяемости

protocol ProgressDisplayable {
    var progressPercentage: Int { get }
}

protocol BackgroundProviding {
    associatedtype BackgroundContent: View
    func makeBackground() -> BackgroundContent
}

// MARK: - Расширенная структура загрузки

struct MonarchLoadingOverlay: View, ProgressDisplayable {
    let progress: Double
    @State private var pulse = false
    var progressPercentage: Int { Int(progress * 100) }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Фон: logo + затемнение
                Image("logo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .ignoresSafeArea()
                    .overlay(Color.black.opacity(0.45))

                VStack {
                    Spacer()
                    // Пульсирующий логотип
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.38)
                        .scaleEffect(pulse ? 1.02 : 0.82)
                        .shadow(color: .black.opacity(0.25), radius: 16, y: 8)
                        .animation(
                            Animation.easeInOut(duration: 1.1).repeatForever(autoreverses: true),
                            value: pulse
                        )
                        .onAppear { pulse = true }
                        .padding(.bottom, 36)
                    // Прогрессбар и проценты
                    VStack(spacing: 14) {
                        Text("Loading \(progressPercentage)%")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                            .shadow(radius: 1)
                        MonarchProgressBar(value: progress)
                            .frame(width: geo.size.width * 0.52, height: 10)
                    }
                    .padding(14)
                    .background(Color.black.opacity(0.22))
                    .cornerRadius(14)
                    .padding(.bottom, geo.size.height * 0.18)
                    Spacer()
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
    }
}

// MARK: - Фоновые представления

struct MonarchBackground: View, BackgroundProviding {
    func makeBackground() -> some View {
        Image("background")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }

    var body: some View {
        makeBackground()
    }
}

// MARK: - Индикатор прогресса с анимацией

struct MonarchProgressBar: View {
    let value: Double
    @State private var shimmerOffset: CGFloat = -200
    @State private var rotationAngle: Double = 0

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            ZStack {
                // Фоновый круг
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#2C3E50").opacity(0.3),
                                Color(hex: "#34495E").opacity(0.5),
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 8
                    )
                    .frame(width: size * 0.8, height: size * 0.8)

                // Прогрессивный круг
                Circle()
                    .trim(from: 0, to: CGFloat(value))
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(hex: "#FFD700"),
                                Color(hex: "#FFA500"),
                                Color(hex: "#FF8C00"),
                                Color(hex: "#FFD700"),
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: size * 0.8, height: size * 0.8)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: value)

                // Внутренние декоративные элементы
                ForEach(0..<12, id: \.self) { index in
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#FFD700").opacity(0.8),
                                    Color(hex: "#FFD700").opacity(0.1),
                                ]),
                                center: .center,
                                startRadius: 1,
                                endRadius: 4
                            )
                        )
                        .frame(width: 4, height: 4)
                        .offset(y: -size * 0.32)
                        .rotationEffect(.degrees(Double(index) * 30 + rotationAngle))
                        .opacity(Double(index) / 12.0 <= value ? 1 : 0.2)
                }
                .onAppear {
                    withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                        rotationAngle = 360
                    }
                }

                // Центральная корона-иконка
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "#FFD700").opacity(0.2),
                                    Color(hex: "#8B4513").opacity(0.1),
                                ]),
                                center: .center,
                                startRadius: 1,
                                endRadius: 20
                            )
                        )
                        .frame(width: 40, height: 40)

                    // Корона из точек
                    VStack(spacing: 2) {
                        HStack(spacing: 3) {
                            Circle().fill(Color(hex: "#FFD700")).frame(width: 3, height: 3)
                            Circle().fill(Color(hex: "#FFD700")).frame(width: 4, height: 4)
                            Circle().fill(Color(hex: "#FFD700")).frame(width: 3, height: 3)
                        }
                        Rectangle()
                            .fill(Color(hex: "#FFD700"))
                            .frame(width: 16, height: 2)
                    }
                    .scaleEffect(value > 0.1 ? 1.0 : 0.8)
                    .animation(.easeInOut(duration: 0.3), value: value)
                }

                // Блестящий эффект
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.clear,
                                Color.white.opacity(0.6),
                                Color.clear,
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 30, height: size * 0.9)
                    .offset(x: shimmerOffset)
                    .mask(
                        Circle()
                            .stroke(lineWidth: 8)
                            .frame(width: size * 0.8, height: size * 0.8)
                    )
                    .onAppear {
                        withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                            shimmerOffset = 200
                        }
                    }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

// MARK: - Превью

#Preview("Vertical") {
    MonarchLoadingOverlay(progress: 0.2)
}

#Preview("Horizontal") {
    MonarchLoadingOverlay(progress: 0.2)
        .previewInterfaceOrientation(.landscapeRight)
}
