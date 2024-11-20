//
//  StatusController.swift
//  ARExperiment
//
//  Created by David Drobny on 14/11/2024.
//

import UIKit
import ARKit

class StatusViewController: UIViewController {
    // Message types to manage the AR session’s different statuses
    enum MessageType {
        case trackingStateEscalation, planeEstimation, contentPlacement, focusSquare
    }
    
    // Views for the status bar
    private var messagePanel: UIVisualEffectView!
    private var messageLabel: UILabel!
    private var restartExperienceButton: UIButton!
    
    // Restart experience handler
    var restartExperienceHandler: () -> Void = {}
    private let displayDuration: TimeInterval = 6  // Message display duration
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()  // Set up the status views
    }
    
    private func setupViews() {
        // Panel for the message (blur effect)
        messagePanel = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        messagePanel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(messagePanel)
        
        // Label to show messages
        messageLabel = UILabel()
        messageLabel.font = UIFont.systemFont(ofSize: 14)
        messageLabel.textColor = .black
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messagePanel.contentView.addSubview(messageLabel)
        
        // Restart button
        restartExperienceButton = UIButton(type: .system)
        restartExperienceButton.setTitle("Restart", for: .normal)
        restartExperienceButton.addTarget(self, action: #selector(didTapRestartButton), for: .touchUpInside)
        restartExperienceButton.translatesAutoresizingMaskIntoConstraints = false
        messagePanel.contentView.addSubview(restartExperienceButton)
        
        // Constraints for layout
        NSLayoutConstraint.activate([
            messagePanel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messagePanel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            messagePanel.topAnchor.constraint(equalTo: view.topAnchor),
            messagePanel.heightAnchor.constraint(equalToConstant: 50),
            
            messageLabel.leadingAnchor.constraint(equalTo: messagePanel.leadingAnchor, constant: 10),
            messageLabel.centerYAnchor.constraint(equalTo: messagePanel.centerYAnchor),
            
            restartExperienceButton.trailingAnchor.constraint(equalTo: messagePanel.trailingAnchor, constant: -10),
            restartExperienceButton.centerYAnchor.constraint(equalTo: messagePanel.centerYAnchor)
        ])
        
        messagePanel.isHidden = true  // Initially hidden
    }
    
    // Action for the restart button
    @objc private func didTapRestartButton() {
        restartExperienceHandler()
    }
    
    // Show a message with a specific type
    func showMessage(_ text: String, type: MessageType) {
        messageLabel.text = text
        messagePanel.isHidden = false
        resetMessageHideTimer()
    }
    
    // Hide the message panel after the display duration
    private func resetMessageHideTimer() {
        Timer.scheduledTimer(withTimeInterval: displayDuration, repeats: false) { [weak self] _ in
            self?.messagePanel.isHidden = true
        }
    }
}
