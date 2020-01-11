//
//  GameScene.swift
//  BU running
//
//  Created by Sam DeCosta on 5/7/19.
//  Copyright © 2019 Sam DeCosta. All rights reserved.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory {
    //physics categories one for every type of object that needs physics
    
    static let player : UInt32 = 0x1 << 1
    static let ground : UInt32 = 0x1 << 2
    static let cone : UInt32 = 0x1 << 3
    static let level : UInt32 = 0x1 << 4
    static let elevator : UInt32 = 0x1 << 5
    static let hockey : UInt32 = 0x1 << 6
    
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    //time
    var lastUpdateTime = TimeInterval(0)
    var timeSinceLastAction = TimeInterval(0)
    var timeUntilNextAction = TimeInterval(4)
    var floorTimer = Timer()
    var monsterTimer = Timer()
    var scoreTimer = Timer()
    
    //animations
    var player = SKSpriteNode()
    var warren = SKSpriteNode()
    var hockey = SKSpriteNode()
    var agganis = SKSpriteNode()
    private var playerwalking: [SKTexture] = []
    private var warrenmoving: [SKTexture] = []
    private var hockeyskating: [SKTexture] = []
    private var agganisfloating: [SKTexture] = []
    
    
    var gamestarted = false
    var firstchecker = 0
    var jump = false
    var overallspeed = 1.0
    var scoreLabel = SKLabelNode()
    var highscoreLabel = SKLabelNode()
    var score = 0
    var highscore = 0
    
    
    override func didMove(to view: SKView) {
        //initialization of scene
        

        highscore = UserDefaults.standard.integer(forKey: "highscore")

        
        //start  timer
        timerstart()
        
        // background initialization
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 0, y: 0)
        background.scale(to: CGSize(width: self.size.width, height: self.size.height))
        background.zPosition = 0
        addChild(background)
        
        //spawners and starting animation
        self.physicsWorld.contactDelegate = self
        createFloor()
        firstchecker += 1
        playeranimation()
        animatePlayer()
        floorSpawner(ground: true)
        objectSpawner()
        
        //player initialization
        player.zPosition = 3
        player.position.y = -20
        player.position.x = -190
        player.physicsBody = SKPhysicsBody(rectangleOf:player.size)
        player.physicsBody?.affectedByGravity = true
        player.physicsBody?.isDynamic = true
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.mass = 0.1
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.ground | PhysicsCategory.cone | PhysicsCategory.level | PhysicsCategory.elevator | PhysicsCategory.hockey
        player.physicsBody?.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.cone | PhysicsCategory.level | PhysicsCategory.level | PhysicsCategory.hockey
        
        //score
        scoreLabel.text = String(score)
        scoreLabel.fontSize = 15
        scoreLabel.fontColor = UIColor.black
        scoreLabel.fontName = "AppleSDGothicNeo-Regular"
        scoreLabel.position = CGPoint(x: -self.size.width / 2 + self.size.width / 8, y: self.size.height / 2 - 20)
        scoreLabel.zPosition = 20
        addChild(scoreLabel)
        
        highscoreLabel.text = String(highscore)
        highscoreLabel.fontSize = 15
        highscoreLabel.fontColor = UIColor.black
        highscoreLabel.fontName = "AppleSDGothicNeo-Regular"
        highscoreLabel.position = CGPoint(x: -self.size.width / 2 + self.size.width / 6, y: self.size.height / 2 - 20)
        highscoreLabel.zPosition = 20
        addChild(highscoreLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //touch on screen
        for touch in touches {
            let location = touch.location(in: self)
            
            //left touch
            if(location.x < 0){
                //left upper touch
                if location.y > 0{
                    if player.position.y < (0 - ((1/6) * self.size.height)){
                        player.physicsBody?.velocity = (CGVector(dx: 0, dy: 0))
                        player.position.y = 0 + player.size.height
                    }
                }
                //left lower touch
                else{
                    if player.position.y > 0{
                        player.physicsBody?.velocity = (CGVector(dx: 0, dy: 0))
                        player.position.y = -self.size.height / 2 + player.size.height * 2
                    }
                }
            }
            //right touch
            else {
                if jump == true{
                    player.physicsBody?.velocity = (CGVector(dx: 0, dy: 0))
                    player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 60))
                    player.removeAllActions()
                    jump = false
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //finger lifted off
        
        //animates player
        animatePlayer()
    }
    
    func playeranimation() {
        //single player animation
        
        let playeratlas = SKTextureAtlas(named: "runner")
        var run: [SKTexture] = []
        
        let numImages = playeratlas.textureNames.count
        for i in 1...numImages {
            let runTexture = "runner\(i)"
            run.append(playeratlas.textureNamed(runTexture))
        }
        playerwalking = run
        let firstframe = playerwalking[0]
        player = SKSpriteNode(texture: firstframe)
        player.position = CGPoint(x: frame.midX,y: frame.midY)
        addChild(player)
    }
    
    func warrenanimation() {
        //single warren animation
        
        let warrenatlas = SKTextureAtlas(named: "warrentowersmonster")
        var run: [SKTexture] = []
        
        let numImages = warrenatlas.textureNames.count - 1
        for i in 0...numImages {
            let runTexture = "warrentowersmonster\(i)"
            run.append(warrenatlas.textureNamed(runTexture))
        }
        warrenmoving = run
        let firstframe = warrenmoving[0]
        warren = SKSpriteNode(texture: firstframe)
        warren.position = CGPoint(x: frame.midX,y: frame.midY)
        warren.scale(to: CGSize(width: self.size.width / 4, height: self.size.height))
        warren.position.x = self.size.width / 2 - warren.size.width / 2
        warren.position.y = self.size.height
        warren.zPosition = 3
        addChild(warren)
    }
    
    func agganisanimation() {
        //single agganis animation
        
        let agganisatlas = SKTextureAtlas(named: "agganismonster")
        var run: [SKTexture] = []
        
        let numImages = agganisatlas.textureNames.count
        for i in 1...numImages {
            let runTexture = "agganismonster\(i)"
            run.append(agganisatlas.textureNamed(runTexture))
        }
        agganisfloating = run
        let firstframe = agganisfloating[0]
        agganis = SKSpriteNode(texture: firstframe)
        agganis.scale(to: CGSize(width: self.size.width / 3.5, height: self.size.height / 1.75))
        agganis.position.x = self.size.width / 2 - agganis.size.width / 2
        agganis.position.y = self.size.height
        agganis.zPosition = 3
        addChild(agganis)
    }
    
    func hockeyanimation(){
        //single hockey player animation
        let hockeyatlas = SKTextureAtlas(named: "hockeyplayer")
        var run: [SKTexture] = []
        
        let numImages = hockeyatlas.textureNames.count
        for i in 1...numImages {
            let runTexture = "hockeyplayer\(i)"
            run.append(hockeyatlas.textureNamed(runTexture))
        }
        hockeyskating = run
        let firstframe = hockeyskating[0]
        hockey = SKSpriteNode(texture: firstframe)
        hockey.scale(to: CGSize(width: self.size.width / 10.7, height: self.size.height / 6.4))
        hockey.position.x = self.size.width / 2 - hockey.size.width
        hockey.zPosition = 3
        addChild(hockey)
        
    }
    
    //animation continuations
    func animatePlayer() {
        //repeats player animation
        player.run(SKAction.repeatForever(
            SKAction.animate(with: playerwalking, timePerFrame: 0.1, resize: false, restore: true)), withKey: "runningPlayer")
    }
    func animateWarren() {
        //repeats warren animation
        warren.run(SKAction.repeatForever(
            SKAction.animate(with: warrenmoving, timePerFrame: 0.1, resize: false, restore: true)), withKey: "warrenAnimation")
    }
    func animateAgganis() {
        //repeats agganis animation
        agganis.run(SKAction.repeatForever(
            SKAction.animate(with: agganisfloating, timePerFrame: 0.15, resize: false, restore: true)), withKey: "agganisAnimation")
    }
    func animateHockey() {
        //repeats hockey animation
        hockey.run(SKAction.repeatForever(
            SKAction.animate(with: hockeyskating, timePerFrame: 0.2, resize: false, restore: true)), withKey: "hockeyAnimation")
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        //contact between objects
        
        let contact1 = contact.bodyA
        let contact2 = contact.bodyB
        
        //player hits object
        if contact1.categoryBitMask == PhysicsCategory.player && contact2.categoryBitMask == PhysicsCategory.cone{
            scoreTimer.invalidate()
            let endScene = endMenu(fileNamed: "endMenu")
            self.view?.presentScene(endScene)
        }
        else if contact1.categoryBitMask == PhysicsCategory.player && contact2.categoryBitMask == PhysicsCategory.elevator{
            scoreTimer.invalidate()
            let endScene = endMenu(fileNamed: "endMenu")
            self.view?.presentScene(endScene)
        }
        else if contact1.categoryBitMask == PhysicsCategory.player && contact2.categoryBitMask == PhysicsCategory.hockey{
            scoreTimer.invalidate()
            let endScene = endMenu(fileNamed: "endMenu")
            self.view?.presentScene(endScene)
        }
        
        //player hits ground or level
        if contact1.categoryBitMask == PhysicsCategory.player && contact2.categoryBitMask  == PhysicsCategory.ground {
            jump = true
        }
        else if contact1.categoryBitMask == PhysicsCategory.player && contact2.categoryBitMask  == PhysicsCategory.level{
            jump = true
        }
    }
    
    func createFloor(){
        //creates a single floor and moves it across the screen
        var timer = 6.0
        let floor = SKSpriteNode(imageNamed: "sidewalk.png")
        floor.scale(to:(CGSize(width:self.size.width, height: self.size.height / 20)))
        if firstchecker == 0{
            floor.position.x = 60
            timer = 3.2
        }
        else{
            floor.position.x = self.size.width
        }
        floor.position.y = -self.size.height / 2
        floor.zPosition = 1
        floor.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.size.width, height: self.size.height / 40))
        floor.physicsBody?.affectedByGravity = false
        floor.physicsBody?.isDynamic = false
        floor.physicsBody?.allowsRotation = false
        floor.physicsBody?.categoryBitMask = PhysicsCategory.ground
        floor.physicsBody?.collisionBitMask = PhysicsCategory.player | PhysicsCategory.cone
        floor.physicsBody?.contactTestBitMask = PhysicsCategory.player
        addChild(floor)
        let delete = SKAction.removeFromParent()
        let move = SKAction.moveTo(x: -self.size.width, duration: timer * overallspeed)
        let sequence = SKAction.sequence([move,delete])
        floor.run(sequence)

    }
    
    func createLevel(){
        //creates an upper level and moves it across the screen
        
        let level = SKSpriteNode(imageNamed: "level")
        level.scale(to: CGSize(width: self.size.width, height: self.size.height / 20))
        level.position.y = 0
        level.position.x = self.size.width
        level.zPosition = 1
        level.physicsBody = SKPhysicsBody(rectangleOf: level.size)
        level.physicsBody?.affectedByGravity = false
        level.physicsBody?.isDynamic = false
        level.physicsBody?.allowsRotation = false
        level.physicsBody?.categoryBitMask = PhysicsCategory.level
        level.physicsBody?.collisionBitMask = PhysicsCategory.player | PhysicsCategory.cone
        level.physicsBody?.contactTestBitMask = PhysicsCategory.player
        addChild(level)
        let delete = SKAction.removeFromParent()
        let move = SKAction.moveTo(x: -self.size.width, duration: 6 * overallspeed)
        let sequence = SKAction.sequence([move, delete])
        level.run(sequence)
        
    }
    
    func createCone(){
        //creates a cone and moves it across the screen (still need to dial in duration)
        
        let cone = SKSpriteNode(imageNamed: "cone.png")
        cone.position.x = self.size.width + 5
        cone.position.y = -self.size.height / 2 + cone.size.height *  0.75
        cone.zPosition = 3
        cone.physicsBody = SKPhysicsBody(rectangleOf: cone.size)
        cone.physicsBody?.affectedByGravity = true
        cone.physicsBody?.allowsRotation = false
        cone.physicsBody?.isDynamic = false
        cone.physicsBody?.categoryBitMask = PhysicsCategory.cone
        cone.physicsBody?.contactTestBitMask = PhysicsCategory.player
        cone.physicsBody?.collisionBitMask = PhysicsCategory.player | PhysicsCategory.ground | PhysicsCategory.level
        addChild(cone)
        let move = SKAction.moveTo(x: -self.size.width, duration: 6 * overallspeed)
        let delete = SKAction.removeFromParent()
        let sequence = SKAction.sequence([move,delete])
        cone.run(sequence)
    }
    
    func createHockeyPlayer(height: Int){
        //creates a hockey player and moves it across the screen
        hockeyanimation()
        animateHockey()
        if height == 1{
           hockey.position.y = -self.size.height / 2 + hockey.size.height
        }
        else if height == 2{
            hockey.position.y = self.size.height / 2 - hockey.size.height
        }
        let move = SKAction.moveTo(x: -self.size.width, duration: 3 * overallspeed)
        let delete = SKAction.removeFromParent()
        hockey.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: hockey.size.width - hockey.size.width / 4, height: hockey.size.height))
        hockey.physicsBody?.affectedByGravity = true
        hockey.physicsBody?.allowsRotation = false
        hockey.physicsBody?.isDynamic = true
        hockey.physicsBody?.categoryBitMask = PhysicsCategory.elevator
        hockey.physicsBody?.contactTestBitMask = PhysicsCategory.player
        hockey.physicsBody?.collisionBitMask = PhysicsCategory.player | PhysicsCategory.ground | PhysicsCategory.level
        let sequence = SKAction.sequence([move,delete])
        hockey.run(sequence)
    }
    
    func createElevator(){
        //creates an elevator and drops it, used for warren towers stage
        
        let elevator = SKSpriteNode(imageNamed: "elevator.png")
        elevator.scale(to: CGSize(width: self.size.width / 10, height: self.size.height / 10))
        let randomNum = CGFloat.random(in: -self.size.height / 2 + elevator.size.height...self.size.height / 2 - elevator.size.height)
        elevator.position.y = randomNum
        elevator.position.x = self.size.width / 2 - elevator.size.width
        elevator.zPosition = 4
        elevator.physicsBody = SKPhysicsBody(rectangleOf: elevator.size)
        elevator.physicsBody?.affectedByGravity = true
        elevator.physicsBody?.allowsRotation = false
        elevator.physicsBody?.isDynamic = false
        elevator.physicsBody?.categoryBitMask = PhysicsCategory.elevator
        elevator.physicsBody?.contactTestBitMask = PhysicsCategory.player
        elevator.physicsBody?.collisionBitMask = PhysicsCategory.player
        addChild(elevator)
       // let move = SKAction.moveTo(y:-self.size.height, duration: 3)
        let move = SKAction.move(to: CGPoint(x:-self.size.width, y: randomNum), duration: 2)
        let wait = SKAction.wait(forDuration: 2 * overallspeed)
        let delete = SKAction.removeFromParent()
        let sequence = SKAction.sequence([wait,move,delete])
        elevator.run(sequence)
    }
    
    func createWarren(){
        //creates a warren towers object and moves it off screen
        warrenanimation()
        animateWarren()
        let warrenSign = SKSpriteNode(imageNamed: "warren_enter.png")
        warrenSign.scale(to: CGSize(width: self.size.width / 6, height: self.size.height / 6))
        warrenSign.position.x = self.size.width + warrenSign.size.width + 5
        warrenSign.position.y = -self.size.height / 2 + warrenSign.size.height / 4 + self.size.height / 20
        warrenSign.zPosition = 2
        let move = SKAction.moveTo(x: -self.size.width, duration: 6.5 * overallspeed)
        let moveout = SKAction.moveTo(x: self.size.width, duration: 1 * overallspeed)
        let fall = SKAction.moveTo(y: 0, duration: 1)
        let delete = SKAction.removeFromParent()
        let sequence = SKAction.sequence([move,delete])
        let wait = SKAction.wait(forDuration: 3 * overallspeed)
        let firstwait = SKAction.wait(forDuration: 5 * overallspeed)
        let Warrensequence = SKAction.sequence([firstwait,fall,wait,moveout,delete])
        addChild(warrenSign)
        warren.run(Warrensequence)
        warrenSign.run(sequence)
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0 * overallspeed, execute: {
            self.spawn3()
        })
    }
    
    func createAgganis(){
        //creates an agganis object and moves it off screen
        agganisanimation()
        animateAgganis()
        let AgganisSign = SKSpriteNode(imageNamed: "agganis_enter.png")
        AgganisSign.scale(to: CGSize(width: self.size.width / 6, height: self.size.height / 6))
        AgganisSign.position.x = self.size.width + AgganisSign.size.width + 5
        AgganisSign.position.y = -self.size.height / 2 + AgganisSign.size.height / 4 + self.size.height / 20
        AgganisSign.zPosition = 2
        let move = SKAction.moveTo(x: -self.size.width, duration: 6.5 * overallspeed)
        let moveout = SKAction.moveTo(x: self.size.width, duration: 1 * overallspeed)
        let fall = SKAction.moveTo(y: -self.size.height / 3 + agganis.size.height / 4, duration: 1)
        let up = SKAction.moveTo(y:self.size.height / 3 - agganis.size.height / 4, duration: 1)
        let delete = SKAction.removeFromParent()
        let sequence = SKAction.sequence([move,delete])
        let wait = SKAction.wait(forDuration: 4.5 * overallspeed)
        let firstwait = SKAction.wait(forDuration: 5 * overallspeed)
        let agganissequence = SKAction.sequence([firstwait,fall,wait,up,wait,moveout,delete])
        addChild(AgganisSign)
        agganis.run(agganissequence)
        AgganisSign.run(sequence)
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0 * overallspeed, execute: {
            self.spawn3hockey(position: 1)
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 11.5 * overallspeed, execute: {
            self.spawn3hockey(position: 2)
        })
    }
    
    func spawn3(){
        //spawn 3 elevators spaced out by duration wait
        let wait = SKAction.wait(forDuration: 1)
        let elevatorSpawn = SKAction.run{
            self.createElevator()
        }
        let sequence = SKAction.sequence([elevatorSpawn,wait,elevatorSpawn,wait,elevatorSpawn])
        self.run(sequence)
        //loop of 3
        //for _ in 1...3{
            
       // }
    }
    
    func spawn3hockey(position: Int){
        //spawn 3 hockey players spaced out by duration wait
        let wait = SKAction.wait(forDuration: 1.5)
        var hockeySpawn = SKAction.run{
            self.createHockeyPlayer(height: 1)
        }
        if position == 2{
            hockeySpawn = SKAction.run{
                self.createHockeyPlayer(height: 2)
            }
        }
        let sequence = SKAction.sequence([hockeySpawn,wait,hockeySpawn,wait,hockeySpawn])
        self.run(sequence)
    }

    func floorSpawner(ground: Bool){
        //spawns floors every 2.8 seconds
        let wait = SKAction.wait(forDuration: 2.8 * overallspeed)
        let floorSpawn = SKAction.run {
            self.createFloor()
            self.createLevel()
        }
        let floordelay = SKAction.sequence([floorSpawn,wait])
        let spawning = SKAction.repeatForever(floordelay)
        self.run(spawning, withKey: "spawningfloors")

    }
    
    func objectSpawner(){
        //spawns objects so far only cones
        let randomNum = Int.random(in: 1...3)
        let conewait = SKAction.wait(forDuration: TimeInterval(randomNum))
        
        let coneSpawn = SKAction.run{
            self.createCone()
        }
        
        let conedelay = SKAction.sequence([conewait, coneSpawn])
        self.run(conedelay)
        
    }
    
    @objc func monsterSpawner(){
        let randomNum = Int.random(in: 0...3)
        if randomNum == 1{
            createAgganis()
        }
        else if randomNum == 2{
            createWarren()
        }
    }
    
    override func update(_ currentTime: TimeInterval){
        // anything that happens over time
        
        //randomly adds in cones
        let delta = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        timeSinceLastAction += delta
        
        if timeSinceLastAction >= timeUntilNextAction{
            objectSpawner()
            timeSinceLastAction = TimeInterval(0)
            timeUntilNextAction = CDouble(arc4random_uniform(4))
        }
    }
    
    func timerstart(){
        //timer that goes off  every 7 seconds
        floorTimer = Timer.scheduledTimer(timeInterval: 7, target: self, selector: #selector(self.increaseby1), userInfo: nil, repeats: true)
        monsterTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.monsterSpawner), userInfo: nil, repeats: true)
        scoreTimer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(self.scoreIncrease), userInfo: nil, repeats: true)
    }
    
    @objc func scoreIncrease(){
        score += Int(3 / (overallspeed * overallspeed))
        scoreLabel.text = String(score)
        if [Int(score)] > [Int(highscore)]{
            highscore = score
            
            let HighscoreDefault = UserDefaults.standard
            HighscoreDefault.set(highscore, forKey: "highscore")
            HighscoreDefault.synchronize()
            highscoreLabel.text = String(highscore)
        }
    }
    
    @objc func increaseby1() {
        // functions that are called by timer: setting overall time to 95% of itself, removes action of spawning floors and re-adds it in with corrected speed
        overallspeed = overallspeed * 0.95
        self.removeAction(forKey: "spawningfloors")
        floorSpawner(ground: true)
        
    }
  
}
