//
//  Card.swift
//  Mahjong2017
//
//  Created by Ray on 8/15/16.
//  Copyright © 2017 EightBam LLC. All rights reserved.
//

import UIKit

class Card {
    var handList: [Hand] = []
    let defaults = UserDefaults.standard
    var showLosses = false
    var year = Year.uninitialized
    var total1s = 0
    var total2s = 0
    var total3s = 0
    var total4s = 0
    var total5s = 0
    var total6s = 0
    var total7s = 0
    var total8s = 0
    var total9s = 0
    var totalSoaps = 0
    var totalGreen = 0
    var totalRed = 0
    var totalNorth = 0
    var totalEast = 0
    var totalWest = 0
    var totalSouth = 0
    var totalFlowers = 0
    var totalYearsHands = 0
    var totalEvenHands = 0
    var totalLikeNumberHands = 0
    var totalAdditionHands = 0
    var totalQuintHands = 0
    var totalRunHands = 0
    var totalOddHands = 0
    var totalWindHands = 0
    var total369Hands = 0
    var totalSinglesAndPairsHands = 0
    var topSections: [(String, Int)] = []
    var bottomSections: [(String, Int)] = []
    var topTiles: [(String, Int)] = []
    var bottomTiles: [(String, Int)] = []
    var resultsArray = [OverlapResult]()
    var resultsSet = Set<OverlapResult>()
    var sectionHands: [String] = []
    var allHands: [String] = []
    
                
    init() {
    }
    
    func getYear() -> String {
        return ""
    }
    
    func copy (_ copy: Card) {
        self.showLosses = copy.showLosses
        // ? hands
    }
    
    func buildIdMaps() {
        for lp in handList {
            lp.buildIdVector()
        }
    }
    
    func count() -> Int {
        return handList.count
    }
    
    func text(_ index: Int) -> NSAttributedString {
        if index < handList.count {
            return handList[index].text
        } else {
            return NSAttributedString(string: "")
        }
    }
    
    func note(_ index: Int) -> NSAttributedString {
        if index < handList.count {
            return toBlack( handList[index].note)
        } else {
            return NSAttributedString(string: "")
        }
    }
    
    func toBlack(_ string: NSMutableAttributedString) -> NSMutableAttributedString {
        let text = NSMutableAttributedString(string: string.mutableString as String)
        let black = [NSAttributedString.Key.foregroundColor: UIColor.black]
        text.addAttributes(black, range: NSRange(location:0, length:text.length))
        return text
    }
    
    func hideHand(_ index: Int) {
        if index < handList.count {
            print("hide \(index) \(handList[index].id) \(handList[index].text.string)")
            handList[index].hide = true
        }
    }
    
    func unhideAll() {
        for lp in handList {
            lp.hide = false
        }
    }
    
    func isHandHidden(id: Int) -> Bool {
        var hidden = false
        for lp in handList {
            if lp.id == id {
                hidden = lp.hide
                break
            }
        }
        return hidden
    }

    func add(_ string: String, mask: String, jokerMask: String, note: String, family: Int, concealed: Bool) -> Hand {
        return add(string, mask: mask, jokerMask: jokerMask, note: note, family: family, concealed: concealed, points: 0)
    }
    
    func add(_ string: String, mask: String, jokerMask: String, note: String, family: Int, concealed: Bool, points: Int) -> Hand {
        let red = [NSAttributedString.Key.foregroundColor: UIColor.red]
        let green = [NSAttributedString.Key.foregroundColor: UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)  ]
        let m = NSMutableAttributedString(string: string)
        var index = 0
        for char in mask {
            switch char {
            case "g":
                m.addAttributes(green, range: NSRange(location:index,length:1))
                break
            case "r":
                m.addAttributes(red, range: NSRange(location:index,length:1))
                break
            default:
                let black = [NSAttributedString.Key.foregroundColor: UIColor.black]
                m.addAttributes(black, range: NSRange(location:index,length:1))
                break
            }
            index += 1
        }
        
        //print(index)
        //print(m.length)
        
        // Assumes (C) in the concealed string, if this crashes check it
        if concealed {
            for i in index...m.length-1 {
                let black = [NSAttributedString.Key.foregroundColor: UIColor.black]
                m.addAttributes(black, range: NSRange(location:i,length:1))
            }
        }
       
        let p = Hand(text: m, mask: mask, jokerMask: jokerMask, note: note, id: handList.count, family: family, concealed: concealed, points: points, year: year)
        handList.append(p)
        return p
    }
    
    func match(_ tiles: [Tile], ignoreFilters: Bool) {
        for p in handList {
            p.match(tiles, ignoreFilters: ignoreFilters)
        }
    }
    
    func rackFilter(_ rack: TileList) {
        let rackVector = TileVector(rack: rack)
        for lp in handList {
            lp.rackFilter(rackVector)
        }
    }
    
    func clearRackFilter() {
        for lp in handList {
            lp.clearRackFilter()
        }
    }
    
    func loadSavedValues() {
        for p in handList {
            p.losses = defaults.integer( forKey: p.lossKey() + getYear() ) + defaults.integer( forKey: p.lossKey() )
            p.winsSinceVersion22 = defaults.integer( forKey: p.winKeySinceVersion22() + getYear()) + defaults.integer( forKey: p.winKeySinceVersion22() )
        }
    }
    
    func addWin(_ index: Int) -> Bool {
        print("addWin \(index)")
        if index < handList.count {
            let p = handList[index]
            p.winsSinceVersion22 += 1
            defaults.set(p.winsSinceVersion22, forKey: p.winKeySinceVersion22() + getYear())
            return true
        } else {
            return false
        }
    }
    
    func subtractWin(_ handId: Int) {
        print("subtractWin \(handId)")
        for hand in handList {
            if hand.id == handId {
                hand.winsSinceVersion22 -= 1
                defaults.set(hand.winsSinceVersion22, forKey: hand.winKeySinceVersion22() + getYear())
                print("Subtracted win from hand ID \(handId), new count: \(hand.winsSinceVersion22)")
                break
            }
        }
    }
    
    func addLoss(_ hand: Hand) {
        hand.losses += 1
        defaults.set(hand.losses, forKey: hand.lossKey() + getYear())
    }
    
    func clearStats() {
        for p in handList {
            p.losses = 0
            p.winsSinceVersion22 = 0
            defaults.set(0, forKey: p.lossKey())
            defaults.set(0, forKey: p.winKeySinceVersion22())
            defaults.set(0, forKey: p.lossKey() + getYear() )
            defaults.set(0, forKey: p.winKeySinceVersion22() + getYear())
        }
    }
    
    func winCountText(_ index: Int) -> NSMutableAttributedString {
        var winText = NSMutableAttributedString()
        if index < handList.count {
            let p = handList[index]
            if showLosses {
                let wins = p.getWins(showLosses: true)
                if index == 0 {
                    winText = NSMutableAttributedString(string: String(wins) + "-" + String(p.losses) + " Win-Loss")
                } else {
                    winText = NSMutableAttributedString(string: String(wins) + "-" + String(p.losses) )
                }
            } else {
                let wins = p.getWins(showLosses: false)
                if (index == 0) && (wins == 1) {
                    winText = NSMutableAttributedString(string: String(wins) + " Win")
                } else if (index == 0) {
                    winText = NSMutableAttributedString(string: String(wins) + " Wins")
                } else {
                    winText = NSMutableAttributedString(string: String(wins) )
                }
            }
        }
        return toBlack(winText)
    }
    
    func getTotalWins() -> Int {
        var total = 0
        for p in handList {
            total += p.getWins(showLosses: showLosses)
        }
        return total
    }
    
    func matchCountText(_ index: Int) -> NSAttributedString {
        var matchText = NSMutableAttributedString()
        if index < handList.count {
            let p = handList[index]
            if p.matchCount > 0 {
                if index == 0 {
                    matchText = NSMutableAttributedString(string: String(p.matchCount) + " Tiles")
                } else {
                    matchText = NSMutableAttributedString(string: String(p.matchCount))
                }
            } else {
                // Show "0" when match count is 0
                if index == 0 {
                    matchText = NSMutableAttributedString(string: "0 Tiles")
                } else {
                    matchText = NSMutableAttributedString(string: "0")
                }
            }
        }
        return toBlack(matchText)
    }
    
    func winningHand(maj: Maj) -> String {
        var hand = ""
        match(maj.east.rack.tiles, ignoreFilters: true)
        hand = getHandString( winningIndex(maj.east.rack.jokerCount()) )
        match(maj.east.rack.tiles, ignoreFilters: false)
        return hand
    }
    
    func winningHand(hand: Player) -> String {
        match(hand.rack.tiles, ignoreFilters: false)
        return getHandString( winningIndex(hand.rack.jokerCount()) )
    }
    
    func getHandString(_ index: Int) -> String {
        var hand = ""
        if index < handList.count {
            hand = handList[index].text.string
            if handList[index].note.string != "" {
                hand = hand + " \n " + handList[index].note.string
            }
        }
        return hand
    }
    
    func getHand(_ index: Int) -> Hand {
        var hand = handList[0]
        if index < handList.count {
            hand = handList[index]
        }
        return hand
    }
    
    func getHandForId(id: Int) -> Hand {
        var hand = handList[0]
        for lp in handList {
            if lp.id == id {
                hand = lp
                break
            }
        }
        return hand
    }
    
    
    func winningIndex(_ jokerCount: Int) -> Int {
        var index = 0
        var found = false
        for p in handList {
            if p.matchCount == 14 {
                found = true
                break
            }
            index += 1
        }
        print("winningIndex \(found) \(index)")
        return found ? index : 0xFFFF
    }
    
    func secondWinningIndex() -> Int {
        var index = 0
        var foundCount = 0
        for p in handList {
            if p.matchCount == 14 {
                foundCount += 1
                if foundCount == 2 {
                    break
                }
            }
            index += 1
        }
        print("secondWinningIndex \(foundCount) \(index)")
        return foundCount == 2 ? index : 0xFFFF
    }
    
    func findHandIndex(_ targetHand: Hand) -> Int {
        var index = 0
        for hand in handList {
            // Compare the hand ID to find the matching hand
            if hand.id == targetHand.id {
                return index
            }
            index += 1
        }
        return 0xFFFF
    }

    func getClosestHand(tiles: [Tile]) -> Hand {
        match(tiles, ignoreFilters: true)
        var closet = handList[0]
        for hand in handList {
            if hand.matchCount > closet.matchCount {
                closet = hand
            }
        }
        return closet
    }
    
    func getAllMatchingWins(tiles: [Tile]) -> [Hand] {
        var wins: [Hand] = []
        match(tiles, ignoreFilters: true)
        for hand in handList {
            if hand.matchCount == 14 {
                wins.append(hand)
            }
        }
        return wins
    }
        
    
    // --------------------------------------------------------------
    //
    //  Stats
    //
    // --------------------------------------------------------------
        
    func getTotalWins(family: Int) -> String {
        var count = 0
        for lp in handList {
            if (family == Family.all) || (lp.family == family) {
                count += lp.getWins(showLosses: showLosses)
            }
        }
        return String(count)
    }

    func getTotalWinCount() -> Int {
        var count = 0
        for lp in handList {
            count += lp.getWins(showLosses: showLosses)
        }
        return count
    }
    
    func getHandWins(family: Int) -> String {
        var count = 0
        var familyTotal = 0
        for lp in handList {
            if (family == Family.all) || (lp.family == family) {
                count += lp.getWins(showLosses: showLosses) > 0 ? 1 : 0
                familyTotal += 1
            }
        }
        return String(count) + "/" + String(familyTotal)
    }

    func getHandWinPercentage(family: Int) -> Double {
        var count = 0.0
        var familyTotal = 0.0
        for lp in handList {
            if (family == Family.all) || (lp.family == family) {
                count += lp.getWins(showLosses: showLosses) > 0 ? 1 : 0
                familyTotal += 1
            }
        }
        return count/familyTotal
    }
    
    func getHandWinPercentageString(family: Int) -> String {
        var count = 0.0
        var familyTotal = 0.0
        for lp in handList {
            if (family == Family.all) || (lp.family == family) {
                count += lp.getWins(showLosses: showLosses) > 0 ? 1 : 0
                familyTotal += 1
            }
        }
        var winPercentage = String("")
        if familyTotal != 0 {
            winPercentage = String(Int(count/familyTotal * 100.0)) + "%"
        }
        return winPercentage;
    }
    
    func getLosses(family: Int) -> String {
        var count = 0
        for lp in handList {
            if (family == Family.all) || (lp.family == family) {
                count += lp.losses
            }
        }
        return String(count)
    }
    
    func getWinLossPercent(family: Int) -> String {
        var lossCount = 0.0
        var winCount = 0.0
        for lp in handList {
            if (family == Family.all) || (lp.family == family) {
                lossCount += Double(lp.losses)
                winCount += Double(lp.winsSinceVersion22)
            }
        }
        var winLossPercentage = String("0%")
        if (lossCount + winCount) != 0 {
            winLossPercentage = String(Int(winCount/(lossCount + winCount) * 100.0)) + "%"
        }
        return winLossPercentage;
    }
    
    func setSectionTotals() -> Int {
        var total = 0
        totalYearsHands = 0
        totalEvenHands = 0
        totalLikeNumberHands = 0
        totalAdditionHands = 0
        totalQuintHands = 0
        totalRunHands = 0
        totalOddHands = 0
        totalWindHands = 0
        total369Hands = 0
        totalSinglesAndPairsHands = 0
        
        var sectionTotals: [String: Int] = ["Years": 0,"2468": 0,"LikeNumbers": 0,"Math": 0,"Quints": 0,"Runs": 0,"13579": 0,"Winds & Dragons": 0,"369": 0,"Singles & Pairs": 0]
        
        for p in handList {
            switch p.family {
            case Family.year: totalYearsHands += p.idList.list.count; sectionTotals["Years"]! += p.idList.list.count
            case Family.f2468: totalEvenHands += p.idList.list.count; sectionTotals["2468"]! += p.idList.list.count
            case Family.likeNumbers: totalLikeNumberHands += p.idList.list.count; sectionTotals["LikeNumbers"]! += p.idList.list.count
            case Family.addition: totalAdditionHands += p.idList.list.count; sectionTotals["Math"]! += p.idList.list.count
            case Family.quints: totalQuintHands += p.idList.list.count; sectionTotals["Quints"]! += p.idList.list.count
            case Family.run: totalRunHands += p.idList.list.count; sectionTotals["Runs"]! += p.idList.list.count
            case Family.f13579: totalOddHands += p.idList.list.count; sectionTotals["13579"]! += p.idList.list.count
            case Family.winds: totalWindHands += p.idList.list.count; sectionTotals["Winds & Dragons"]! += p.idList.list.count
            case Family.f369: total369Hands += p.idList.list.count; sectionTotals["369"]! += p.idList.list.count
            case Family.pairs: totalSinglesAndPairsHands += p.idList.list.count; sectionTotals["Singles & Pairs"]! += p.idList.list.count
            default: break
            }
            total += p.idList.list.count
        }
        
        topSections = Array(sectionTotals.sorted(by: { $0.value > $1.value }).prefix(4))
        bottomSections = Array(sectionTotals.sorted(by: { $0.value < $1.value }).prefix(4))
        return total
    }
    
    func topSectionsString() -> String {
        let sectionNames = topSections.map { $0.0 }
        return sectionNames.joined(separator: ", ")
    }
    
    func bottomSectionsString() -> String {
        let sectionNames = bottomSections.map { $0.0 }
        return sectionNames.joined(separator: ", ")
    }
        
    func setTileTotals() {
        var tileTotals: [String: Int] = [:] // Dictionary to track tile names and their counts

        total1s = 0
        total2s = 0
        total3s = 0
        total4s = 0
        total5s = 0
        total6s = 0
        total7s = 0
        total8s = 0
        total9s = 0
        totalSoaps = 0
        totalGreen = 0
        totalRed = 0
        totalNorth = 0
        totalSouth = 0
        totalWest = 0
        totalEast = 0
        totalFlowers = 0
            
        for p in handList {
            for idlist in p.idList.list {
                for id in idlist.ids {
                    let tileName: String
                    switch(id) {
                    case 1: total1s += 1; tileName = "1"
                    case 2: total2s += 1; tileName = "2"
                    case 3: total3s += 1; tileName = "3"
                    case 4: total4s += 1; tileName = "4"
                    case 5: total5s += 1; tileName = "5"
                    case 6: total6s += 1; tileName = "6"
                    case 7: total7s += 1; tileName = "7"
                    case 8: total8s += 1; tileName = "8"
                    case 9: total9s += 1; tileName = "9"
                    case 10: totalSoaps += 1; tileName = "Soap"
                    case 11: total1s += 1; tileName = "1"
                    case 12: total2s += 1; tileName = "2"
                    case 13: total3s += 1; tileName = "3"
                    case 14: total4s += 1; tileName = "4"
                    case 15: total5s += 1; tileName = "5"
                    case 16: total6s += 1; tileName = "6"
                    case 17: total7s += 1; tileName = "7"
                    case 18: total8s += 1; tileName = "8"
                    case 19: total9s += 1; tileName = "9"
                    case 20: totalGreen += 1; tileName = "Green"
                    case 21: total1s += 1; tileName = "1"
                    case 22: total2s += 1; tileName = "2"
                    case 23: total3s += 1; tileName = "3"
                    case 24: total4s += 1; tileName = "4"
                    case 25: total5s += 1; tileName = "5"
                    case 26: total6s += 1; tileName = "6"
                    case 27: total7s += 1; tileName = "7"
                    case 28: total8s += 1; tileName = "8"
                    case 29: total9s += 1; tileName = "9"
                    case 30: totalRed += 1; tileName = "Red"
                    case 31: totalNorth += 1; tileName = "North"
                    case 32: totalSouth += 1; tileName = "South"
                    case 33: totalWest += 1; tileName = "West"
                    case 34: totalEast += 1; tileName = "East"
                    case 35: totalFlowers += 1; tileName = "Flowers"
                    default: tileName = "Unknown"
                    }
                    tileTotals[tileName, default: 0] += 1
                }
            }
        }
        topTiles = Array(tileTotals.sorted(by: { $0.value > $1.value }).prefix(4))
        bottomTiles = Array(tileTotals.sorted(by: { $0.value < $1.value }).prefix(4))
    }
    
    func topTilesString() -> String {
        let tileNames = topTiles.map { $0.0 }
        return tileNames.joined(separator: ", ")
    }
    
    func bottomTilesString() -> String {
        let tileNames = bottomTiles.map { $0.0 }
        return tileNames.joined(separator: ", ")
    }
    
    func getHandString(_ ids: [Int]) -> String {
        var hand = ""
        for id in ids {
            switch(id) {
            case 1: hand += "1d "
            case 2: hand += "2d "
            case 3: hand += "3d "
            case 4: hand += "4d "
            case 5: hand += "5d "
            case 6: hand += "6d "
            case 7: hand += "7d "
            case 8: hand += "8d "
            case 9: hand += "9d "
            case 10: hand += "0 "
            case 11: hand += "1b "
            case 12: hand += "2b "
            case 13: hand += "3b "
            case 14: hand += "4b "
            case 15: hand += "5b "
            case 16: hand += "6b "
            case 17: hand += "7b "
            case 18: hand += "8b "
            case 19: hand += "9b "
            case 20: hand += "g "
            case 21: hand += "1c "
            case 22: hand += "2c "
            case 23: hand += "3c "
            case 24: hand += "4c "
            case 25: hand += "5c "
            case 26: hand += "6c "
            case 27: hand += "7c "
            case 28: hand += "8c "
            case 29: hand += "9c "
            case 30: hand += "r "
            case 31: hand += "n "
            case 32: hand += "s "
            case 33: hand += "w "
            case 34: hand += "e "
            case 35: hand += "f "
            default: break
            }
        }
        return hand
    }
    
    
    // --------------------------------------------------------------
    //
    //  Overlapping Hands
    //
    // --------------------------------------------------------------
    
    func setOverlappingHands(lps: [Hand]) {
        // do this once to generate the hardcodded array
        if resultsSet.isEmpty {
            for lp in lps {
                findOverlappingHandsForHand(lps: lps, lp: lp)
            }
            rebuildResultsArray()
        }
    }
    
    func rebuildResultsArray() {
        resultsArray.removeAll()
        let sortedResults = resultsSet.sorted { $0.lpId < $1.lpId }
        resultsArray.append(contentsOf: sortedResults)
    }
    
    func findOverlappingHandsForHand(lps: [Hand], lp: Hand) {
        for x in lp.tileVectorList.list {
            findOverlappingHandsForMap(lps: lps, lp: lp, tileMap: x.vector)
        }
    }
    
    struct OverlapResult: Hashable {
        let lpId: Int
        let pId: Int
        let difference: Int
        
        func getString(card: Card) -> String {
            let lp1 = card.getHandForId(id: lpId)
            let lp2 = card.getHandForId(id: pId)
            return String("\(lp1.text.string) : \(lp2.text.string)")
        }
    }

    func findOverlappingHandsForMap(lps: [Hand], lp: Hand, tileMap: [Int]) {
        for p in lps {
            var dif = 99
            if p.id != lp.id {
                for x in p.tileVectorList.list {
                    let newdif = sumOfDifferences(list1: tileMap, list2: x.vector) / 2
                    if newdif < dif {
                        dif = newdif
                    }
                }
            }
            if dif <= 4 {
                let newResult = OverlapResult(lpId: lp.id, pId: p.id, difference: 14 - dif)

                   if let existingResult = resultsSet.first(where: { $0.lpId == newResult.lpId && $0.pId == newResult.pId }) {
                    if newResult.difference > existingResult.difference {
                        resultsSet.remove(existingResult)
                        resultsSet.insert(newResult)
                        resultsArray.append(newResult)
                        //print("add \(lp.text.string) : \(p.text.string) \(14 - dif) matching tiles \(lp.id) \(p.id)")
                    }
                } else {
                    if resultsSet.insert(newResult).inserted {
                        resultsArray.append(newResult)
                        //print("add \(lp.text.string) : \(p.text.string) \(14 - dif) matching tiles \(lp.id) \(p.id)")
                    }
                }
            }
        }
       
    }
    
    func sumOfDifferences(list1: [Int], list2: [Int]) -> Int {
        var totalDifference = 0
        for i in 0..<list1.count {
            let difference = abs(list1[i] - list2[i])
            totalDifference += difference
        }
        return totalDifference
    }
    
    
    // -----------------------------------------------------------------------------------------
    //
    //  Load Card Stats
    //
    // -----------------------------------------------------------------------------------------
    
    func loadSectionHands(lps: [Hand]) -> [String] {
        if sectionHands.isEmpty {
            for p in lps {
                let line = "\(p.id + 1). \(p.getFamilyString()) \(p.idList.list.count) hands"
                sectionHands.append(line)
            }
        }
        return sectionHands
    }
        
    func loadAllHands(lps: [Hand]) -> [String] {
        var hand = 1
        if allHands.isEmpty {
            for p in lps {
                var index = 1
                for idlist in p.idList.list {
                    let line = "\(p.id + 1).\(index).  \(getHandString(idlist.ids))"
                    allHands.append(line)
                    hand += 1
                    index += 1
                }
            }
        }
        return allHands
    }
    
    
    // -----------------------------------------------------------------------------------------
    //
    //  2468
    //
    // -----------------------------------------------------------------------------------------
    
    func add18e1() {
        let p1 = add("FFF 22 44 666 8888", mask: "000 00 00 000 0000", jokerMask: "", note: "",  family: Family.f2468, concealed: false, points: 25)
        p1.generateList()
    }
    
    func add18e2() {
        let p2 = add("2222 44 6666 88 88", mask: "0000 00 0000 gg rr", jokerMask: "", note: "Any 3 Suits",  family: Family.f2468, concealed: false, points: 30)
        p2.add([2,2,2,2, 4,4, 6,6,6,6, 18,18, 28,28])
        p2.add([12,12,12,12, 14,14, 16,16,16,16, 8,8, 28,28])
        p2.add([22,22,22,22, 24,24, 26,26,26,26, 8,8, 18,18])
    }

    func add18e3() {
        let p3 = add("22 44 666 888 DDDD", mask: "gg gg rrr rrr 0000", jokerMask: "", note: "Any 3 Suits",  family: Family.f2468, concealed: false, points: 25)
        p3.generateList()
    }
    
    func add18e4() {
        let p4 = add("2222 4444 6666 88", mask: "0000 0000 0000 00", jokerMask: "", note: "",  family: Family.f2468, concealed: false, points: 25)
        p4.generateList()
    }
    
    func add18e5() {
        let p5 = add("222 444 6666 8888", mask: "ggg ggg rrrr rrrr", jokerMask: "", note: "Any 2 Suits",  family: Family.f2468, concealed: false, points: 25)
        p5.generateList()
    }
    
    func add18e6() {
        let p6 = add("222 444 666 888 DD (C)", mask: "000 000 000 000 00", jokerMask: "", note: "Any 1 Suit",  family: Family.f2468, concealed: true, points: 30)
        p6.generateList()
    }

    func add19e1() {
        let p1 = add("FFF 22 44 666 8888", mask: "000 00 00 000 0000", jokerMask: "", note: "",  family: Family.f2468, concealed: false, points: 25)
        p1.generateList()
    }
    
    func add19e2() {
        let p2 = add("222 4444 666 8888", mask: "ggg gggg rrr rrrr", jokerMask: "", note: "Any 2 Suits",  family: Family.f2468, concealed: false, points: 25)
        p2.generateList()
    }
    
    func add19e3() {
        let p3 = add("2222 4444 6666 88", mask: "0000 0000 0000 00", jokerMask: "", note: "",  family: Family.f2468, concealed: false, points: 25)
        p3.generateList()
    }
     
    func add19e4() {
        let p4 = add("FF 2222 44 66 8888", mask: "00 rrrr gg gg rrrr", jokerMask: "", note: "Any 2 Suits",  family: Family.f2468, concealed: false, points: 25)
        p4.generateList()
    }
     
    func add19e5() {
        let p5 = add("22 444 DDDD 666 88", mask: "00 000 0000 000 00", jokerMask: "", note: "",  family: Family.f2468, concealed: false, points: 25)
        p5.generateList()
    }
   
    func add19e6() {
        let p6 = add("222 44 666 888 888 (C)", mask: "ggg gg ggg rrr 000", jokerMask: "", note: "Any 3 Suits",  family: Family.f2468, concealed: true, points: 30)
        p6.add([2,2,2, 4,4, 6,6,6, 18,18,18, 28,28,28])
        p6.add([12,12,12, 14,14, 16,16,16, 8,8,8, 28,28,28])
        p6.add([22,22,22, 24,24, 26,26,26, 8,8,8, 18,18,18])
    }
    
    func add20e1() {
        let p1 = add("FFFF 2 44 666 8888", mask: "0000 0 00 000 0000", jokerMask: "", note: "Any 1 Suit",  family: Family.f2468, concealed: false, points: 25)
        p1.generateList()
    }
        
    func add20e2() {
        let p2 = add("22 44 666 888 DDDD", mask: "gg gg rrr rrr 0000", jokerMask: "", note: "Any 3 Suits",  family: Family.f2468, concealed: false, points: 25)
        p2.generateList()
    }
        
    func add20e3() {
        let p3 = add("2222 4444 6666 88", mask: "0000 0000 0000 00", jokerMask: "", note: "Any 1 Suit",  family: Family.f2468, concealed: false, points: 25)
        p3.generateList()
    }
    
    func add20e4() {
        let p4 = add("222 444 6666 8888", mask: "ggg ggg rrrr rrrr", jokerMask: "", note: "Any 2 Suits",  family: Family.f2468, concealed: false, points: 25)
        p4.generateList()
    }
        
    func add20e5() {
        let p5 = add("FFFF 4444 6666 24", mask: "0000 gggg rrrr 00", jokerMask: "", note: "Any 3 Suits",  family: Family.f2468, concealed: false, points: 25)
        p5.generateList()
    }
        
    func add20e6() {
        let p6 = add("FFFF 6666 8888 48", mask: "0000 gggg rrrr 00", jokerMask: "", note: "Any 3 Suits",  family: Family.f2468, concealed: false, points: 25)
        p6.generateList()
    }
    
    func add20e7() {
        let p7 = add("22 444 44 666 8888", mask: "gg ggg rr rrr 0000", jokerMask: "", note: "Any 3 Suits",  family: Family.f2468, concealed: false, points: 25)
        p7.generateList()
    }
    
    func add20e8() {
        let p8 = add("22 444 DDDD 666 88", mask: "00 000 0000 000 00", jokerMask: "", note: "Any 1 Suit",  family: Family.f2468, concealed: false, points: 25)
        p8.generateList()
    }
    
    func add20e9() {
        let p9 = add("FF 222 444 666 888 (C)", mask: "00 ggg rrr rrr ggg", jokerMask: "", note: "Any 2 Suits",  family: Family.f2468, concealed: true, points: 30)
        p9.generateList()
    }
        
    func addF2468_32234_1() {
        let p = add("FFF 22 44 666 8888", mask: "000 00 00 000 0000", jokerMask: "", note: "Any 1 Suit",  family: Family.f2468, concealed: false, points: 25)
        p.generateList()
    }
    
    func addF2468_41234_1() {
        let p = add("FFFF 2 44 666 8888", mask: "0000 0 00 000 0000", jokerMask: "", note: "Any 1 Suit",  family: Family.f2468, concealed: false, points: 25)
        p.generateList()
    }
        
    func add2021e2() {
        let p = add("222 4444 666 8888", mask: "ggg gggg rrr rrrr", jokerMask: "", note: "Any 2 Suits",  family: Family.f2468, concealed: false, points: 25)
        p.generateList()
    }
    
    func add2468_3344_2() {
        let p = add("222 444 6666 8888", mask: "ggg ggg rrrr rrrr", jokerMask: "", note: "Any 2 Suits",  family: Family.f2468, concealed: false, points: 25)
        p.generateList()
    }
    
    func add2021e6() {
        let p = add("2222 4444 6666 88", mask: "0000 0000 0000 00", jokerMask: "", note: "Any 1 Suit",  family: Family.f2468, concealed: false, points: 25)
        p.generateList()
    }
    
    func add2021e5() {
        let p = add("222 444 6666 8888", mask: "ggg ggg rrrr 0000", jokerMask: "", note: "Any 3 Suits",  family: Family.f2468, concealed: false, points: 25)
        p.generateList()
    }
    
    func add2021e4() {
        let p = add("FF 2222 44 66 8888", mask: "00 gggg rr rr gggg", jokerMask: "", note: "Any 2 Suits",  family: Family.f2468, concealed: false, points: 25)
        p.generateList()
    }
    
    func add2021e7() {
        let p = add("FF DDDD 2 4 6 8 DDDD", mask: "00 gggg 0 0 0 0 rrrr", jokerMask: "", note: "Any 3 Suits",  family: Family.f2468, concealed: false, points: 25)
        p.add([35,35, 10,10,10,10, 12,14,16,18, 30,30,30,30])
        p.add([35,35, 20,20,20,20, 2,4,6,8, 30,30,30,30])
        p.add([35,35, 10,10,10,10, 22,24,26,28, 20,20,20,20])
    }
    
    func add2021e8() {
        let p = add("222 4 6 888 222 222 (C)", mask: "ggg g g ggg rrr 000", jokerMask: "", note: "Like Pungs 2,4,6,8 in Other 2 Suits",  family: Family.f2468, concealed: true, points: 25)
        p.add([2,2,2, 4, 6, 8,8,8, 12,12,12, 22,22,22])
        p.add([2,2,2, 4, 6, 8,8,8, 14,14,14, 24,24,24])
        p.add([2,2,2, 4, 6, 8,8,8, 16,16,16, 26,26,26])
        p.add([2,2,2, 4, 6, 8,8,8, 18,18,18, 28,28,28])
        p.add([12,12,12, 14, 16, 18,18,18, 2,2,2, 22,22,22])
        p.add([12,12,12, 14, 16, 18,18,18, 4,4,4, 24,24,24])
        p.add([12,12,12, 14, 16, 18,18,18, 6,6,6, 26,26,26])
        p.add([12,12,12, 14, 16, 18,18,18, 8,8,8, 28,28,28])
        p.add([22,22,22, 24, 26, 28,28,28, 2,2,2, 12,12,12])
        p.add([22,22,22, 24, 26, 28,28,28, 4,4,4, 14,14,14])
        p.add([22,22,22, 24, 26, 28,28,28, 6,6,6, 16,16,16])
        p.add([22,22,22, 24, 26, 28,28,28, 8,8,8, 18,18,18])
    }
    
    func add24468_22334_3() {
        let p = add("22 44 444 666 8888", mask: "gg gg rrr rrr 0000", jokerMask: "", note: "Any 3 Suits",  family: Family.f2468, concealed: false, points: 25)
        p.generateList()
    }
        
    func add24D68_23432_1() {
        let p = add("22 444 DDDD 666 88", mask: "00 000 0000 000 00", jokerMask: "", note: "Any 1 Suit",  family: Family.f2468, concealed: false, points: 25)
        p.generateList()
    }
    
    func add2021e3() {
        let p = add("22 44 666 888 DDDD", mask: "00 00 000 000 0000", jokerMask: "", note: "Any 1 Suit, Matching Dragon",  family: Family.f2468, concealed: false, points: 25)
        p.generateList()
    }
    
    func add2021e1() {
        let p = add("22 444 FFFF 666 88", mask: "00 000 0000 000 00", jokerMask: "", note: "Any 1 Suit",  family: Family.f2468, concealed: false, points: 25)
        p.generateList()
    }
            
    func add2468_42422_3() {
        let p = add("2222 44 6666 88 88", mask: "0000 00 0000 gg rr", jokerMask: "", note: "Any 3 Suits",  family: Family.f2468, concealed: false, points: 30)
        p.add([2,2,2,2, 4,4, 6,6,6,6, 18,18, 28,28])
        p.add([12,12,12,12, 14,14, 16,16,16,16, 8,8, 28,28])
        p.add([22,22,22,22, 24,24, 26,26,26,26, 8,8, 18,18])
    }
    
    func add2468D_22334_3() {
        let p = add("22 44 666 888 DDDD", mask: "gg gg rrr rrr 0000", jokerMask: "", note: "Any 3 Suits",  family: Family.f2468, concealed: false, points: 25)
        p.generateList()
    }
        
    func add2468D_33332_C() {
        let p = add("222 444 666 888 DD (C)", mask: "000 000 000 000 00", jokerMask: "", note: "Any 1 Suit",  family: Family.f2468, concealed: true, points: 30)
        p.generateList()
    }
        
    func add24688_32333_C() {
        let p = add("222 44 666 888 888 (C)", mask: "ggg gg ggg rrr 000", jokerMask: "", note: "Any 3 Suits",  family: Family.f2468, concealed: true, points: 30)
        p.add([2,2,2, 4,4, 6,6,6, 18,18,18, 28,28,28])
        p.add([12,12,12, 14,14, 16,16,16, 8,8,8, 28,28,28])
        p.add([22,22,22, 24,24, 26,26,26, 8,8,8, 18,18,18])
    }
    
    func addF2348_23333_C() {
        let p = add("FF 222 444 666 888 (C)", mask: "00 000 000 000 000", jokerMask: "", note: "",  family: Family.f2468, concealed: true, points: 30)
        p.generateList()
    }
    
    func add2022e1() {
        let p1 = add("FFF 22 44 666 8888", mask: "000 00 00 000 0000", jokerMask: "", note: "Any 1 Suit",  family: Family.f2468, concealed: false, points: 25)
        p1.generateList()
    }
    
    func add2022e2() {
        let p2 = add("22 46 88 2222 2222", mask: "gg gg gg rrrr 0000", jokerMask: "", note: "Any 3 Suits, Kongs Any Like Even No",  family: Family.f2468, concealed: false, points: 25)
        p2.add([2,2, 4,6, 8,8, 12,12,12,12, 22,22,22,22])
        p2.add([2,2, 4,6, 8,8, 14,14,14,14, 24,24,24,24])
        p2.add([2,2, 4,6, 8,8, 16,16,16,16, 26,26,26,26])
        p2.add([2,2, 4,6, 8,8, 18,18,18,18, 28,28,28,28])
        p2.add([12,12, 14,16, 18,18, 2,2,2,2, 22,22,22,22])
        p2.add([12,12, 14,16, 18,18, 4,4,4,4, 24,24,24,24])
        p2.add([12,12, 14,16, 18,18, 6,6,6,6, 26,26,26,26])
        p2.add([12,12, 14,16, 18,18, 8,8,8,8, 28,28,28,28])
        p2.add([22,22, 24,26, 28,28, 2,2,2,2, 12,12,12,12])
        p2.add([22,22, 24,26, 28,28, 4,4,4,4, 14,14,14,14])
        p2.add([22,22, 24,26, 28,28, 6,6,6,6, 16,16,16,16])
        p2.add([22,22, 24,26, 28,28, 8,8,8,8, 18,18,18,18])
    }
    
    func add2022e3() {
        let p3 = add("222 444 6666 8888", mask: "ggg ggg rrrr rrrr", jokerMask: "", note: "Any 2 Suits",  family: Family.f2468, concealed: false, points: 25)
        p3.generateList()
    }
    
    func add2022e4() {
        let p4 = add("222 444 6666 8888", mask: "ggg ggg rrrr 0000", jokerMask: "", note: "Any 3 Suits",  family: Family.f2468, concealed: false, points: 25)
        p4.generateList()
    }
    
    func add2022e5() {
        let p5 = add("2222 44 6666 88 88", mask: "0000 00 0000 gg rr", jokerMask: "", note: "Any 3 Suits",  family: Family.f2468, concealed: false, points: 30)
        p5.add([2,2,2,2, 4,4, 6,6,6,6, 18,18, 28,28])
        p5.add([12,12,12,12, 14,14, 16,16,16,16, 8,8, 28,28])
        p5.add([22,22,22,22, 24,24, 26,26,26,26, 8,8, 18,18])
    }
    
    func add2022e6() {
        let p6 = add("22 444 66 888 DDDD", mask: "00 000 00 000 0000", jokerMask: "", note: "Any 1 Suit",  family: Family.f2468, concealed: false, points: 25)
        p6.generateList()
    }
    
    func add2022e7() {
        let p7 = add("22 444 66 888 DDDD", mask: "gg ggg rr rrr 0000", jokerMask: "", note: "Any 3 Suits",  family: Family.f2468, concealed: false, points: 25)
        p7.generateList()
    }
    
    func add2022e8() {
        let p8 = add("FFF 2222 FFF 8888", mask: "000 gggg 000 rrrr", jokerMask: "", note: "Any 2 Suits, These Nos Only",  family: Family.f2468, concealed: false, points: 30)
        p8.add([35,35,35, 2,2,2,2, 35,35,35, 18,18,18,18])
        p8.add([35,35,35, 2,2,2,2, 35,35,35, 28,28,28,28])
        p8.add([35,35,35, 12,12,12,12, 35,35,35, 8,8,8,8])
        p8.add([35,35,35, 12,12,12,12, 35,35,35, 28,28,28,28])
        p8.add([35,35,35, 22,22,22,22, 35,35,35, 8,8,8,8])
        p8.add([35,35,35, 22,22,22,22, 35,35,35, 18,18,18,18])
    }
    
    func add2022e9() {
        let p9 = add("22 444 44 666 8888", mask: "gg ggg rr rrr 0000", jokerMask: "", note: "Any 3 Suits",  family: Family.f2468, concealed: false, points: 25)
        p9.generateList()
    }
    
    func add2022e10() {
        let p10 = add("FF 246 888 246 888 (C)", mask: "00 ggg ggg rrr rrr", jokerMask: "", note: "Any 2 Suits",  family: Family.f2468, concealed: true, points: 30)
        p10.add([35,35, 2,4,6, 8,8,8, 12,14,16, 18,18,18])
        p10.add([35,35, 2,4,6, 8,8,8, 22,24,26, 28,28,28])
        p10.add([35,35, 12,14,16, 18,18,18, 22,24,26, 28,28,28])
    }
    
    // -----------------------------------------------------------------------------------------
    //
    //  Standard Like Num
    //
    // -----------------------------------------------------------------------------------------
    
    func add2018l1() {
        let p1 = add("FF 1111 DDDD 1111", mask: "00 gggg 0000 rrrr", jokerMask: "", note: "Any Like No.",  family: Family.likeNumbers, concealed: false, points: 25)
        for i in 1...9 {
            let d = i
            let b = i+10
            let c = i+20
            p1.add([35,35, b,b,b,b, 10,10,10,10, c,c,c,c])
            p1.add([35,35, d,d,d,d, 20,20,20,20, c,c,c,c])
            p1.add([35,35, d,d,d,d, 30,30,30,30, b,b,b,b])
        }
    }
    
    func add2018l2() {
        let p2 = add("FFF 1111 FFF 1111", mask: "000 gggg 000 rrrr", jokerMask: "", note: "Any Like No.",  family: Family.likeNumbers, concealed: false, points: 30)
        for i in 1...9 {
            let d = i
            let b = i+10
            let c = i+20
            p2.add([35,35,35, d,d,d,d, 35,35,35, b,b,b,b])
            p2.add([35,35,35, d,d,d,d, 35,35,35, c,c,c,c])
            p2.add([35,35,35, b,b,b,b, 35,35,35, c,c,c,c])
        }
    }
    
    func add2018l3() {
        let p3 = add("11 DD 111 DDD 1111 (C)", mask: "gg gg rrr rrr 0000", jokerMask: "", note: "Any Like No.",  family: Family.likeNumbers, concealed: true, points: 30)
        p3.generateList()
    }
    
    func add2019l1() {
        let p1 = add("FF 1111 1111 1111", mask: "00 gggg rrrr 0000", jokerMask: "", note: "Any 3 Suits",  family: Family.likeNumbers, concealed: false, points: 25)
        for i in 1...9 {
            let d = i
            let b = i+10
            let c = i+20
            p1.add([35,35, d,d,d,d, b,b,b,b, c,c,c,c])
        }
    }
    
    func add2019l2() {
        let p2 = add("11 DD 111 DDD 1111 (C)", mask: "gg gg rrr rrr 0000", jokerMask: "", note: "Any 3 Suits",  family: Family.likeNumbers, concealed: true, points: 30)
        p2.generateList()
    }
    
    func add2020l1() {
        let p1 = add("FF 1111 1111 1111", mask: "00 gggg rrrr 0000", jokerMask: "", note: "Any 3 Suits",  family: Family.likeNumbers, concealed: false, points: 25)
        for i in 1...9 {
            let d = i
            let b = i+10
            let c = i+20
            p1.add([35,35, d,d,d,d, b,b,b,b, c,c,c,c])
        }
    }
    
    func add2020l2() {
        let p2 = add("FF 1111 DD 1111 DD", mask: "00 gggg gg rrrr rr", jokerMask: "", note: "Any 2 Suits",  family: Family.likeNumbers, concealed: false, points: 25)
        for i in 1...9 {
            let d = i
            let b = i+10
            let c = i+20
            p2.add([35,35, d,d,d,d, 10,10, b,b,b,b, 20,20])
            p2.add([35,35, d,d,d,d, 10,10, c,c,c,c, 30,30])
            p2.add([35,35, b,b,b,b, 20,20, c,c,c,c, 30,30])
        }
    }
    
    func add2020l3() {
        let p3 = add("FFFFF 11 111 1111", mask: "00000 gg rrr 0000", jokerMask: "", note: "Any 3 Suits",  family: Family.likeNumbers, concealed: false, points: 25)
        for i in 1...9 {
            let d = i
            let b = i+10
            let c = i+20
            p3.add([35,35,35,35,35, d,d, b,b,b, c,c,c,c])
            p3.add([35,35,35,35,35, d,d, c,c,c, b,b,b,b])
            p3.add([35,35,35,35,35, b,b, d,d,d, c,c,c,c])
            p3.add([35,35,35,35,35, b,b, c,c,c, d,d,d,d])
            p3.add([35,35,35,35,35, c,c, d,d,d, b,b,b,b])
            p3.add([35,35,35,35,35, c,c, b,b,b, d,d,d,d])
        }
    }
    
    
    func addLikeF111_2444_3() {
        let p = add("FF 1111 1111 1111", mask: "00 gggg rrrr 0000", jokerMask: "", note: "Any 3 Suits",  family: Family.likeNumbers, concealed: false, points: 25)
        for i in 1...9 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([35,35, d,d,d,d, b,b,b,b, c,c,c,c])
        }
    }
    
    func addLike1D1D1_22334_C() {
        let p = add("11 DD 111 DDD 1111 (C)", mask: "gg gg rrr rrr 0000", jokerMask: "", note: "Any 3 Suits",  family: Family.likeNumbers, concealed: true, points: 30)
        p.generateList()
    }
    
    func add2022l3() {
        let p = add("FF 1111 DDDD 1111", mask: "00 gggg rrrr 0000", jokerMask: "", note: "Any Like No.",  family: Family.likeNumbers, concealed: false, points: 25)
        for i in 1...9 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([35,35, b,b,b,b, 10,10,10,10, c,c,c,c])
            p.add([35,35, d,d,d,d, 20,20,20,20, c,c,c,c])
            p.add([35,35, d,d,d,d, 30,30,30,30, b,b,b,b])
        }
    }
    
    func add2022l1() {
        let p = add("FFF 1111 FFF 1111", mask: "000 gggg 000 rrrr", jokerMask: "", note: "Any Like No.",  family: Family.likeNumbers, concealed: false, points: 30)
        for i in 1...9 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([35,35,35, d,d,d,d, 35,35,35, b,b,b,b])
            p.add([35,35,35, d,d,d,d, 35,35,35, c,c,c,c])
            p.add([35,35,35, b,b,b,b, 35,35,35, c,c,c,c])
        }
    }
    
    func addLikeF1D1D_24242_2() {
        let p = add("FF 1111 DD 1111 DD", mask: "00 gggg gg rrrr rr", jokerMask: "", note: "Any 2 Suits",  family: Family.likeNumbers, concealed: false, points: 25)
        for i in 1...9 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([35,35, d,d,d,d, 10,10, b,b,b,b, 20,20])
            p.add([35,35, d,d,d,d, 10,10, c,c,c,c, 30,30])
            p.add([35,35, b,b,b,b, 20,20, c,c,c,c, 30,30])
        }
    }
    
    func add2022l2() {
        let p = add("111 DD 111 DD 1111", mask: "ggg gg rrr rr 0000", jokerMask: "", note: "Any 3 Suits",  family: Family.likeNumbers, concealed: false, points: 25)
        for i in 1...9 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([d,d,d, 10,10, b,b,b, 20,20, c,c,c,c])
            p.add([d,d,d, 10,10, c,c,c, 30,30, b,b,b,b])
            p.add([b,b,b, 20,20, c,c,c, 30,30, d,d,d,d])
        }
    }
        
    func addLikeF111_5234_3() {
        let p = add("FFFFF 11 111 1111", mask: "00000 gg rrr 0000", jokerMask: "", note: "Any 3 Suits",  family: Family.likeNumbers, concealed: false, points: 25)
        for i in 1...9 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([35,35,35,35,35, d,d, b,b,b, c,c,c,c])
            p.add([35,35,35,35,35, d,d, c,c,c, b,b,b,b])
            p.add([35,35,35,35,35, b,b, d,d,d, c,c,c,c])
            p.add([35,35,35,35,35, b,b, c,c,c, d,d,d,d])
            p.add([35,35,35,35,35, c,c, d,d,d, b,b,b,b])
            p.add([35,35,35,35,35, c,c, b,b,b, d,d,d,d])
        }
    }
    
    func add2021l2() {
        let p = add("FFFF 1111 11 1111", mask: "0000 gggg rr 0000", jokerMask: "", note: "Any 3 Suits",  family: Family.likeNumbers, concealed: false, points: 25)
        for i in 1...9 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([35,35,35,35, d,d,d,d, b,b, c,c,c,c])
            p.add([35,35,35,35, d,d,d,d, c,c, b,b,b,b])
            p.add([35,35,35,35, b,b,b,b, d,d, c,c,c,c])
        }
    }
    
    func add2021l3() {
        let p = add("111 DDDD 111 DDDD", mask: "ggg gggg rrr rrrr", jokerMask: "", note: "Any 2 Suits, Matching Dragons",  family: Family.likeNumbers, concealed: false, points: 25)
        for i in 1...9 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([d,d,d, 10,10,10,10, b,b,b, 20,20,20,20])
            p.add([d,d,d, 10,10,10,10, c,c,c, 30,30,30,30])
            p.add([b,b,b, 20,20,20,20, c,c,c, 30,30,30,30])
        }
    }
    
    func add2021l1() {
        let p = add("FF 1111 NEWS 1111", mask: "00 gggg 0000 rrrr", jokerMask: "", note: "Any 2 Suits",  family: Family.likeNumbers, concealed: false, points: 25)
        for i in 1...9 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([35,35, d,d,d,d, 31,34,33,32, b,b,b,b])
            p.add([35,35, d,d,d,d, 31,34,33,32, c,c,c,c])
            p.add([35,35, b,b,b,b, 31,34,33,32, c,c,c,c])
        }
    }
    
    
    // -----------------------------------------------------------------------------------------
    //
    //  Standard Quints
    //
    // -----------------------------------------------------------------------------------------
    
    func add2018q1() {
        let p1 = add("NNNNN DDDD 11111", mask: "00000 gggg rrrrr", jokerMask: "", note: "Any Wind, Dragon or No.",  family: Family.quints, concealed: false, points: 45)
        for w in 31...34 {
            for i in 1...9 {
                let d = i
                let b = i+10
                let c = i+20
                p1.add([w,w,w,w,w, 10,10,10,10, d,d,d,d,d])
                p1.add([w,w,w,w,w, 20,20,20,20, d,d,d,d,d])
                p1.add([w,w,w,w,w, 30,30,30,30, d,d,d,d,d])
                p1.add([w,w,w,w,w, 10,10,10,10, b,b,b,b,b])
                p1.add([w,w,w,w,w, 20,20,20,20, b,b,b,b,b])
                p1.add([w,w,w,w,w, 30,30,30,30, b,b,b,b,b])
                p1.add([w,w,w,w,w, 10,10,10,10, c,c,c,c,c])
                p1.add([w,w,w,w,w, 20,20,20,20, c,c,c,c,c])
                p1.add([w,w,w,w,w, 30,30,30,30, c,c,c,c,c])
            }
        }
    }
     
    func add2018q2() {
        let p2 = add("FF 33333 66 99999", mask: "00 00000 00 00000", jokerMask: "", note: "",  family: Family.quints, concealed: false, points: 45)
        p2.generateList()
    }
    
    func add2018q3() {
        let p3 = add("1123 11111 11111", mask: "gggg rrrrr 00000", jokerMask: "", note: "Any Run, Any Pair",  family: Family.quints, concealed: false, points: 40)
        for i in 1...7 {
            let d = i
            let b = i+10
            let c = i+20
            p3.add([d,d,d+1,d+2, b,b,b,b,b, c,c,c,c,c])
            p3.add([b,b,b+1,b+2, d,d,d,d,d, c,c,c,c,c])
            p3.add([c,c,c+1,c+2, d,d,d,d,d, b,b,b,b,b])
            p3.add([d,d+1,d+1,d+2, b+1,b+1,b+1,b+1,b+1, c+1,c+1,c+1,c+1,c+1])
            p3.add([b,b+1,b+1,b+2, d+1,d+1,d+1,d+1,d+1, c+1,c+1,c+1,c+1,c+1])
            p3.add([c,c+1,c+1,c+2, d+1,d+1,d+1,d+1,d+1, b+1,b+1,b+1,b+1,b+1])
            p3.add([d,d+1,d+2,d+2, b+2,b+2,b+2,b+2,b+2, c+2,c+2,c+2,c+2,c+2])
            p3.add([b,b+1,b+2,b+2, d+2,d+2,d+2,d+2,d+2, c+2,c+2,c+2,c+2,c+2])
            p3.add([c,c+1,c+2,c+2, d+2,d+2,d+2,d+2,d+2, b+2,b+2,b+2,b+2,b+2])
        }
    }
    
    func add2018q4() {
        let p4 = add("11111 22 33 44444", mask: "00000 00 00 00000", jokerMask: "", note: "Any 4 Consec. Nos.",  family: Family.quints, concealed: false, points: 45)
        for i in 1...6 {
            let d = i
            let b = i+10
            let c = i+20
            p4.add([d,d,d,d,d, d+1,d+1, d+2,d+2, d+3,d+3,d+3,d+3,d+3])
            p4.add([b,b,b,b,b, b+1,b+1, b+2,b+2, b+3,b+3,b+3,b+3,b+3])
            p4.add([c,c,c,c,c, c+1,c+1, c+2,c+2, c+3,c+3,c+3,c+3,c+3])
        }
    }
        
    func add2019q1() {
        let p1 = add("11 222 3333 44444", mask: "00 000 0000 00000", jokerMask: "", note: "Any 4 Consec Nos.",  family: Family.quints, concealed: false, points: 45)
        for i in 1...6 {
            let d = i
            let b = i+10
            let c = i+20
            p1.add([d,d, d+1,d+1,d+1, d+2,d+2,d+2,d+2, d+3,d+3,d+3,d+3,d+3])
            p1.add([b,b, b+1,b+1,b+1, b+2,b+2,b+2,b+2, b+3,b+3,b+3,b+3,b+3])
            p1.add([c,c, c+1,c+1,c+1, c+2,c+2,c+2,c+2, c+3,c+3,c+3,c+3,c+3])
        }
    }
    
    func add2019q2() {
        let p2 = add("FFFF NNNNN 11111", mask: "0000 00000 ggggg", jokerMask: "", note: "Any Wind, Any No.",  family: Family.quints, concealed: false, points: 45)
        for w in 31...34 {
            for i in 1...9 {
                let d = i
                let b = i+10
                let c = i+20
                p2.add([35,35,35,35, w,w,w,w,w, d,d,d,d,d])
                p2.add([35,35,35,35, w,w,w,w,w, b,b,b,b,b])
                p2.add([35,35,35,35, w,w,w,w,w, c,c,c,c,c])
            }
        }
    }
    
    func add2019q3() {
        let p3 = add("11111 22 33333 DD", mask: "00000 00 00000 00", jokerMask: "", note: "Any 3 Consec Nos. Dragons Match",  family: Family.quints, concealed: false, points: 45)
        for i in 1...7 {
            let d = i
            let b = i+10
            let c = i+20
            p3.add([d,d,d,d,d, d+1,d+1, d+2,d+2,d+2,d+2,d+2, 10,10])
            p3.add([b,b,b,b,b, b+1,b+1, b+2,b+2,b+2,b+2,b+2, 20,20])
            p3.add([c,c,c,c,c, c+1,c+1, c+2,c+2,c+2,c+2,c+2, 30,30])
        }
    }
    
    func add2019q4() {
        let p4 = add("11111 DDDD 11111", mask: "ggggg 0000 rrrrr", jokerMask: "", note: "Any Like Nos. Opposite Dragon",  family: Family.quints, concealed: false, points: 40)
        for i in 1...9 {
            let d = i
            let b = i+10
            let c = i+20
            p4.add([d,d,d,d,d, 20,20,20,20, c,c,c,c,c])
            p4.add([d,d,d,d,d, 30,30,30,30, b,b,b,b,b])
            p4.add([b,b,b,b,b, 10,10,10,10, c,c,c,c,c])
        }
    }
        
    func add2020q1() {
        let p1 = add("FFFFF DDDD 11111", mask: "00000 0000 ggggg", jokerMask: "", note: "Any No in Any Suit, Any Dragon",  family: Family.quints, concealed: false, points: 40)
        for i in 1...9 {
            let d = i
            let b = i+10
            let c = i+20
            p1.add([35,35,35,35,35, 10,10,10,10, d,d,d,d,d])
            p1.add([35,35,35,35,35, 10,10,10,10, b,b,b,b,b])
            p1.add([35,35,35,35,35, 10,10,10,10, c,c,c,c,c])
            p1.add([35,35,35,35,35, 20,20,20,20, d,d,d,d,d])
            p1.add([35,35,35,35,35, 20,20,20,20, b,b,b,b,b])
            p1.add([35,35,35,35,35, 20,20,20,20, c,c,c,c,c])
            p1.add([35,35,35,35,35, 30,30,30,30, d,d,d,d,d])
            p1.add([35,35,35,35,35, 30,30,30,30, b,b,b,b,b])
            p1.add([35,35,35,35,35, 30,30,30,30, c,c,c,c,c])
        }
    }
    
    func add2020q2() {
        let p2 = add("11 22 33333 33333", mask: "gg gg rrrrr 00000", jokerMask: "", note: "Any 3 Suits, Any 3 Consec Nos",  family: Family.quints, concealed: false, points: 45)
        for i in 1...7 {
            let d = i
            let b = i+10
            let c = i+20
            p2.add([d,d, d+1,d+1, b+2,b+2,b+2,b+2,b+2, c+2,c+2,c+2,c+2,c+2])
            p2.add([b,b, b+1,b+1, d+2,d+2,d+2,d+2,d+2, c+2,c+2,c+2,c+2,c+2])
            p2.add([c,c, c+1,c+1, d+2,d+2,d+2,d+2,d+2, b+2,b+2,b+2,b+2,b+2])
        }
    }
    
    func add2020q3() {
        let p3 = add("11111 3333 55555", mask: "00000 0000 00000", jokerMask: "", note: "Any 1 Suit, These No Only",  family: Family.quints, concealed: false, points: 45)
        p3.generateList()
    }
    
    func add2020q4() {
        let p4 = add("55555 7777 99999", mask: "00000 0000 00000", jokerMask: "", note: "Any 1 Suit, These No Only",  family: Family.quints, concealed: false, points: 45)
        p4.generateList()
    }
    
    func add2020q5() {
        let p5 = add("11111 22 33 44444", mask: "00000 00 00 00000", jokerMask: "", note: "Any 1 Suit, Any 4 Consec Nos",  family: Family.quints, concealed: false, points: 45)
        for i in 1...6 {
            let d = i
            let b = i+10
            let c = i+20
            p5.add([d,d,d,d,d, d+1,d+1, d+2,d+2, d+3,d+3,d+3,d+3,d+3])
            p5.add([b,b,b,b,b, b+1,b+1, b+2,b+2, b+3,b+3,b+3,b+3,b+3])
            p5.add([c,c,c,c,c, c+1,c+1, c+2,c+2, c+3,c+3,c+3,c+3,c+3])
        }
    }
    
    func add2022q2() {
        let p2 = add("22 444 6666 88888", mask: "00 000 0000 00000", jokerMask: "", note: "Any 1 Suit",  family: Family.quints, concealed: false, points: 45)
        p2.generateList()
    }
        
    func addQ1234_2345_1() {
        let p = add("11 222 3333 44444", mask: "00 000 0000 00000", jokerMask: "", note: "Any 4 Consec Nos.",  family: Family.quints, concealed: false, points: 45)
        for i in 1...6 {
            let d = i
            let b = i+10
            let c = i+20
            p.add( [d,d, d+1,d+1,d+1, d+2,d+2,d+2,d+2, d+3,d+3,d+3,d+3,d+3])
            p.add([b,b, b+1,b+1,b+1, b+2,b+2,b+2,b+2, b+3,b+3,b+3,b+3,b+3])
            p.add([c,c, c+1,c+1,c+1, c+2,c+2,c+2,c+2, c+3,c+3,c+3,c+3,c+3])
        }
    }
    
    func add2021q2() {
        let p = add("11111 22 33 44444", mask: "ggggg rr rr ggggg", jokerMask: "", note: "Any 2 Suits, Any 4 Consec Nos.",  family: Family.quints, concealed: false, points: 45)
        for i in 1...6 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([d,d,d,d,d, b+1,b+1, b+2,b+2, d+3,d+3,d+3,d+3,d+3])
            p.add([d,d,d,d,d, c+1,c+1, c+2,c+2, d+3,d+3,d+3,d+3,d+3])
            p.add([b,b,b,b,b, d+1,d+1, d+2,d+2, b+3,b+3,b+3,b+3,b+3])
            p.add([b,b,b,b,b, c+1,c+1, c+2,c+2, b+3,b+3,b+3,b+3,b+3])
            p.add([c,c,c,c,c, d+1,d+1, d+2,d+2, c+3,c+3,c+3,c+3,c+3])
            p.add([c,c,c,c,c, b+1,b+1, b+2,b+2, c+3,c+3,c+3,c+3,c+3])
        }
    }
    
    func add2021q5() {
        let p = add("11 22222 11 22222", mask: "gg ggggg rr rrrrr", jokerMask: "", note: "Any 2 Suits, Any 2 Consec Nos.",  family: Family.quints, concealed: false, points: 45)
        for i in 1...8 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([d,d, d+1,d+1,d+1,d+1,d+1, b,b, b+1,b+1,b+1,b+1,b+1])
            p.add([d,d, d+1,d+1,d+1,d+1,d+1, c,c, c+1,c+1,c+1,c+1,c+1])
            p.add([b,b, b+1,b+1,b+1,b+1,b+1, c,c, c+1,c+1,c+1,c+1,c+1])
        }
    }
    
    func addQFN1_455() {
        let p = add("FFFF NNNNN 11111", mask: "0000 00000 ggggg", jokerMask: "", note: "Any Wind, Any No.",  family: Family.quints, concealed: false, points: 45)
        for w in 31...34 {
            for i in 1...9 {
                let d = i
                let b = i+10
                let c = i+20
                p.add([35,35,35,35, w,w,w,w,w, d,d,d,d,d])
                p.add([35,35,35,35, w,w,w,w,w, b,b,b,b,b])
                p.add([35,35,35,35, w,w,w,w,w, c,c,c,c,c])
            }
        }
    }
    
    func add2021q1() {
        let p = add("FFFFF 1111 NNNNN", mask: "00000 0000 00000", jokerMask: "", note: "Any Wind, Any No.",  family: Family.quints, concealed: false, points: 45)
        for w in 31...34 {
            for i in 1...9 {
                let d = i
                let b = i+10
                let c = i+20
                p.add([35,35,35,35,35, d,d,d,d, w,w,w,w,w])
                p.add([35,35,35,35,35, b,b,b,b, w,w,w,w,w])
                p.add([35,35,35,35,35, c,c,c,c, w,w,w,w,w])
            }
        }
    }
    
    func addQ123D_5252_1() {
        let p = add("11111 22 33333 DD", mask: "00000 00 00000 00", jokerMask: "", note: "Any 3 Consec Nos. Dragons Match",  family: Family.quints, concealed: false, points: 45)
        for i in 1...7 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([d,d,d,d,d, d+1,d+1, d+2,d+2,d+2,d+2,d+2, 10,10])
            p.add([b,b,b,b,b, b+1,b+1, b+2,b+2,b+2,b+2,b+2, 20,20])
            p.add([c,c,c,c,c, c+1,c+1, c+2,c+2,c+2,c+2,c+2, 30,30])
        }
    }
    
    func addQ1D1_545_3() {
        let p = add("11111 DDDD 11111", mask: "ggggg 0000 rrrrr", jokerMask: "", note: "Any Like Nos. Opposite Dragon",  family: Family.quints, concealed: false, points: 40)
        for i in 1...9 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([d,d,d,d,d, 20,20,20,20, c,c,c,c,c])
            p.add([d,d,d,d,d, 30,30,30,30, b,b,b,b,b])
            p.add([b,b,b,b,b, 10,10,10,10, c,c,c,c,c])
        }
    }
    
    func addQND1_545() {
        let p = add("NNNNN DDDD 11111", mask: "00000 gggg rrrrr", jokerMask: "", note: "Any Wind, Dragon or No.",  family: Family.quints, concealed: false, points: 45)
        for w in 31...34 {
            for i in 1...9 {
                let d = i
                let b = i+10
                let c = i+20
                p.add([w,w,w,w,w, 10,10,10,10, d,d,d,d,d])
                p.add([w,w,w,w,w, 20,20,20,20, d,d,d,d,d])
                p.add([w,w,w,w,w, 30,30,30,30, d,d,d,d,d])
                p.add([w,w,w,w,w, 10,10,10,10, b,b,b,b,b])
                p.add([w,w,w,w,w, 20,20,20,20, b,b,b,b,b])
                p.add([w,w,w,w,w, 30,30,30,30, b,b,b,b,b])
                p.add([w,w,w,w,w, 10,10,10,10, c,c,c,c,c])
                p.add([w,w,w,w,w, 20,20,20,20, c,c,c,c,c])
                p.add([w,w,w,w,w, 30,30,30,30, c,c,c,c,c])
            }
        }
    }
    
    func add2022q1() {
        let p = add("DDDDD NNNN 11111", mask: "00000 0000 00000", jokerMask: "", note: "Any Dragon, Any Wind, Any No.",  family: Family.quints, concealed: false, points: 45)
        for w in 31...34 {
            for i in 1...9 {
                let d = i
                let b = i+10
                let c = i+20
                p.add([10,10,10,10,10, w,w,w,w, d,d,d,d,d])
                p.add([20,20,20,20,20, w,w,w,w, d,d,d,d,d])
                p.add([30,30,30,30,30, w,w,w,w, d,d,d,d,d])
                p.add([10,10,10,10,10, w,w,w,w, b,b,b,b,b])
                p.add([20,20,20,20,20, w,w,w,w, b,b,b,b,b])
                p.add([30,30,30,30,30, w,w,w,w, b,b,b,b,b])
                p.add([10,10,10,10,10, w,w,w,w, c,c,c,c,c])
                p.add([20,20,20,20,20, w,w,w,w, c,c,c,c,c])
                p.add([30,30,30,30,30, w,w,w,w, c,c,c,c,c])
            }
        }
    }
    
    func addQ111_545_3() {
        let p = add("11111 1111 11111", mask: "ggggg rrrr 00000", jokerMask: "", note: "Any Like No.",  family: Family.quints, concealed: false, points: 40)
        for i in 1...9 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([d,d,d,d,d, b,b,b,b, c,c,c,c,c])
            p.add([d,d,d,d,d, c,c,c,c, b,b,b,b,b])
            p.add([b,b,b,b,b, d,d,d,d, c,c,c,c,c])
        }
    }
    
    func addQF123_2525_1() {
        let p = add("FF 11111 22 33333", mask: "00 00000 00 00000", jokerMask: "", note: "Any 3 Consec. Nos.",  family: Family.quints, concealed: false, points: 45)
        for i in 1...7 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([35,35, d,d,d,d,d, d+1,d+1, d+2,d+2,d+2,d+2,d+2])
            p.add([35,35, b,b,b,b,b, b+1,b+1, b+2,b+2,b+2,b+2,b+2])
            p.add([35,35, c,c,c,c,c, c+1,c+1, c+2,c+2,c+2,c+2,c+2])
        }
    }
    
    func add2022q4() {
        let p = add("FFFF 11111 22222", mask: "0000 00000 00000", jokerMask: "", note: "Any 1 Suit, Any 2 Consec. Nos.",  family: Family.quints, concealed: false, points: 45)
        for i in 1...8 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([35,35,35,35, d,d,d,d,d, d+1,d+1,d+1,d+1,d+1])
            p.add([35,35,35,35, b,b,b,b,b, b+1,b+1,b+1,b+1,b+1])
            p.add([35,35,35,35, c,c,c,c,c, c+1,c+1,c+1,c+1,c+1])
        }
    }
    
    func addQ12311_455_3() {
        let p = add("1123 11111 11111", mask: "gggg rrrrr 00000", jokerMask: "", note: "Any Run, Any Pair",  family: Family.quints, concealed: false, points: 40)
        for i in 1...7 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([d,d,d+1,d+2, b,b,b,b,b, c,c,c,c,c])
            p.add([b,b,b+1,b+2, d,d,d,d,d, c,c,c,c,c])
            p.add([c,c,c+1,c+2, d,d,d,d,d, b,b,b,b,b])
            p.add([d,d+1,d+1,d+2, b+1,b+1,b+1,b+1,b+1, c+1,c+1,c+1,c+1,c+1])
            p.add([b,b+1,b+1,b+2, d+1,d+1,d+1,d+1,d+1, c+1,c+1,c+1,c+1,c+1])
            p.add([c,c+1,c+1,c+2, d+1,d+1,d+1,d+1,d+1, b+1,b+1,b+1,b+1,b+1])
            p.add([d,d+1,d+2,d+2, b+2,b+2,b+2,b+2,b+2, c+2,c+2,c+2,c+2,c+2])
            p.add([b,b+1,b+2,b+2, d+2,d+2,d+2,d+2,d+2, c+2,c+2,c+2,c+2,c+2])
            p.add([c,c+1,c+2,c+2, d+2,d+2,d+2,d+2,d+2, b+2,b+2,b+2,b+2,b+2])
        }
    }
    
    func add2022q3() {
        let p = add("1122 33333 33333", mask: "gggg rrrrr 00000", jokerMask: "", note: "Any 3 Suits, Any 3 Consec No.",  family: Family.quints, concealed: false, points: 40)
        for i in 1...7 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([d,d,d+1,d+1, b+2,b+2,b+2,b+2,b+2, c+2,c+2,c+2,c+2,c+2])
            p.add([b,b,b+1,b+1, d+2,d+2,d+2,d+2,d+2, c+2,c+2,c+2,c+2,c+2])
            p.add([c,c,c+1,c+1, d+2,d+2,d+2,d+2,d+2, b+2,b+2,b+2,b+2,b+2])
        }
    }
    
    func addQ1234_5225_1() {
        let p = add("11111 22 33 44444", mask: "00000 00 00 00000", jokerMask: "", note: "Any 4 Consec. Nos.",  family: Family.quints, concealed: false, points: 45)
        for i in 1...6 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([d,d,d,d,d, d+1,d+1, d+2,d+2, d+3,d+3,d+3,d+3,d+3])
            p.add([b,b,b,b,b, b+1,b+1, b+2,b+2, b+3,b+3,b+3,b+3,b+3])
            p.add([c,c,c,c,c, c+1,c+1, c+2,c+2, c+3,c+3,c+3,c+3,c+3])
        }
    }
    
    func add2021q3() {
        let p = add("11111 2222 33333", mask: "00000 0000 00000", jokerMask: "", note: "Any 3 Consec, Nos.",  family: Family.quints, concealed: false)
        for i in 1...7 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([d,d,d,d,d, d+1,d+1,d+1,d+1, d+2,d+2,d+2,d+2,d+2])
            p.add([b,b,b,b,b, b+1,b+1,b+1,b+1, b+2,b+2,b+2,b+2,b+2])
            p.add([c,c,c,c,c, c+1,c+1,c+1,c+1, c+2,c+2,c+2,c+2,c+2])
        }
    }
    
    func add2021q4() {
        let p = add("11111 2222 33333", mask: "ggggg rrrr 00000", jokerMask: "", note: "Any 3 Consec, Nos.",  family: Family.quints, concealed: false)
        for i in 1...7 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([d,d,d,d,d, b+1,b+1,b+1,b+1, c+2,c+2,c+2,c+2,c+2])
            p.add([d,d,d,d,d, c+1,c+1,c+1,c+1, b+2,b+2,b+2,b+2,b+2])
            p.add([b,b,b,b,b, d+1,d+1,d+1,d+1, c+2,c+2,c+2,c+2,c+2])
            p.add([b,b,b,b,b, c+1,c+1,c+1,c+1, d+2,d+2,d+2,d+2,d+2])
            p.add([c,c,c,c,c, d+1,d+1,d+1,d+1, b+2,b+2,b+2,b+2,b+2])
            p.add([c,c,c,c,c, b+1,b+1,b+1,b+1, d+2,d+2,d+2,d+2,d+2])
        }
    }
    
    
    // -----------------------------------------------------------------------------------------
    //
    //  Standard Runs
    //
    // -----------------------------------------------------------------------------------------
    
    func add12345_23432_1() {
        let p = add("11 222 3333 444 55", mask: "00 000 0000 000 00", jokerMask: "", note: "Any 1 Suit",  family: Family.run, concealed: false, points: 25)
        p.add([1,1, 2,2,2, 3,3,3,3, 4,4,4, 5,5])
        p.add([11,11, 12,12,12, 13,13,13,13, 14,14,14, 15,15])
        p.add([21,21, 22,22,22, 23,23,23,23, 24,24,24, 25,25])
    }
    
    func add56789_23432_1() {
        let p = add("55 666 7777 888 99", mask: "00 000 0000 000 00", jokerMask: "", note: "Any 1 Suit",  family: Family.run, concealed: false, points: 25 )
        p.add([5,5, 6,6,6, 7,7,7,7, 8,8,8, 9,9])
        p.add([15,15, 16,16,16, 17,17,17,17, 18,18,18, 19,19])
        p.add([25,25, 26,26,26, 27,27,27,27, 28,28,28, 29,29])
    }
    
    func add1234_3434_2() {
        let p = add("111 2222 333 4444", mask: "ggg gggg rrr rrrr", jokerMask: "", note: "Any Run, Any 2 Suits",  family: Family.run, concealed: false, points: 25)
        for i in 1...6 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([d,d,d, d+1,d+1,d+1,d+1, b+2,b+2,b+2, b+3,b+3,b+3,b+3])
            p.add([d,d,d, d+1,d+1,d+1,d+1, c+2,c+2,c+2, c+3,c+3,c+3,c+3])
            p.add([b,b,b, b+1,b+1,b+1,b+1, d+2,d+2,d+2, d+3,d+3,d+3,d+3])
            p.add([b,b,b, b+1,b+1,b+1,b+1, c+2,c+2,c+2, c+3,c+3,c+3,c+3])
            p.add([c,c,c, c+1,c+1,c+1,c+1, d+2,d+2,d+2, d+3,d+3,d+3,d+3])
            p.add([c,c,c, c+1,c+1,c+1,c+1, b+2,b+2,b+2, b+3,b+3,b+3,b+3])
        }
    }
    
    func addF123_2444_1() {
        let p = add("FF 1111 2222 3333", mask: "00 0000 0000 0000", jokerMask: "", note: "Any 1 Suit, Any Run",  family: Family.run, concealed: false, points: 25)
        for i in 1...7 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([35,35, d,d,d,d, d+1,d+1,d+1,d+1, d+2,d+2,d+2,d+2])
            p.add([35,35, b,b,b,b, b+1,b+1,b+1,b+1, b+2,b+2,b+2,b+2])
            p.add([35,35, c,c,c,c, c+1,c+1,c+1,c+1, c+2,c+2,c+2,c+2])
        }
    }
    
    func addF123_5234_1() {
        let p = add("FFFFF 11 222 3333", mask: "00000 00 000 0000", jokerMask: "", note: "Any 1 Suit, Any Run",  family: Family.run, concealed: false, points: 25)
        for i in 1...7 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([35,35,35,35,35, d,d, d+1,d+1,d+1, d+2,d+2,d+2,d+2])
            p.add([35,35,35,35,35, b,b, b+1,b+1,b+1, b+2,b+2,b+2,b+2])
            p.add([35,35,35,35,35, c,c, c+1,c+1,c+1, c+2,c+2,c+2,c+2])
        }
    }
    
    func addF123D_42233_1() {
        let p = add("FFFF 11 22 333 DDD", mask: "0000 00 00 000 000", jokerMask: "", note: "Any Run, Matching Dragons",  family: Family.run, concealed: false, points: 25)
        for i in 1...7 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([35,35,35,35, d,d, d+1,d+1, d+2,d+2,d+2, 10,10,10])
            p.add([35,35,35,35, b,b, b+1,b+1, b+2,b+2,b+2, 20,20,20])
            p.add([35,35,35,35, c,c, c+1,c+1, c+2,c+2,c+2, 30,30,30])
        }
    }
    
    func addF123_2444_3() {
        let p = add("FF 1111 2222 3333", mask: "00 gggg rrrr 0000", jokerMask: "", note: "Any 3 Suits, Any Run",  family: Family.run, concealed: false, points: 25)
        for i in 1...7 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([35,35, d,d,d,d, b+1,b+1,b+1,b+1, c+2,c+2,c+2,c+2])
            p.add([35,35, d,d,d,d, c+1,c+1,c+1,c+1, b+2,b+2,b+2,b+2])
            p.add([35,35, b,b,b,b, d+1,d+1,d+1,d+1, c+2,c+2,c+2,c+2])
            p.add([35,35, b,b,b,b, c+1,c+1,c+1,c+1, d+2,d+2,d+2,d+2])
            p.add([35,35, c,c,c,c, d+1,d+1,d+1,d+1, b+2,b+2,b+2,b+2])
            p.add([35,35, c,c,c,c, b+1,b+1,b+1,b+1, d+2,d+2,d+2,d+2])
        }
    }
    
    func add12344_22244_3() {
        let p = add("11 22 33 4444 4444", mask: "gg gg gg rrrr 0000", jokerMask: "", note: "Any 3 Suits, Any Run",  family: Family.run, concealed: false, points: 30)
        for i in 1...6 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([d,d, d+1,d+1, d+2,d+2, b+3,b+3,b+3,b+3, c+3,c+3,c+3,c+3])
            p.add([b,b, b+1,b+1, b+2,b+2, d+3,d+3,d+3,d+3, c+3,c+3,c+3,c+3])
            p.add([c,c, c+1,c+1, c+2,c+2, d+3,d+3,d+3,d+3, b+3,b+3,b+3,b+3])
        }
    }
    
    func addF12D_3443_1() {
        let p = add("FFF 1111 2222 DDD", mask: "000 0000 0000 000", jokerMask: "", note: "Any 1 Suit",  family: Family.run, concealed: false, points: 25)
        for i in 1...8 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([35,35,35, d,d,d,d, d+1,d+1,d+1,d+1, 10,10,10])
            p.add([35,35,35, b,b,b,b, b+1,b+1,b+1,b+1, 20,20,20])
            p.add([35,35,35, c,c,c,c, c+1,c+1,c+1,c+1, 30,30,30])
        }
    }
    
    func addF1F2_3434_2() {
        let p = add("FFF 1111 FFF 2222", mask: "000 gggg 000 rrrr", jokerMask: "", note: "Any 2 Suits, Any Run",  family: Family.run, concealed: false, points: 25)
        for i in 1...8 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([35,35,35, d,d,d,d, 35,35,35, b+1,b+1,b+1,b+1])
            p.add([35,35,35, d,d,d,d, 35,35,35, c+1,c+1,c+1,c+1])
            p.add([35,35,35, b,b,b,b, 35,35,35, d+1,d+1,d+1,d+1])
            p.add([35,35,35, b,b,b,b, 35,35,35, c+1,c+1,c+1,c+1])
            p.add([35,35,35, c,c,c,c, 35,35,35, d+1,d+1,d+1,d+1])
            p.add([35,35,35, c,c,c,c, 35,35,35, b+1,b+1,b+1,b+1])
        }
    }
    
    func add1234D_12344_1() {
        let p = add("1 22 333 4444 DDDD", mask: "0 00 000 0000 0000", jokerMask: "", note: "Any 1 Suit, Any Run, Matching Dragons",  family: Family.run, concealed: false, points: 25)
        for i in 1...6 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([d, d+1,d+1, d+2,d+2,d+2, d+3,d+3,d+3,d+3, 10,10,10,10])
            p.add([b, b+1,b+1, b+2,b+2,b+2, b+3,b+3,b+3,b+3, 20,20,20,20])
            p.add([c, c+1,c+1, c+2,c+2,c+2, c+3,c+3,c+3,c+3, 30,30,30,30])
        }
    }
    
    
    func addF12D_2444_1() {
        let p = add("FF 1111 2222 DDDD", mask: "00 0000 0000 0000", jokerMask: "", note: "Any Run",  family: Family.run, concealed: false, points: 25)
        for i in 1...8 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([35,35, d,d,d,d, d+1,d+1,d+1,d+1, 10,10,10,10])
            p.add([35,35, b,b,b,b, b+1,b+1,b+1,b+1, 20,20,20,20])
            p.add([35,35, c,c,c,c, c+1,c+1,c+1,c+1, 30,30,30,30])
        }
    }
    
    func addF12D_4442_1() {
        let p = add("FFFF 1111 2222 DD", mask: "0000 0000 0000 00", jokerMask: "", note: "Any Run",  family: Family.run, concealed: false, points: 25)
        for i in 1...8 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([35,35,35,35, d,d,d,d, d+1,d+1,d+1,d+1, 10,10])
            p.add([35,35,35,35, b,b,b,b, b+1,b+1,b+1,b+1, 20,20])
            p.add([35,35,35,35, c,c,c,c, c+1,c+1,c+1,c+1, 30,30])
        }
    }
    
    func addF1212_42323_2() {
        let p = add("FFFF 11 222 11 222", mask: "0000 gg ggg rr rrr", jokerMask: "", note: "Any 2 Suits, Any 2 Like Consec Nos",  family: Family.run, concealed: false, points: 30)
        for i in 1...8 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([35,35,35,35, d,d, d+1,d+1,d+1, b,b, b+1,b+1,b+1])
            p.add([35,35,35,35, d,d, d+1,d+1,d+1, c,c, c+1,c+1,c+1])
            p.add([35,35,35,35, b,b, b+1,b+1,b+1, c,c, c+1,c+1,c+1])
        }
    }
    
    func add12322_32333_C() {
        let p = add("111 22 333 222 222 (C)", mask: "ggg gg ggg rrr 000", jokerMask: "", note: "Any 3 Consec Nos, Pungs Match Pair",  family: Family.run, concealed: true, points: 30)
        for i in 1...7 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([d,d,d, d+1,d+1, d+2,d+2,d+2, b+1,b+1,b+1, c+1,c+1,c+1])
            p.add([b,b,b, b+1,b+1, b+2,b+2,b+2, d+1,d+1,d+1, c+1,c+1,c+1])
            p.add([c,c,c, c+1,c+1, c+2,c+2,c+2, d+1,d+1,d+1, b+1,b+1,b+1])
        }
    }
    
    func add1234_3344_1() {
        let p = add("111 222 3333 4444", mask: "000 000 0000 0000", jokerMask: "", note: "Any 1 Suit, Any Run",  family: Family.run, concealed: false, points: 25)
        for i in 1...6 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([d,d,d, d+1,d+1,d+1, d+2,d+2,d+2,d+2, d+3,d+3,d+3,d+3])
            p.add([b,b,b, b+1,b+1,b+1, b+2,b+2,b+2,b+2, b+3,b+3,b+3,b+3])
            p.add([c,c,c, c+1,c+1,c+1, c+2,c+2,c+2,c+2, c+3,c+3,c+3,c+3])
        }
    }
 
    func add1234_3344_2() {
        let p = add("111 222 3333 4444", mask: "ggg ggg rrrr rrrr", jokerMask: "", note: "Any 2 Suits, Any Run",  family: Family.run, concealed: false, points: 25)
        for i in 1...6 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([d,d,d, d+1,d+1,d+1, b+2,b+2,b+2,b+2, b+3,b+3,b+3,b+3])
            p.add([d,d,d, d+1,d+1,d+1, c+2,c+2,c+2,c+2, c+3,c+3,c+3,c+3])
            p.add([b,b,b, b+1,b+1,b+1, d+2,d+2,d+2,d+2, d+3,d+3,d+3,d+3])
            p.add([b,b,b, b+1,b+1,b+1, c+2,c+2,c+2,c+2, c+3,c+3,c+3,c+3])
            p.add([c,c,c, c+1,c+1,c+1, d+2,d+2,d+2,d+2, d+3,d+3,d+3,d+3])
            p.add([c,c,c, c+1,c+1,c+1, b+2,b+2,b+2,b+2, b+3,b+3,b+3,b+3])
        }
    }
    
    func add12345_22244_3() {
        let p = add("11 22 33 4444 5555", mask: "gg gg gg rrrr 0000", jokerMask: "", note: "Any 5 Consec Nos",  family: Family.run, concealed: false, points: 30)
        for i in 1...5 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([d,d, d+1,d+1, d+2,d+2, b+3,b+3,b+3,b+3, c+4,c+4,c+4,c+4])
            p.add([d,d, d+1,d+1, d+2,d+2, c+3,c+3,c+3,c+3, b+4,b+4,b+4,b+4])
            p.add([b,b, b+1,b+1, b+2,b+2, d+3,d+3,d+3,d+3, c+4,c+4,c+4,c+4])
            p.add([b,b, b+1,b+1, b+2,b+2, c+3,c+3,c+3,c+3, d+4,d+4,d+4,d+4])
            p.add([c,c, c+1,c+1, c+2,c+2, d+3,d+3,d+3,d+3, b+4,b+4,b+4,b+4])
            p.add([c,c, c+1,c+1, c+2,c+2, b+3,b+3,b+3,b+3, d+4,d+4,d+4,d+4])
        }
    }
    
    func add123D_4343_2() {
        let p = add("1111 222 3333 DDD", mask: "gggg rrr gggg rrr", jokerMask: "", note: "Any 2 Suits, Any Run",  family: Family.run, concealed: false, points: 25)
        for i in 1...7 {
            let d = i
            let b = i+10
            let c = i+20
            let s = 10
            let g = 20
            let r = 30
            p.add([d,d,d,d, b+1,b+1,b+1, d+2,d+2,d+2,d+2, g,g,g])
            p.add([d,d,d,d, c+1,c+1,c+1, d+2,d+2,d+2,d+2, r,r,r])
            p.add([b,b,b,b, d+1,d+1,d+1, b+2,b+2,b+2,b+2, s,s,s])
            p.add([b,b,b,b, c+1,c+1,c+1, b+2,b+2,b+2,b+2, r,r,r])
            p.add([c,c,c,c, d+1,d+1,d+1, c+2,c+2,c+2,c+2, s,s,s])
            p.add([c,c,c,c, b+1,b+1,b+1, c+2,c+2,c+2,c+2, g,g,g])
        }
    }
    
    func addF1212_23333_C() {
        let p9 = add("FF 111 222 111 222 (C)", mask: "00 ggg ggg rrr rrr", jokerMask: "", note: "Any 2 Suits, Any Run",  family: Family.run, concealed: true, points: 30)
        for i in 1...8 {
            let d = i
            let b = i+10
            let c = i+20
            p9.add([35,35, d,d,d, d+1,d+1,d+1, b,b,b, b+1,b+1,b+1])
            p9.add([35,35, d,d,d, d+1,d+1,d+1, c,c,c, c+1,c+1,c+1])
            p9.add([35,35, b,b,b, b+1,b+1,b+1, c,c,c, c+1,c+1,c+1])
        }
    }
    
    func add12123_22334_3() {
        let p = add("11 22 111 222 3333", mask: "gg gg rrr rrr 0000", jokerMask: "", note: "Any 3 Consec Nos",  family: Family.run, concealed: false, points: 25)
        for i in 1...7 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([d,d, d+1,d+1, b,b,b, b+1,b+1,b+1, c+2,c+2,c+2,c+2])
            p.add([d,d, d+1,d+1, c,c,c, c+1,c+1,c+1, b+2,b+2,b+2,b+2])
            p.add([b,b, b+1,b+1, d,d,d, d+1,d+1,d+1, c+2,c+2,c+2,c+2])
            p.add([b,b, b+1,b+1, c,c,c, c+1,c+1,c+1, d+2,d+2,d+2,d+2])
            p.add([c,c, c+1,c+1, d,d,d, d+1,d+1,d+1, b+2,b+2,b+2,b+2])
            p.add([c,c, c+1,c+1, b,b,b, b+1,b+1,b+1, d+2,d+2,d+2,d+2])
        }
    }
    
    func add12123_23234_3() {
        let p = add("11 222 11 222 3333", mask: "gg ggg rr rrr 0000", jokerMask: "", note: "Any 3 Suits, Any 3 Consec Nos",  family: Family.run, concealed: false, points: 25)
        for i in 1...7 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([d,d, d+1,d+1,d+1, b,b, b+1,b+1,b+1, c+2,c+2,c+2,c+2])
            p.add([d,d, d+1,d+1,d+1, c,c, c+1,c+1,c+1, b+2,b+2,b+2,b+2])
            p.add([b,b, b+1,b+1,b+1, c,c, c+1,c+1,c+1, d+2,d+2,d+2,d+2])
        }
    }
    
    func add122123_323323_2_C() {
        let p = add("111 2 333 111 2 333 (C)", mask: "ggg g ggg rrr r rrr", jokerMask: "", note: "Any 2 Suits, Any Run",  family: Family.run, concealed: true, points: 25)
        for i in 1...7 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([d,d,d, d+1, d+2,d+2,d+2, b,b,b, b+1, b+2,b+2,b+2])
            p.add([d,d,d, d+1, d+2,d+2,d+2, c,c,c, c+1, c+2,c+2,c+2])
            p.add([b,b,b, b+1, b+2,b+2,b+2, c,c,c, c+1, c+2,c+2,c+2])
        }
    }
    
    func add1212D_23234_3() {
        let p = add("11 222 11 222 DDDD", mask: "gg ggg rr rrr 0000", jokerMask: "", note: "Any 3 Suits, Any Run, Opp Dragons",  family: Family.run, concealed: false, points: 25)
        for i in 1...8 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([d,d, d+1,d+1,d+1, b,b, b+1,b+1,b+1, 30,30,30,30])
            p.add([d,d, d+1,d+1,d+1, c,c, c+1,c+1,c+1, 20,20,20,20])
            p.add([b,b, b+1,b+1,b+1, c,c, c+1,c+1,c+1, 10,10,10,10])
        }
    }
    
    func add12223_42224_3() {
        let p = add("1111 22 22 22 3333", mask: "gggg rr gg 00 gggg", jokerMask: "", note: "Any Run, Pairs in the Middle",  family: Family.run, concealed: false, points: 30)
        for i in 1...7 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([d,d,d,d, d+1,d+1, b+1,b+1, c+1,c+1, d+2,d+2,d+2,d+2])
            p.add([b,b,b,b, d+1,d+1, b+1,b+1, c+1,c+1, b+2,b+2,b+2,b+2])
            p.add([c,c,c,c, d+1,d+1, b+1,b+1, c+1,c+1, c+2,c+2,c+2,c+2])
        }
    }
    
    func add123DD_323333_C() {
        let p = add("111 22 333 DDD DDD (C)", mask: "ggg gg ggg rrr 000", jokerMask: "", note: "Any 3 Consec Nos",  family: Family.run, concealed: true, points: 30)
        for i in 1...7 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([d,d,d, d+1,d+1, d+2,d+2,d+2, 20,20,20, 30,30,30])
            p.add([b,b,b, b+1,b+1, b+2,b+2,b+2, 10,10,10, 30,30,30])
            p.add([c,c,c, c+1,c+1, c+2,c+2,c+2, 10,10,10, 20,20,20])
        }
    }
    
    func addF12DD_23333_C() {
        let p = add("FF 111 222 DDD DDD (C)", mask: "00 ggg ggg rrr 000", jokerMask: "", note: "Any 2 Consec Nos, Opp Dragons",  family: Family.run, concealed: true, points: 30)
        for i in 1...8 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([35,35, d,d,d, d+1,d+1,d+1, 20,20,20, 30,30,30])
            p.add([35,35, b,b,b, b+1,b+1,b+1, 10,10,10, 30,30,30])
            p.add([35,35, c,c,c, c+1,c+1,c+1, 10,10,10, 20,20,20])
        }
    }
    
    
    // -----------------------------------------------------------------------------------------
    //
    //  Standard Odds
    //
    // -----------------------------------------------------------------------------------------
    
    func add13579_23432_1() {
        let p = add("11 333 5555 777 99", mask: "00 000 0000 000 00", jokerMask: "", note: "Any 1 Suit",  family: Family.f13579, concealed: false, points: 25)
        p.add([1,1, 3,3,3, 5,5,5,5, 7,7,7, 9,9])
        p.add([11,11, 13,13,13, 15,15,15,15, 17,17,17, 19,19])
        p.add([21,21, 23,23,23, 25,25,25,25, 27,27,27, 29,29])
    }
    
    func add13579_23432_3() {
        let p = add("11 333 5555 777 99", mask: "gg ggg rrrr 000 00", jokerMask: "", note: "Any 3 Suits",  family: Family.f13579, concealed: false, points: 25)
        p.add([1,1, 3,3,3, 15,15,15,15, 27,27,27, 29,29])
        p.add([1,1, 3,3,3, 25,25,25,25, 17,17,17, 19,19])
        p.add([11,11, 13,13,13, 5,5,5,5, 27,27,27, 29,29])
        p.add([11,11, 13,13,13, 25,25,25,25, 7,7,7, 9,9])
        p.add([21,21, 23,23,23, 5,5,5,5, 17,17,17, 19,19])
        p.add([21,21, 23,23,23, 15,15,15,15, 7,7,7, 9,9])
    }

    func add13579_22244_3() {
        let p = add("11 33 55 7777 9999", mask: "gg gg gg rrrr 0000", jokerMask: "", note: "Any 3 Suits",  family: Family.f13579, concealed: false, points: 30)
        p.generateList()
    }
    
    func add13579_42224_2() {
        let p = add("1111 33 55 77 9999", mask: "gggg rr rr rr gggg", jokerMask: "", note: "Any 2 Suits",  family: Family.f13579, concealed: false, points: 30)
        p.generateList()
    }
        
    func add1335_3434_2() {
        let p = add("111 3333 333 5555", mask: "ggg gggg rrr rrrr", jokerMask: "", note: "Any 2 Suits",  family: Family.f13579, concealed: false, points: 25)
        p.add([1,1,1, 3,3,3,3, 13,13,13, 15,15,15,15])
        p.add([1,1,1, 3,3,3,3, 23,23,23, 25,25,25,25])
        p.add([11,11,11, 13,13,13,13, 3,3,3, 5,5,5,5])
        p.add([11,11,11, 13,13,13,13, 23,23,23, 25,25,25,25])
        p.add([21,21,21, 23,23,23,23, 3,3,3, 5,5,5,5])
        p.add([21,21,21, 23,23,23,23, 13,13,13, 15,15,15,15])
    }
    
    func add5779_3434_2() {
        let p = add("555 7777 777 9999", mask: "ggg gggg rrr rrrr", jokerMask: "", note: "Any 2 Suits",  family: Family.f13579, concealed: false, points: 25)
        p.add([5,5,5, 7,7,7,7, 17,17,17, 19,19,19,19])
        p.add([5,5,5, 7,7,7,7, 27,27,27, 29,29,29,29])
        p.add([15,15,15, 17,17,17,17, 7,7,7, 9,9,9,9])
        p.add([15,15,15, 17,17,17,17, 27,27,27, 29,29,29,29])
        p.add([25,25,25, 27,27,27,27, 7,7,7, 9,9,9,9])
        p.add([25,25,25, 27,27,27,27, 17,17,17, 19,19,19,19])
    }
    
    func addF135D_22334_1() {
        let p = add("FF 11 333 555 DDDD", mask: "00 00 000 000 0000", jokerMask: "", note: "Any 1 Suit",  family: Family.f13579, concealed: false, points: 25)
        p.generateList()
    }
    
    func addF135D_22343_1() {
        let p = add("FF 11 333 5555 DDD", mask: "00 00 000 0000 000", jokerMask: "", note: "Any 1 Suit",  family: Family.f13579, concealed: false, points: 25)
        p.generateList()
    }
    
    func addF579D_22334_1() {
        let p = add("FF 55 777 999 DDDD", mask: "00 00 000 000 0000", jokerMask: "", note: "Any 1 Suit",  family: Family.f13579, concealed: false, points: 25)
        p.generateList()
    }
    
    func addF579D_22343_1() {
        let p = add("FF 55 777 9999 DDD", mask: "00 00 000 0000 000", jokerMask: "", note: "Any 1 Suit",  family: Family.f13579, concealed: false, points: 25)
        p.generateList()
    }
    
    func addF135_4424_1(){
        let p = add("FFFF 1111 33 5555", mask: "0000 0000 00 0000", jokerMask: "", note: "Any 1 Suit",  family: Family.f13579, concealed: false, points: 25)
        p.generateList()
    }
    
    func addF135_2444_1() {
        let p = add("FF 1111 3333 5555", mask: "00 0000 0000 0000", jokerMask: "", note: "Any 1 Suit",  family: Family.f13579, concealed: false, points: 25)
        p.generateList()
    }
            
    func addF579_4424_1(){
        let p = add("FFFF 5555 77 9999", mask: "0000 0000 00 0000", jokerMask: "", note: "Any 1 Suit",  family: Family.f13579, concealed: false, points: 25)
        p.generateList()
    }
     
    func addF579_2444_1() {
        let p = add("FF 5555 7777 9999", mask: "00 0000 0000 0000", jokerMask: "", note: "Any 1 Suit",  family: Family.f13579, concealed: false, points: 25)
        p.generateList()
    }
    
    func add1335D_22334_3() {
        let p = add("11 33 333 555 DDDD", mask: "gg gg rrr rrr 0000", jokerMask: "", note: "Any 3 Suits",  family: Family.f13579, concealed: false, points: 25)
        p.generateList()
    }
    
    func add13D35_23432_3() {
        let p = add("11 333 DDDD 333 55", mask: "gg ggg rrrr 000 00", jokerMask: "", note: "Any 3 Suits",  family: Family.f13579, concealed: false, points: 25)
        p.generateList()
    }
    
    func add57D79_23432_3() {
        let p = add("55 777 DDDD 777 99", mask: "gg ggg rrrr 000 00", jokerMask: "", note: "Any 3 Suits",  family: Family.f13579, concealed: false, points: 25)
        p.generateList()
    }
    
    func add135D_4343_2() {
        let p = add("1111 333 5555 DDD", mask: "gggg rrr gggg rrr", jokerMask: "", note: "Any 2 Suits",  family: Family.f13579, concealed: false, points: 25)
        p.generateList()
    }
    
    func add5779D_22334_3() {
        let p = add("55 77 777 999 DDDD", mask: "gg gg rrr rrr 0000", jokerMask: "", note: "Any 3 Suits",  family: Family.f13579, concealed: false, points: 25)
        p.generateList()
    }

    func add579D_4343_2() {
        let p = add("5555 777 9999 DDD", mask: "gggg rrr gggg rrr", jokerMask: "", note: "Any 2 Suits",  family: Family.f13579, concealed: false, points: 25)
        p.generateList()
    }
        
    func add13511_22244_3() {
        let p = add("11 33 55 1111 1111", mask: "gg gg gg rrrr 0000", jokerMask: "", note: "Kongs Like 1,3,5s",  family: Family.f13579, concealed: false, points: 25)
        p.add([1,1, 3,3, 5,5, 11,11,11,11, 21,21,21,21])
        p.add([11,11, 13,13, 15,15, 1,1,1,1, 21,21,21,21])
        p.add([21,21, 23,23, 25,25, 1,1,1,1, 11,11,11,11])
        p.add([1,1, 3,3, 5,5, 13,13,13,13, 23,23,23,23])
        p.add([11,11, 13,13, 15,15, 3,3,3,3, 23,23,23,23])
        p.add([21,21, 23,23, 25,25, 3,3,3,3, 13,13,13,13])
        p.add([1,1, 3,3, 5,5, 15,15,15,15, 25,25,25,25])
        p.add([11,11, 13,13, 15,15, 5,5,5,5, 25,25,25,25])
        p.add([21,21, 23,23, 25,25, 5,5,5,5, 15,15,15,15])
    }
    
    func add57955_22244_3() {
        let p = add("55 77 99 5555 5555", mask: "gg gg gg rrrr 0000", jokerMask: "", note: "Kongs Like 5,7,9s",  family: Family.f13579, concealed: false, points: 25)
        p.add([5,5, 7,7, 9,9, 15,15,15,15, 25,25,25,25])
        p.add([15,15, 17,17, 19,19, 5,5,5,5, 25,25,25,25])
        p.add([25,25, 27,27, 29,29, 5,5,5,5, 15,15,15,15])
        p.add([5,5, 7,7, 9,9, 17,17,17,17, 27,27,27,27])
        p.add([15,15, 17,17, 19,19, 7,7,7,7, 27,27,27,27])
        p.add([25,25, 27,27, 29,29, 7,7,7,7, 17,17,17,17])
        p.add([5,5, 7,7, 9,9, 19,19,19,19, 29,29,29,29])
        p.add([15,15, 17,17, 19,19, 9,9,9,9, 29,29,29,29])
        p.add([25,25, 27,27, 29,29, 9,9,9,9, 19,19,19,19])
    }
    
    func add13135_22334_3() {
        let p = add("11 33 111 333 5555", mask: "gg gg rrr rrr 0000", jokerMask: "", note: "Any 3 Suits",  family: Family.f13579, concealed: false, points: 25)
        p.generateList()
    }
    
    func add13135_23234_3() {
        let p = add("11 333 11 333 5555", mask: "gg ggg rr rrr 0000", jokerMask: "", note: "Any 3 Suits",  family: Family.f13579, concealed: false, points: 25)
        p.add([1,1, 3,3,3, 11,11, 13,13,13, 25,25,25,25])
        p.add([1,1, 3,3,3, 21,21, 23,23,23, 15,15,15,15])
        p.add([11,11, 13,13,13, 21,21, 23,23,23, 5,5,5,5])
    }
    
    func add13135_33332_C() {
        let p = add("111 333 111 333 55 (C)", mask: "ggg ggg rrr rrr 00", jokerMask: "", note: "Any 3 Suits",  family: Family.f13579, concealed: true, points: 30)
        p.add([1,1,1, 3,3,3, 11,11,11, 13,13,13, 25,25])
        p.add([1,1,1, 3,3,3, 21,21,21, 23,23,23, 15,15])
        p.add([11,11,11, 13,13,13, 21,21,21, 23,23,23, 5,5])
    }
    
    func add57579_33332_C() {
        let p = add("555 777 555 777 99 (C)", mask: "ggg ggg rrr rrr 00", jokerMask: "", note: "Any 3 Suits",  family: Family.f13579, concealed: true, points: 30)
        p.add([5,5,5, 7,7,7, 15,15,15, 17,17,17, 29,29])
        p.add([5,5,5, 7,7,7, 25,25,25, 27,27,27, 19,19])
        p.add([15,15,15, 17,17,17, 25,25,25, 27,27,27, 9,9])
    }
    
    func add57579_22334_3() {
        let p = add("55 77 555 777 9999", mask: "gg gg rrr rrr 0000", jokerMask: "", note: "Any 3 Suits",  family: Family.f13579, concealed: false, points: 25)
        p.generateList()
    }
        
    func add57579_23234_3() {
        let p = add("55 777 55 777 9999", mask: "gg ggg rr rrr 0000", jokerMask: "", note: "Any 3 Suits",  family: Family.f13579, concealed: false, points: 25)
        p.add([5,5, 7,7,7, 15,15, 17,17,17, 29,29,29,29])
        p.add([5,5, 7,7,7, 25,25, 27,27,27, 19,19,19,19])
        p.add([15,15, 17,17,17, 25,25, 27,27,27, 9,9,9,9])
    }
    
    func addF1F5_3434_1() {
        let p = add("FFF 1111 FFF 5555", mask: "000 0000 000 0000", jokerMask: "", note: "Any 1 Suit",  family: Family.f13579, concealed: false, points: 30)
        p.generateList()
    }
    
    func addF5F9_3434_1() {
        let p = add("FFF 5555 FFF 9999", mask: "000 0000 000 0000", jokerMask: "", note: "Any 1 Suit",  family: Family.f13579, concealed: false, points: 30)
        p.generateList()
    }
    
    func add135579_313313_C() {
        let p = add("111 3 555 555 7 999 (C)", mask: "ggg g ggg rrr r rrr", jokerMask: "", note: "Any 2 Suits, These Nos Only",  family: Family.f13579, concealed: true, points: 30)
        p.generateList()
    }

    func addF135D_2333_C() {
        let p = add("FF 111 333 555 DDD (C)", mask: "00 000 000 000 000", jokerMask: "", note: "Any 1 Suit",  family: Family.f13579, concealed: true, points: 30)
        p.generateList()
    }
    
    func addF579D_2333_C() {
        let p = add("FF 555 777 999 DDD (C)", mask: "00 000 000 000 000", jokerMask: "", note: "Any 1 Suit",  family: Family.f13579, concealed: true, points: 30)
        p.generateList()
    }

    
    // -----------------------------------------------------------------------------------------
    //
    //  Standard Winds
    //
    // -----------------------------------------------------------------------------------------
    
    func addNEWS_4442() {
        let p = add("NNNN EEEE WWWW SS", mask: "0000 0000 0000 00", jokerMask: "", note: "",  family: Family.winds, concealed: false, points: 25)
        p.add([31,31,31,31, 34,34,34,34, 33,33,33,33, 32,32,])
    }
    
    func addNEWS_4334() {
        let p = add("NNNN EEE WWW SSSS", mask: "0000 000 000 0000", jokerMask: "", note: "",  family: Family.winds, concealed: false, points: 25)
        p.add([31,31,31,31, 34,34,34, 33,33,33, 32,32,32,32])
    }
    
    func addNDDDS_42224_3() {
        let p = add("NNNN DD DD DD SSSS", mask: "0000 gg rr 00 0000", jokerMask: "", note: "",  family: Family.winds, concealed: false, points: 30)
        p.add([31,31,31,31, 10,10, 20,20, 30,30, 32,32,32,32])
    }
    
    func addEDDDW_42224_3() {
        let p = add("EEEE DD DD DD WWWW", mask: "0000 gg rr 00 0000", jokerMask: "", note: "",  family: Family.winds, concealed: false, points: 30)
        p.add([33,33,33,33, 10,10, 20,20, 30,30, 34,34,34,34])
    }

    func addFN11S_22442_2() {
        let p = add("FF NN 1111 1111 SS", mask: "00 00 gggg rrrr 00", jokerMask: "", note: "Any Like Odd Nos",  family: Family.winds, concealed: false, points: 30)
        for i in 1...9 {
            if i & 1 == 1 {
                let d = i
                let b = i+10
                let c = i+20
                p.add([35,35, 31,31, d,d,d,d, b,b,b,b, 32,32])
                p.add([35,35, 31,31, d,d,d,d, c,c,c,c, 32,32])
                p.add([35,35, 31,31, b,b,b,b, c,c,c,c, 32,32])
            }
        }
    }
    
    func add1N1S1_23234_3() {
        let p = add("11 NNN 11 SSS 1111", mask: "gg 000 rr 000 0000", jokerMask: "", note: "Any Like Odd Nos",  family: Family.winds, concealed: false, points: 30)
        for i in 1...9 {
            if i & 1 == 1 {
                let d = i
                let b = i+10
                let c = i+20
                p.add([d,d, 31,31,31, b,b, 32,32,32, c,c,c,c])
                p.add([d,d, 31,31,31, c,c, 32,32,32, b,b,b,b])
                p.add([b,b, 31,31,31, c,c, 32,32,32, d,d,d,d])
            }
        }
    }

    func addFE22W_22442_2() {
        let p = add("FF EE 2222 2222 WW", mask: "00 00 gggg rrrr 00", jokerMask: "", note: "Any Like Even Nos",  family: Family.winds, concealed: false, points: 30)
        for i in 1...9 {
            if i & 1 == 0 {
                let d = i
                let b = i+10
                let c = i+20
                p.add([35,35, 34,34, d,d,d,d, b,b,b,b, 33,33])
                p.add([35,35, 34,34, d,d,d,d, c,c,c,c, 33,33])
                p.add([35,35, 34,34, b,b,b,b, c,c,c,c, 33,33])
            }
        }
    }

    func add2E2W2_23234_3() {
        let p = add("22 EEE 22 WWW 2222", mask: "gg 000 rr 000 0000", jokerMask: "", note: "Any Like Even Nos",  family: Family.winds, concealed: false, points: 30)
        for i in 1...9 {
            if i & 1 == 0 {
                let d = i
                let b = i+10
                let c = i+20
                p.add([d,d, 34,34,34, b,b, 33,33,33, c,c,c,c])
                p.add([d,d, 34,34,34, c,c, 33,33,33, b,b,b,b])
                p.add([b,b, 34,34,34, c,c, 33,33,33, d,d,d,d])
            }
        }
    }
    
    func addFDDD_3434_3() {
        let p = add("FFF DDDD DDD DDDD", mask: "000 gggg rrr 0000", jokerMask: "", note: "Any 3 Suits",  family: Family.winds, concealed: false, points: 30)
        p.add([35,35,35, 10,10,10,10, 20,20,20, 30,30,30,30])
        p.add([35,35,35, 10,10,10,10, 30,30,30, 20,20,20,20])
        p.add([35,35,35, 20,20,20,20, 10,10,10, 30,30,30,30])
    }
    
    func addFNEWS_2333_C() {
        let p = add("FF NNN EEE WWW SSS (C)", mask: "00 000 000 000", jokerMask: "", note: "",  family: Family.winds, concealed: true, points: 30)
        p.add([35,35, 31,31,31, 34,34,34, 33,33,33, 32,32,32])
    }
    
    func addNEWSDD_311333_C() {
        let p = add("NNN E W SSS DDD DDD (C)", mask: "000 0 0 000 ggg rrr", jokerMask: "", note: "Any 2 Dragons",  family: Family.winds, concealed: true, points: 30)
        p.add([31,31,31, 34,33, 32,32,32, 10,10,10, 20,20,20])
        p.add([31,31,31, 34,33, 32,32,32, 10,10,10, 30,30,30])
        p.add([31,31,31, 34,33, 32,32,32, 20,20,20, 30,30,30])
    }
    
    func addFNEWS_43223() {
        let p = add("FFFF NNN EE WW SSS", mask: "0000 000 00 00 000", jokerMask: "", note: "",  family: Family.winds, concealed: false, points: 30)
        p.add([35,35,35,35, 31,31,31, 34,34, 33,33, 32,32,32])
    }
    
    func addFNRS_2444() {
        let p = add("FF NNNN RRRR SSSS", mask: "00 0000 rrrr 0000", jokerMask: "", note: "Red Dragons Only",  family: Family.winds, concealed: false, points: 30)
        p.add([35,35, 31,31,31,31, 30,30,30,30, 32,32,32,32])
    }
    
    func addFEGW_2444() {
        let p = add("FF EEEE GGGG WWWW", mask: "00 0000 gggg 0000", jokerMask: "", note: "Green Dragons Only",  family: Family.winds, concealed: false, points: 30)
        p.add([35,35, 34,34,34,34, 20,20,20,20, 33,33,33,33])
    }
    
    func addFNGS_4424() {
        let p = add("FFFF NNNN DD SSSS", mask: "0000 0000 rr 0000", jokerMask: "", note: "Red Dragon only",  family: Family.winds, concealed: false, points: 25)
        p.add([35,35,35,35, 31,31,31,31, 30,30, 32,32,32,32])
    }
    
    func addFERW_4424() {
        let p = add("FFFF EEEE DD WWWW", mask: "0000 0000 gg 0000", jokerMask: "", note: "Green Dragon only",  family: Family.winds, concealed: false, points: 25)
        p.add([35,35,35,35, 34,34,34,34, 20,20, 33,33,33,33])
    }
    
    func addNS123_44123_1() {
        let p = add("NNNN SSSS 1 22 333", mask: "0000 0000 0 00 000", jokerMask: "", note: "Any 3 Consec Nos In 1 Suit",  family: Family.winds, concealed: false, points: 30)
        for i in 1...7 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([31,31,31,31, 32,32,32,32, d, d+1,d+1, d+2,d+2,d+2])
            p.add([31,31,31,31, 32,32,32,32, b, b+1,b+1, b+2,b+2,b+2])
            p.add([31,31,31,31, 32,32,32,32, c, c+1,c+1, c+2,c+2,c+2])
        }
    }
    
    func addEW123_44123_1() {
        let p = add("EEEE WWWW 1 22 333", mask: "0000 0000 0 00 000", jokerMask: "", note: "Any 3 Consec Nos In 1 Suit",  family: Family.winds, concealed: false, points: 30)
        for i in 1...7 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([34,34,34,34, 33,33,33,33, d, d+1,d+1, d+2,d+2,d+2])
            p.add([34,34,34,34, 33,33,33,33, b, b+1,b+1, b+2,b+2,b+2])
            p.add([34,34,34,34, 33,33,33,33, c, c+1,c+1, c+2,c+2,c+2])
        }
    }
    
    func add1NEWS1_421124_2() {
        let p = add("1111 NN E W SS 1111", mask: "gggg 00 0 0 00 rrrr", jokerMask: "", note: "Any Like Odd or Even Nos",  family: Family.winds, concealed: false, points: 30)
        for i in 1...9 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([d,d,d,d, 31,31, 34,33, 32,32, b,b,b,b])
            p.add([d,d,d,d, 31,31, 34,33, 32,32, c,c,c,c])
            p.add([b,b,b,b, 31,31, 34,33, 32,32, c,c,c,c])
        }
    }
    
        
    // -----------------------------------------------------------------------------------------
    //
    //  Standard 369
    //
    // -----------------------------------------------------------------------------------------
    
    func add36369_22334_3() {
        let p = add("33 66 333 666 9999", mask: "gg gg rrr rrr 0000", jokerMask: "", note: "Any 3 Suits",  family: Family.f369, concealed: false, points: 25)
        p.generateList()
    }
     
    func add3669_3434_2() {
        let p = add("333 6666 666 9999", mask: "ggg gggg rrr rrrr", jokerMask: "", note: "Any 2 Suits",  family: Family.f369, concealed: false, points: 25)
        p.generateList()
    }
     
    func add369D_3434_2() {
        let p = add("3333 666 9999 DDD", mask: "gggg 000 gggg 000", jokerMask: "", note: "Any 2 Suits, Dragons Match",  family: Family.f369, concealed: false, points: 25)
        p.generateList()
    }
     
    func add369D_4343_1() {
        let p = add("3333 666 9999 DDD", mask: "0000 000 0000 000", jokerMask: "", note: "Any 1 Suit",  family: Family.f369, concealed: false, points: 25)
        p.generateList()
    }
    
    func addF369_2444_1() {
        let p = add("FF 3333 6666 9999", mask: "00 0000 0000 0000", jokerMask: "", note: "Any 1 Suit",  family: Family.f369, concealed: false, points: 25)
        p.generateList()
    }
    
    func addF369_2444_3() {
        let p = add("FF 3333 6666 9999", mask: "00 gggg rrrr 0000", jokerMask: "", note: "Any 3 Suits",  family: Family.f369, concealed: false, points: 25)
        p.generateList()
    }

    func add36F69_23432_2() {
        let p = add("33 666 FFFF 666 99", mask: "gg ggg 0000 rrr rr", jokerMask: "", note: "Any 2 Suits",  family: Family.f369, concealed: false, points: 30)
        p.add([3,3, 6,6,6, 35,35,35,35, 16,16,16, 19,19])
        p.add([3,3, 6,6,6, 35,35,35,35, 26,26,26, 29,29])
        p.add([13,13, 16,16,16, 35,35,35,35, 6,6,6, 9,9])
        p.add([13,13, 16,16,16, 35,35,35,35, 26,26,26, 29,29])
        p.add([23,23, 26,26,26, 35,35,35,35, 6,6,6, 9,9])
        p.add([23,23, 26,26,26, 35,35,35,35, 16,16,16, 19,19])
    }
     
    func addF369D_23333_C() {
        let p = add("FF 333 666 999 DDD (C)", mask: "00 000 000 000 000", jokerMask: "", note: "",  family: Family.f369, concealed: true, points: 30)
        p.generateList()
    }
    
    func addF369D_32324_1() {
        let p = add("FFF 33 666 99 DDDD", mask: "000 00 000 00 0000", jokerMask: "", note: "Any 1 Suit",  family: Family.f369, concealed: false, points: 25)
        p.generateList()
    }
    
    func addF369_5234_1() {
        let p = add("FFFFF 33 666 9999", mask: "00000 00 000 0000", jokerMask: "", note: "Any 1 Suit",  family: Family.f369, concealed: false, points: 25)
        p.generateList()
    }
    
    func addF369_3434_1() {
        let p = add("FFF 3333 666 9999", mask: "000 0000 000 0000", jokerMask: "", note: "Any 1 Suit",  family: Family.f369, concealed: false, points: 25)
        p.generateList()
    }
    
    func addF369_3434_3() {
        let p = add("FFF 3333 666 9999", mask: "000 gggg rrr 0000", jokerMask: "", note: "Any 3 Suits",  family: Family.f369, concealed: false, points: 25)
        p.generateList()
    }
    
    func add3669_3344_2() {
        let p = add("333 666 6666 9999", mask: "ggg ggg rrrr rrrr", jokerMask: "", note: "Any 2 Suits",  family: Family.f369, concealed: false, points: 25)
        p.generateList()
    }

    func add3699_4433_3() {
        let p = add("3333 6666 999 999", mask: "gggg gggg rrr 000", jokerMask: "", note: "Any 3 Suits, Pung 9s only",  family: Family.f369, concealed: false, points: 25)
        p.add([3,3,3,3, 6,6,6,6, 19,19,19, 29,29,29])
        p.add([13,13,13,13, 16,16,16,16, 9,9,9, 29,29,29])
        p.add([23,23,23,23, 26,26,26,26, 9,9,9, 19,19,19])
    }
    
    func add36933_22244_3() {
        let p = add("33 66 99 3333 3333", mask: "gg gg gg rrrr 0000", jokerMask: "", note: "Kongs Like 3,6,9s",  family: Family.f369, concealed: false, points: 30)
        p.add([3,3,6,6,9,9, 13,13,13,13, 23,23,23,23])
        p.add([13,13,16,16,19,19, 3,3,3,3, 23,23,23,23])
        p.add([23,23,26,26,29,29, 3,3,3,3, 13,13,13,13])
        p.add([3,3,6,6,9,9, 16,16,16,16, 26,26,26,26])
        p.add([13,13,16,16,19,19, 6,6,6,6, 26,26,26,26])
        p.add([23,23,26,26,29,29, 6,6,6,6, 16,16,16,16])
        p.add([3,3,6,6,9,9, 19,19,19,19, 29,29,29,29])
        p.add([13,13,16,16,19,19, 9,9,9,9, 29,29,29,29])
        p.add([23,23,26,26,29,29, 9,9,9,9, 19,19,19,19])
    }
    
    func addF3693_23234_2() {
        let p = add("FF 333 66 999 3333", mask: "00 000 00 000 gggg", jokerMask: "", note: "Any 2 Suits, Kong 3,6, or 9",  family: Family.f369, concealed: false, points: 30)
        p.add([35,35, 3,3,3,6,6,9,9,9, 13,13,13,13])
        p.add([35,35, 3,3,3,6,6,9,9,9, 23,23,23,23])
        p.add([35,35, 13,13,13,16,16,19,19,19, 3,3,3,3])
        p.add([35,35, 13,13,13,16,16,19,19,19, 23,23,23,23])
        p.add([35,35, 23,23,23,26,26,29,29,29, 3,3,3,3])
        p.add([35,35, 23,23,23,26,26,29,29,29, 13,13,13,13])
     
        p.add([35,35, 3,3,3,6,6,9,9,9, 16,16,16,16])
        p.add([35,35, 3,3,3,6,6,9,9,9, 26,26,26,26])
        p.add([35,35, 13,13,13,16,16,19,19,19, 6,6,6,6])
        p.add([35,35, 13,13,13,16,16,19,19,19, 26,26,26,26])
        p.add([35,35, 23,23,23,26,26,29,29,29, 6,6,6,6])
        p.add([35,35, 23,23,23,26,26,29,29,29, 16,16,16,16])
        
        p.add([35,35, 3,3,3,6,6,9,9,9, 19,19,19,19])
        p.add([35,35, 3,3,3,6,6,9,9,9, 29,29,29,29])
        p.add([35,35, 13,13,13,16,16,19,19,19, 9,9,9,9])
        p.add([35,35, 13,13,13,16,16,19,19,19, 29,29,29,29])
        p.add([35,35, 23,23,23,26,26,29,29,29, 9,9,9,9])
        p.add([35,35, 23,23,23,26,26,29,29,29, 19,19,19,19])
    }
    
    func add369D_4343_2() {
        let p = add("3333 666 9999 DDD", mask: "gggg rrr gggg rrr", jokerMask: "", note: "Any 2 Suits",  family: Family.f369, concealed: false, points: 25)
        p.generateList()
    }
    
    func add3669D_22334_3() {
        let p = add("33 66 666 999 DDDD", mask: "gg gg rrr rrr 0000", jokerMask: "", note: "Any 3 Suits",  family: Family.f369, concealed: false, points: 25)
        p.generateList()
    }
    
    func add369369_313313_C() {
        let p = add("333 6 999 333 6 999 (C)", mask: "ggg g ggg rrr r rrr", jokerMask: "", note: "Any 2 Suits",  family: Family.f369, concealed: true, points: 30)
        p.add([3,3,3, 6, 9,9,9, 13,13,13, 16, 19,19,19])
        p.add([3,3,3, 6, 9,9,9, 23,23,23, 26, 29,29,29])
        p.add([13,13,13, 16, 19,19,19, 23,23,23, 26, 29,29,29])
    }
    
    func add369D_3244_1() {
        let p = add("3333 66 9999 DDDD", mask: "0000 00 0000 0000", jokerMask: "", note: "Any 1 Suit",  family: Family.f369, concealed: false, points: 25)
        p.generateList()
    }
    
    func addF3699_23333_C() {
        let p = add("FF 333 666 999 999 (C)", mask: "00 ggg ggg rrr 000", jokerMask: "", note: "Any 3 Suits",  family: Family.f369, concealed: true, points: 30)
        p.add([35,35, 3,3,3,    6,6,6,    19,19,19, 29,29,29])
        p.add([35,35, 13,13,13, 16,16,16, 9,9,9,    29,29,29])
        p.add([35,35, 23,23,23, 26,26,26, 9,9,9,    19,19,19])
    }
    
    func add36369_33332_C() {
        let p = add("333 666 333 666 99 (C)", mask: "ggg ggg rrr rrr 00", jokerMask: "", note: "Any 3 Suits",  family: Family.f369, concealed: true, points: 30)
        p.add([3,3,3, 6,6,6, 13,13,13, 16,16,16, 29,29])
        p.add([3,3,3, 6,6,6, 23,23,23, 26,26,26, 19,19])
        p.add([13,13,13, 16,16,16, 23,23,23, 26,26,26, 9,9])
    }
    
    
    // -----------------------------------------------------------------------------------------
    //
    //  Standard Pairs
    //
    // -----------------------------------------------------------------------------------------
    
    func addNEWS111_222222_3() {
        let p = add("NN EE WW SS 11 11 11 (C)", mask: "00 00 00 00 gg rr 00", jokerMask: "", note: "Any Like Nos",  family: Family.pairs, concealed: true, points: 50)
        for i in 1...9 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([31,31, 34,34, 33,33, 32,32, d,d, b,b, c,c])
        }
    }
    
    func addNEWSDDD_2222222_3() {
        let p = add("NN EE WW SS DD DD DD (C)", mask: "00 00 00 00 gg rr 00", jokerMask: "", note: "",  family: Family.pairs, concealed: true, points: 50)
        p.add([31,31, 34,34, 33,33, 32,32, 10,10, 20,20, 30,30])
    }
    
    func add1357911_2222222_3() {
        let p5 = add("11 33 55 77 99 11 11 (C)", mask: "gg gg gg gg gg rr 00", jokerMask: "", note: "Odd Pairs Match in Opp Suits",  family: Family.pairs, concealed: true, points: 50)
        p5.add([1,1, 3,3, 5,5, 7,7, 9,9, 11,11, 21,21])
        p5.add([1,1, 3,3, 5,5, 7,7, 9,9, 13,13, 23,23])
        p5.add([1,1, 3,3, 5,5, 7,7, 9,9, 15,15, 25,25])
        p5.add([1,1, 3,3, 5,5, 7,7, 9,9, 17,17, 27,27])
        p5.add([1,1, 3,3, 5,5, 7,7, 9,9, 19,19, 29,29])

        p5.add([11,11, 13,13, 15,15, 17,17, 19,19, 1,1, 21,21])
        p5.add([11,11, 13,13, 15,15, 17,17, 19,19, 3,3, 23,23])
        p5.add([11,11, 13,13, 15,15, 17,17, 19,19, 5,5, 25,25])
        p5.add([11,11, 13,13, 15,15, 17,17, 19,19, 7,7, 27,27])
        p5.add([11,11, 13,13, 15,15, 17,17, 19,19, 9,9, 29,29])
        
        p5.add([21,21, 23,23, 25,25, 27,27, 29,29, 11,11, 1,1])
        p5.add([21,21, 23,23, 25,25, 27,27, 29,29, 13,13, 3,3])
        p5.add([21,21, 23,23, 25,25, 27,27, 29,29, 15,15, 5,5])
        p5.add([21,21, 23,23, 25,25, 27,27, 29,29, 17,17, 7,7])
        p5.add([21,21, 23,23, 25,25, 27,27, 29,29, 19,19, 9,9])
    }
    
    func addFNEWS111_22112222_3() {
        let p = add("FF NN E W SS 11 11 11 (C)", mask: "00 00 0 0 00 gg rr 00", jokerMask: "", note: "Any Like Nos",  family: Family.pairs, concealed: true, points: 50)
        for i in 1...9 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([35,35, 31,31, 34, 33, 32,32, d,d, b,b, c,c])
        }
    }
    
    func add13135135_21221222_3() {
        let p = add("113 11335 113355 (C)", mask: "ggg rrrrr 000000", jokerMask: "", note: "",  family: Family.pairs, concealed: true, points: 50)
        p.add([1,1,3, 11,11,13,13,15, 21,21,23,23,25,25])
        p.add([1,1,3, 21,21,23,23,25, 11,11,13,13,15,15])
        p.add([11,11,13, 1,1,3,3,5, 21,21,23,23,25,25])
        p.add([11,11,13, 21,21,23,23,25, 1,1,3,3,5,5])
        p.add([21,21,23, 1,1,3,3,5, 11,11,13,13,15,15])
        p.add([21,21,23, 11,11,13,13,15, 1,1,3,3,5,5])
    }
    
    func add57579579_21221222_3() {
        let p = add("557 55779 557799 (C)", mask: "ggg rrrrr 000000", jokerMask: "", note: "",  family: Family.pairs, concealed: true, points: 50)
        p.add([5,5,7, 15,15,17,17,19, 25,25,27,27,29,29])
        p.add([5,5,7, 25,25,27,27,29, 15,15,17,17,19,19])
        p.add([15,15,17, 5,5,7,7,9, 25,25,27,27,29,29])
        p.add([15,15,17, 25,25,27,27,29, 5,5,7,7,9,9])
        p.add([25,25,27, 5,5,7,7,9, 15,15,17,17,19,19])
        p.add([25,25,27, 15,15,17,17,19, 5,5,7,7,9,9])
    }
        
    func addF24682468_2222222_2() {
        let p = add("FF 22 46 88 22 46 88 (C)", mask: "00 gg gg gg rr rr rr", jokerMask: "", note: "Any 2 Suits",  family: Family.pairs, concealed: true, points: 50)
        p.add([35,35, 2,2, 4,6, 8,8, 12,12, 14,16, 18,18])
        p.add([35,35, 2,2, 4,6, 8,8, 22,22, 24,26, 28,28])
        p.add([35,35, 12,12, 14,16, 18,18, 22,22, 24,26, 28,28])
    }
    
    func add1234567_2222222_1() {
        let p = add("11 22 33 44 55 66 77 (C)", mask: "00 00 00 00 00 00 00", jokerMask: "", note: "Any 7 Consec Nos",  family: Family.pairs, concealed: true, points: 50)
        for i in 1...3 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([d,d, d+1,d+1, d+2,d+2, d+3,d+3, d+4,d+4, d+5,d+5, d+6,d+6])
            p.add([b,b, b+1,b+1, b+2,b+2, b+3,b+3, b+4,b+4, b+5,b+5, b+6,b+6])
            p.add([c,c, c+1,c+1, c+2,c+2, c+3,c+3, c+4,c+4, c+5,c+5, c+6,c+6])
        }
    }
    
    func addF123456_2222222_1() {
        let p = add("FF 11 22 33 44 55 66 (C)", mask: "00 00 00 00 00 00 00", jokerMask: "", note: "Any 6 Conces Nos",  family: Family.pairs, concealed: true, points: 50)
        for i in 1...4 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([35,35, d,d, d+1,d+1, d+2,d+2, d+3,d+3, d+4,d+4, d+5,d+5])
            p.add([35,35, b,b, b+1,b+1, b+2,b+2, b+3,b+3, b+4,b+4, b+5,b+5])
            p.add([35,35, c,c, c+1,c+1, c+2,c+2, c+3,c+3, c+4,c+4, c+5,c+5])
        }
    }
    
    func addF123123_2222222_2() {
        let p = add("FF 11 22 33 11 22 33 (C)", mask: "00 gg gg gg rr rr rr", jokerMask: "", note: "Any 2 Suits, Any 3 Conces Nos",  family: Family.pairs, concealed: true, points: 50)
        for i in 1...7 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([35,35, d,d, d+1,d+1, d+2,d+2, b,b, b+1,b+1, b+2,b+2])
            p.add([35,35, d,d, d+1,d+1, d+2,d+2, c,c, c+1,c+1, c+2,c+2])
            p.add([35,35, b,b, b+1,b+1, b+2,b+2, c,c, c+1,c+1, c+2,c+2])
        }
    }
        
    func addF369369_2222222_2() {
        let p = add("FF 33 66 99 33 66 99 (C)", mask: "00 gg gg gg rr rr rr", jokerMask: "", note: "Any 2 Suits",  family: Family.pairs, concealed: true, points: 50)
        p.add([35,35, 3,3, 6,6, 9,9, 13,13, 16,16, 19,19])
        p.add([35,35, 3,3, 6,6, 9,9, 23,23, 26,26, 29,29])
        p.add([35,35, 13,13, 16,16, 19,19, 23,23, 26,26, 29,29])
    }
    
    func addF12D12D_2222222_2() {
        let p = add("FF 11 22 DD 11 22 DD (C)", mask: "00 gg gg gg rr rr rr", jokerMask: "", note: "Any 2 Suits, Any 2 Like Consec Nos",  family: Family.pairs, concealed: true, points: 50)
        for i in 1...8 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([35,35, d,d, d+1,d+1, 10,10, b,b, b+1,b+1, 20,20])
            p.add([35,35, d,d, d+1,d+1, 10,10, c,c, c+1,c+1, 30,30])
            p.add([35,35, b,b, b+1,b+1, 20,20, c,c, c+1,c+1, 30,30])
        }
    }
    
    func addF121212_2222222_3() {
        let p = add("FF 11 22 11 22 11 22 (C)", mask: "00 gg gg rr rr 00 00", jokerMask: "", note: "Any 2 Consec Nos",  family: Family.pairs, concealed: true, points: 50)
        for i in 1...8 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([35,35, d,d,d+1,d+1, b,b,b+1,b+1, c,c,c+1,c+1])
        }
    }
    
    func addF123DDD_2222222_3() {
        let p = add("FF 11 22 33 DD DD DD (C)", mask: "00 00 00 00 gg rr", jokerMask: "", note: "Any 3 Consec Nos",  family: Family.pairs, concealed: true)
        for i in 1...7 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([35,35, d,d, d+1,d+1, d+2,d+2, 10,10, 20,20, 30,30])
            p.add([35,35, b,b, b+1,b+1, b+2,b+2, 10,10, 20,20, 30,30])
            p.add([35,35, c,c, c+1,c+1, c+2,c+2, 10,10, 20,20, 30,30])
        }
    }
    
    func addF12345D_2222222_1() {
        let p = add("FF 11 22 33 44 55 DD (C)", mask: "00 00 00 00 00 00 00", jokerMask: "", note: "Any 5 Consec Nos",  family: Family.pairs, concealed: true)
        for i in 1...5 {
            let d = i
            let b = i+10
            let c = i+20
            p.add([35,35,d,d,d+1,d+1,d+2,d+2,d+3,d+3,d+4,d+4,10,10])
            p.add([35,35,b,b,b+1,b+1,b+2,b+2,b+3,b+3,b+4,b+4,20,20])
            p.add([35,35,c,c,c+1,c+1,c+2,c+2,c+3,c+3,c+4,c+4,30,30])
        }
    }
    
    func addF246822_2222222_3() {
        let p = add("FF 22 44 66 88 22 22 (C)", mask: "00 00 00 00 00 gg rr", jokerMask: "", note: "Any Like Even Nos in Other 2 Suits",  family: Family.pairs, concealed: true)
        p.add([35,35, 2,2,4,4,6,6,8,8, 12,12, 22,22])
        p.add([35,35, 2,2,4,4,6,6,8,8, 14,14, 24,24])
        p.add([35,35, 2,2,4,4,6,6,8,8, 16,16, 26,26])
        p.add([35,35, 2,2,4,4,6,6,8,8, 18,18, 28,28])
        p.add([35,35, 12,12,14,14,16,16,18,18, 2,2, 22,22])
        p.add([35,35, 12,12,14,14,16,16,18,18, 4,4, 24,24])
        p.add([35,35, 12,12,14,14,16,16,18,18, 6,6, 26,26])
        p.add([35,35, 12,12,14,14,16,16,18,18, 8,8, 28,28])
        p.add([35,35, 22,22,24,24,26,26,28,28, 2,2, 12,12])
        p.add([35,35, 22,22,24,24,26,26,28,28, 4,4, 14,14])
        p.add([35,35, 22,22,24,24,26,26,28,28, 6,6, 16,16])
        p.add([35,35, 22,22,24,24,26,26,28,28, 8,8, 18,18])
    }
   
    // MARK: - Export Functionality
    
    func exportToJSON(fileName: String) {
        var jsonString = "[\n"
        
        for (index, hand) in handList.enumerated() {
            jsonString += "  {\n"
            
            // Basic hand information in specific order
            jsonString += "    \"id\" : \(hand.id),\n"
            jsonString += "    \"text\" : \"\(hand.text.string.replacingOccurrences(of: "\"", with: "\\\""))\",\n"
            jsonString += "    \"mask\" : \"\(hand.mask)\",\n"
            jsonString += "    \"jokerMask\" : \"\(hand.jokerMask)\",\n"
            jsonString += "    \"note\" : \"\(hand.note.string.replacingOccurrences(of: "\"", with: "\\\""))\",\n"
            jsonString += "    \"family\" : \"\(hand.getFamilyString())\",\n"
            jsonString += "    \"concealed\" : \(hand.concealed),\n"
            jsonString += "    \"points\" : \(hand.points),\n"
            
            // Tile sets - convert IdList to array of tile ID arrays
            jsonString += "    \"tileSets\" : [\n"
            for (tileSetIndex, extendedIdList) in hand.idList.list.enumerated() {
                jsonString += "[\(extendedIdList.ids.map(String.init).joined(separator: ","))]"
                if tileSetIndex < hand.idList.list.count - 1 {
                    jsonString += ",\n"
                }
            }
            jsonString += "]\n"
            
            jsonString += "  }"
            if index < handList.count - 1 {
                jsonString += ","
            }
            jsonString += "\n"
        }
        
        jsonString += "]"
        
        // Convert to JSON data
        do {
            let jsonData = jsonString.data(using: .utf8)!
            
            // Write to Documents directory
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsPath.appendingPathComponent(fileName)
            
            try jsonData.write(to: fileURL)
            print("Card data exported to: \(fileURL.path)")
            print("📁 File contains \(handList.count) hands with tile sets")
            
        } catch {
            print("Error exporting card data: \(error)")
        }
    }
    
    // MARK: - Import Functionality
    
    static func importFromJSON(fileName: String, year: Int) -> Card? {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("Error: \(fileName).json not found in bundle")
            return nil
        }
        
        guard let data = try? Data(contentsOf: url) else {
            print("Error: Failed to load \(fileName).json data")
            return nil
        }
        
        guard let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            print("Error: Failed to parse \(fileName).json")
            return nil
        }
        
        let card = Card()
        card.year = year
        
        // Helper to normalize mask (3 spaces -> 1 space)
        func normalizeMask(_ mask: String) -> String {
            var normalized = mask
            while normalized.contains("   ") {
                normalized = normalized.replacingOccurrences(of: "   ", with: " ")
            }
            return normalized
        }
        
        // Helper to map family string to int
        func familyStringToInt(_ familyStr: String) -> Int {
            switch familyStr {
            case "Year", "2024": return Family.year
            case "2468": return Family.f2468
            case "Like Numbers", "Any Like Numbers": return Family.likeNumbers
            case "Addition", "Addition Hands (Lucky sevens)", "Addition Hands (Lucky Sevens)": return Family.addition
            case "Quints": return Family.quints
            case "Runs": return Family.run
            case "13579": return Family.f13579
            case "Winds": return Family.winds
            case "369": return Family.f369
            case "Singles & Pairs": return Family.pairs
            default: return -1
            }
        }
        
        for jsonHand in jsonArray {
            guard let id = jsonHand["id"] as? Int,
                  let textStr = jsonHand["text"] as? String,
                  let maskStr = jsonHand["mask"] as? String,
                  let jokerMaskStr = jsonHand["jokerMask"] as? String,
                  let noteStr = jsonHand["note"] as? String,
                  let familyStr = jsonHand["family"] as? String else {
                print("Warning: Skipping invalid hand in JSON")
                continue
            }
            
            // Normalize mask (3 spaces -> 1 space)
            let normalizedMask = normalizeMask(maskStr)
            
            // Map family name to family int
            let familyInt = familyStringToInt(familyStr)
            if familyInt == -1 {
                print("Warning: Unknown family '\(familyStr)' for hand ID \(id)")
            }
            
            // Get optional fields
            let points = jsonHand["points"] as? Int ?? 0
            let concealed = jsonHand["concealed"] as? Bool ?? false
            
            // Create attributed string for text (similar to Card.add method)
            let red = [NSAttributedString.Key.foregroundColor: UIColor.red]
            let green = [NSAttributedString.Key.foregroundColor: UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)]
            let textAttr = NSMutableAttributedString(string: textStr)
            var index = 0
            for char in normalizedMask {
                switch char {
                case "g":
                    textAttr.addAttributes(green, range: NSRange(location: index, length: 1))
                case "r":
                    textAttr.addAttributes(red, range: NSRange(location: index, length: 1))
                default:
                    let black = [NSAttributedString.Key.foregroundColor: UIColor.black]
                    textAttr.addAttributes(black, range: NSRange(location: index, length: 1))
                }
                index += 1
            }
            
            // Handle concealed text
            if concealed {
                for i in index..<textAttr.length {
                    let black = [NSAttributedString.Key.foregroundColor: UIColor.black]
                    textAttr.addAttributes(black, range: NSRange(location: i, length: 1))
                }
            }
            
            // Create Hand object
            let hand = Hand(text: textAttr, 
                           mask: normalizedMask, 
                           jokerMask: jokerMaskStr, 
                           note: noteStr, 
                           id: id, 
                           family: familyInt, 
                           concealed: concealed, 
                           points: points, 
                           year: year)
            
            // Add tileSets to hand
            if let tileSets = jsonHand["tileSets"] as? [[Int]] {
                for tileSet in tileSets {
                    hand.add(tileSet)
                }
            }
            
            card.handList.append(hand)
        }
        
        return card
    }
    
    // MARK: - Comparison Functionality
    
    func compare(with otherCard: Card) {
        print("\n===== Card Comparison Summary =====")
        print("This card contains \(handList.count) hands")
        print("Other card contains \(otherCard.handList.count) hands")
        
        var matches = 0
        var mismatches = 0
        var missingInOther: [Int] = []
        var missingInThis: [Int] = []
        var differences: [String] = []
        
        // Create map of other card hands by id
        var otherHandsMap: [Int: Hand] = [:]
        for hand in otherCard.handList {
            otherHandsMap[hand.id] = hand
        }
        
        // Compare each hand in this card with other card
        for thisHand in handList {
            guard let otherHand = otherHandsMap[thisHand.id] else {
                missingInOther.append(thisHand.id)
                continue
            }
            
            var handMatches = true
            var handDifferences: [String] = []
            
            // Compare text (ignore "x ", "= ", and " (C)")
            var cleanThisText = thisHand.text.string.replacingOccurrences(of: " (C)", with: "")
            cleanThisText = cleanThisText.replacingOccurrences(of: "x ", with: "")
            cleanThisText = cleanThisText.replacingOccurrences(of: "= ", with: "")
            var cleanOtherText = otherHand.text.string.replacingOccurrences(of: " (C)", with: "")
            cleanOtherText = cleanOtherText.replacingOccurrences(of: "x ", with: "")
            cleanOtherText = cleanOtherText.replacingOccurrences(of: "= ", with: "")
            if cleanThisText != cleanOtherText {
                handMatches = false
                handDifferences.append("text: '\(cleanThisText)' vs '\(cleanOtherText)'")
            }
            
            // Compare mask
            if thisHand.mask != otherHand.mask {
                handMatches = false
                handDifferences.append("mask: '\(thisHand.mask)' vs '\(otherHand.mask)'")
            }
            
            // jokerMask and note comparison ignored per user request
            
            // Compare family
            if thisHand.family != otherHand.family {
                handMatches = false
                handDifferences.append("family: \(thisHand.family) (\(thisHand.getFamilyString())) vs \(otherHand.family) (\(otherHand.getFamilyString()))")
            }
            
            // Compare points
            if thisHand.points != otherHand.points {
                handMatches = false
                handDifferences.append("points: \(thisHand.points) vs \(otherHand.points)")
            }
            
            // Compare concealed
            if thisHand.concealed != otherHand.concealed {
                handMatches = false
                handDifferences.append("concealed: \(thisHand.concealed) vs \(otherHand.concealed)")
            }
            
            // Compare tileSets (order doesn't matter - check complete list)
            let thisTileSets = thisHand.idList.list.map { $0.ids }
            let otherTileSets = otherHand.idList.list.map { $0.ids }
            
            // Sort each tileSet array to normalize order, then convert to sets for comparison
            let thisTileSetsSet = Set(thisTileSets.map { $0.sorted().map(String.init).joined(separator: ",") })
            let otherTileSetsSet = Set(otherTileSets.map { $0.sorted().map(String.init).joined(separator: ",") })
            
            if thisTileSetsSet != otherTileSetsSet {
                handMatches = false
                if thisTileSets.count != otherTileSets.count {
                    handDifferences.append("tileSets count: \(thisTileSets.count) vs \(otherTileSets.count)")
                } else {
                    // Same count but different sets
                    let missingInThis = otherTileSetsSet.subtracting(thisTileSetsSet)
                    let missingInOther = thisTileSetsSet.subtracting(otherTileSetsSet)
                    if !missingInThis.isEmpty {
                        handDifferences.append("tileSets missing in this: \(Array(missingInThis).prefix(2))")
                    }
                    if !missingInOther.isEmpty {
                        handDifferences.append("tileSets missing in other: \(Array(missingInOther).prefix(2))")
                    }
                }
            }
            
            if handMatches {
                matches += 1
            } else {
                mismatches += 1
                differences.append("Hand ID \(thisHand.id): \(thisHand.text.string) - \(handDifferences.joined(separator: ", "))")
            }
        }
        
        // Find hands in other card that aren't in this card
        for otherHand in otherCard.handList {
            if !handList.contains(where: { $0.id == otherHand.id }) {
                missingInThis.append(otherHand.id)
            }
        }
        
        // Print summary
        print("\nMatches: \(matches)")
        print("Mismatches: \(mismatches)")
        if !missingInOther.isEmpty {
            print("Warning: Missing in other card (in this but not in other): \(missingInOther.sorted())")
        }
        if !missingInThis.isEmpty {
            print("Warning: Missing in this card (in other but not in this): \(missingInThis.sorted())")
        }
        
        if !differences.isEmpty {
            print("\n📝 Detailed Differences:")
            for diff in differences.prefix(10) { // Limit to first 10 differences
                print("  - \(diff)")
            }
            if differences.count > 10 {
                print("  ... and \(differences.count - 10) more differences")
            }
        }
        
        print("==========================================\n")
    }

}

