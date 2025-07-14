//
//  ViewController.swift
//  EverlinkTestIntegration
//
//  Created by Nathan Kuruvilla on 14/07/2025.
//

import UIKit
import EverlinkBroadcastSDK

class ViewController: UIViewController, EverlinkEventDelegate {
    
    private let myAppID = "myTestKey12345"
    private let token1 = "evpandc9b9ee1347705c95a4df9cfa7a4b151"
    private let token2 = "evpan06ba9da2c73aca17abaa57a7c0889089"
    private let token3 = "evpancf4c33b29bb6a4a783a4065de5336759"
    private let token4 = "evpan09cbdf75af059b239b14f50659415074"
    private let token5 = "evpan1495009724f29fb15fbe83a947c8c265"
    private var everlink:Everlink?
    private let savedDefaultsName: String = "EverlinkSAT"
    private let defaults = UserDefaults.standard
    
    //Everlink event listeners
    func onAudiocodeReceived(token: String) {
        view.backgroundColor = .themeGreen // Change to green
        if self.token1 == token {
            print("Token 1 received: \(token)")
        } else if self.token2 == token {
            print("Token 2 received: \(token)")
        } else if self.token3 == token {
            print("Token 3 received: \(token)")
        } else if self.token4 == token {
            print("Token 4 received: \(token)")
        }else if self.token5 == token {
            print("Token 5 received: \(token)")
        }
    }
    
    func onMyTokenGenerated(token: String, oldToken: String) {
        print("New token: \(token)")
        print("Old token: \(oldToken)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .themeBackground // Default background color
        
        //Set up Everlink class
        everlink = Everlink(appID: myAppID)
        everlink?.delegate = self
        everlink?.playVolume(volume: 0.8, loudspeaker: true)
        
        //Save token for offline usage
        let arrayOfTokens = [token1, token2, token3, token4, token5]
        everlink?.saveSounds(tokensArray: arrayOfTokens)
       //change expiration date
        editTokensArray()
        
        // Setup UI & button actions
        setupUI()
        setupButtonActions()
    }
    
    private lazy var startDetectingButton: UIButton = createButton(title: "Start Detecting")
    private lazy var stopDetectingButton: UIButton = createButton(title: "Stop Detecting")
    private lazy var playTokenButton: UIButton = createButton(title: "Play Token")
    private lazy var stopPlayingButton: UIButton = createButton(title: "Stop Playing")
    
    private func createButton(title: String) -> UIButton {
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
    
    private func setupUI() {
        let stackView = UIStackView(arrangedSubviews: [startDetectingButton, stopDetectingButton, playTokenButton, stopPlayingButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    private func setupButtonActions() {
        startDetectingButton.addTarget(self, action: #selector(startDetecting), for: .touchUpInside)
        stopDetectingButton.addTarget(self, action: #selector(stopDetecting), for: .touchUpInside)
        playTokenButton.addTarget(self, action: #selector(playToken), for: .touchUpInside)
        stopPlayingButton.addTarget(self, action: #selector(stopPlaying), for: .touchUpInside)
    }
    
    //Everlink class functions usage
    @objc private func startDetecting() {
        print("Start detecting tapped")
        do {
            try everlink?.startDetecting()
            view.backgroundColor = .themeBackground // Reset to original color
        } catch {
            print("Error starting detecting: \(error)")
        }
    }

    @objc private func stopDetecting() {
        print("Stop detecting tapped")
        everlink?.stopDetecting()
        view.backgroundColor = .themeBackground // Reset to original color
    }

    @objc private func playToken() {
        print("Play token tapped")
        everlink?.startEmittingToken(token: token4) { error in
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
    
     private func newToken() {
        do {
            try everlink?.createNewToken(startDate: "")
        } catch let error as EverlinkError {
            print("Everlink error caught: \(error.getErrorMessage())")
        }  catch let error {
            print("Error caught: \(error)")
        }
    }
    
    
    private func editTokensArray() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            var defaultsArray:Array = self.defaults.array(forKey: self.savedDefaultsName) ?? [Any]()
            for index in stride(from: 4, to: defaultsArray.count, by: 5) {
                defaultsArray[index] = 182625
            }
            self.defaults.set(defaultsArray, forKey: self.savedDefaultsName)
        }
    }
    
}

