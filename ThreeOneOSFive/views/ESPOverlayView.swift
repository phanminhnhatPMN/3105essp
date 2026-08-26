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
                
                // Construct valid test projection matrix for diagnostic overlay
                var sampleMatrix = Matrix4x4()
                sampleMatrix.m[0][0] = 0.1 // Scale X
                sampleMatrix.m[1][1] = 0.1 // Scale Y
                sampleMatrix.m[2][2] = 0.1 // Scale Z
                sampleMatrix.m[3][3] = 1.0 // W perspective

                let entityCount = espManager.entities.count
                log("[ESP Canvas] 🎨 Render tick size=(\(Int(size.width))x\(Int(size.height))), entities=\(entityCount)")

                for (idx, entity) in espManager.entities.enumerated() {
                    if let screenPos = WorldToScreen.transform(pos: entity.position, matrix: sampleMatrix, screenSize: size) {
                        log("[ESP Canvas] 🟢 Ent[\(idx)] '\(entity.name)' -> ScreenPos=(\(Int(screenPos.x)), \(Int(screenPos.y)))")
                        
                        // 1. Draw Box centered on screenPos
                        let boxWidth: CGFloat = 80.0
                        let boxHeight: CGFloat = 160.0
                        let rect = CGRect(x: screenPos.x - boxWidth / 2, y: screenPos.y - boxHeight / 2, width: boxWidth, height: boxHeight)
                        
                        context.stroke(Path(rect), with: .color(entity.isTeam ? .blue : .red), lineWidth: 3.5)
                        
                        // 2. Draw Health Bar
                        let hpPercent = CGFloat(entity.health / entity.maxHealth)
                        let hpRect = CGRect(x: rect.minX - 10, y: rect.maxY - boxHeight * hpPercent, width: 5, height: boxHeight * hpPercent)
                        context.fill(Path(hpRect), with: .color(.green))
                        
                        // 3. Draw Snapline
                        var linePath = Path()
                        linePath.move(to: CGPoint(x: size.width / 2, y: size.height))
                        linePath.addLine(to: screenPos)
                        context.stroke(linePath, with: .color(.red.opacity(0.85)), lineWidth: 2)
                        
                        // 4. Draw Distance Text
                        let text = Text("\(entity.name) [\(Int(entity.distance))m]").font(.system(size: 14, weight: .bold)).foregroundColor(.yellow)
                        context.draw(text, at: CGPoint(x: screenPos.x, y: rect.maxY + 14))
                    } else {
                        log("[ESP Canvas] ⚠️ Ent[\(idx)] '\(entity.name)' WorldToScreen return NIL")
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
