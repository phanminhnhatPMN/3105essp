//
//  ESPMath.swift
//  3105 - ESP Matrix & World-To-Screen Transformations
//
import Foundation
import CoreGraphics
import UIKit

public struct Vector3 {
    public var x: Float
    public var y: Float
    public var z: Float

    public init(x: Float = 0, y: Float = 0, z: Float = 0) {
        self.x = x
        self.y = y
        self.z = z
    }
}

public struct Matrix4x4 {
    public var m: [[Float]] = Array(repeating: Array(repeating: 0, count: 4), count: 4)

    public init() {}
}

public struct ESPEntity {
    public var position: Vector3
    public var name: String
    public var health: Float
    public var maxHealth: Float
    public var distance: Float
    public var isTeam: Bool

    public init(position: Vector3, name: String = "Enemy", health: Float = 100, maxHealth: Float = 100, distance: Float = 0, isTeam: Bool = false) {
        self.position = position
        self.name = name
        self.health = health
        self.maxHealth = maxHealth
        self.distance = distance
        self.isTeam = isTeam
    }
}

public enum WorldToScreen {
    /// World to Screen Transformation using 4x4 ViewMatrix
    public static func transform(pos: Vector3, matrix: Matrix4x4, screenSize: CGSize) -> CGPoint? {
        let m = matrix.m
        
        let w = pos.x * m[0][3] + pos.y * m[1][3] + pos.z * m[2][3] + m[3][3]
        guard w > 0.01 else { return nil }

        let x = pos.x * m[0][0] + pos.y * m[1][0] + pos.z * m[2][0] + m[3][0]
        let y = pos.x * m[0][1] + pos.y * m[1][1] + pos.z * m[2][1] + m[3][1]

        let screenWidth = Float(screenSize.width)
        let screenHeight = Float(screenSize.height)

        let screenX = (screenWidth / 2.0) * (1.0 + x / w)
        let screenY = (screenHeight / 2.0) * (1.0 - y / w)

        return CGPoint(x: CGFloat(screenX), y: CGFloat(screenY))
    }
}

