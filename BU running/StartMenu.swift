//
//  StartMenu.swift
//  BU running
//
//  Created by Sam DeCosta on 5/14/19.
//  Copyright © 2019 Sam DeCosta. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit
import UIKit

class StartMenu : SKScene {
    
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "backgroundopaque")
        background.position.x = 0
        background.position.y = 0
        background.zPosition = 0
        background.scale(to: CGSize(width: self.size.width, height: self.size.height))
        addChild(background)
        
        let StartButton = SKSpriteNode(imageNamed: "startbutton")
        StartButton.position.x = 0
        StartButton.position.y = 0
        StartButton.zPosition = 1
        StartButton.name = "StartButton"
        addChild(StartButton)
        
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let location = touch?.location(in: self){
            let nodesArray = self.nodes(at: location)
            if nodesArray.first?.name == "StartButton"{
                let gameScene = GameScene(fileNamed: "GameScene")
                self.view?.presentScene(gameScene)
            }
        }
    }
}
