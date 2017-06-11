//
//  DirectionMarkerNode.swift
//  Graviton
//
//  Created by Ben Lu on 6/1/17.
//  Copyright © 2017 Ben Lu. All rights reserved.
//

import UIKit
import SceneKit
import MathUtil

extension ObserverScene {
    class DirectionMarkerNode: BooleanFlaggedNode {
        enum Marker {
            case east
            case west
            case north
            case south

            var unitPosition: Vector3 {
                switch self {
                case .north:
                    return Vector3(1, 0, 0)
                case .south:
                    return Vector3(-1, 0, 0)
                case .east:
                    return Vector3(0, 1, 0)
                case .west:
                    return Vector3(0, -1, 0)
                }
            }

            var transparentTexture: UIImage {
                switch self {
                case .north:
                    return #imageLiteral(resourceName: "direction_marker_north")
                case .south:
                    return #imageLiteral(resourceName: "direction_marker_south")
                case .east:
                    return #imageLiteral(resourceName: "direction_marker_east")
                case .west:
                    return #imageLiteral(resourceName: "direction_marker_west")
                }
            }
        }

        private class MarkerNode: SCNNode {
            let marker: Marker

            init(marker: Marker) {
                self.marker = marker
                super.init()
            }

            required init?(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
        }

        let radius: Double
        let sideLength: Double

        /// The orientation to transform from ECEF to NED coordinate
        ///
        /// **Note**: do not use orientation property or otherwise the orientation of each marker will be wrong
        var ecefToNedOrientation: Quaternion = Quaternion.identity {
            didSet {
                self.childNodes.forEach { (node) in
                    let markerNode = node as! MarkerNode
                    node.position = SCNVector3(self.ecefToNedOrientation * markerNode.marker.unitPosition * radius)
                }
            }
        }

        init(radius: Double, sideLength: Double) {
            self.radius = radius
            self.sideLength = sideLength
            super.init(setting: .showDirectionMarkers)
            name = "direction marker"
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func setUpMarker(_ marker: Marker) {
            let plane = SCNPlane(width: CGFloat(sideLength), height: CGFloat(sideLength))
            plane.firstMaterial?.isDoubleSided = true
            plane.firstMaterial?.transparent.contents = marker.transparentTexture
            plane.firstMaterial?.diffuse.contents = #colorLiteral(red: 0.9241236663, green: 0.9842761147, blue: 1, alpha: 1)
            let node = MarkerNode(marker: marker)
            node.geometry = plane
            node.position = SCNVector3(marker.unitPosition * radius)
            node.constraints = [SCNBillboardConstraint()]
            addChildNode(node)
        }

        // MARK: - ObserverSceneElement

        override var isSetUp: Bool {
            return childNodes.count > 0
        }

        override func setUpElement() {
            setUpMarker(.north)
            setUpMarker(.south)
            setUpMarker(.east)
            setUpMarker(.west)
        }

        override func removeElement() {
            childNodes.forEach { $0.removeFromParentNode() }
        }

        override func hideElement() {
            childNodes.forEach { $0.isHidden = true }
        }

        override func showElement() {
            childNodes.forEach { node in
                node.constraints = [SCNBillboardConstraint()]
                node.isHidden = false
            }
        }
    }
}