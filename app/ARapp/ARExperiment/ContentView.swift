//
//  ContentView.swift
//  ARExperiment
//
//  Created by David Drobny on 14/09/2024.
//

import SwiftUI
import CoreML
import ARKit
import RealityKit


struct ContentView : View {
    @State private var showSheet: Bool = false
    @State private var activeTab: Tab = .designs
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer().edgesIgnoringSafeArea(.all)
            
            TabBar()
                .frame(height: 49)
                .background(.regularMaterial)
        }
        .task {
            showSheet = true
        }
        .sheet(isPresented: $showSheet, content: {
            VStack(alignment: .leading, spacing: 10, content: {
                Text(activeTab.rawValue)
                    .font(.title2)
                    .fontWeight(.semibold)
                
//                switch activeTab {
//                    case .designs:
//                        DesignsView()
//                    case .marketPlace:
//                        MarketPlaceView()
//                    case .settings:
//                        SettingsView()
//                    case .profile:
//                        ProfileView()
//                }
            })
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .presentationDetents([.height(60), .medium, .large])
            .presentationCornerRadius(20)
            .presentationBackground(.regularMaterial)
            .presentationDragIndicator(.visible)
            .interactiveDismissDisabled()
            .presentationBackgroundInteraction(.enabled(upThrough: .large))
            .bottomMaskForSheet()
        })
    }
    
    @ViewBuilder
    func TabBar() -> some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.rawValue) {
                tab in Button(action: { activeTab = tab}, label: {
                    VStack(spacing: 2) {
                        Image(systemName: tab.symbol)
                            .font(.title2)
                        Text(tab.rawValue)
                            .font(.caption2)
                    }
                    .foregroundColor(activeTab == tab ? Color.accentColor : .gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(.rect)
                })
            }
        }
    }
}


class ARViewController: UIViewController {
    @IBOutlet var arView: ARView!
    
    @objc
    func handleTap(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: arView)
        
        let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
        
        if let firstResult = results.first {
            let anchor = ARAnchor(name: "CosmonautSuit_en", transform: firstResult.worldTransform)
            arView.session.add(anchor: anchor)
        }
        else {
            print("Object placement failed - no surface found.")
        }
    }
    
    override func viewDidLoad() {
            super.viewDidLoad()
            
            // Initialize ARView
            arView = ARView(frame: self.view.bounds)
            arView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.view.addSubview(arView)

            // Set up AR session
            setupARView()
            
            // Add tap gesture recognizer
            arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:))))
        }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        arView.session.delegate = self
        
        setupARView()
        
        arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:))))
    }
    
    
    // MARK: Setup methods
    func setupARView() {
        arView.automaticallyConfigureSession = false
        let configuration = ARWorldTrackingConfiguration()
        
        guard ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) else {
            fatalError("People occlusion is not supported on this device.")
        }

        
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.maximumNumberOfTrackedImages = 1
        configuration.environmentTexturing = .automatic
        
        // Enable people occlusion into the configuration
        configuration.frameSemantics.insert(.personSegmentationWithDepth)
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
    }
    func placeObject(named entityName: String, for anchor: ARAnchor) {
        let entity = try! ModelEntity.load(named: entityName)
        
//        entity.generateCollisionShapes(recursive: true)
//        
//        arView.installGestures([.rotation, .translation], for: entity)
        
        let anchorEntity = AnchorEntity(anchor: anchor)
        anchorEntity.addChild(entity)
        arView.scene.addAnchor(anchorEntity)
    }
}

extension ARViewController: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let anchorName = anchor.name {
                print("Anchor added: \(anchorName)")
                placeObject(named: anchorName, for: anchor)
            }
        }
    }
}

struct ARViewContainer: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ARViewController {
        return ARViewController() // Replace with your actual UIViewController
    }

    func updateUIViewController(_ uiViewController: ARViewController, context: Context) {
        // Update your UIViewController when SwiftUI state changes
    }
}


//struct ARViewContainer: UIViewRepresentable {
//        
//    func makeUIView(context: Context) -> ARView {
//        
//        // check if the device is capable of people occlusion
//        guard ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) else {
//            fatalError("People occlusion is not supported on this device.")
//        }
//        
//        // check if the reference images are available
//        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "Assets", bundle: nil) else {
//            fatalError("Missing expected markers.")
//        }
//        
//        
//        let arView = ARView(frame: .zero)
//        let configuration = ARWorldTrackingConfiguration()
//        configuration.planeDetection = [.horizontal, .vertical]
//        configuration.maximumNumberOfTrackedImages = 1
//        configuration.isLightEstimationEnabled = true
//        configuration.environmentTexturing = .automatic
//        
//        
//        
//        // detect the reference images
////        let focusImage = referenceImages.filter { $0.name == "wall_picture" }
////        configuration.detectionImages = focusImage
//        
//
//        // Enable people occlusion into the configuration
//        configuration.frameSemantics.insert(.personSegmentationWithDepth)
//        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
//
//        // Create a cube model
//        let mesh = MeshResource.generateBox(size: 0.1, cornerRadius: 0.005)
//        let material = SimpleMaterial(color: .gray, roughness: 0.15, isMetallic: true)
//        let model = ModelEntity(mesh: mesh, materials: [material])
//        model.transform.translation.y = 0.05
//        
//        // Create horizontal plane anchor for the content
//        let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
//        anchor.children.append(model)
//
//        // Add the horizontal plane anchor to the scene
//        arView.scene.anchors.append(anchor)
//
//        return arView
//        
//    }
//    
//    func updateUIView(_ uiView: ARView, context: Context) {}
//    
//}
