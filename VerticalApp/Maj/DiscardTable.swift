//
//  DiscardTable.swift
//  Mahjong2018
//
//  Created by Ray Meyer on 4/22/18.
//  Copyright © 2018 Ray. All rights reserved.
//
// test

import Foundation

class DiscardTable {
    var jokerCount = 0
    var flowerCount = 0
    var blankCount = 0
    var wndCount = [0,0,0,0]
    var dotCount = [0,0,0,0,0,0,0,0,0,0]
    var bamCount = [0,0,0,0,0,0,0,0,0,0]
    var crakCount = [0,0,0,0,0,0,0,0,0,0]
    
    func copy(_ copy: DiscardTable) {
        jokerCount = copy.jokerCount
        flowerCount = copy.flowerCount
        wndCount = copy.wndCount
        dotCount = copy.dotCount
        bamCount = copy.bamCount
        crakCount = copy.crakCount
        blankCount = copy.blankCount
    }
    
    func resetCounts() {
        for index in 0...dotCount.count-1 {
            dotCount[index] = 0
            bamCount[index] = 0
            crakCount[index] = 0
        }
        for index in 0...wndCount.count-1 {
            wndCount[index] = 0
        }
        jokerCount = 0
        flowerCount = 0
        blankCount = 0
    }
    
    func recount(_ maj: Maj) {
        resetCounts()
        dotCount = [4,4,4,4,4,4,4,4,4,4]
        bamCount = [4,4,4,4,4,4,4,4,4,4]
        crakCount = [4,4,4,4,4,4,4,4,4,4]
        wndCount = [4,4,4,4]
        jokerCount = 8
        flowerCount = 8
        if maj.settings.blankTiles && !maj.challengeHand { blankCount = 2}
        maj.east.recount(self)
        maj.south.recount(self)
        maj.west.recount(self)
        maj.north.recount(self)
        maj.east.rack.recount(self)
        maj.south.rack.recount(self)
        maj.west.rack.recount(self)
        maj.north.rack.recount(self)
        maj.wall.recount(self)
        if maj.discardTile != nil {
            if maj.discardTile.isJoker() {
                jokerCount -= 1
            }
            else if maj.discardTile.suit == "dot" {
                dotCount[maj.discardTile.number-1] -= 1
            }
            else if maj.discardTile.suit == "bam" {
                bamCount[maj.discardTile.number-1] -= 1
            }
            else if maj.discardTile.suit == "crak" {
                crakCount[maj.discardTile.number-1] -= 1
            }
            else if maj.discardTile.isWind() {
                wndCount[maj.discardTile.number-1] -= 1
            }
            else if maj.discardTile.isFlower() {
                flowerCount -= 1
            }
            else if maj.discardTile.isBlankTile() {
                blankCount -= 1
            }
        }
    }
    
    func getCount() -> Int {
        var count = 0
        for index in 0...dotCount.count-1 {
            count += dotCount[index]
            count += bamCount[index]
            count += crakCount[index]
        }
        for index in 0...wndCount.count-1 {
            count += wndCount[index]
        }
        count += jokerCount
        count += flowerCount
        return count
    }
    
    func countTile(_ tile: Tile, increment: Int) {
        switch tile.suit {
        case "dot": dotCount[tile.number - 1] += increment
        case "bam": bamCount[tile.number - 1] += increment
        case "crak": crakCount[tile.number - 1] += increment
        case "wnd": wndCount[tile.number - 1] += increment
        case "jkr": jokerCount += increment
        case "flwr": flowerCount += increment
        case "blank": blankCount += increment
        default: break
        }

        // print("DiscardTable count \(getCount())")
    }
    
    func getCount(_ tile: Tile) -> Int {
        switch tile.suit {
        case "dot": return dotCount[tile.number - 1]
        case "bam": return bamCount[tile.number - 1]
        case "crak": return crakCount[tile.number - 1]
        case "wnd": return wndCount[tile.number - 1]
        case "jkr": return jokerCount
        case "flwr": return flowerCount
        case "blank": return flowerCount
        default: return 0
        }
    }
    
    func printCounts() {
        print("DicardTable")
        print(dotCount)
        print(bamCount)
        print(crakCount)
        print(wndCount)
        print(jokerCount)
        print(flowerCount)
    }
}
