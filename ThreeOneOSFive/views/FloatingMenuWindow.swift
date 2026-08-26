//
//  FloatingMenuWindow.swift
//  3105 - Floating In-Game Mod Menu & Quick Launcher
//
import SwiftUI
import UIKit

public class FloatingMenuWindow {
    public static let shared = FloatingMenuWindow()
    private var window: UIWindow?
    private var isExpanded: Bool = false

    private init() {}

    public func show() {
        DispatchQueue.main.async {
            guard self.window == nil else { return }
            
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            let window = UIWindow(frame: UIScreen.main.bounds)
            if let windowScene = windowScene {
                window.windowScene = windowScene
            }
            
            window.windowLevel = .statusBar + 200
            window.backgroundColor = .clear
            
            let controller = UIHostingController(rootView: FloatingMenuView())
            controller.view.backgroundColor = .clear
            
            window.rootViewController = controller
            window.isHidden = false
            self.window = window
        }
    }

    public func hide() {
        DispatchQueue.main.async {
            self.window?.isHidden = true
            self.window = nil
        }
    }
}

public struct FloatingMenuView: View {
    @State private var isExpanded: Bool = false
    @State private var position: CGPoint = CGPoint(x: 80, y: 180)
    @ObservedObject var espManager = ESPManager.shared

    public init() {}

    public var body: some View {
        ZStack {
            if isExpanded {
                expandedMenuCard
                    .position(position)
            } else {
                floatingIconButton
                    .position(position)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }

    private var floatingIconButton: some View {
        Button {
            withAnimation(.spring()) {
                isExpanded = true
            }
        } label: {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color.orange, Color.red], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 54, height: 54)
                    .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
                
                Image(systemName: "flame.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    self.position = value.location
                }
        )
    }

    private var expandedMenuCard: some View {
        VStack(spacing: 14) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                Text("3105 ESP MENU")
                    .font(.system(size: 15, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button {
                    withAnimation(.spring()) {
                        isExpanded = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                }
            }
            .padding(.bottom, 4)
            
            Divider().background(Color.gray.opacity(0.5))
            
            // Status & Scan Button
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Game Status:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Spacer()
                    Text(espManager.isActive ? "🟢 ACTIVE" : "🔴 STOPPED")
                        .font(.caption.bold())
                        .foregroundColor(espManager.isActive ? .green : .red)
                }
                
                Button {
                    if espManager.isActive {
                        ESPOverlayWindow.shared.hide()
                        log("[ESP] 🔴 Đã tắt ESP từ Floating Menu.")
                    } else {
                        ESPOverlayWindow.shared.show()
                        log("[ESP] 🟢 Đã quét RAM & Bật ESP từ Floating Menu!")
                    }
                } label: {
                    HStack {
                        Image(systemName: espManager.isActive ? "eye.slash.fill" : "eye.fill")
                        Text(espManager.isActive ? "TẮT ESP OVERLAY" : "QUÉT RAM & BẬT ESP")
                            .font(.system(size: 13, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(espManager.isActive ? Color.red.opacity(0.8) : Color.green.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
            
            // Launch FreeFire Game Button
            Button {
                launchFreeFireGame()
            } label: {
                HStack {
                    Image(systemName: "play.fill")
                    Text("QUÉT RAM & MỞ FREE FIRE")
                        .font(.system(size: 13, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(LinearGradient(colors: [Color.orange, Color.red], startPoint: .leading, endPoint: .trailing))
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding(16)
        .frame(width: 260)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.85))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(LinearGradient(colors: [Color.orange.opacity(0.6), Color.red.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5)
                )
        )
        .shadow(color: .black.opacity(0.6), radius: 12, x: 0, y: 6)
        .gesture(
            DragGesture()
                .onChanged { value in
                    self.position = value.location
                }
        )
    }

    private func launchFreeFireGame() {
        log("[ESP] 🚀 Đang khởi chạy game FreeFire và mở ESP...")
        ESPOverlayWindow.shared.show()
        
        let schemes = ["freefire://", "freefireth://", "freefiremax://"]
        var launched = false
        
        for scheme in schemes {
            if let url = URL(string: scheme), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                launched = true
                log("[ESP] 🟢 Đã mở game thành công qua URL Scheme: \(scheme)")
                break
            }
        }
        
        if !launched {
            if let url = URL(string: "freefire://") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                log("[ESP] 🚀 Đã gửi lệnh mở FreeFire URL scheme.")
            }
        }
    }
}
