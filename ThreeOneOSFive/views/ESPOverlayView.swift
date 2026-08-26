//
//  ESPOverlayView.swift
//  3105 - Transparent High-FPS ESP Canvas & Overlay Window
//
import SwiftUI
import UIKit

public struct ESPOverlayCanvasView: View {
    @ObservedObject var espManager = ESPManager.shared
    
    public init() {}

    public var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                guard espManager.isActive else { return }
                
                // Sample Matrix & Screen Size
                let sampleMatrix = Matrix4x4()
                
                for entity in espManager.entities {
                    if let screenPos = WorldToScreen.transform(pos: entity.position, matrix: sampleMatrix, screenSize: size) {
                        
                        // 1. Draw Box
                        let boxWidth: CGFloat = 40.0
                        let boxHeight: CGFloat = 80.0
                        let rect = CGRect(x: screenPos.x - boxWidth / 2, y: screenPos.y - boxHeight / 2, width: boxWidth, height: boxHeight)
                        
                        context.stroke(Path(rect), with: .color(entity.isTeam ? .blue : .red), lineWidth: 2)
                        
                        // 2. Draw Health Bar
                        let hpPercent = CGFloat(entity.health / entity.maxHealth)
                        let hpRect = CGRect(x: rect.minX - 6, y: rect.maxY - boxHeight * hpPercent, width: 3, height: boxHeight * hpPercent)
                        context.fill(Path(hpRect), with: .color(.green))
                        
                        // 3. Draw Snapline
                        var linePath = Path()
                        linePath.move(to: CGPoint(x: size.width / 2, y: 0))
                        linePath.addLine(to: screenPos)
                        context.stroke(linePath, with: .color(.red.opacity(0.6)), lineWidth: 1)
                        
                        // 4. Draw Distance Text
                        let text = Text("\(Int(entity.distance))m").font(.system(size: 10, weight: .bold)).foregroundColor(.white)
                        context.draw(text, at: CGPoint(x: screenPos.x, y: rect.maxY + 10))
                    }
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

public class ESPOverlayWindow {
    public static let shared = ESPOverlayWindow()
    private var window: UIWindow?

    private init() {}

    public func show() {
        DispatchQueue.main.async {
            guard self.window == nil else { return }
            
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            let window = UIWindow(frame: UIScreen.main.bounds)
            if let windowScene = windowScene {
                window.windowScene = windowScene
            }
            
            window.windowLevel = .statusBar + 100
            window.backgroundColor = .clear
            window.isUserInteractionEnabled = false
            
            let controller = UIHostingController(rootView: ESPOverlayCanvasView())
            controller.view.backgroundColor = .clear
            
            window.rootViewController = controller
            window.isHidden = false
            self.window = window
            
            ESPManager.shared.start()
        }
    }

    public func hide() {
        DispatchQueue.main.async {
            ESPManager.shared.stop()
            self.window?.isHidden = true
            self.window = nil
        }
    }
}
