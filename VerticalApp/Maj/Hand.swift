//
//  Pattern.swift
//  Mahjong2017
//
//  Created by Ray on 10/2/16.
//  Copyright © 2017 EightBam LLC. All rights reserved.
//
// A letter Pattern from a mahjong score card
// For example pattern "11 222 3333 444 55".
// Contains all expressions of that pattern in a TileIdList

import UIKit

class Family {
    static let year = 0
    static let f2468 = 1
    static let likeNumbers = 2
    static let addition = 3
    static let quints = 4
    static let run = 5
    static let f13579 = 6
    static let winds = 7
    static let f369 = 8
    static let pairs = 9
    static let all = 10
}

class Hand {
    var text = NSMutableAttributedString(string: "")
    var note = NSMutableAttributedString(string: "")
    var wins = 0
    var winsSinceVersion22 = 0
    var losses = 0
    var idList = IdList()
    var tileVectorList = TileVectorList()
    var matchCount = -1
    var jokerCount = 0
    var id = 0
    var mask = ""
    var jokerMask = ""
    var family = 0
    var concealed = false
    var filterOut = false
    var points = 0
    var rackFilter = false
    var hide = false
    var year = Year.uninitialized
    
    init(text: NSMutableAttributedString, mask: String, jokerMask: String, note: String, id: Int, family: Int, concealed: Bool, points: Int, year: Int) {
        self.text = text
        self.note = NSMutableAttributedString(string: note)
        self.id = id
        self.mask = mask
        self.jokerMask = jokerMask
        self.family = family
        self.concealed = concealed
        self.points = points
        self.year = year
    }
    
    func getDescription() -> String {
        return text.string + "\n" + note.string
    }
    
    func getFamilyString() -> String {
        switch self.family {
        case Family.year: return "Year"
        case Family.f2468: return "2468"
        case Family.likeNumbers: return "Like Numbers"
        case Family.addition: return "Addition"
        case Family.quints: return "Quints"
        case Family.run: return "Runs"
        case Family.f13579: return "13579"
        case Family.winds: return "Winds"
        case Family.f369: return "369"
        case Family.pairs: return "Singles & Pairs"
        default: return ""
        }
    }
    
    func buildIdVector() {
        if tileVectorList.list.count == 0 {
            tileVectorList.build(idList)
        }
    }
    
    func add(_ item: [Int], singles: Int = Singles.normal) {
        idList.add(item, singles: singles)
    }
    
    func getWins(showLosses: Bool) -> Int {
        var count = winsSinceVersion22
        if showLosses == false {
            count += wins
        }
        return count
    }
    
    func key() -> String {
        return String(id) + ":" + text.string
    }
    
    func lossKey() -> String {
        return String(id) + ":" + text.string + ":L"
    }
    
    func winKeySinceVersion22() -> String {
        return String(id) + ":" + text.string + ":W"
    }
    
    func winPercent() -> String {
        var percent = "0%"
        if winsSinceVersion22 + losses > 0 {
            percent = String(winsSinceVersion22 * 100 / (winsSinceVersion22 + losses)) + "%"
        }
        return percent
    }
    
    func match(_ tiles: [Tile], ignoreFilters: Bool) {
        matchCount = 0
        let filter = filterOut || hide || rackFilter
        if ignoreFilters || (filter == false) {
            buildIdVector()
            if idList.list.count > 0 {
                var jokerCount = 0
                for tile in tiles {
                    if tile.isJoker() {
                        jokerCount += 1
                    }
                }
                for (index, map) in tileVectorList.list.enumerated() {
                    var count = 0
                    if year == Year.y2022 {
                        count = countMatches2022(tiles: tiles, map: map.vector, jokerCount: jokerCount, subId: index)
                    } else {
                        count = countMatches(tiles: tiles, map: map.vector, jokerCount: jokerCount, subId: index)
                    }
                    if count > matchCount {
                        matchCount = count
                    }
                }
            }
        }
    }
    
    private func countMatches(tiles: [Tile], map: [Int], jokerCount: Int, subId: Int) -> Int {
        var remainder = map
        for tile in tiles {
            if remainder[tile.id] != 0 {
                remainder[tile.id] -= 1
            }
        }
            
        // check jokers
        var jokerRemainder = jokerCount
        if (jokerRemainder != 0) && (family != Family.pairs) {
            for (index, idCount) in map.enumerated() {
                if (idCount > 2) && (remainder[index] != 0) {
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
            
        // count remainder
        var count = 14
        for idCount in remainder {
            count -= idCount
        }
        // print("countMatches patternId \(self.id) subId \(subId) count \(count)")
        return count
    }
    
    private func countMatches2022(tiles: [Tile], map: [Int], jokerCount: Int, subId: Int) -> Int {
        var remainder = map
        for tile in tiles {
            if remainder[tile.id] != 0 {
                remainder[tile.id] -= 1
            }
        }
            
        // check jokers
        var jokerRemainder = jokerCount
        if (jokerRemainder != 0) && (family != Family.pairs) {
            for (index, idCount) in map.enumerated() {
                if (idCount > 2) && (remainder[index] != 0) {
                    if (id == 0) && (index == 2)         { // hardcoded special case FF GGGG 2022 RRRR dots
                    } else if (id == 0) && (index == 12) { // hardcoded special case FF GGGG 2022 RRRR bams
                    } else if (id == 0) && (index == 22) { // hardcoded special case FF GGGG 2020 RRRR craks
                    } else if (id == 2) && (subId == 0) && (index == 2)  { // hardcoded special case FFFF 2022 222 222 dots
                    } else if (id == 2) && (subId == 1) && (index == 12) { // hardcoded special case FFFF 222 2022 222 bams
                    } else if (id == 2) && (subId == 2) && (index == 22) { // hardcoded special case FFFF 222 222 2022 craks
                    } else if (id == 3) && (index == 2)  { // hardcoded special case NN EEE 2022 WWW SS dots
                    } else if (id == 3) && (index == 12) { // hardcoded special case NN EEE 2022 WWW SSS bams
                    } else if (id == 3) && (index == 22) { // hardcoded special case NN EEE 2022 WWW SS craks
                    } else if (id == 4) && (index == 2)  { // hardcoded special case FF 2022 2022 2022 dots
                    } else if (id == 4) && (index == 12) { // hardcoded special case FF 2022 2022 2022 bams
                    } else if (id == 4) && (index == 22) { // hardcoded special case FF 2022 2022 2022 craks
                    } else if (id == 4) && (index == 10) { // hardcoded special case FF 2022 2022 2022 soaps
                    } else if remainder[index] >= jokerRemainder {
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
            
        // count remainder
        var count = 14
        for idCount in remainder {
            count -= idCount
        }
        // print("countMatches patterId \(self.id) subId \(subId) count \(count)")
        return count
    }


    private func countMatches(_ tiles: [Tile], item: [Int]) -> Int {
        var ids = item
        var count = 0
        for tile in tiles {
            var index = 0
            for id in ids {
                if tile.id == id  {
                    count += 1
                    ids.remove(at: index)
                    break
                }
                index += 1
            }
        }
        return count
    }
    
    func rackFilter(_ rackVector: TileVector) {
        buildIdVector()
        rackFilter = false
        var removeCount = 0
        for handVector in tileVectorList.list {
            for i in 1...35 {
                if handVector.vector[i] == 6 && rackVector.vector[i] == 3 {
                    continue    // 2 sets of 3 flowers
                } else if self.text.string == "FFFF DDD 2023 DDD" && i == 10 && handVector.vector[i] == 4 && rackVector.vector[i] == 3 {
                    continue    // 3 soaps in the rack is ok for this hand even though we need 4 total
                } else if self.text.string == "FFFF 11 111 111 11" {
                    if filterFFFF_11_111_111_11(rackVector, handVector: handVector, index: i) {
                        removeCount += 1
                        break
                    }
                } else if self.text.string == "2025 222 555 DDDD" {
                    if i == 10 && handVector.vector[i] == 5 {
                        if rackVector.vector[i] != 0 && rackVector.vector[i] != 4 {
                            removeCount += 1
                            break
                        }
                    } else if rackVector.vector[i] != 0 && rackVector.vector[i] != handVector.vector[i] {
                        removeCount += 1
                        break
                    }
                } else if rackVector.vector[i] != 0 && rackVector.vector[i] != handVector.vector[i] {
                    removeCount += 1
                    break
                }
            }
        }
        
        // if we remove all the idlists we filter out the hand
        if removeCount == tileVectorList.list.count {
            rackFilter = true
        }
    }

    // for this hand the first pair and the last pair are matching suits and like numbers
    // putting both pairs on the rack at the same time is invalid
    // since the other tiles are sets of 3 remove the hand when we see any count of 4 racked except for the flowers
    // for the final mahjong check it will be ok
    func filterFFFF_11_111_111_11(_ rackVector: TileVector, handVector: TileVector, index: Int) -> Bool {
        var remove = false
        if index < 35 && rackVector.vector[index] == 4 {
            remove = true
        }
        if rackVector.vector[index] != 0 && rackVector.vector[index] != handVector.vector[index] {
            remove = true
        }
        return remove
    }
    
    func clearRackFilter() {
        rackFilter = false
    }
    
    func generateList() {
        idList.generateList(text: text, family: family, mask: mask)
    }
    
    func getDarkModeString(textColor: UIColor) -> NSMutableAttributedString {
        let red = [NSAttributedString.Key.foregroundColor: UIColor.red]
        let green = [NSAttributedString.Key.foregroundColor: UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)  ]
        let color = [NSAttributedString.Key.foregroundColor: textColor]
        let darkModeString = NSMutableAttributedString(string: text.string)
        var index = 0
        for char in mask {
            switch char {
            case "g":
                darkModeString.addAttributes(green, range: NSRange(location:index,length:1))
                break
            case "r":
                darkModeString.addAttributes(red, range: NSRange(location:index,length:1))
                break
            default:
                darkModeString.addAttributes(color, range: NSRange(location:index,length:1))
                break
            }
            index += 1
        }
        
        // Assumes (C) in the concealed string, if this crashes check it
        if concealed {
            for i in index...darkModeString.length-1 {
                darkModeString.addAttributes(color, range: NSRange(location:i,length:1))
            }
        }
        
        return darkModeString
    }
    
    func getDarkModeNote(textColor: UIColor) -> NSMutableAttributedString {
        let color = [NSAttributedString.Key.foregroundColor: textColor]
        let darkModeNote = NSMutableAttributedString(string: note.string)
        darkModeNote.addAttributes(color, range: NSRange(location:0,length:note.string.count))
        return darkModeNote
    }
 
    func applyFilters(_ maj: Maj) {
        switch family {
        case Family.year: filterOut = maj.settings.displayFilters.hideYears
        case Family.f2468: filterOut = maj.settings.displayFilters.hide2468
        case Family.likeNumbers: filterOut = maj.settings.displayFilters.hideLikeNumbers
        case Family.addition: filterOut = maj.settings.displayFilters.hideAdditionHands
        case Family.quints: filterOut = maj.settings.displayFilters.hideQuints
        case Family.run: filterOut = maj.settings.displayFilters.hideRuns
        case Family.f13579: filterOut = maj.settings.displayFilters.hide13579
        case Family.winds: filterOut = maj.settings.displayFilters.hideWinds
        case Family.f369: filterOut = maj.settings.displayFilters.hide369
        case Family.pairs: filterOut = maj.settings.displayFilters.hidePairs
        default: filterOut = false
    }
    
        if maj.settings.displayFilters.hideConcealed && concealed {
                filterOut = true
        }
        
        let count = maj.east.rack.tiles.count
        if (count > 0) && (count < 14) && concealed {
            filterOut = true
        }
    }
}

