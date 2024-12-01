//
//  QRCodeScannerView.swift
//  ARExperiment
//
//  Created by David Drobny on 30/11/2024.
//

import SwiftUI
import AVFoundation

import SwiftUI
import AVFoundation

struct QRCodeScannerView: UIViewControllerRepresentable {
    var onCodeScanned: (String) -> Void

    func makeUIViewController(context: Context) -> ScannerViewController {
        let scannerViewController = ScannerViewController()
        scannerViewController.onCodeScanned = onCodeScanned
        return scannerViewController
    }

    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {
        // No updates needed in this case
    }

    class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
        var captureSession: AVCaptureSession!
        var previewLayer: AVCaptureVideoPreviewLayer!
        var onCodeScanned: ((String) -> Void)?

        // UI Feedback
        var feedbackLabel: UILabel!

        override func viewDidLoad() {
            super.viewDidLoad()

            // Setup Camera
            view.backgroundColor = UIColor.black
            captureSession = AVCaptureSession()

            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
                showAlert(message: "Your device does not support video input.")
                return
            }

            let videoInput: AVCaptureDeviceInput
            do {
                videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            } catch {
                showAlert(message: "Cannot access camera: \(error.localizedDescription)")
                return
            }

            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            } else {
                showAlert(message: "Failed to add video input to the capture session.")
                return
            }

            let metadataOutput = AVCaptureMetadataOutput()
            if captureSession.canAddOutput(metadataOutput) {
                captureSession.addOutput(metadataOutput)
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.qr]
            } else {
                showAlert(message: "Failed to add metadata output to the capture session.")
                return
            }

            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = view.layer.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)

            setupFeedbackLabel()

            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            if captureSession.isRunning {
                DispatchQueue.global(qos: .background).async {
                    self.captureSession.stopRunning()
                }
            }
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
                      let stringValue = readableObject.stringValue else { return }

                DispatchQueue.main.async {
                    self.feedbackLabel.text = "QR Code Found Successfully!"
                }

                captureSession.stopRunning()
                onCodeScanned?(stringValue)
            }
        }

        private func setupFeedbackLabel() {
            feedbackLabel = UILabel()
            feedbackLabel.text = "Point the camera at a QR Code"
            feedbackLabel.textColor = .white
            feedbackLabel.textAlignment = .center
            feedbackLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(feedbackLabel)

            NSLayoutConstraint.activate([
                feedbackLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
                feedbackLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                feedbackLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                feedbackLabel.heightAnchor.constraint(equalToConstant: 50)
            ])
        }

        private func showAlert(message: String) {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
}
