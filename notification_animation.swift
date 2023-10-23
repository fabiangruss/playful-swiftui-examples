import SwiftUI

// This view simulates a priming screen to show the user how notifications would look and prompt for notification permissions.
struct NotificationAnimation: View {
    // State to handle animation.
    @State private var shouldAnimate = false
    
    // Router to handle navigation.
    @EnvironmentObject var router: Router
    
    var body: some View {
        VStack {
            // Background for iPhone visual representation.
            self.iPhoneBG()
                .padding(.top, 64)
                
            // Simulated notification stack. Opacity and offset (position) are altered by the animation
            ZStack {
                // Lower notification
                self.notificationView(avatarPath: "memoji-3", title: "Check in with Johnny", subtitle: "Regular reminder", time: "4d")
                    .offset(CGSize(width: 0, height: self.shouldAnimate ? -30 : 100))
                    .scaleEffect(0.8)
                    .opacity(self.shouldAnimate ? 0.8 : 0)
                
                // Middle notification
                self.notificationView(avatarPath: "memoji-6", title: "It’s William’s birthday soon!", subtitle: "One week left for a present", time: "4h")
                    .offset(CGSize(width: 0, height: self.shouldAnimate ? -80 : 100))
                    .scaleEffect(0.9)
                    .opacity(self.shouldAnimate ? 0.9 : 0)
                
                // Top notification
                self.notificationView(avatarPath: "memoji-1", title: "Check in with Melissa", subtitle: "Regular reminder", time: "now")
                    .offset(CGSize(width: 0, height: self.shouldAnimate ? -130 : 100))
                    .opacity(self.shouldAnimate ? 1 : 0)
            }
            
            // Add a slight gradient on top to focus on the top notification more
            .overlay {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 392, height: 360)
                    .background(
                        LinearGradient(
                            stops: [
                                Gradient.Stop(color: .white.opacity(0), location: 0.00),
                                Gradient.Stop(color: .white.opacity(0), location: 0.00),
                                Gradient.Stop(color: .white.opacity(1), location: 1.00),
                            ],
                            startPoint: UnitPoint(x: 0.5, y: 0.13),
                            endPoint: UnitPoint(x: 0.5, y: 0.83)
                        )
                    )
            }
           
            Spacer()
        }
        
        // The magic happens here. Set the animation bool to true and do that with an animation
        .onAppear(perform: {
            withAnimation(Animation.bouncy(duration: 0.7).delay(0.5)) {
                self.shouldAnimate = true
            }
        })
    }
    
    // iPhone Background (Rectangle + Time + Gradient)
    @ViewBuilder
    private func iPhoneBG() -> some View {
        ZStack {
            Rectangle()
                .foregroundStyle(.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 60)
                        .stroke(Color(red: 0.87, green: 0.89, blue: 1), lineWidth: 6)
                )
                .frame(height: 280)
                .padding(.horizontal, 48)
            
            Rectangle()
                .foregroundColor(.white.opacity(0.4))
                .frame(width: 392, height: 320)
                .background(
                    LinearGradient(
                        stops: [
                            Gradient.Stop(color: .white.opacity(0), location: 0.00),
                            Gradient.Stop(color: .white.opacity(0), location: 0.00),
                            Gradient.Stop(color: .white.opacity(1), location: 1.00),
                        ],
                        startPoint: UnitPoint(x: 0.5, y: 0.13),
                        endPoint: UnitPoint(x: 0.5, y: 0.83)
                    )
                )
            
            VStack {
                Text(formatCurrentDate())
                    .font(.system(size: 16))
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.accentColorSecondary)
                    
                Text(formatCurrentTime()) // Current day
                    .font(.system(size: 76)).bold()
                    .fontDesign(.rounded)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.accentColorSecondary)
            }
        }
    }
    
    // Notification cards including image and texts
    // TODO: Use your own paths here
    @ViewBuilder
    private func notificationView(avatarPath: String? = nil, title: String? = nil, subtitle: String? = nil, time: String? = nil) -> some View {
        Rectangle()
            .foregroundColor(.clear)
            .frame(width: 326, height: 77)
            .background(Color(red: 0.98, green: 0.98, blue: 0.98))
            .cornerRadius(19)
            .shadow(color: Color(red: 0.83, green: 0.83, blue: 0.83).opacity(0.5), radius: 10, x: 0, y: 9)
            .overlay(
                RoundedRectangle(cornerRadius: 19)
                    .inset(by: 1)
                    .stroke(.midGrey, lineWidth: 2)
            )
            .overlay {
                HStack(alignment: .top, spacing: 0) {
                    if avatarPath != nil {
                        VStack {
                            Spacer()
                            ZStack(alignment: .center) {
                                Rectangle()
                                    .foregroundColor(.white)
                                    .frame(width: 52, height: 52)
                                    .cornerRadius(60)
                                
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 60)
                                            .inset(by: 0)
                                            .stroke(.white, lineWidth: 3)
                                            .shadow(color: Color(red: 0.83, green: 0.83, blue: 0.83).opacity(0.5), radius: 4, x: 0, y: 0)
                                    )
                                
                                NotificationAvatar(size: 44.0, assetName: avatarPath!)
                            }
                            .padding(.horizontal, 12)
                            
                            Spacer()
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Spacer()
                        Text(title ?? "").fontDesign(.rounded).font(.callout).fontWeight(.semibold)
                        Text(subtitle ?? "").fontDesign(.rounded).font(.subheadline).fontWeight(.medium).foregroundStyle(.greyHint)
                        Spacer()
                    }
                    Spacer()
                    
                    Text(time ?? "").fontDesign(.rounded).font(.subheadline).fontWeight(.medium).foregroundStyle(.greyHint)
                        .padding(.trailing, 16)
                        .padding(.top, 12)
                }
            }
    }
    
    private func formatCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d"
        return dateFormatter.string(from: .now)
    }
    
    private func formatCurrentTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm" // "h" for 12-hour format without leading zero, "mm" for minutes with two digits.
        return dateFormatter.string(from: Date())
    }
}

// Placeholder for Avatar, so the file can run standalone.
struct NotificationAvatar: View {
    var size: CGFloat
    var assetName: String
  
    var body: some View {
        Image(self.assetName)
            .resizable()
            .shadow(color: Color(red: 0.87, green: 0.87, blue: 0.87).opacity(0.6), radius: 5, x: 0, y: 4)
            .frame(width: self.size, height: self.size)
    }
}

#Preview {
    MainActor.assumeIsolated {
        let container = PreviewSampleData.container

        return VStack {
            NotificationAnimation()
        }
    }
}
