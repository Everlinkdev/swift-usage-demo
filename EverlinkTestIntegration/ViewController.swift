//
//  ViewController.swift
//  EverlinkTestIntegration
//
//  Created by Nathan Kuruvilla on 14/07/2025.
//

import UIKit
import EverlinkBroadcastSDK

final class ViewController: UIViewController {

    // MARK: - Properties

    private let appID = "myTestKey12345"
    private let tokens = [
        "evpandc9b9ee1347705c95a4df9cfa7a4b151",
        "evpan06ba9da2c73aca17abaa57a7c0889089",
        "evpancf4c33b29bb6a4a783a4065de5336759",
        "evpan09cbdf75af059b239b14f50659415074",
        "evpan1495009724f29fb15fbe83a947c8c265"
    ]
    private var everlink: Everlink?
    private let savedDefaultsName = "EverlinkSAT"
    private let defaults = UserDefaults.standard

    // MARK: - UI Elements

    private lazy var startDetectingButton = makeButton(title: "Start Detecting")
    private lazy var stopDetectingButton = makeButton(title: "Stop Detecting")
    private lazy var playTokenButton = makeButton(title: "Play Token")
    private lazy var stopPlayingButton = makeButton(title: "Stop Playing")

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .themeBackground
        setupEverlink()
        setupUI()
        setupButtonActions()
        saveTokens()
        updateTokenArrayAfterDelay()
    }

    // MARK: - Setup Methods

    private func setupEverlink() {
        everlink = Everlink(appID: appID)
        everlink?.delegate = self
        everlink?.playVolume(volume: 0.8, loudspeaker: true)
    }

    private func setupUI() {
        let stackView = UIStackView(arrangedSubviews: [
            startDetectingButton,
            stopDetectingButton,
            playTokenButton,
            stopPlayingButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupButtonActions() {
        startDetectingButton.addTarget(self, action: #selector(startDetecting), for: .touchUpInside)
        stopDetectingButton.addTarget(self, action: #selector(stopDetecting), for: .touchUpInside)
        playTokenButton.addTarget(self, action: #selector(playToken), for: .touchUpInside)
        stopPlayingButton.addTarget(self, action: #selector(stopPlaying), for: .touchUpInside)
    }

    private func makeButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .themeButton
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 250).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return button
    }

    // MARK: - Everlink SDK Integration

    private func saveTokens() {
        everlink?.saveSounds(tokensArray: tokens)
    }

    private func updateTokenArrayAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.overwriteTokensArray()
        }
    }

    private func overwriteTokensArray() {
        var defaultsArray = defaults.array(forKey: savedDefaultsName) ?? []
        for index in stride(from: 4, to: defaultsArray.count, by: 5) {
            defaultsArray[index] = 182625
        }
        defaults.set(defaultsArray, forKey: savedDefaultsName)
    }

    private func generateNewToken() {
        do {
            try everlink?.createNewToken(startDate: "")
        } catch let error as EverlinkError {
            print("Everlink error caught: \(error.getErrorMessage())")
        } catch {
            print("Error caught: \(error)")
        }
    }

    // MARK: - Button Actions

    @objc private func startDetecting() {
        print("Start detecting tapped")
        do {
            try everlink?.startDetecting()
            view.backgroundColor = .themeBackground
        } catch {
            print("Error starting detecting: \(error)")
        }
    }

    @objc private func stopDetecting() {
        print("Stop detecting tapped")
        everlink?.stopDetecting()
        view.backgroundColor = .themeBackground
    }

    @objc private func playToken() {
        print("Play token tapped")
        guard let token = tokens[safe: 0] else { return }
        everlink?.startEmittingToken(token: token) { error in
            if let error = error {
                print(error.getErrorMessage())
                print("Error starting emitting: \(error)")
            }
        }
    }

    @objc private func stopPlaying() {
        print("Stop playing tapped")
        everlink?.stopEmitting()
    }
}

// MARK: - EverlinkEventDelegate

extension ViewController: EverlinkEventDelegate {
    func onAudiocodeReceived(token: String) {
        view.backgroundColor = .themeGreen
        if let tokenIndex = tokens.firstIndex(of: token) {
            print("Token \(tokenIndex + 1) received: \(token)")
        } else {
            print("Unknown token received: \(token)")
        }
    }

    func onMyTokenGenerated(token: String, oldToken: String) {
        print("New token: \(token)")
        print("Old token: \(oldToken)")
    }
}

// MARK: - Safe Array Indexing Extension

private extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

