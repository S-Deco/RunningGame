//
//  endMenu.swift
//  BU running
//
//  Created by Sam DeCosta on 5/13/19.
//  Copyright © 2019 Sam DeCosta. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit
import UIKit

class endMenu: SKScene {
    
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position.x = 0
        background.position.y = 0
        background.zPosition = 0
        background.scale(to: CGSize(width: self.size.width, height: self.size.height))
        addChild(background)
        
        let retryButton = SKSpriteNode(imageNamed: "resetbutton")
        retryButton.position.x = 0
        retryButton.position.y = 0
        retryButton.zPosition = 1
        retryButton.scale(to: CGSize(width: self.size.width / 4, height: self.size.height / 5.5))
        retryButton.name = "retryButton"
        addChild(retryButton)
        
       // if UserDefaults.standard.value(forKey: "highscore") != nil{
        let highscore = UserDefaults.standard.integer(forKey: "highscore")
      //  }
        let highscoreLabel = SKLabelNode()
        highscoreLabel.position = CGPoint(x: 0, y: 0)
        highscoreLabel.text = String(highscore)
        highscoreLabel.fontSize = 15
        highscoreLabel.zPosition = 10
        highscoreLabel.fontColor = UIColor.black
        highscoreLabel.fontName = "AppleSDGothicNeo-Regular"
        addChild(highscoreLabel)
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let location = touch?.location(in: self){
            let nodesArray = self.nodes(at: location)
            if nodesArray.first?.name == "retryButton"{
                let gameScene = GameScene(fileNamed: "GameScene")
                self.view?.presentScene(gameScene)
            }
        }
    }
    
    
}
