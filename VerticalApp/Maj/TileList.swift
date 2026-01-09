//
//  TileList.swift
//  MahjongPractice
//
//  Created by Ray on 8/11/16.
//  Copyright © 2017 EightBam LLC. All rights reserved.
//

import Foundation
import GameKit

class TileList {
    var tiles: [Tile] = []
    
    // --------------------------------------------------------------
    //  init
    
    init() {
        // Default initializer
    }
    
    // --------------------------------------------------------------
    //  copy
    
    func copy(_ copy: TileList) {
        tiles = []
        for tile in copy.tiles {
            tiles.append(Tile(tile))
        }
    }
    
    // --------------------------------------------------------------
    //  tile operations
    
    func addTile(_ tile: Tile) {
        tiles.append(tile)
    }
    
    func removeTile(_ tile: Tile) {
        for (index, t) in tiles.enumerated() {
            if tile.id == t.id {
                tiles.remove(at: index)
                break
            }
        }
    }
    
    func getTile(id: Int) -> Tile? {
        var tile: Tile?
        for (index, t) in tiles.enumerated() {
            if id == t.id {
                tile = tiles.remove(at: index)
                break
            }
        }
        return tile
    }
    
    func getTile(_ suit: String, number: Int) -> Tile? {
        var index = 0
        for tile in tiles {
            if tile.isEqual(suit, number: number) {
                return tiles.remove(at: index)
            }
            index += 1
        }
        return nil
    }
    
    func exists(tile: Tile) -> Bool {
        var exists = false
        for t in tiles {
            if t.id == tile.id {
                exists = true
                break
            }
        }
        return exists
    }
    
    func addJoker() {
        tiles.append(Tile(named: "joker", num: 11, suit: "jkr", id: 36, sortId: 55, sortNum: 55))
    }
    
    // --------------------------------------------------------------
    //  drawing from the wall
    
    func draw(_ maj: Maj) {
        if maj.settings.lefty {
            tiles.insert(maj.wall.tiles.remove(at: 0), at: 0)
        } else {
            tiles.append(maj.wall.tiles.remove(at: 0))
        }
    }
    
    // --------------------------------------------------------------
    //  sorting
    
    func sort() {
        tiles.sort(by: { $0.sortId < $1.sortId })
    }
    
    func sortNumbers() {
        tiles.sort(by: { $0.sortNumbers < $1.sortNumbers })
    }
    
    func getSortedTiles() -> TileList {
        let sortedTiles = TileList()
        for tile in tiles {
            let newTile = Tile(named: tile.name, num: tile.number, suit: tile.suit, id: tile.id, sortId: tile.sortId, sortNum: tile.sortNumbers)
            sortedTiles.tiles.append(newTile)
        }
        sortedTiles.sort()
        return sortedTiles
    }
    
    // --------------------------------------------------------------
    //  shuffling
    
    func shuffle(withSeed: Bool, seedString: String) {
        if withSeed {
            shuffleWithSeed(seedString)
        } else {
            shuffleRandom()
        }
    }
    
    func shuffleRandom() {
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
    
    func shuffleWithSeed(_ seedString: String) {
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
    //  utility methods
    
    func setHistory(_ history: History) {
        for tile in tiles {
            tile.history = history
        }
    }
    
    func setTiles(_ ids: [Int]) {
        self.tiles = ids.map { id in
            return Tile(id: id)
        }
    }
    
    func printTiles() {
        var s = ""
        for tile in tiles {
            s += String(tile.id) + ", "
        }
        s += "Count:\(tiles.count) Jokers:\(jokerCount())"
        print(s)
    }
    
    // --------------------------------------------------------------
    //  counting methods
    
    func jokerCount() -> Int {
        var count = 0
        for t in tiles {
            if t.isJoker() {
                count += 1
            }
        }
        return count
    }
    
    func getYearCount() -> Int {
        // todo support any year
        var count = 0
        for tile in tiles {
            if tile.id == 2 || tile.id == 3 || tile.id == 10 {
                count += 1
            }
            if tile.id == 12 || tile.id == 13 {
                count += 1
            }
            if tile.id == 22 || tile.id == 23 {
                count += 1
            }
        }
        return count
    }
        
    func get2468Count() -> Int {
        var count = 0
        for tile in tiles {
            if tile.id == 2 || tile.id == 4 || tile.id == 6 || tile.id == 8 {
                count += 1
            }
            if tile.id == 12 || tile.id == 14 || tile.id == 16 || tile.id == 18 {
                count += 1
            }
            if tile.id == 22 || tile.id == 24 || tile.id == 26 || tile.id == 28 {
                count += 1
            }
        }
        return count
    }
    
    func getLikeNumCount() -> Int {
        var count = 0
        for i in 1...9 {
            var newCount = 0
            for tile in tiles {
                if tile.id == i || tile.id == i + 10 || tile.id == i + 20 {
                    newCount += 1
                }
            }
            if newCount > count {
                count = newCount
            }
        }
        return count
    }
    
    func getRunCount(_ start: Int) -> Int {
        var count = 0
        for i in start...start+4 {
            for tile in tiles {
                if tile.id == i || tile.id == i + 10 || tile.id == i + 20 {
                    count += 1
                }
            }
        }
        return count
    }
            
    func get13579Count() -> Int {
        var count = 0
        for tile in tiles {
            if tile.id == 1 || tile.id == 3 || tile.id == 5 || tile.id == 7 || tile.id == 9 {
                count += 1
            }
            if tile.id == 11 || tile.id == 13 || tile.id == 15 || tile.id == 17 || tile.id == 19 {
                count += 1
            }
            if tile.id == 21 || tile.id == 23 || tile.id == 25 || tile.id == 27 || tile.id == 29 {
                count += 1
            }
        }
        return count
    }
    
    func getWindCount() -> Int {
        var count = 0
        for tile in tiles {
            if tile.id == 31 || tile.id == 32 || tile.id == 33 || tile.id == 34 {
                count += 1
            }
            if tile.id == 10 || tile.id == 20 || tile.id == 30 {
                count += 1
            }
        }
        return count
    }
    
    func getDragonCount() -> Int {
        var count = 0
        for tile in tiles {
            if tile.id == 10 || tile.id == 20 || tile.id == 30 {
                count += 1
            }
        }
        return count
    }
    
    func get369Count() -> Int {
        var count = 0
        for tile in tiles {
            if tile.id == 3 || tile.id == 6 || tile.id == 9 {
                count += 1
            }
            if tile.id == 13 || tile.id == 16 || tile.id == 19 {
                count += 1
            }
            if tile.id == 23 || tile.id == 26 || tile.id == 29 {
                count += 1
            }
        }
        return count
    }
    
    func getDotCount() -> Int {
        var count = 0
        for tile in tiles {
            if tile.id > 0 && tile.id < 11 {
                count += 1
            }
        }
        return count
    }

    func getBamCount() -> Int {
        var count = 0
        for tile in tiles {
            if tile.id > 10 && tile.id < 21 {
                count += 1
            }
        }
        return count
    }
    
    func getCrakCount() -> Int {
        var count = 0
        for tile in tiles {
            if tile.id > 20 && tile.id < 31 {
                count += 1
            }
        }
        return count
    }
    
    func getFlowerCount() -> Int {
        var count = 0
        for tile in tiles {
            if tile.isFlower() {
                count += 1
            }
        }
        return count
    }
    
    func getJokerCount() -> Int {
        var count = 0
        for tile in tiles {
            if tile.isJoker() {
                count += 1
            }
        }
        return count
    }
    
    // --------------------------------------------------------------
    //  discard table methods
    
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
        print("hand jokerCount \(jokerCount)" )
    }
    
    // --------------------------------------------------------------
    //  blank tile methods
    
    func resetBlankTiles() {
        for tile in tiles {
            if tile.isBlankTile() {
                tile.set(named: "blank", num: 37, suit: "blank", id: 37, sortId: 56, sortNum: 56)
            }
        }
    }
}
