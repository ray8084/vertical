//
//  MatchingTileSets.swift
//  Mahjong2017
//
//  Created by Ray Meyer on 12/2/17.
//  Copyright © 2017 Ray. All rights reserved.
//

import Foundation

// some pattersn break the singles & pairs algorithm, for example 2022 has 3 twos but they are singles
class Singles {
    static let normal = 0
    static let dot2 = 2
    static let bam2 = 12
    static let crak2 = 22
    static let ff_2022_2022_2022 = 2022
}

class MatchingTileSets {
    var tileSets = [TileSet]()
    
    func loadHands(_ handList: [Hand]) {
        tileSets = []
        var handIndex = 0
        for hand in handList {
            for tileIds in hand.idList.list {
                tileSets.append(TileSet(tileIds: tileIds.ids, handIndex: handIndex, hand: hand, singles: tileIds.singles))
            }
            handIndex += 1
        }
    }
    
    func loadOpponentHands(_ handList: [Hand]) {
        tileSets = [] // Clear existing hands first
        var handIndex = 0
        var loadedCount = 0
        for hand in handList {
            if (hand.concealed == false) && (hand.family != Family.pairs) && (hand.family != Family.quints){
                for tileIds in hand.idList.list {
                    tileSets.append(TileSet(tileIds: tileIds.ids, handIndex: handIndex, hand: hand, singles: tileIds.singles))
                    loadedCount += 1
                }
            }
            handIndex += 1
        }
        // print("   Loaded \(loadedCount) bot hand variations from \(handList.count) total hands")
    }
    
    func countMatches(hand: Player, rack: Rack, maj: Maj) {
        countMatches(hand: hand, tiles: hand.tiles + rack.tiles, jokerCount: hand.jokerCount() + rack.jokerCount(), maj: maj)
    }
    
    private func countMatches(hand: Player, tiles: [Tile], jokerCount: Int, maj: Maj) {
        for tileSet in tileSets {
            countMatchesForItem(hand: hand, tiles: tiles, tileSet: tileSet, jokerCount: jokerCount, maj: maj)
        }
    }
    
    func countMatchesForItem(hand: Player, tiles: [Tile], tileSet: TileSet, jokerCount: Int, maj: Maj) {
        var remainder = tileSet.tileVector.vector
        tileSet.matchCount = 0
        let rackCount = hand.rack.tiles.count
        if maj.settings.displayFilters.isHidden(tileSet: tileSet, rackCount: rackCount) == false {
            // matching tiles
            for tile in tiles {
                if remainder[tile.id] != 0 {
                    remainder[tile.id] -= 1
                }
            }

            // check jokers
            var jokerRemainder = jokerCount
            if (jokerRemainder != 0) && (tileSet.family != Family.pairs) {
                for (index, idCount) in tileSet.tileVector.vector.enumerated() {
                    if (idCount > 2) && (remainder[index] != 0) {
                        if tileSet.areSinglesNormal(tileId: index) {
                            if remainder[index] >= jokerRemainder {
                                remainder[index] -= jokerRemainder
                                jokerRemainder = 0
                                break
                            } else {
                                jokerRemainder -= remainder[index]
                                remainder[index] = 0
                            }
                        }
                    }
                }
            }
            
            // count remainder
            var count = 14
            for idCount in remainder {
                count -= idCount
            }
            tileSet.matchCount = count
        }
    }

    func countMatchesForItemNoFilters(hand: Player, tiles: [Tile], tileSet: TileSet, jokerCount: Int) {
        var remainder = tileSet.tileVector.vector
        tileSet.matchCount = 0

        // matching tiles
        for tile in tiles {
            if remainder[tile.id] != 0 {
                remainder[tile.id] -= 1
            }
        }

        // check jokers
        var jokerRemainder = jokerCount
        if (jokerRemainder != 0) && (tileSet.family != Family.pairs) {
            for (index, idCount) in tileSet.tileVector.vector.enumerated() {
                if (idCount > 2) && (remainder[index] != 0) {
                    if tileSet.areSinglesNormal(tileId: index) {
                        if remainder[index] >= jokerRemainder {
                            remainder[index] -= jokerRemainder
                            jokerRemainder = 0
                            break
                        } else {
                            jokerRemainder -= remainder[index]
                            remainder[index] = 0
                        }
                    }
                }
            }
        }
        
        // count remainder
        var count = 14
        for idCount in remainder {
            count -= idCount
        }
        tileSet.matchCount = count
    }
    
    func countMatchesForEast(_ maj: Maj) {
        let tiles = maj.east.tiles + maj.rackTiles()
        for tileSet in tileSets {
            if maj.card.isHandHidden(id: tileSet.handId) {
                tileSet.matchCount = 0
            } else if tileSet.rackFilter {
                tileSet.matchCount = 0
            } else {
                countMatchesForItem(hand: maj.east, tiles: tiles, tileSet: tileSet, jokerCount: maj.east.jokerCount() + maj.east.rack.jokerCount(), maj: maj)
            }
        }
    }
    
    func countMatchesForEastNoFilters(_ maj: Maj) {
        let tiles = maj.east.tiles + maj.rackTiles()
        for tileSet in tileSets {
            countMatchesForItemNoFilters(hand: maj.east, tiles: tiles, tileSet: tileSet, jokerCount: maj.east.jokerCount() + maj.east.rack.jokerCount())
        }
    }
    
    func rackFilter(_ rack: TileList, year: Int) {
        let rackVector = TileVector(rack: rack)
        for tileSet in tileSets {
            tileSet.rackFilter(rackVector, year: year)
        }
    }
    
    func clearRackFilter() {
        for tileSet in tileSets {
            tileSet.rackFilter = false
        }
    }
    
    func sort(settings: Settings) {
        if settings.stopSorting == false || settings.initialSortDone == false {
            tileSets.sort(by: { $0.matchCount == $1.matchCount ? $0.handId < $1.handId :  $0.matchCount > $1.matchCount })
            if settings.stopSorting == true {
                settings.initialSortDone = true
                UserDefaults.standard.set(settings.initialSortDone, forKey: "initialSortDone")
            }
        }
    }
    
    func sortForced() {
        tileSets.sort(by: { $0.matchCount == $1.matchCount ? $0.handId < $1.handId :  $0.matchCount > $1.matchCount })
    }
}