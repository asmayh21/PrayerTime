import SwiftUI

struct QiblaView: View {
    @State private var currentGradient: [Color] = []
    @StateObject private var viewModel = QiblaViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: currentGradient,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 77) {
                HStack {
                    Text("القبلة")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.top,-10)
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 44)
                        .padding(.trailing, -20)
                }
                .padding(.top, 60)
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 350, height: 350)
                        .padding(.top,-88)

                    // سهم البوصلة يدور مع زاوية القبلة
                    Image(systemName: "location.north.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 130, height: 130)
                        .foregroundColor(Color.white.opacity(0.75))
                        .padding(.top,-40)
                        .rotationEffect(.degrees(viewModel.qiblaAngle))
                        .animation(.easeInOut(duration: 0.2), value: viewModel.qiblaAngle)
                    
                    // الكعبة تتحرك على محيط الدائرة حسب زاوية القبلة
                    KabaOnCircle(angle: viewModel.qiblaAngle)
                        .animation(.easeInOut(duration: 0.2), value: viewModel.qiblaAngle)
                }
                
                Spacer(minLength: 100)
            }
        }
        .onAppear {
            updateGradient()
        }
    }
    
    func updateGradient() {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 0..<6:
            currentGradient = [
                Color(red: 0.05, green: 0.08, blue: 0.12),
                Color(red: 0.08, green: 0.12, blue: 0.18),
                Color(red: 0.10, green: 0.14, blue: 0.20)
            ]
        case 6..<11, 11..<17:
            currentGradient = [
                Color(red: 0x2D/255.0, green: 0x8C/255.0, blue: 0xFF/255.0),
                Color(red: 0xD1/255.0, green: 0xE0/255.0, blue: 0xFF/255.0)
            ]
        case 17..<20:
            currentGradient = [
                Color(red: 0.65, green: 0.50, blue: 0.75),
                Color(red: 0.85, green: 0.60, blue: 0.70),
                Color(red: 0.95, green: 0.70, blue: 0.55),
                Color(red: 0.85, green: 0.55, blue: 0.40)
            ]
        default:
            currentGradient = [
                Color(red: 0.05, green: 0.08, blue: 0.12),
                Color(red: 0.08, green: 0.12, blue: 0.18),
                Color(red: 0.10, green: 0.14, blue: 0.20)
            ]
        }
    }
}

private struct KabaOnCircle: View {
    let angle: Double
    
    // اضبط نصف القطر لتعويض الـ padding/top بحيث الكعبة تكون على الحافة بصريًا
    private let radius: CGFloat = 150 // قريب من نصف 350 مع تعويض بسيط
    // تعويض بسيط للمحاذاة العمودية بسبب .padding(.top, -88) في الدائرة
    private let verticalAdjust: CGFloat = -40
    
    var body: some View {
        let radians = CGFloat((angle - 90).degreesToRadians) // -90° لجعل 0° للأعلى
        let x = radius * cos(radians)
        let y = radius * sin(radians)
        
        return Image("kaba")
            .resizable()
            .scaledToFit()
            .frame(width: 70, height: 70)
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
            .offset(x: x, y: y + verticalAdjust)
    }
}

#Preview {
    QiblaView()
}
