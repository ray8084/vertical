//
//  Player.swift
//  Mahjong2017
//
//  Created by Ray on 8/11/16.
//  Copyright © 2017 EightBam LLC. All rights reserved.
//

import Foundation
import GameKit

class Player: TileList {
    var name: String
    var rack: Rack
    let matchingTileSets = MatchingTileSets()
    var message = ""
    var testJokerExchange = true
    var botTargetHand: TileSet?  // Hand bot is working on after first call
    // var winBot = false
    
    // --------------------------------------------------------------
    //  copy
    
    func copy(_ copy: Player) {
        super.copy(copy as TileList)
        name = copy.name
        rack = Rack("")
        rack.copy(copy.rack)
        //tileMatches = TileMatches()
        message = copy.message
        testJokerExchange = copy.testJokerExchange
        botTargetHand = copy.botTargetHand
        // winBot = copy.winBot
    }
    
    
    // --------------------------------------------------------------
    //  init
    
    init(_ name: String) {
        self.name = name
        self.rack = Rack(name)
        super.init()
    }
    
    override func setTiles(_ ids: [Int]) {
        self.tiles = ids.map { id in
            return Tile(id: id)
        }
    }

    
    // --------------------------------------------------------------
    //  counts
    
    func getHighestMatch(maj: Maj) -> TileSet {
        if matchingTileSets.tileSets[0].matchCount == 0 {
            matchingTileSets.countMatches(hand: self, rack: rack, maj: maj)
            matchingTileSets.sort(settings: maj.settings)
        }
        return matchingTileSets.tileSets[0]
    }
    
    func resetHighestMatch(maj: Maj) {
        matchingTileSets.countMatches(hand: self, rack: rack, maj: maj)
        matchingTileSets.sort(settings: maj.settings)
    }
    
    func declareMahjong(maj: Maj) -> Bool {
        let matchCount = getHighestMatch(maj: maj).matchCount       // we had it
        let totalTiles = tiles.count + rack.tiles.count    // do we still have it
        if matchCount == 14 && totalTiles != 14 {
            // print("declareMahjong todo")                    // we had mahjong and we lost it somehow
        }
        let declare = (matchCount == 14) && (totalTiles == 14)     // matchcount can be old so double check it
        if declare {
            rack.message = "\(name) declared Mahjong"
        }
        return declare
    }
    
    func onCall(maj: Maj) -> Bool {
        let matchCount = getHighestMatch(maj: maj).matchCount
        return matchCount == 13
    }
    
    func countMatches(maj: Maj) {
        matchingTileSets.countMatches(hand: self, rack: rack, maj: maj)
        matchingTileSets.sort(settings: maj.settings)
    }
    
    
    // --------------------------------------------------------------
    //  charleston
    
    func getCharlestonSet(maj: Maj, rack: Rack, count: Int) -> Player {
        let set = Player("")
        var tries = 0
        while set.tiles.count < count {
            let discard = getDiscard(maj: maj, rack: rack, withFlowers: false)
            var found = false
            for tile in set.tiles {
                // try to avoid passing pairs
                if tile.isEqual(discard) {
                    found = true
                    break
                }
                // try to avoid passing multiple winds
                if tile.isWind() && discard.isWind() {
                    found = true
                    break
                }
            }
            if found == true {
                // put it back
                tiles.append(discard)
            } else {
                // use it
                set.tiles.append(discard)
            }
            tries += 1
            if tries == tiles.count {
                break
            }
        }
        // couldnt find a good set, ok to pass pairs now
        while set.tiles.count < count {
            set.tiles.append(getDiscard(maj: maj, rack: rack, withFlowers: false))
        }
        return set
    }
    
    
    // --------------------------------------------------------------
    //  discard
    
    func getDiscard(maj: Maj, rack: Rack, withFlowers: Bool) -> Tile {
        maj.previousHandName = maj.lastHandName
        maj.lastHandName = name
        return getBestDiscard(maj: maj, rack: rack, withFlowers: withFlowers)
    }
    
    override func exists(tile: Tile) -> Bool {
        var exists = false
        for t in tiles {
            if t.id == tile.id {
                exists = true
                break
            }
        }
        return exists
    }
    
    override func shuffle(withSeed: Bool, seedString: String) {
        if withSeed {
            shuffleWithSeed(seedString)
        } else {
            shuffleRandom()
        }
    }
    
    override func shuffleRandom() {
        if tiles.count > 0 {
            let range: UInt32 = UInt32(tiles.count)
            for _ in 1...10 {
                let tile1 = tiles.remove(at: Int(arc4random_uniform(range)))
                tiles.insert(tile1, at: 0)
                let index = abs(GKRandomSource.sharedRandom().nextInt() % tiles.count)
                let tile2 = tiles.remove(at: index)
                tiles.insert(tile2, at: 0)
            }
        } else {
            print("no tiles to shuffle")
        }
    }
    
    override func shuffleWithSeed(_ seedString: String) {
        let range = tiles.count
        let seed = seedString.isEmpty ? "0".data(using: .utf8) : seedString.lowercased().data(using: .utf8)
        let source = GKARC4RandomSource(seed: seed!)
        for _ in 1...3000 {
            let index1 = abs(source.nextInt() % range)
            let tile1 = tiles.remove(at: index1)
            tiles.insert(tile1, at: 0)
            let index = abs(source.nextInt() % range)
            let tile2 = tiles.remove(at: index)
            tiles.insert(tile2, at: 0)
        }
    }
    
    
    // --------------------------------------------------------------
    //  drawing from the wall
    
    override func draw(_ maj: Maj) {
        if maj.settings.lefty {
            tiles.insert(maj.wall.tiles.remove(at: 0), at: 0)
        } else {
            tiles.append(maj.wall.tiles.remove(at: 0))
        }
    }
    
    
    // --------------------------------------------------------------
    //  sorting
    
    override func getSortedTiles() -> Player {
        let sortedTiles = Player("")
        for tile in tiles {
            let newTile = Tile(named: tile.name, num: tile.number, suit: tile.suit, id: tile.id, sortId: tile.sortId, sortNum: tile.sortNumbers)
            sortedTiles.tiles.append(newTile)
        }
        sortedTiles.sort()
        return sortedTiles
    }
    
    func finalSortEastRack(_ maj: Maj) {
        matchingTileSets.countMatchesForEastNoFilters(maj)
        matchingTileSets.sort(settings: maj.settings)
        let best = matchingTileSets.tileSets[0].tileIds
        let handId = matchingTileSets.tileSets[0].handId
        let year = maj.settings.year
        rack.tiles = finalSort(maj, hand: rack, best: best, handId: handId, year: year)
    }
    
    func finalSort(_ maj: Maj, hand: TileList, best: [Int], handId: Int, year: Int) -> [Tile] {
        var oldTiles: [Tile] = hand.tiles
        var newTiles: [Tile] = []
        for tileId in best {
            var found = false
            for (index, tile) in oldTiles.enumerated() {
                if tile.id == tileId {
                    newTiles.append(tile)
                    oldTiles.remove(at: index)
                    found = true
                    break
                }
            }
            if found == false {
                for (index, tile) in oldTiles.enumerated() {
                    if tile.isJoker() {
                        tile.jokerId = tileId
                        newTiles.append(tile)
                        oldTiles.remove(at: index)
                        found = true
                        break
                    }
                }
            }
        }
        
        // leftover tiles
        newTiles.append(contentsOf: oldTiles)
        
        // fix pattern FFFF 000 2J23 DDD
        print(year)
        if year == Year.y2023 && handId == 2 {
            if newTiles[8].isJoker() {
                if newTiles[6].id == 10 {
                    let joker = newTiles.remove(at: 8)
                    let soap = newTiles.remove(at: 6)
                    newTiles.insert(joker, at: 6)
                    newTiles.insert(soap, at: 8)
                } else if newTiles[5].id == 10 {
                    let joker = newTiles.remove(at: 8)
                    let soap = newTiles.remove(at: 5)
                    newTiles.insert(joker, at: 5)
                    newTiles.insert(soap, at: 8)
                } else if newTiles[4].id == 10 {
                    let joker = newTiles.remove(at: 8)
                    let soap = newTiles.remove(at: 4)
                    newTiles.insert(joker, at: 4)
                    newTiles.insert(soap, at: 8)
                }
            }
        }
        return newTiles
    }
    
    
    
    // --------------------------------------------------------------
    //  rack methods - todo move to rack object
    
    func rackTiles(rack: Rack, tileId: Int, count: Int) {
        for _ in 1...count {
            for (index, tile) in tiles.enumerated() {
                if tile.id == tileId {
                    let tile = tiles.remove(at:index)
                    let newTile = Tile(tile)
                    rack.tiles.append( newTile )
                    break
                }
            }
            //print("rackTiles count \(count):\(i)" )
        }
    }
    
    func rackAllTiles() {
        for tile in tiles {
            rack.tiles.append(tile)
        }
        rack.sort()
        tiles.removeAll()
    }
    
    func rackJokers(rack: Rack, id: Int, suit: String, number: Int, count: Int) {
        for _ in 1...count {
            for (index, tile) in tiles.enumerated() {
                if tile.isJoker() {
                    let joker = tiles.remove(at:index)
                    joker.jokerId = id
                    joker.jokerSuit = suit
                    joker.jokerNumber = number
                    rack.tiles.append(joker)
                    break
                }
            }
            //print("rackJokers count \(count):\(i)" )
        }
    }
    
    func getRackCount() -> Int {
        return rack.tiles.count
    }
    
    func removeFromRack(_ index: Int) -> Tile {
        return rack.tiles.remove(at: index)
    }
    
    func addToRack(_ tile: Tile, index: Int) {
        if index >= getRackCount() {
            rack.tiles.append(tile)
        } else {
            rack.tiles.insert(tile, at: index)
        }
    }
    
    
    // --------------------------------------------------------------
    //  filters
    
    // moved to DisplayFilters
    
    
    // -----------------------------------------------------------------------------------------
    //
    //  Recount Discard Table
    //
    // -----------------------------------------------------------------------------------------
    
    override func recount(_ discardTable: DiscardTable) {
        var jokerCount = 0
        for tile in tiles {
            if tile.isJoker() {
                jokerCount += 1
                discardTable.jokerCount -= 1
            }
            else if tile.suit == "dot" {
                discardTable.dotCount[tile.number-1] -= 1
            }
            else if tile.suit == "bam" {
                discardTable.bamCount[tile.number-1] -= 1
            }
            else if tile.suit == "crak" {
                discardTable.crakCount[tile.number-1] -= 1
            }
            else if tile.isWind() {
                discardTable.wndCount[tile.number-1] -= 1
            }
            else if tile.isFlower() {
                discardTable.flowerCount -= 1
            }
            else if tile.isBlankTile() {
                discardTable.blankCount -= 1
            }
        }
        print("hand \(name) jokerCount \(jokerCount)" )
    }
    

    // -----------------------------------------------------------------------------------------
    //
    //  Reset Blank Tiles
    //
    // -----------------------------------------------------------------------------------------
    
    // -----------------------------------------------------------------------------------------
    //
    //  Charleston Categories
    //
    // -----------------------------------------------------------------------------------------
    
}
