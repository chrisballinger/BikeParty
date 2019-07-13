//
//  ViewController.swift
//  BikeParty
//
//  Created by Chris Ballinger on 7/12/19.
//  Copyright © 2019 Chris Ballinger. All rights reserved.
//

import UIKit
import Network

enum UDPCommand: String, CaseIterable {
    case f
    case g
    case u
    case w
    case v
    
    var color: UIColor {
        switch self {
        case .f:
            return .red
        case .g:
            return .green
        case .u:
            return .purple
        case .w:
            return .blue
        case .v:
            return .orange
        }
    }
}

final class ViewController: UIViewController {
    
    var broadcast: UDPBroadcastConnection?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        broadcast = try? UDPBroadcastConnection(port: 8422, handler: { (address, port, response) in
            print("Received response: \(response) from \(address) \(port)")
        }, errorHandler: { (error) in
            print("error sending broadcast \(error)")
        })
    
        var buttons: [UIButton] = []
        
        for (index, command) in UDPCommand.allCases.enumerated() {
            let button = UIButton()
            button.titleLabel?.font = UIFont.systemFont(ofSize: 40)
            button.setTitle(command.rawValue, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.setBackgroundColor(color: command.color, forState: .normal)
            button.tag = index
            button.addTarget(self, action: #selector(tappedButton(_:)), for: .touchUpInside)
            buttons.append(button)
        }
        
        let stack = UIStackView(arrangedSubviews: buttons)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .fillEqually
        
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: stack.topAnchor),
            view.bottomAnchor.constraint(equalTo: stack.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
            ])
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

private extension ViewController {
    @objc func tappedButton(_ sender: UIButton) {
        let command = UDPCommand.allCases[sender.tag]
        
        print("sending command: \(command)")

        do {
            try broadcast?.sendBroadcast(command.rawValue)
        } catch {
            print("error sending command: \(error)")
        }
    }
}



extension UIButton {
    
    // https://stackoverflow.com/a/49773196
    func setBackgroundColor(color: UIColor, forState: UIControl.State) {
        
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.setBackgroundImage(colorImage, for: forState)
    }
    
}
