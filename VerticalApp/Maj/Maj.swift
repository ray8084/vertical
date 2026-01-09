//
//  Maj.swift
//  Mahjong2017
//
//  Created by Ray on 12/7/16.
//  Copyright © 2017 EightBam LLC. All rights reserved.
//

import Foundation

class State {
    static let east = 0
    static let south = 1
    static let west = 2
    static let north = 3
    static let wall = 4
}



class Maj {
    var override2020 = false   // make this false for release
    var override2021 = false   // make this false for release
    var unlockedWarning = false // warning when barryOverride default is true
    var state = State.east
    var lastState = 0
    var charlestonState = 0
    static var testHandIndex = 0  // Track which test hand to use
    var handRackFilterPending = false
    var tileMatchesRackFilterPending = false
    var enableRules = true
    var disableUndo = false
    var viewOpponentHands = false
    var showLosses = false
    var sortStyle = SortStyle.suits

    var techSupportDebug = false
    var lockBotView = true
    var challengeHand = false
    var challengeHandShuffleSeed = ""
    
    // Settings moved to Settings class
    let settings = Settings()
            
    var wall = Wall(blankTiles: false)
    var replayWall = Wall(blankTiles: false)
    var card: Card = Card()
    var unsortedHandList: [Hand] = []
    
    // var lastRacked = Player("LastRacked")
    var charleston = TileList()
    var east = Player("East")
    var south = Player("South")
    var west = Player("West")
    var north = Player("North")
    var replayHand = Player("EastReplay")
    var replaySouth = Player("SouthReplay")
    var replayWest = Player("WestReplay")
    var replayNorth = Player("NorthReplay")

    var specialCase2022Rack: [Tile] = []

    var discardTile: Tile!
    var lastDiscard: Tile!
    var discardCalled = false
    var jokerExchanged = false
    var jokerExchangeRackOwner = ""  // Track which rack had the joker in the exchange
    var lastHandName = ""
    var previousHandName = ""
    var discardTable = DiscardTable()
    var initialRackTileCount = 0  // Track rack tiles at start of turn
    var initialRackTileIds: [Int] = []  // Track tile IDs in rack at start of turn
    
    let maxHand = 14
    let maxCharleston = 3

    let defaults = UserDefaults.standard
    
    
    // --------------------------------------------------------------
    //
    //  Copy
    //
    // --------------------------------------------------------------
    
    func copy(_ copy: Maj) {
        // print("maj.copy")
        // print("Copying shuffleFamily from: \(copy.shuffleFamily)")
        state = copy.state
        lastState = copy.lastState
        charlestonState = copy.charlestonState
        handRackFilterPending = copy.handRackFilterPending
        tileMatchesRackFilterPending = copy.tileMatchesRackFilterPending
        enableRules = copy.enableRules
        disableUndo = copy.disableUndo
        viewOpponentHands = copy.viewOpponentHands
        wall.copy(copy.wall)
        replayWall.copy(copy.replayWall)
        settings.copy(copy.settings)
        east.copy(copy.east)
        south.copy(copy.south)
        west.copy(copy.west)
        north.copy(copy.north)
        if copy.discardTile == nil {
            discardTile = nil
        } else {
            discardTile = Tile(copy.discardTile)
        }
        if copy.lastDiscard == nil {
            lastDiscard = nil
        } else {
            lastDiscard = Tile(copy.lastDiscard)
        }
        discardCalled = copy.discardCalled
        jokerExchanged = copy.jokerExchanged
        jokerExchangeRackOwner = copy.jokerExchangeRackOwner
        lastHandName = copy.lastHandName
        previousHandName = copy.previousHandName
        discardTable.copy(discardTable)
        card.showLosses = copy.showLosses
        override2020 = copy.override2020
        override2021 = copy.override2021
        specialCase2022Rack = copy.specialCase2022Rack
        lockBotView = copy.lockBotView
        challengeHand = copy.challengeHand
     }
    
  
    // --------------------------------------------------------------
    //
    //  Init
    //
    // --------------------------------------------------------------
    
    init() {
        state = State.east
        if override2020 { defaults.set(override2020, forKey: "barryOverride") }
        if override2021 { defaults.set(override2021, forKey: "override2021") }
        loadSavedValues()
        setYearSegment(segment: getYearSegment())
        deal()
        
        // test cases - AFTER deal() so they don't get overwritten
        // Test cases - comment out for production
        //loadNextTestHand()
        //loadSingleTestHand()
    }
    
    func loadSingleTestHand() {
        charlestonState = 7
        // Test hand: 35,35,35, 9,9,9, 19,19,19, 29,29,29, 36,36
        let testHand: [Int] = [35, 35, 35, 9, 9, 9, 19, 19, 19, 29, 29, 29, 36, 36]
        east.setTiles(testHand)
        print("🎲 Loaded single test hand: \(testHand)")
    }
    
    func loadNextTestHand() {
        charlestonState = 6
        
        // Array of test hands - automatically cycles through them on each deal
        let testHands: [[Int]] = [
            // 2025 Year hands with 4 jokers each
            [35, 35, 35, 35, 2, 10, 2, 5, 12, 12, 36, 22, 36, 36],      // 0: FFFF 2025 222 (bam) J 22 (crak) JJJ
            [2, 36, 10, 36, 2, 5, 12, 12, 12, 15, 36, 15, 36, 15],      // 1: 2 (dot) J 0 (dot) J 25 222 (bam) 555 (bam) J 5 (bam) J
            [2, 10, 2, 5, 12, 36, 12, 36, 15, 36, 15, 15, 30, 36],      // 2: 2025 (dots) 22 (bam) J 2 (bam) J 555 (bam) J 5 (bam) W J
            [35, 35, 2, 2, 2, 10, 10, 36, 12, 36, 12, 12, 25, 36],      // 3: FF 222 (dot) 00 (dot) J 222 (bam) J 2 (bam) 5 (crak) J
            // 2468 hands with 4 jokers each
            [2, 36, 2, 4, 36, 4, 4, 36, 6, 6, 6, 8, 8, 36],             // 4: 222 4444 666 8888 JJJJ (1 suit)
            [2, 2, 36, 14, 36, 14, 14, 14, 6, 6, 36, 28, 28, 36],       // 5: 222 4444 666 8888 JJJJ (2 suits)
            [35, 35, 2, 36, 2, 2, 12, 12, 12, 36, 26, 26, 26, 36],      // 6: FF 2222+4444=6666 JJJJ
            [35, 35, 2, 2, 36, 2, 16, 16, 16, 36, 28, 28, 28, 36],      // 7: FF 2222+6666=8888 JJJJ
            [2, 2, 4, 4, 36, 6, 6, 8, 8, 36, 10, 36, 10, 36],           // 8: 22 444 66 888 DDDD JJJJ
            [35, 35, 35, 35, 2, 4, 6, 36, 12, 12, 36, 22, 36, 36],      // 9: FFFF 2468 222 222 JJJJ
            [35, 35, 35, 2, 2, 4, 36, 6, 6, 36, 8, 8, 36, 36],          // 10: FFF 22 44 666 8888 JJJJ
            [2, 2, 36, 4, 4, 36, 4, 4, 6, 6, 36, 18, 18, 36],           // 11: 222 4444 666 88 88 JJJJ
            [35, 35, 2, 2, 36, 2, 20, 20, 36, 20, 22, 22, 36, 36],      // 12: FF 2222 DDDD 2222 JJJJ
            // 2025 Consecutive Runs hands with 4 jokers each
            [1, 1, 2, 2, 2, 3, 3, 3, 3, 4, 36, 36, 36, 36],             // 13: 11 222 3333 444 55 -> JJJJ (dots)
            [11, 11, 12, 12, 12, 13, 13, 13, 13, 14, 36, 36, 36, 36],   // 14: 11 222 3333 444 55 -> JJJJ (bam)
            [21, 21, 22, 22, 22, 23, 23, 23, 23, 24, 36, 36, 36, 36],   // 15: 11 222 3333 444 55 -> JJJJ (crak)
            [5, 5, 6, 6, 6, 7, 7, 7, 7, 8, 36, 36, 36, 36],             // 16: 55 666 7777 888 99 -> JJJJ (dots)
            [15, 15, 16, 16, 16, 17, 17, 17, 17, 18, 36, 36, 36, 36],   // 17: 55 666 7777 888 99 -> JJJJ (bam)
            [25, 25, 26, 26, 26, 27, 27, 27, 27, 28, 36, 36, 36, 36],   // 18: 55 666 7777 888 99 -> JJJJ (crak)
            [1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 36, 36, 36, 36],             // 19: 111 2222 333 4444 -> JJJJ (dots, 1 suit)
            [11, 11, 11, 12, 12, 12, 12, 13, 13, 13, 36, 36, 36, 36],   // 20: 111 2222 333 4444 -> JJJJ (bam, 1 suit)
            [21, 21, 21, 22, 22, 22, 22, 23, 23, 23, 36, 36, 36, 36],   // 21: 111 2222 333 4444 -> JJJJ (crak, 1 suit)
            [1, 1, 1, 2, 2, 2, 2, 13, 13, 13, 36, 36, 36, 36],          // 22: 111 2222 333 4444 -> JJJJ (dots+bam, 2 suits)
            [11, 11, 11, 12, 12, 12, 12, 23, 23, 23, 36, 36, 36, 36],   // 23: 111 2222 333 4444 -> JJJJ (bam+crak, 2 suits)
            [35, 35, 35, 35, 1, 1, 1, 1, 2, 2, 36, 36, 36, 36],         // 24: FFFF 1111 22 3333 -> JJJJ (dots, 1 suit)
            [35, 35, 35, 35, 11, 11, 11, 11, 12, 12, 36, 36, 36, 36],   // 25: FFFF 1111 22 3333 -> JJJJ (bam, 1 suit)
            // Original test hands
            [31, 31, 31, 33, 33, 33, 34, 34, 34, 32, 32, 32, 36, 36],  // 26: NNN WWW EEE SSS JJ
            [35, 35, 7, 7, 7, 17, 17, 17, 27, 27, 27, 36, 36, 36],      // 27: FF 777 (all suits) JJJJ
            [9, 36, 36, 14, 14, 36, 14, 16, 16, 16, 28, 28, 8, 8],      // 15: Test hand
            [36, 36, 35, 35, 11, 11, 11, 11, 21, 21, 21, 1, 1, 1],      // 16: Test hand
            [35, 35, 1, 12, 12, 13, 13, 13, 21, 22, 22, 23, 36, 36],    // 17: Test hand
            [6, 26, 16, 26, 33, 26, 33, 16, 34, 36, 34, 36, 34, 34],    // 18: Test hand
            [36, 36, 36, 36, 18, 18, 8, 8, 8, 28, 28, 28, 18, 18],      // 19: Test hand
            [13, 36, 13, 16, 16, 16, 16, 26, 36, 26, 29, 36, 29, 29],   // 20: Test hand
            [35, 35, 11, 11, 11, 2, 2, 23, 23, 23, 36, 36, 36, 36],     // 21: Test hand
            [28, 28, 28, 35, 35, 35, 35, 8, 8, 8, 18, 18, 36, 36],      // 22: Test hand
            [35, 35, 11, 12, 13, 30, 30, 36, 36, 36, 20, 20, 20, 20]  // 23: FF 11-13 30,30 JJJ 20,20,20,20
        ]
        
        // Enable 2025 card for first 26 test hands (2025 year + 2468 + consecutive runs)
        if Maj.testHandIndex < 26 {
            settings.enable2025 = true
            settings.year = Year.y2025
        }
        
        east.setTiles(testHands[Maj.testHandIndex])
        print("🎲 Loaded test hand \(Maj.testHandIndex + 1)/\(testHands.count)")
        
        // Advance to next test hand for next deal
        Maj.testHandIndex = (Maj.testHandIndex + 1) % testHands.count
    }
    
    init(_ maj: Maj) {
        self.copy(maj)
    }
   
    func isGameOver() -> Bool {
        return  wall.tiles.count == 0 || eastWon()
    }
      
    func eastWon() -> Bool {
        return east.rack.tiles.count == 14
    }
    
    func loadSavedValues() {
        if override2021 { settings.year = Year.y2021 }
        showLosses = defaults.bool( forKey: "showLosses" )
        card.loadSavedValues()
        card.showLosses = showLosses
        override2020 = defaults.bool( forKey: "barryOverride" )
        override2021 = defaults.bool(forKey: "override2021")
        techSupportDebug = defaults.bool(forKey: "techSupportDebug")

        lockBotView = defaults.bool(forKey: "lockBotView")
        
        // Load all settings
        settings.loadSavedValues()
    }
    
    func loadHands(_ handList: [Hand]) {
        print("maj.loadHands")
        east.matchingTileSets.loadHands(handList)
        loadOpponentHands()
        unsortedHandList = handList
    }
    
    func loadOpponentHands() {
        // print("loadOpponentHands - Loading bot hands for year \(card.getYear())")
            north.matchingTileSets.loadOpponentHands(card.handList)
            south.matchingTileSets.loadOpponentHands(card.handList)
            west.matchingTileSets.loadOpponentHands(card.handList)
    }
    
    
    // --------------------------------------------------------------
    //
    //  Feature Checks
    //
    // --------------------------------------------------------------
    
    func isLeaderboardSupported() -> Bool {
        return settings.isLeaderboardSupported()
    }
    
    // --------------------------------------------------------------
    //
    //  Get Methods
    //
    // --------------------------------------------------------------
    
    func getPlayer(state: Int) -> Player {
        switch state {
        case State.east: return east
        case State.south: return south
        case State.west: return west
        case State.north: return north
        default: return Player("")
        }
    }

    func getRack(state: Int) -> Rack {
        switch state {
        case State.east: return east.rack
        case State.south: return south.rack
        case State.west: return west.rack
        case State.north: return north.rack
        default: return Rack("")
        }
    }
    
    func getHandByIndex(_ index: Int) -> NSAttributedString {
        return unsortedHandList[index].text
    }
    
    func getHandNoteByIndex(_ index: Int) -> NSAttributedString {
        return unsortedHandList[index].note
    }
    
    func getMessages() -> [String]{
        return [south.rack.message, west.rack.message, north.rack.message]
    }
    
    func clearMessages() {
        west.rack.message = ""
        north.rack.message = ""
        south.rack.message = ""
    }
    
    func isTileDesigner() -> Bool {
        return settings.isTileDesigner()
    }
    
    func isOpenPlay() -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC") // Ensures consistent date handling
        
        let today = Date()
        guard let expirationDate = formatter.date(from: "2025-03-16") else {
            return settings.enableOpenPlay && !challengeHand
        }
        
        if today > expirationDate {
            return settings.enableOpenPlay && !challengeHand
        }
        
        return true
    }
    
    
    // --------------------------------------------------------------
    //
    //  Settings
    //
    // --------------------------------------------------------------
  
    func toggleLosses(){
        showLosses = !showLosses
        defaults.set(showLosses, forKey: "showLosses")
        card.showLosses = showLosses
    }
    


    
    
    func setYearSegment(segment: Int) {
        // print("🔄 Maj.setYearSegment \(segment) - Changing year")
        let showLosses = card.showLosses
        switch segment {
        case YearSegment.segment2017:
            settings.setYearSegment(segment: segment)
            card = Card2017()
        case YearSegment.segment2018:
            settings.setYearSegment(segment: segment)
            card = Card2018()
        case YearSegment.segment2019:
            settings.setYearSegment(segment: segment)
            card = Card2019()
        case YearSegment.segment2020:
            settings.setYearSegment(segment: segment)
            card = Card2020()
        case YearSegment.segment2021:
            settings.setYearSegment(segment: segment)
            card = Card2021()
        case YearSegment.segment2022:
            settings.setYearSegment(segment: segment)
            card = Card2022()
        case YearSegment.segment2023:
            settings.setYearSegment(segment: segment)
            card = Card2023()
        case YearSegment.segment2024:
            settings.setYearSegment(segment: segment)
            card = Card2024()
        case YearSegment.segment2025:
            settings.setYearSegment(segment: segment)
            card = Card2025()
        default:
            settings.setYearSegment(segment: segment)
            card = Card2017()
        }
        card.loadSavedValues()
        card.showLosses = showLosses
        defaults.set(settings.year, forKey: "year")
        // print("Year changed to: \(card.getYear()), total hands: \(card.handList.count)")
        // Reload bot hands for the new year
        loadOpponentHands()
    }
    
    func getYearSegment() -> Int {
        _ = 0
        return settings.getYearSegment()
    }
    
    func setTechSupportDebug(_ enable: Bool) {
        techSupportDebug = enable
        defaults.set(techSupportDebug, forKey: "techSupportDebug")
    }
    
    func setLockBotView(_ lock: Bool) {
        lockBotView = lock
        defaults.set(lockBotView, forKey: "lockBotView")
    }
    
    
    
    // --------------------------------------------------------------
    //
    //  Dealing
    //
    // --------------------------------------------------------------
    
    func deal() {
        if challengeHand == true {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyMMdd"
            let date = formatter.string(from: Date())
            challengeHandShuffleSeed = date + "88"
            wall.shuffle(withSeed: true, seedString: challengeHandShuffleSeed, blankTiles: false, probabilisticDistribution: settings.probabilisticDistribution, card: card)
        } else {
            wall.shuffle(withSeed: settings.shuffleWithSeed, seedString: settings.shuffleSeed, blankTiles: settings.blankTiles && !challengeHand, probabilisticDistribution: settings.probabilisticDistribution, card: card)
        }
        east.tiles = wall.pullTiles(count: 14)
        south.tiles = wall.pullTiles(count: 13)
        west.tiles = wall.pullTiles(count: 13)
        north.tiles = wall.pullTiles(count: 13)
        
        // TESTING ONLY: Preload challenge hand with specific tiles for testing: FF 9 9 9 9 10 19 19 19 19 20 29 29
        // Adding one more 20 to make 14 tiles total
        // Skip charleston phase by setting state to 7
        // TODO: Remove this test code before production
        // if challengeHand == true {
        //     let challengeHandTiles: [Int] = [35, 9, 9, 9, 9, 10, 19, 19, 19, 19, 20, 20, 29, 29]
        //     east.setTiles(challengeHandTiles)
        //     charlestonState = 7  // Skip charleston phase for testing challenge hand
        // }
        
        setHistory()
        // Sort the east player's hand after dealing 14 tiles (independent of sort lock, unless expert mode is enabled)
        if !settings.expertMode {
            east.sort()
        }
        east.matchingTileSets.sort(settings: settings)
        south.matchingTileSets.sort(settings: settings)
        west.matchingTileSets.sort(settings: settings)
        north.matchingTileSets.sort(settings: settings)
        replayHand.tiles = east.tiles
        replaySouth.tiles = south.tiles
        replayWest.tiles = west.tiles
        replayNorth.tiles = north.tiles
        replayWall.tiles = wall.tiles
        specialCase2022Rack = []
        initialRackTileCount = 0  // Reset at start of game
        initialRackTileIds = []  // Reset at start of game
        
        // debugging
        /*east.tiles[0] = Tile(named: "2crak", num: 2, suit: "crak", id: 22, sortId: 2, sortNum: 2)
        east.tiles[1] = Tile(named: "2crak", num: 2, suit: "crak", id: 22, sortId: 2, sortNum: 2)
        east.tiles[2] = Tile(named: "3crak", num: 3, suit: "crak", id: 23, sortId: 3, sortNum: 3)
        east.tiles[3] = Tile(named: "3crak", num: 3, suit: "crak", id: 23, sortId: 3, sortNum: 3)
        east.tiles[4] = Tile(named: "3crak", num: 3, suit: "crak", id: 23, sortId: 3, sortNum: 3)
        east.tiles[5] = Tile(named: "green", num: 11, suit: "crak", id: 11, sortId: 4, sortNum: 4)
        east.tiles[6] = Tile(named: "green", num: 11, suit: "crak", id: 11, sortId: 4, sortNum: 4)
        east.tiles[7] = Tile(named: "green", num: 11, suit: "crak", id: 11, sortId: 4, sortNum: 4)
        east.tiles[8] = Tile(named: "green", num: 11, suit: "crak", id: 11, sortId: 4, sortNum: 4)
        east.tiles[9] = Tile(named: "4crak", num: 4, suit: "crak", id: 24, sortId: 5, sortNum: 5)
        east.tiles[10] = Tile(named: "4crak", num: 4, suit: "crak", id: 24, sortId: 5, sortNum: 5)
        east.tiles[11] = Tile(named: "4crak", num: 4, suit: "crak", id: 24, sortId: 5, sortNum: 5)
        east.tiles[12] = Tile(named: "5crak", num: 5, suit: "crak", id: 25, sortId: 6, sortNum: 6)
        east.tiles[13] = Tile(named: "5crak", num: 5, suit: "crak", id: 25, sortId: 6, sortNum: 6)
        charlestonState = 7*/
    }
   
    func replay() {
        wall.tiles = replayWall.tiles
        east.tiles = replayHand.tiles
        south.tiles = replaySouth.tiles
        west.tiles = replayWest.tiles
        north.tiles = replayNorth.tiles
        setHistory()
        charlestonState = 0
        state = State.east
        discardTile = nil
        charleston.tiles = []
        east.rack.tiles = []
        south.rack.tiles = []
        west.rack.tiles = []
        north.rack.tiles = []
        clearMessages()
        specialCase2022Rack = []
        wall.resetBlankTiles()
        east.resetBlankTiles()
        south.resetBlankTiles()
        west.resetBlankTiles()
        north.resetBlankTiles()
        // Clear bot target hands when replaying
        south.botTargetHand = nil
        west.botTargetHand = nil
        north.botTargetHand = nil
    }
    
    func setHistory() {
        east.setHistory(.east)
        east.rack.setHistory(.rack)
        south.setHistory(.bot)
        west.setHistory(.bot)
        north.setHistory(.bot)
    }
    
    
    // --------------------------------------------------------------
    //
    //  Sorting
    //
    // --------------------------------------------------------------
    
    func userSort() {
        switch(sortStyle) {
            case SortStyle.suits:
                east.sortNumbers()
                sortStyle = SortStyle.num
            case SortStyle.num:
                east.sort()
                sortStyle = SortStyle.suits
            default: break
        }
        settings.hideSortMessage = true
        defaults.set(settings.hideSortMessage, forKey: "hideSortMessage")
    }
     
    
    // --------------------------------------------------------------
    //
    //  Charleston
    //
    // --------------------------------------------------------------
    
    func isCharlestonActive() -> Bool {
        return charlestonState < 7
    }
    
    func isBlindPass() -> Bool {
        return charlestonState == 2 || charlestonState == 5
    }
    
    func isCourtesyPass() -> Bool {
        return charlestonState == 6
    }
    
    func isCharlestonOutDone() -> Bool {
        return (charleston.tiles.count == maxCharleston) || (charlestonState == 6) || ((charleston.tiles.count == 0) && (charlestonState == 3) || isBlindPass())
    }

    func charleston(hand: Player, rack: Rack) {
        let set = hand.getCharlestonSet(maj: self, rack: rack, count: charleston.tiles.count)
        for tile in set.tiles {
            if settings.lefty {
                east.tiles.insert(tile, at: 0)
            } else {
                east.tiles.append(tile)
            }
        }
        for tile in charleston.tiles {
            hand.tiles.append(tile)
        }
        charleston.tiles = []
        hand.matchingTileSets.countMatches(hand: hand, rack: rack, maj: self)
        hand.matchingTileSets.sort(settings: settings)
    }
    
    func nextCharleston(){
        charlestonState += 1
        switch charlestonState {
        case 0: break
        case 1: charleston(hand: south, rack: south.rack)
        case 2: charleston(hand: west, rack: west.rack)
        case 3: charleston(hand: north, rack: north.rack)
        case 4:
            if charleston.tiles.count == 0 {
                charlestonState = 7
            } else {
                charleston(hand: north, rack: north.rack)
            }
        case 5: charleston(hand: west, rack: west.rack)
        case 6: charleston(hand: south, rack: south.rack)
        case 7: charleston(hand: west, rack: west.rack)
        default: break
        }
        
        if (charlestonState == 7) && isWinBotEnabled() {
             botCharleston()
        }
    }

    func botCharleston() {
        // dumpBots()
        let southMatchCount = south.getBestBotHand().matchCount
        let westMatchCount = west.getBestBotHand().matchCount
        let northMatchCount = north.getBestBotHand().matchCount
        var bestBot = southMatchCount > westMatchCount ? south : west
        bestBot = northMatchCount > bestBot.getBestBotHand().matchCount ? north : bestBot
        switch(bestBot.name) {
          case "South":
              botCharlestonSwapTiles(source: west, dest: south)
              botCharlestonSwapTiles(source: north, dest: south)
              break
          case "West":
              botCharlestonSwapTiles(source: south, dest: west)
              botCharlestonSwapTiles(source: north, dest: west)
              break
          case "North":
              botCharlestonSwapTiles(source: south, dest: north)
              botCharlestonSwapTiles(source: west, dest: north)
              break
          default:
              break
        }
    }
  
    func botCharlestonSwapTiles(source: Player, dest: Player) {
        var tiles: [Tile] = []
        for tile in source.tiles {
          tiles.append(Tile(tile))
        }
        for tile in tiles {
            if !tile.isJoker() {
                let count = dest.getBestBotHand().matchCount
                dest.tiles.append(tile)
                dest.matchingTileSets.countMatches(hand: dest, rack: dest.rack, maj: self)
                dest.matchingTileSets.sort(settings: settings)
                let newCount = dest.getBestBotHand().matchCount
                if newCount > count {
                source.removeTile(tile)
                let discard = dest.getBestDiscard(maj: self, rack: dest.rack, withFlowers: true)
                source.tiles.append(discard)
                } else {
                  dest.removeTile(tile)
                }
            }
        }
        // print(dest.getBestBotHand().matchCount)
    }
    
    
    // --------------------------------------------------------------
    //
    //  Game State
    //
    // --------------------------------------------------------------
    
    func nextState() -> String {
        lastState = state
        lastDiscard = discardTile
        switch state {
        case State.north:
            state = State.east
            takeTurnEast()
            previousHandName = lastHandName
            lastHandName = east.name
            break
        case State.east:
            if south.call(maj: self, rack: south.rack) {
                state = State.south
                break
            }
            if west.call(maj: self, rack: west.rack) {
                state = State.west
                break
            }
            if north.call(maj: self, rack: north.rack) {
                state = State.north
                break
            }
            state = State.south
            takeTurn(hand: south, rack: south.rack)
            if south.declareMahjong(maj: self) {
                break
            }
            if west.call(maj: self, rack: west.rack) {
                state = State.west
                break
            }
            if north.call(maj: self, rack: north.rack) {
                state = State.north
                break
            }
            break
        case State.south:
            state = State.west
            takeTurn(hand: west, rack: west.rack)
            if west.declareMahjong(maj: self) {
                break
            }
            if north.call(maj: self, rack: north.rack) {
                state = State.north
                break
            }
            break
        case State.west:
            if south.call(maj: self, rack: south.rack) {
                state = State.south
                break
            }
            state = State.north
            takeTurn(hand: north, rack: north.rack)
            break
        default:
            break
        }
                       
        return stateLabel()
    }
    
    func takeTurnEast() {
        // print("Turn \(east.name)")
        discardTable.countTile(discardTile, increment: 1)
        discardTile = nil
        east.draw(self)
        // Remember rack tile count and IDs at start of turn
        initialRackTileCount = east.rack.tiles.count
        initialRackTileIds = east.rack.tiles.map { $0.id }
    }
    
    func hasRackChangedBySingleTile() -> Bool {
        let currentCount = east.rack.tiles.count
        let difference = abs(currentCount - initialRackTileCount)
        
        // Check if count changed by 1 or 2 tiles
        if difference >= 1 && difference <= 2 {
            let currentTileIds = east.rack.tiles.map { $0.id }
            
            // Count how many new tile IDs appeared
            var newTileIdCount = 0
            let uniqueCurrentIds = Set(currentTileIds)
            for tileId in uniqueCurrentIds {
                if !initialRackTileIds.contains(tileId) {
                    newTileIdCount += 1
                }
            }
            
            // If 2 new tile IDs appeared, let singles/pairs validation catch it
            if newTileIdCount >= 2 {
                return false
            }
            
            // If any new tile ID appeared (1 new ID), let singles/pairs validation catch it
            if newTileIdCount == 1 {
                return false
            }
            
            // No new IDs but count changed - this is modifying an existing meld (bad!)
            return true
        }
        
        return false
    }
    
    func takeTurn(hand: Player, rack: Rack) {
        if isWinBotEnabled() {
            hand.botDraw(self)
            if hand.onCall(maj: self) {
                hand.matchingTileSets.countMatches(hand: hand, rack: rack, maj: self)
            }
            if hand.declareMahjong(maj: self) {
                south.rackAllTiles()
                west.rackAllTiles()
                north.rackAllTiles()
                // print("\(hand.name) mahjong")
            } else {
                finishTurn(hand: hand, rack: rack)
            }
        } else {
            hand.botDraw(self)
            finishTurn(hand: hand, rack: rack)
        }
    }
    
    func finishTurn(hand: Player, rack: Rack) {
        replaceRackJokers(hand)
        if (hand.matchingTileSets.tileSets[0].matchCount == 0) {
            hand.matchingTileSets.countMatches(hand: hand, rack: rack, maj: self)
            hand.matchingTileSets.sort(settings: settings)
        }
        // Safety check: only count discard tile if it exists
        if discardTile != nil {
            discardTable.countTile(discardTile, increment: 1)
        }
        discardTile = hand.getDiscard(maj: self, rack: rack, withFlowers: wall.tiles.count < 50)
        hand.matchingTileSets.countMatches(hand: hand, rack: rack, maj: self)
        hand.matchingTileSets.sort(settings: settings)
    }
            
    func botWon() -> Bool {
        return isWinBotEnabled() && (south.declareMahjong(maj: self) || west.declareMahjong(maj: self) || north.declareMahjong(maj: self))
    }
    
    func getWinningBot() -> Player? {
        var hand: Player? = nil
        if botWon() {
            south.rack.message = south.name
            west.rack.message = west.name
            north.rack.message = north.name
        }
        if south.declareMahjong(maj: self) { hand = south }
        if west.declareMahjong(maj: self) { hand = west }
        if north.declareMahjong(maj: self) { hand = north }
        if hand != nil { hand!.rack.message = ("\(hand!.name) declared Mahjong") }
        return hand
    }
    
    func getWinningBotHand() -> String {
        var hand = ""
        let bot = getWinningBot()
        if bot != nil {
            let tileSet = bot!.getHighestMatch(maj: self)
            hand = getHandByIndex(tileSet.handId).string
        }
        return hand
    }
    
    func getWinningBotHandNote() -> String {
        var note = ""
        let bot = getWinningBot()
        if bot != nil {
                    let tileSet = bot!.getHighestMatch(maj: self)
        note = getHandNoteByIndex(tileSet.handId).string
        }
        return note
    }
    
    func isFirstFourDiscards() -> Bool {
        // Check if we're in the first 4 discards phase (one from each player) after Charleston
        // This is true when Charleston is complete and we haven't discarded 4 times yet
        guard !isCharlestonActive() else {
            return false
        }
        // Count total discards in the discard table
        // After Charleston, each player discards once = 4 total discards
        let totalDiscards = discardTable.getCount()
        return totalDiscards <= 4
    }
    
    func discardCalloutTip() -> String {
        let totalDiscards = discardTable.getCount()
        
        // Show callout when State.south and 1 discard has been made
        if state == State.south && totalDiscards == 1 {
            return "This discard is from the first player to your right. Drag it to your rack above\n your hand to call it, or drag it off screen to let the next player go."
        }
        
        // Show callout when State.west and 2 discards have been made
        if state == State.west && totalDiscards == 2 {
            return "This discard is from the player across from you.\nCall it, or drag it off screen."
        }
        
        // Show callout when State.north and 3 discards have been made
        if state == State.north && totalDiscards == 3 {
            return "This discard is from the player to your left. Call it, or drag it off screen.\nA tile from the wall will be added to your hand automatically for your turn."
        }
        
        // For first 4 discards phase
        guard isFirstFourDiscards() else {
            return ""
        }
        
        // Check if there's a tile in the discard position (first east discard)
        if totalDiscards == 0 && discardTile != nil {
            return "Drag this tile off screen to the right to complete the discard."
        }
        
        // Different messages based on how many discards have been made
        // Note: This assumes it's the player's turn (state == east)
        switch totalDiscards {
        case 0:
            return "Drag a tile from your hand here to discard"
        case 1:
            return "The first player has discarded. Drag a tile from your hand here to discard."
        case 2:
            return "Two players have discarded. Drag a tile from your hand here to discard."
        case 3:
            return "Three players have discarded. Drag a tile from your hand here to discard."
        default:
            return ""
        }
    }
    
    func charlestonCalloutTip() -> String {
        guard isCharlestonActive() else {
            return ""
        }
        
        let tileCount = charleston.tiles.count
        
        switch charlestonState {
        case 0: // First round
            if tileCount == 3 {
                return "Drag 1 tile off screen to the right to pass. Then 3 tiles from the player to your left will be added to your hand automatically."
            } else {
                return "Right: Drag 3 tiles from your hand here to pass to the player to your right, to start the Charleston"
            }
        case 1: // Second round
            if tileCount == 3 {
                return "Drag 1 of these tiles off screen to the right to pass"
            } else {
                return "Across: Drag 3 tiles here to pass to the player across from you"
            }
        case 2: // Third round (Blind Pass)
            if tileCount == 1 || tileCount == 2 {
                return "Drag a tile off screen to the right to blind pass\n or add more tiles from your hand"
            } else if tileCount == 3 {
                return "Drag 1 tile off screen to the right to pass"
            } else {
                return "Blind Pass: Drag 1-3 tiles here to pass to the player to your left, or drag an empty position off screen to blind pass all 3"
            }
        case 3: // Fourth round
            if tileCount == 3 {
                return "Drag 1 of these tiles off screen to the right to pass"
            } else {
                return "Second Left: Drag 3 tiles here to pass left again or drag an empty position off screen to the right to stop the Charleston"
            }
        case 4: // Fifth round
            if tileCount == 3 {
                return "Drag 1 of these tiles off screen to the right to pass"
            } else {
                return "Across: Drag 3 tiles here to pass across again"
            }
        case 5: // Sixth round
            if tileCount == 1 || tileCount == 2 {
                return "Drag a tile off screen to the right to blind pass\n or add more tiles from your hand"
            } else if tileCount == 3 {
                return "Drag 1 tile off screen to the right to pass"
            } else {
                return "Final Right: Drag 1-3 tiles here to pass or blind pass now"
            }
        case 6: // Courtesy Pass round
            if tileCount == 1 || tileCount == 2 {
                return "Drag a tile off screen to the right to pass\n or add more tiles from your hand"
            } else if tileCount == 3 {
                return "Drag 1 tile off screen to the right to pass"
            } else {
                return "Courtesy Pass: Drag 1-3 tiles here to pass across, or drag an\n empty position off screen to skip the courtesy pass"
            }
        default:
            return ""
        }
    }
    
    func stateLabel() -> String {
        var text = ""
        if isCharlestonActive() {
            switch(charlestonState) {
            case 0:
                if charleston.tiles.count == 3 {
                    text = settings.lefty ? "< Charleston right (South)\nDrag left to pass now" : "Charleston right (South) >\nDrag right to pass now"
                } else {
                                          text = settings.lefty ? "< Charleston right (South)\nDrag 3 tiles here to pass" : "Charleston right (South) >\nDrag 3 tiles here to pass"
                }
            case 1:
                if charleston.tiles.count == 3 {
                    text = settings.lefty ? "< Across (West)\nDrag left to pass now" : "Across (West) >\nDrag right to pass now"
                } else {
                                          text = settings.lefty ? "< Across (West)\nDrag 3 tiles here to pass" : "Across (West) >\nDrag 3 tiles here to pass"
                }
            case 2:
                if charleston.tiles.count == 0 {
                    text = settings.lefty ? "< First left (North)\nBlind Pass option" : "First left (North) >\nBlind Pass option"
                } else if charleston.tiles.count == 3 {
                                          text = settings.lefty ? "< First left (North)\nDrag left to pass now" : "First left (North) >\nDrag right to pass now"
                } else {
                                          text = settings.lefty ? "< First left (North)\nPass now or Drag more tiles" : "First left (North) >\nPass now or Drag more tiles"
                }
            case 3:
                if charleston.tiles.count == 0 {
                    text = settings.lefty ? "< Second left (North)\nOr drag left to stop Charleston" : "Second left (North) >\nOr drag right to stop Charleston"
                } else if charleston.tiles.count == 3 {
                                          text = settings.lefty ? "< Second left (North)\nDrag left to pass now" : "Second left (North) >\nDrag right to pass now"
                } else {
                                          text = settings.lefty ? "< Second left (North)\nDrag 3 tiles here to pass" : "Second left (North) >\nDrag 3 tiles here to pass"
                }
            case 4: text = settings.lefty ? "< Across (West)\n" : "Across (West) >\n"
            case 5: text = settings.lefty ? "< Last right (South)\nBlind Pass option" : "Last right (South) >\nBlind Pass option"
            case 6: text = settings.lefty ? "< Across (West)\nCourtesy Pass" : "Across (West) >\nCourtesy Pass"
            case 7: text = settings.lefty ? "< Discard" : "Discard >"
            default: break
            }
        } else {
            switch(state) {
            case State.east: text = settings.lefty ? "< Discard" : "Discard >"
            case State.south: text = "Discard from South"
            case State.west: text = "Discard from West"
            case State.north: text = "Discard from North"
            default: break
            }
        }
        if isWinBotEnabled() && botWon() {
            text = ""
        }
        // print(charleston.tiles.count)
        return text
    }
    
    func unrecognizedHandDeclared() -> Bool {
        var unrecognizedHand = false
        let message = card.winningHand(maj: self)
        if (east.rack.tiles.count == 14) && (message.count == 0) {
            unrecognizedHand = true
        }
        return unrecognizedHand
    }
    
    func isWinBotEnabled() -> Bool {
        return settings.winBotEnabled
    }
    
    
    // --------------------------------------------------------------
    //
    //  Racks
    //
    // --------------------------------------------------------------

    func rackTiles() -> [Tile] {
        return east.rack.tiles
    }
 
    func replaceRackJokers(_ hand: Player) {
        // Clear jokerExchanged flag before checking
        jokerExchanged = false
        jokerExchangeRackOwner = ""
        
        // Clear messages before checking
        east.rack.message = ""
        south.rack.message = ""
        west.rack.message = ""
        north.rack.message = ""
        
        // Replace jokers in all racks and collect exchange information
        var allExchanges: [(tileName: String, jokerRackOwner: String)] = []
        allExchanges.append(contentsOf: east.rack.replaceJokers(hand))
        allExchanges.append(contentsOf: south.rack.replaceJokers(hand))
        allExchanges.append(contentsOf: west.rack.replaceJokers(hand))
        allExchanges.append(contentsOf: north.rack.replaceJokers(hand))
        
        // Set message on the initiating player's rack (the one whose turn it is)
        if !allExchanges.isEmpty {
            let messages = allExchanges.map { "\(hand.name) exchanged \($0.tileName) for Joker" }
            hand.rack.message = messages.joined(separator: ", ")
            // Store the joker rack owner (use the first exchange's joker rack owner)
            jokerExchangeRackOwner = allExchanges[0].jokerRackOwner
            jokerExchanged = true
        }
    }
    
    func validateRack() -> String{
        return enableRules ? east.rack.validate() : ""
    }
    
    func validateMahjong() -> Bool {
        var wins: [Hand]
        
        if discardTile != nil {
            wins = card.getAllMatchingWins(tiles: east.tiles + east.rack.tiles + [discardTile])
        } else {
            wins = card.getAllMatchingWins(tiles: east.tiles + east.rack.tiles)
        }
        
        // Use the new non-destructive validation that doesn't consume jokers
        for win in wins {
            if doubleCheckForMahjongNonDestructive(win) {
                return true
            }
        }
        
        return false
    }
    
    // New method to detect multiple valid winning hands (e.g., when jokers can match multiple patterns)
    func getAllValidWinningHands() -> [Hand] {
        var validWins: [Hand] = []
        var wins: [Hand]
        
        let allTiles = east.tiles + east.rack.tiles
        
        if discardTile != nil {
            wins = card.getAllMatchingWins(tiles: allTiles + [discardTile])
        } else {
            wins = card.getAllMatchingWins(tiles: allTiles)
        }
        
        for win in wins {
            if doubleCheckForMahjongNonDestructive(win) {
                validWins.append(win)
            }
        }
        
        return validWins
    }
    
    // Get the first valid winning hand using the new robust validation logic
    func getFirstValidWinningHand() -> Hand? {
        return getAllValidWinningHands().first
    }
    
    // Non-destructive version of doubleCheckForMahjong that doesn't consume jokers
    // This allows checking multiple patterns without side effects
    // We use a mathematical tile counting approach that doesn't depend on pre-assigned jokers
    private func doubleCheckForMahjongNonDestructive(_ hand: Hand) -> Bool {
        var valid = false
        
        // Check each possible id list using non-destructive counting
        for ids in hand.idList.list {
            // Use our non-destructive count check that creates fresh tile vectors
            if doubleCheckCountNonDestructive(ids, hand: hand) {
                // Check special pattern rules that don't depend on joker state
                if !doubleCheck_FFFF_2022_222_222(ids, hand: hand) {
                    continue
                }
                if !doubleCheck_FF_2022_2022_2022(ids, hand: hand) {
                    continue
                }
                if !doubleCheck_FFFF_11_111_111_11(ids, hand: hand) {
                    continue
                }
                
                valid = true
                break
            }
        }
        
        // Do the dejoker check if we have exposed tiles
        if valid && east.tiles.count > 0 {
            valid = dejokerCheckForMahjong()
        }
        
        return valid
    }
    
    // Non-destructive version that creates a fresh copy of tiles for each validation
    private func doubleCheckCountNonDestructive(_ list: ExtendedIdList, hand: Hand) -> Bool {
        // remove rack tiles
        var remainder = list.ids;
        for tile in east.rack.tiles {
            for (index, id) in remainder.enumerated() {
                if tile.id == id || tile.jokerId == id {
                    remainder.remove(at: index)
                    break
                }
            }
        }
              
        // tile maps - create FRESH copies each time (don't modify originals)
        let originalVector = TileVector(list.ids)
        let remainderVector = TileVector(remainder)
        // Create hand vector from all tiles (hand + rack), counting jokers at position 36
        let allTiles = east.tiles + east.rack.tiles
        let handVector = TileVector(tiles: allTiles)  // Fresh copy - jokers counted as id 36
        if discardTile != nil && !discardTile.isJoker() {
            handVector.vector[discardTile.id] += 1
        }
        
        // Work on the copies - subtract hand tiles from remainder tiles
        for (index, count) in remainderVector.vector.enumerated() {
            if count != 0 && index != 36 {
                remainderVector.vector[index] -= handVector.vector[index]
                handVector.vector[index] = 0
                if remainderVector.vector[index] != 0 && handVector.vector[36] >= remainderVector.vector[index] {
                    if list.singles != index && originalVector.vector[index] > 2 {
                        handVector.vector[36] -= remainderVector.vector[index]  // Only affects local copy
                        remainderVector.vector[index] = 0
                    }
                }
            }
        }
        let remainderCount = remainderVector.vector.reduce(0, +)
        return remainderCount == 0
    }
    
    func rackOpponentHands() {
        south.rack.rackAll(south)
        west.rack.rackAll(west)
        north.rack.rackAll(north)
        south.rack.sort()
        west.rack.sort()
        north.rack.sort()
        south.tiles = []
        west.tiles = []
        north.tiles = []
    }
 
    func discardLastDiscard(){
        if discardTile != nil {
            discardTable.countTile(discardTile, increment: 1)
            discardTile = nil
        }
    }
        
    func stealJoker(tile: Tile) -> Bool {
        var found = false
        if south.rack.replaceJoker(tile) {
            found = true
        }
        else if west.rack.replaceJoker(tile) {
            found = true
        }
        else if north.rack.replaceJoker(tile) {
            found = true
        }
        
        if found {
            east.removeTile(tile)
            east.addJoker()
        }
        return found
    }
    
    
    // --------------------------------------------------------------
    //
    //  Double Check
    //
    // --------------------------------------------------------------
        
    func doubleCheckForMahjong(_ closest: Hand) -> Bool {
        var valid = false;
        for ids in closest.idList.list {
            if doubleCheckIds(ids, hand: closest) {
                valid = true
                break
            }
        }
        if valid && east.tiles.count > 0 {
            valid = dejokerCheckForMahjong()
        }
        return valid
    }
    
    // make sure the jokers in the rack are not used to complete sets in the hand
    // first tile is never a joker
    private func dejokerCheckForMahjong() -> Bool {
        var valid = true
        let dejokerRack = Rack("dejoker")
        for tile in east.rack.tiles {
            dejokerRack.tiles.append(Tile(tile))
        }
        var previousTile: Tile?
        for tile in dejokerRack.tiles {
            if tile.isJoker() && previousTile != nil {
                tile.copy(previousTile!)
            }
            previousTile = tile
        }
        dejokerRack.printTiles()
        
        if discardTile != nil {
            let closest = card.getClosestHand(tiles: east.tiles + dejokerRack.tiles + [discardTile])
            valid = closest.matchCount == 14
        } else {
            let closest = card.getClosestHand(tiles: east.tiles + dejokerRack.tiles)
            valid = closest.matchCount == 14
         }
        
        return valid
    }
    
    private func doubleCheckIds(_ list: ExtendedIdList, hand: Hand) -> Bool {
        var valid = true
        if hand.text.string == "FFFF DDD 2023 DDD" {
            valid = doubleCheck_FFFF_DDD_2023_DDD()
        } else {
            valid = doubleCheckCount(list, hand: hand);
        }
        if hand.text.string == "2025 222 555 DDDD" {
            //valid = doubleCheck_FFFF_DDD_2023_DDD()
        } else {
            valid = doubleCheckCount(list, hand: hand);
        }
        if valid { valid = doubleCheckRack(list, hand: hand) }
        print("doubleCheckRack \(valid)")
        if valid { valid = doubleCheck_FFFF_2022_222_222(list, hand: hand) }
        if valid { valid = doubleCheck_FF_2022_2022_2022(list, hand: hand) }
        if valid { valid = doubleCheck_FFFF_11_111_111_11(list, hand: hand) }
        print("doubleCheckIds \(valid)")
        return valid
    }
    
    private func doubleCheck_FFFF_DDD_2023_DDD() -> Bool {
        var twosInHand = false
        var soapsInHand = false
        for tile in east.tiles {
            if tile.id == 2 || tile.id == 12 || tile.id == 22 {
                twosInHand = true
            }
            if tile.id == 10 {
                soapsInHand = true
            }
        }

        var soapInDiscard = false
        if discardTile != nil {
            if discardTile.id == 10 {
                soapInDiscard = true
            }
        }

        // doubleCheck_FFFF_DDD_2023_DDD
        if twosInHand == true && soapsInHand == false && soapInDiscard == false {
            print("doubleCheck_FFFF_DDD_2023_DDD false")
            return false
        }
        print("doubleCheck_FFFF_DDD_2023_DDD true")
        return true
    }
        
    private func   doubleCheckCount(_ list: ExtendedIdList, hand: Hand) -> Bool {
        // remove rack tiles
        var remainder = list.ids;
        for tile in east.rack.tiles {
            for (index, id) in remainder.enumerated() {
                if tile.id == id || tile.jokerId == id {
                    remainder.remove(at: index)
                    break
                }
            }
        }
        
        if remainder.count == 0 {
            print("doubleCheckCount \(hand.text.string)")
            print(list.ids)
            print("remainder \(remainder.count)")
            //return true
        }
              
        // tile maps
        let originalVector = TileVector(list.ids)
        let remainderVector = TileVector(remainder)
        let handVector = TileVector(tiles: east.tiles)
        if discardTile != nil && !discardTile.isJoker() {
            handVector.vector[discardTile.id] += 1
        }
        
        // subtract hand tiles from remainder tiles
        for (index, count) in remainderVector.vector.enumerated() {
            if count != 0 && index != 36 {
                remainderVector.vector[index] -= handVector.vector[index]                   // subtract tiles
                handVector.vector[index] = 0
                if remainderVector.vector[index] != 0 && handVector.vector[36] >= remainderVector.vector[index] {
                    if list.singles != index && originalVector.vector[index] > 2 {    // check for singles and pairs
                        handVector.vector[36] -= remainderVector.vector[index]              // subtract jokers
                        remainderVector.vector[index] = 0
                    }
                }
            }
        }
        let remainderCount = remainderVector.vector.reduce(0, +)
        print("doubleCheckCount \(remainderCount == 0)")
        return remainderCount == 0
    }
    
    //
    // This is a unique hand. The first and last pairs are the same tile. We need 4 real tiles.
    // Jokers wont work for these tiles because of singles and pairs rules.
    // list.singles is the index in the tile id maps for the pairs
    // If the last tile we need to declare mahjong is discarded we can pick it up even if its for a pair.
    //
    private func doubleCheck_FFFF_11_111_111_11(_ list: ExtendedIdList, hand: Hand) -> Bool {
        var valid = true
        if hand.text.string == "FFFF 11 111 111 11" {
            let rackVector = TileVector(tiles: east.rack.tiles)
            let handVector = TileVector(tiles: east.tiles)
            var singles = rackVector.vector[list.singles] + handVector.vector[list.singles]
            if discardTile != nil && discardTile.id == list.singles { singles += 1 }
            valid = singles == 4
            print("doubleCheck_FFFF_11_111_111_11 \(valid)")
        }
        return valid
    }
        
    //
    // If the 2s from 2022 are posted but soap is not posted it cant be this pattern
    //
    private func doubleCheck_FFFF_2022_222_222(_ list: ExtendedIdList, hand: Hand) -> Bool {
        var valid = true
        if hand.year == Year.y2022 && hand.id == 2 {
            let rackVector = TileVector(rack: east.rack)
            if rackVector.vector[10] == 0 && rackVector.vector[list.singles] != 0 {
                valid = false
            }
        }
        return valid
    }
    
    //
    // No jokers allowed in this pattern
    //
    private func doubleCheck_FF_2022_2022_2022(_ list: ExtendedIdList, hand: Hand) -> Bool {
        var valid = true
        if list.singles == Singles.ff_2022_2022_2022 {
            if east.jokerCount() != 0 || east.rack.jokerCount() != 0 {
                valid = false
            }
        }
        return valid
    }
    
    //
    // Rack count has to match excactly for each, we cant add more tiles to a set later
    //
    // special case: "FFFF DDD 2023 DDD - 3 of the 4 soaps are on the rack are ok
    //
    private func doubleCheckRack(_ list: ExtendedIdList, hand: Hand) -> Bool {
        var valid = true
        let rackVector = TileVector(rack: east.rack)   // accounts for jokers
        let idVector = TileVector(list.ids)
        for (index, count) in rackVector.vector.enumerated() {
            if count != 0 && index < 35 {
                if hand.text.string == "FFFF DDD 2023 DDD" && index == 10 && idVector.vector[index] == 4 && count == 3 {
                    continue
                } else if hand.text.string == "2025 222 555 DDDD" && index == 10 && idVector.vector[index] == 5 && count == 4 {
                    continue
                } else if count != idVector.vector[index] {
                    valid = false
                    break
                }
            }
        }
        if valid {
            if rackVector.flowerCount() == 3 {
                if !(idVector.flowerCount() == 3 || idVector.flowerCount() == 6) {
                    valid = false
                }
            } else if rackVector.flowerCount() > 0 && (rackVector.flowerCount() != idVector.flowerCount()) {
                valid = false
            }
        }

        return valid
    }
    
    // --------------------------------------------------------------
    //
    //  Logging
    //
    // --------------------------------------------------------------
    
    func printHands()  {
        east.printTiles()
        south.printTiles()
        west.printTiles()
        north.printTiles()
        wall.printTiles()
        discardTable.printCounts()
    }
    
    // --------------------------------------------------------------
    //
    //  Tile Movement
    //
    // --------------------------------------------------------------
    
    /// Moves a tile within a player's hand from one position to another
    /// - Parameters:
    ///   - player: The player whose hand to modify
    ///   - startIndex: The starting position of the tile
    ///   - endIndex: The ending position for the tile
    /// - Returns: true if the move was successful, false otherwise
    func moveTileInHand(player: Player, startIndex: Int, endIndex: Int) -> Bool {
        // Index validation
        guard startIndex >= 0 && startIndex < player.tiles.count else {
            print("moveTileInHand: Invalid startIndex \(startIndex), hand count: \(player.tiles.count)")
            return false
        }
        
        guard endIndex >= 0 && endIndex <= player.tiles.count else {
            print("moveTileInHand: Invalid endIndex \(endIndex), hand count: \(player.tiles.count)")
            return false
        }
        
        // If start and end are the same, no move needed
        if startIndex == endIndex {
            return true
        }
        
        // Perform the tile movement
        let tile = player.tiles.remove(at: startIndex)
        if endIndex >= player.tiles.count {
            player.tiles.append(tile)
        } else {
            player.tiles.insert(tile, at: endIndex)
        }
        
        return true
    }
    
    /// Swaps a tile within a player's rack from one position to another
    /// - Parameters:
    ///   - player: The player whose rack to modify
    ///   - startIndex: The starting position of the tile
    ///   - endIndex: The ending position for the tile
    /// - Returns: true if the swap was successful, false otherwise
    func swapTileInRack(player: Player, startIndex: Int, endIndex: Int) -> Bool {
        // Index validation
        guard startIndex >= 0 && startIndex < player.getRackCount() else {
            print("swapTileInRack: Invalid startIndex \(startIndex), rack count: \(player.getRackCount())")
            return false
        }
        
        guard endIndex >= 0 else {
            print("swapTileInRack: Invalid endIndex \(endIndex), rack count: \(player.getRackCount())")
            return false
        }
        
        // If start and end are the same, no swap needed
        if startIndex == endIndex {
            return true
        }
        
        // Perform the tile swap
        let tile = player.removeFromRack(startIndex)
        // Force joker to initialRackTileCount + 1 instead of before initialRackTileCount to avoid error
        var adjustedEndIndex = endIndex
        if tile.isJoker() && endIndex <= initialRackTileCount && player.getRackCount() != 0 {
            adjustedEndIndex = initialRackTileCount + 1
        }
        player.addToRack(tile, index: adjustedEndIndex)
        
        // Mark jokers after the swap
        player.rack.markJokers()
        
        return true
    }
    
}

