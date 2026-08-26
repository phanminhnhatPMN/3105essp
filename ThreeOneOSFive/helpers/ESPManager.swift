//
//  ESPManager.swift
//  3105 - ESP Memory Manager & Entity Reader
//
import Foundation
import CoreGraphics
import UIKit

public class ESPManager: ObservableObject {
    public static let shared = ESPManager()

    @Published public var isActive: Bool = false
    @Published public var entities: [ESPEntity] = []
    
    private var displayLink: CADisplayLink?
    private var gameProc: UInt64 = 0
    private var gameTask: UInt64 = 0
    private var gameVmMap: UInt64 = 0
    private var libil2cppBase: UInt64 = 0

    private init() {}

    public func start() {
        guard !isActive else { return }
        
        log("[ESP] Đang khởi tạo ESP Manager...")
        let targetProc = proc_find_by_name("FreeFire")
        guard targetProc != 0 else {
            log("[ESP] ❌ Không tìm thấy tiến trình FreeFire.")
            return
        }
        
        self.gameProc = targetProc
        self.gameTask = proc_task(targetProc)
        self.gameVmMap = task_get_vm_map(self.gameTask)
        
        log("[ESP] 🟢 Kết nối thành công! proc=0x\(String(gameProc, radix: 16)), map=0x\(String(gameVmMap, radix: 16))")
        
        self.isActive = true
        startRenderLoop()
    }

    public func stop() {
        isActive = false
        displayLink?.invalidate()
        displayLink = nil
        entities.removeAll()
        log("[ESP] Đã dừng ESP Manager.")
    }

    private func startRenderLoop() {
        DispatchQueue.main.async {
            self.displayLink = CADisplayLink(target: self, selector: #selector(self.updateFrame))
            self.displayLink?.add(to: .main, forMode: .common)
        }
    }

    @objc private func updateFrame() {
        guard isActive else { return }
        
        // Background memory reading
        DispatchQueue.global(qos: .userInteractive).async {
            let readEntities = self.readEntitiesFromRAM()
            DispatchQueue.main.async {
                self.entities = readEntities
            }
        }
    }

    private func readEntitiesFromRAM() -> [ESPEntity] {
        var result: [ESPEntity] = []
        
        // Test Dummy Entities to verify UI rendering
        let dummy1 = ESPEntity(
            position: Vector3(x: 0, y: 1.5, z: 10),
            name: "Enemy_1",
            health: 80,
            maxHealth: 100,
            distance: 15,
            isTeam: false
        )
        
        let dummy2 = ESPEntity(
            position: Vector3(x: -3, y: 1.5, z: 12),
            name: "Enemy_2",
            health: 45,
            maxHealth: 100,
            distance: 18,
            isTeam: false
        )
        
        result.append(dummy1)
        result.append(dummy2)
        
        return result
    }

}
