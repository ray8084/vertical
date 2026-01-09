//
//  TileVector.swift
//  Mahjong2017
//
//  Created by Ray Meyer on 1/21/18.
//  Copyright © 2018 Ray. All rights reserved.
//
// TileVector counts the count for tile ids for a mahjong in a fixed sized list
// For example hand "11 22 333 444 5555".
// tileVector = [0,2,2,3,3,4,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0]
// index mapping
// 0 = reserved for matching count
// 1 = 1 dot
// 2 = 2 dot
// 10 = soap
// 11 = 1 bam
// 12 = 2 bam
// 20 = green dragon
// 21 = 1 crak
// 22 = 2 crak
// 30 = red dragon
// 31 = north
// 32 = south
// 33 = west
// 34 = east
// 35 = flower
// 36 = joker
// 37 = blank tile, swap with a tile on the table anytime
//
// TileVectorList is a list of TileVectors for a given hand
// For example hand "11 22 333 444 5555".
// tileVectorList = ([0, 2,2,3,3,4,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0],  // hand in dots
//                   [0, 0,0,0,0,0,0,0,0,0,0, 2,2,3,3,4,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0],  // hand in bams
//                   [0, 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 2,2,3,3,4,0,0,0,0,0, 0,0,0,0,0],  // hand in craks

import Foundation

class TileVector {
    var vector = [Int](repeating: 0, count: 38)
   
    init(_ idList: [Int]){
        for id in idList {
            vector[id] += 1
        }
    }
    
    init(rack: TileList) {
        for tile in rack.tiles {
            if tile.isJoker() {
                vector[tile.jokerId] += 1
            } else {
                vector[tile.id] += 1
            }
        }
    }
    
    init(tiles: [Tile]) {
        for tile in tiles {
            vector[tile.id] += 1
        }
    }
    
    func jokerCount() -> Int {
        return vector[36]
    }
    
    func flowerCount() -> Int {
        return vector[35]
    }
    
    func log() {
        print(vector)
    }
    
    func isFiveSoapHand() -> Bool {
        return vector[10] == 5
    }
    
    func isLastSet() -> Bool {
        var setCount = 0
        for tileCount in vector {
            if tileCount > 0 {
                setCount += 1
            }
        }
        return setCount == 1
    }
    
    func lastSetId() -> Int {
        var id = 0
        for (index, tileCount) in vector.enumerated() {
            if tileCount > 0 {
                id = index
                break
            }
        }
        return id
    }
    
    func singlesAndPairsCount() -> Int {
        var singlesAndPairsCount = 0
        for count in vector {
            if count > 0 && count < 3 {
                singlesAndPairsCount += 1
            }
        }
        return singlesAndPairsCount
    }
}

class TileVectorList {
    var list = [TileVector]()
    
    func build(_ tileIdList: IdList) {
        for idList in tileIdList.list {
            let tileVector = TileVector(idList.ids)
            list.append(tileVector)
        }
    }
    
    func buildFromRack(_ rack: TileList) {
        let rackVector = TileVector(rack: rack)
        list.append(rackVector)
    }
}
