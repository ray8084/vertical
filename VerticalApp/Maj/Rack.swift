//
//  Rack.swift
//  Mahjong2017
//
//  Created by Ray Meyer on 2/10/18.
//  Copyright © 2018 Ray. All rights reserved.
//

import Foundation

class Rack: TileList {
    var name: String = ""
    var message: String = ""
    
    // --------------------------------------------------------------
    //  init
    
    init(_ name: String) {
        super.init()
        self.name = name
    }
    
    // --------------------------------------------------------------
    //  copy
    
    func copy(_ copy: Rack) {
        super.copy(copy as TileList)
        name = copy.name
        message = copy.message
    }
    
    func validate() -> String {
        markJokers()
        if tiles.count > 0 {
            let rackVector = TileVector(rack: self)
            rackVector.log()
            
            //if let newsError = validateNEWS(rackVector: rackVector) {
            //    return newsError
            //}
            
            //if let validateYearsError = validateYears(rackVector: rackVector) {
            //    return validateYearsError
            //}

            //if let jokersIn2025Error = validateJokersIn2025(tiles: tiles) {
            //    return jokersIn2025Error
            //}

            if let singlesPairsError = validateSinglesAndPairs(from: rackVector.vector) {
                return singlesPairsError
            }
        }
        return ""
    }

    
    func validateSinglesAndPairs(from map: [Int]) -> String? {
        for count in map {
            if count == 1 {
                return "Single and pairs (including NEWS and 2025) cannot be exposed under NMJL rules until declaring Mahjong with all 14 tiles.  Only 3 or more identical tiles (including Jokers) can be exposed when calling a tile."
            } else if count == 2 {
                return "Single and pairs (including NEWS and 2025) cannot be exposed under NMJL rules until declaring Mahjong with all 14 tiles.  Only 3 or more identical tiles (including Jokers) can be exposed when calling a tile."
            }
        }
        return nil
    }
    
    private func validateNEWS(rackVector: TileVector) -> String? {
        var windTileCount = 0
        var hasSingleNEWS = false
        var hasWindJoker = false

        for tile in tiles {
            if (31...34).contains(tile.id) {
                windTileCount += 1
                if rackVector.vector[tile.id] == 1 {
                    hasSingleNEWS = true
                }
            }
            if tile.id == 36 && (31...34).contains(tile.jokerId) {
                hasWindJoker = true
            }
        }

        // Only return NEWS-specific error if there are exactly 4 wind tiles
        if windTileCount == 4 && hasSingleNEWS {
            var message = "\nUnder NMJL tournament rules, the tiles in NEWS are singles. NEWS cannot be exposed until declaring Mahjong."
            if hasWindJoker {
                message += "\n\nAlso, a Joker was used in NEWS, which is not allowed."
            }
            return message
        }

        // If winds are present but not exactly 4, still flag a singles error
        if hasSingleNEWS {
            return "\nUnder NMJL tournament rules, singles cannot be exposed until declaring Mahjong."
        }

        return nil
    }

    
    private func validateYears(rackVector: TileVector) -> String? {
        let valid2s = [2, 12, 22]
        let valid5s = [5, 15, 25]
        let whiteDragonId = 10

        for i in 0..<valid2s.count {
            let twoId = valid2s[i]
            let fiveId = valid5s[i]

            if rackVector.vector[twoId] == 2, rackVector.vector[fiveId] == 1, rackVector.vector[whiteDragonId] == 1 {
                return "Under NMJL tournament rules, the year 2025 cannot be exposed until declaring Mahjong."
            }
        }

        return nil
    }
    
    private func validateJokersIn2025(tiles: [Tile]) -> String? {
        // Ensure there are exactly 4 tiles on the rack to perform the validation
        if tiles.count != 4 {
            return nil
        }

        // Define all 9 bad tile ID combinations (where one is a Joker)
        let invalidCombos: Set<Set<Int>> = [
            [2, 10, 2, 36], [2, 10, 5, 36], [2, 2, 5, 36],
            [12, 10, 12, 36], [12, 10, 15, 36], [12, 12, 15, 36],
            [22, 10, 22, 36], [22, 10, 25, 36], [22, 22, 25, 36]
        ]

        // Get tile IDs from hand
        let tileIds = tiles.map { $0.id }

        // Check if the single 4-tile set matches a bad combo
        let subset: Set<Int> = Set(tileIds)
        if invalidCombos.contains(subset) {
            return "Under NMJL tournament rules, you cannot expose 2025 before declaring Mahjong, and you cannot use Jokers in it."
        }

        return nil
    }
    
    func markJokers() {
        for (index, tile) in tiles.enumerated() {
            if tile.isJoker() && (index > 0) {
                tile.setJokerFields(tiles[index-1])
            }
            if tile.isJoker() && (index == 0) && (tiles.count > 1) {
                tile.setJokerFields(tiles[1])
            }
        }
    }
        
    func markJoker(joker: Tile, index: Int) {
        if (tiles.count > 0) && (index >= tiles.count) {
            joker.setJokerFields(lastNonJoker())
        } else if (index > 0) && (index < tiles.count) {
            joker.setJokerFields(tiles[index-1])
        } else if (index == 0) {
            joker.setJokerFields(firstNonJoker())
        }
    }
    
    func lastNonJoker() -> Tile {
        var foundTile: Tile = Tile()
        for tile in tiles {
            if tile.isJoker() == false {
                foundTile = tile
            }
        }
        return foundTile
    }

    func firstNonJoker() -> Tile {
        var foundTile: Tile = Tile()
        for tile in tiles {
            if tile.isJoker() == false {
                foundTile = tile
                break
            }
        }
        return foundTile
    }
    
    func replaceJokers(_ hand: TileList) -> [(tileName: String, jokerRackOwner: String)] {
        var exchanges: [(tileName: String, jokerRackOwner: String)] = []
        for _ in 1...14 {
            var index = 0
            for tile in tiles {
                if tile.isJoker() {
                    let t = hand.getTile(tile.jokerSuit, number: tile.jokerNumber)
                    if t != nil {
                        // Track the exchange: player with tile initiates exchange with player who has joker in rack
                        let tileName = t!.getDisplayName()
                        // This rack (self) had the joker, so name is the joker rack owner
                        exchanges.append((tileName: tileName, jokerRackOwner: name))
                        tiles.remove(at: index)
                        tiles.insert(t!, at: index)
                        hand.tiles.append(tile)
                        break
                    }
                }
                index += 1
            }
        }
        return exchanges
    }
    
    func replaceJoker(_ tile: Tile) -> Bool {
        var found = false
        for (index, t) in tiles.enumerated() {
            if t.isJoker() && (t.jokerId == tile.id) {
                tiles.remove(at: index)
                tiles.insert(tile, at: index)
                found = true
                break
            }
        }
        return found
    }
    
    func rackAll(_ hand: TileList) {
        hand.sort()
        for tile in hand.tiles {
            tiles.append(tile)
        }
    }
}
