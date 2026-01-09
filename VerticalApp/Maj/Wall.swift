//
//  Wall.swift
//  Mahjong2017
//
//  Created by Ray on 8/10/16.
//  Copyright © 2017 EightBam LLC. All rights reserved.
//

import Darwin
import Foundation
import GameKit

class Wall {
    var tiles: [Tile] = []
    static var shuffleHands: [Int] = Array(repeating: 0, count: 100) // Track which hands we've used - singleton
    static var shuffleHandsCounter: Int = 0 // Count of unique hands used
    
    func copy(_ copy: Wall) {
        tiles = []
        for tile in copy.tiles {
            tiles.append(Tile(tile))
        }
    }
    
    init(blankTiles: Bool) {
        loadTiles(blankTiles: blankTiles)
    }
    
    func loadTiles(blankTiles: Bool) {
        tiles = []
        for loop in 1...4 {
            for index in 1...9 {
                let sortNum = 7 + (index * 3)
                tiles.append(Tile(named: "\(index)dot", num: index, suit: "dot", id: index, sortId: index+10, sortNum: sortNum))
            }
            for index in 1...9 {
                let sortNum = 8 + (index * 3)
                tiles.append(Tile(named: "\(index)bam", num: index, suit: "bam", id: index+10, sortId: index+20, sortNum: sortNum))
            }
            for index in 1...9 {
                let sortNum = 9 + (index * 3)
                tiles.append(Tile(named: "\(index)crak", num: index, suit: "crak", id: index+20, sortId: index+30, sortNum: sortNum))
            }
            appendJoker()
            appendJoker()
            tiles.append(Tile(named: "red", num: 10, suit: "crak", id: 30, sortId: 43, sortNum: 43))
            tiles.append(Tile(named: "green", num: 10, suit: "bam", id: 20, sortId: 42, sortNum: 42))
            tiles.append(Tile(named: "soap", num: 10, suit: "dot", id: 10, sortId: 41, sortNum: 41))
            tiles.append(Tile(named: "north", num: 1, suit: "wnd", id: 31, sortId: 51, sortNum: 51))
            tiles.append(Tile(named: "south", num: 2, suit: "wnd", id: 32, sortId: 52, sortNum: 52))
            tiles.append(Tile(named: "west", num: 3, suit: "wnd", id: 33, sortId: 53, sortNum: 53))
            tiles.append(Tile(named: "east", num: 4, suit: "wnd", id: 34, sortId: 54, sortNum: 54))
            tiles.append(Tile(named: "f\(loop)", num: 12, suit: "flwr", id: 35, sortId: 1, sortNum: 1))
        }
        tiles.append(Tile(named: "sum", num: 12, suit: "flwr", id: 35, sortId: 2, sortNum: 2))
        tiles.append(Tile(named: "aut", num: 12, suit: "flwr", id: 35, sortId: 3, sortNum: 3))
        tiles.append(Tile(named: "win", num: 12, suit: "flwr", id: 35, sortId: 4, sortNum: 4))
        tiles.append(Tile(named: "spr", num: 12, suit: "flwr", id: 35, sortId: 5, sortNum: 5))
        
        if blankTiles {
            tiles.append(Tile(named: "blank", num: 37, suit: "blank", id: 37, sortId: 56, sortNum: 56))
            tiles.append(Tile(named: "blank", num: 37, suit: "blank", id: 37, sortId: 56, sortNum: 56))
        }
    }
    
    func appendJoker() {
        let joker = Tile(named: "joker", num: 11, suit: "jkr", id: 36, sortId: 55, sortNum: 55)
        joker.jokerFlag = true
        tiles.append(joker)
    }
    
    func shuffle(withSeed: Bool, seedString: String, blankTiles: Bool, probabilisticDistribution: Bool = true, card: Card? = nil) {
        // print("wall.shuffle \(seedString)")
        if withSeed {
            shuffleWithSeed(seedString, blankTiles: blankTiles)
        } else {
            // Check probabilistic distribution setting
            if probabilisticDistribution {
                shuffleRandom(blankTiles: blankTiles)
            } else {
                shuffleUniformRandom(blankTiles: blankTiles, card: card)
            }
        }
    }

    func shuffleRandom(blankTiles: Bool) {
        loadTiles(blankTiles: blankTiles)
        let range: UInt32 = UInt32(tiles.count)
        for _ in 1...3000 {
            let tile1 = tiles.remove(at: Int(arc4random_uniform(range)))
            tiles.insert(tile1, at: 0)
            let index = abs(GKRandomSource.sharedRandom().nextInt() % 152)
            let tile2 = tiles.remove(at: index)
            tiles.insert(tile2, at: 0)
        }
    }
    
    func shuffleWithSeed(_ seedString: String, blankTiles: Bool) {
        loadTiles(blankTiles: blankTiles)
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
    
    func shuffleUniformRandom(blankTiles: Bool, card: Card? = nil) {
        loadTiles(blankTiles: blankTiles)
        
        // print("shuffleUniformRandom called with shuffleHands: \(Wall.shuffleHands)")
        
        // Check if we've used 60 unique hands, if so reset the flags and counter
        if Wall.shuffleHandsCounter >= 60 {
            Wall.shuffleHands = Array(repeating: 0, count: 100)
            Wall.shuffleHandsCounter = 0
            print("60 unique hands used, resetting shuffleHands flags and counter")
        }
        
        var attempts = 0
        let maxAttempts = 50 // Prevent infinite loops
        
        while attempts < maxAttempts {
            // Perform uniform random shuffle
            let range = tiles.count
            for i in 0..<range {
                let randomIndex = Int(arc4random_uniform(UInt32(range - i)))
                tiles.swapAt(i, i + randomIndex)
            }
            
            // Check the ID of the closest matching hand based on first 14 tiles
            if tiles.count >= 14, let card = card {
                let first14Tiles = Array(tiles[0..<14])
                let closestHand = card.getClosestHand(tiles: first14Tiles)
                let handId = closestHand.id
                
                // print("Attempt \(attempts + 1): First 14 tiles: \(first14Tiles.map { $0.id })")
                // print("Closest hand ID: \(handId), match count: \(closestHand.matchCount)")
                
                // Check if this hand hasn't been used yet
                if handId < Wall.shuffleHands.count && Wall.shuffleHands[handId] == 0 {
                    Wall.shuffleHands[handId] = 1
                    Wall.shuffleHandsCounter += 1
                    // print("Using hand ID \(handId) - setting flag to 1 (counter: \(Wall.shuffleHandsCounter))")
                    // print("ShuffleHands state: \(Wall.shuffleHands.prefix(20))...") // Show first 20 for debugging
                    return // Found a new hand, use this shuffle
                } else {
                    // print("Hand ID \(handId) already used, reshuffling...")
                }
            } else {
                // No card available, just use the shuffle
                return
            }
            
            attempts += 1
        }
        
        // If we couldn't find a new family after max attempts, use the last shuffle
        // print("Max attempts reached, using current shuffle")
    }
        
    func replace(_ tile: Tile) {
        let range: UInt32 = UInt32(tiles.count)
        tiles.insert(tile, at: Int(arc4random_uniform(range)))
    }
    
    func findTile(id: Int) -> Tile? {
        var foundTile: Tile? = nil
        for (index,tile) in tiles.enumerated() {
            if tile.id == id {
                foundTile = tile
                tiles.remove(at: index)
                break
            }
        }
        return foundTile
    }
    
    func pullTiles(tileVector: TileVector) -> [Tile] {
        print("pullTiles wallcount \(self.tiles.count)")
        tileVector.log()
        var tiles: [Tile] = []
        for (index, count) in tileVector.vector.enumerated() {
            if count > 0 {
                for _ in 1...count {
                    let tile = findTile(id: index)
                    if tile != nil {
                        tiles.append(tile!)
                    }
                }
            }
        }
        print("pullTiles count \(tiles.count)")
        return tiles
    }
    
    func pullTiles(count: Int) -> [Tile] {
        var tiles: [Tile] = []
        for _ in 1...count {
            tiles.append(self.tiles.remove(at: 0))
        }
        return tiles
    }
    
    func insertRandom(_ tile: Tile) {
        if tiles.count <= 2 {
            tiles.append(tile)
        } else {
            let index = Int.random(in: 0...tiles.count-1)
            tiles.insert(tile, at: index)
        }
    }
    
    func printTiles() {
        print("Wall")
        var s = ""
        for tile in tiles {
            s += String(tile.id) + ", "
        }
        s += "Count:\(tiles.count)"
        print(s)
    }
    
    // -----------------------------------------------------------------------------------------
    //
    //  Recount Discard Table
    //
    // -----------------------------------------------------------------------------------------
    
    func recount(_ discardTable: DiscardTable) {
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
        print("wall jokerCount \(jokerCount)")
    }  
    
    
    // -----------------------------------------------------------------------------------------
    //
    //  Blank Tiles
    //
    // -----------------------------------------------------------------------------------------
        
    func resetBlankTiles() {
        for tile in tiles {
            if tile.isBlankTile() {
                tile.set(named: "blank", num: 37, suit: "blank", id: 37, sortId: 56, sortNum: 56)
            }
        }
    }
    
    func swap(tile: Tile, id: Int) {
        switch(id){
        case 1: tile.set(named: "1dot", num: 1, suit: "dot", id: 1, sortId: 11, sortNum: 7 + 3)
        case 2: tile.set(named: "2dot", num: 2, suit: "dot", id: 2, sortId: 12, sortNum: 7 + 6)
        case 3: tile.set(named: "3dot", num: 3, suit: "dot", id: 3, sortId: 13, sortNum: 7 + 9)
        case 4: tile.set(named: "4dot", num: 4, suit: "dot", id: 4, sortId: 14, sortNum: 7 + 12)
        case 5: tile.set(named: "5dot", num: 5, suit: "dot", id: 5, sortId: 15, sortNum: 7 + 15)
        case 6: tile.set(named: "6dot", num: 6, suit: "dot", id: 6, sortId: 16, sortNum: 7 + 18)
        case 7: tile.set(named: "7dot", num: 7, suit: "dot", id: 7, sortId: 17, sortNum: 7 + 21)
        case 8: tile.set(named: "8dot", num: 8, suit: "dot", id: 8, sortId: 18, sortNum: 7 + 24)
        case 9: tile.set(named: "9dot", num: 9, suit: "dot", id: 9, sortId: 19, sortNum: 7 + 27)
        case 10: tile.set(named: "soap", num: 10, suit: "dot", id: 10, sortId: 41, sortNum: 41)
        case 11: tile.set(named: "1bam", num: 1, suit: "bam", id: 11, sortId: 21, sortNum: 8 + 3)
        case 12: tile.set(named: "2bam", num: 2, suit: "bam", id: 12, sortId: 22, sortNum: 8 + 6)
        case 13: tile.set(named: "3bam", num: 3, suit: "bam", id: 13, sortId: 23, sortNum: 8 + 9)
        case 14: tile.set(named: "4bam", num: 4, suit: "bam", id: 14, sortId: 24, sortNum: 8 + 12)
        case 15: tile.set(named: "5bam", num: 5, suit: "bam", id: 15, sortId: 25, sortNum: 8 + 15)
        case 16: tile.set(named: "6bam", num: 6, suit: "bam", id: 16, sortId: 26, sortNum: 8 + 18)
        case 17: tile.set(named: "7bam", num: 7, suit: "bam", id: 17, sortId: 27, sortNum: 8 + 21)
        case 18: tile.set(named: "8bam", num: 8, suit: "bam", id: 18, sortId: 28, sortNum: 8 + 24)
        case 19: tile.set(named: "9bam", num: 9, suit: "bam", id: 19, sortId: 29, sortNum: 8 + 27)
        case 20: tile.set(named: "green", num: 10, suit: "bam", id: 20, sortId: 42, sortNum: 42)
        case 21: tile.set(named: "1crak", num: 1, suit: "crak", id: 21, sortId: 31, sortNum: 9 + 3)
        case 22: tile.set(named: "2crak", num: 2, suit: "crak", id: 22, sortId: 32, sortNum: 9 + 6)
        case 23: tile.set(named: "3crak", num: 3, suit: "crak", id: 23, sortId: 33, sortNum: 9 + 9)
        case 24: tile.set(named: "4crak", num: 4, suit: "crak", id: 24, sortId: 34, sortNum: 9 + 12)
        case 25: tile.set(named: "5crak", num: 5, suit: "crak", id: 25, sortId: 35, sortNum: 9 + 15)
        case 26: tile.set(named: "6crak", num: 6, suit: "crak", id: 26, sortId: 36, sortNum: 9 + 18)
        case 27: tile.set(named: "7crak", num: 7, suit: "crak", id: 27, sortId: 37, sortNum: 9 + 21)
        case 28: tile.set(named: "8crak", num: 8, suit: "crak", id: 28, sortId: 38, sortNum: 9 + 24)
        case 29: tile.set(named: "9crak", num: 9, suit: "crak", id: 29, sortId: 39, sortNum: 9 + 27)
        case 30: tile.set(named: "red", num: 10, suit: "crak", id: 30, sortId: 43, sortNum: 43)
        case 31: tile.set(named: "north", num: 1, suit: "wnd", id: 31, sortId: 51, sortNum: 51)
        case 32: tile.set(named: "south", num: 2, suit: "wnd", id: 32, sortId: 52, sortNum: 52)
        case 33: tile.set(named: "west", num: 3, suit: "wnd", id: 33, sortId: 53, sortNum: 53)
        case 34: tile.set(named: "east", num: 4, suit: "wnd", id: 34, sortId: 54, sortNum: 54)
        case 35: tile.set(named: "f1", num: 12, suit: "flwr", id: 35, sortId: 1, sortNum: 1)
        default: break
        }
    }
    
    
 }

