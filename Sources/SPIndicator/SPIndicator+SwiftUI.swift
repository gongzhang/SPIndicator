//
//  SPIndicator+SwiftUI.swift
//  
//
//  Created by Gong Zhang on 2023/3/14.
//

import SwiftUI

#if os(iOS) // tvOS may work, but not tested

@available(iOS 13.0, *)
@available(iOSApplicationExtension, unavailable)
fileprivate struct SPIndicatorRepresentable: UIViewRepresentable {
    
    @Binding var isPresented: Bool
    
    var title: String
    var message: String?
    var preset: SPIndicatorIconPreset?
    var haptic: SPIndicatorHaptic
    var presentSide: SPIndicatorPresentSide
    var customize: (SPIndicatorView) -> ()
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> WindowDetector {
        WindowDetector { window in
            toggle(context.coordinator, in: window)
        }
    }
    
    func updateUIView(_ view: WindowDetector, context: Context) {
        if let window = view.window {
            toggle(context.coordinator, in: window)
        }
    }
    
    private func toggle(_ coordinator: Coordinator, in window: UIWindow) {
        if isPresented && coordinator.indicatorView == nil {
            let alertView: SPIndicatorView
            if let preset {
                alertView = SPIndicatorView(title: title, message: message, preset: preset)
            } else {
                alertView = SPIndicatorView(title: title, message: message)
            }
            alertView.presentWindow = window
            alertView.presentSide = presentSide
            
            customize(alertView)
            coordinator.indicatorView = alertView
            
            alertView.present(haptic: haptic) {
                isPresented = false
            }
            
        } else if let view = coordinator.indicatorView, !isPresented {
            coordinator.indicatorView = nil
            view.dismiss()
        }
    }
    
    static func dismantleUIView(_ uiView: WindowDetector, coordinator: Coordinator) {
    }
    
    @available(iOS 16.0, *)
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: WindowDetector, context: Context) -> CGSize? {
        nil
    }
    
    // MARK: -
    
    final class Coordinator {
        weak var indicatorView: SPIndicatorView? = nil
    }
    
    final class WindowDetector: UIView {
        let action: (UIWindow) -> ()
        
        init(action: @escaping (UIWindow) -> ()) {
            self.action = action
            super.init(frame: .zero)
            backgroundColor = .clear
            isUserInteractionEnabled = false
        }
        
        required init?(coder: NSCoder) {
            fatalError()
        }
        
        override func willMove(toWindow newWindow: UIWindow?) {
            super.willMove(toWindow: newWindow)
            if let window = newWindow {
                action(window)
            }
        }
    }
    
}

@available(iOS 13.0, *)
@available(iOSApplicationExtension, unavailable)
extension View {
    
    /**
     SPIndicator: Present alert with preset and custom haptic.
     
     - parameter isPresented: Show/hide the indicator.
     - parameter title: Title text in alert.
     - parameter message: Subtitle text in alert. Optional.
     - parameter preset: Icon ready-use style or custom image.
     - parameter haptic: Haptic response with present. Default is `.success`.
     - parameter presentSide: Choose from side appear indicator.
     - parameter customize: A block that let you customize the `SPIndicatorView`.
     */
    public func spIndicator(isPresented: Binding<Bool>, title: String, message: String? = nil, preset: SPIndicatorIconPreset? = nil, haptic: SPIndicatorHaptic, from presentSide: SPIndicatorPresentSide = .top, customize: @escaping (SPIndicatorView) -> () = { _ in }) -> some View {
        self.background(
            SPIndicatorRepresentable(isPresented: isPresented, title: title, message: message, preset: preset, haptic: haptic, presentSide: presentSide, customize: customize)
        )
    }
    
    /**
     SPIndicator: Present alert with preset and custom haptic.
     
     - parameter isPresented: Show/hide the indicator.
     - parameter title: Title text in alert.
     - parameter message: Subtitle text in alert. Optional.
     - parameter preset: Icon ready-use style or custom image.
     - parameter presentSide: Choose from side appear indicator.
     - parameter customize: A block that let you customize the `SPIndicatorView`.
     */
    public func spIndicator(isPresented: Binding<Bool>, title: String, message: String? = nil, preset: SPIndicatorIconPreset, from presentSide: SPIndicatorPresentSide = .top, customize: @escaping (SPIndicatorView) -> () = { _ in }) -> some View {
        self.background(
            SPIndicatorRepresentable(isPresented: isPresented, title: title, message: message, preset: preset, haptic: preset.getHaptic(), presentSide: presentSide, customize: customize)
        )
    }
    
}

@available(iOS 15.0, *)
struct SPIndicator_Previews: PreviewProvider {
    struct Preview: View {
        
        @State private var isPresented = false
        @State private var duration: TimeInterval = 0.5
        
        var body: some View {
            VStack {
                Text("Duration: \(duration, format: .number.precision(.fractionLength(1)))")
                Slider(value: $duration, in: 0.1...2.0)
                
                Button(isPresented ? "Hide" : "Show", action: { isPresented.toggle() })
                    .spIndicator(isPresented: $isPresented, title: "Hello", message: "World", preset: .done, haptic: .none) {
                        $0.duration = duration
                    }
            }
            .padding()
        }
        
    }
    
    static var previews: some View {
        Preview()
    }
}

#endif
