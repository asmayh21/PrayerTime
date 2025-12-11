import SwiftUI

struct QiblaView: View {
    @State private var currentGradient: [Color] = []
    @StateObject private var viewModel = QiblaViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var backgroundType: BackgroundType = {
            return initialBackgroundType()
        }()
    var body: some View {
        ZStack {
            createBackgroundGradient(for: backgroundType)
            .ignoresSafeArea()
            
            VStack(spacing: 66){
                Spacer()
                
         //       Spacer()
                HStack {
                    Text("القبلة")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                }
                Spacer()
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 350, height: 350)
                      //  .padding(.top,-88)

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
