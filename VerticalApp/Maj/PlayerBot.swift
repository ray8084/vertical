//
//  PlayerBot.swift
//  MahjongPractice
//
//  Bot-specific methods extension for Player class
//  This file contains all bot AI logic for calling tiles and selecting discards
//

import Foundation

extension Player {
    
    // MARK: - Bot Discard Methods
    
    func getRandomDiscard(maj: Maj, withFlowers: Bool) -> Tile {
        var index = 0
        for tile in tiles {
            if (!tile.isJoker() && !tile.isFlower() && !tile.isBlankTile()) || (tile.isFlower() && withFlowers) {
                if !maj.east.rack.exists(tile: tile) {
                    break
                }
            }
            index += 1
        }
        var tile: Tile!
        if index < tiles.count {
            tile = tiles.remove(at: index)
        } else {
            tile = tiles.remove(at: tiles.count-1)
        }
        return tile
    }
    
    func getBestDiscard(maj: Maj, rack: Rack, withFlowers: Bool) -> Tile {
        matchingTileSets.countMatches(hand: self, rack: rack, maj: maj)
        matchingTileSets.sort(settings: maj.settings)
        let tileMatchItem = getBestBotHand()
        let matchCount = tileMatchItem.matchCount
        shuffle(withSeed: true, seedString: "repeatableRandom")
        var tile = tiles[0]
        var found = false
        for index in 0...tiles.count-1 {
            if maj.isWinBotEnabled() {
                tile = tiles.remove(at: 0)
                matchingTileSets.countMatchesForItem(hand: self, tiles: tiles + rack.tiles, tileSet: tileMatchItem, jokerCount: jokerCount() + rack.jokerCount(), maj: maj)
            } else {
                tile = tiles.remove(at: index)
                matchingTileSets.countMatchesForItem(hand: self, tiles: tiles, tileSet: tileMatchItem, jokerCount: jokerCount() + rack.jokerCount(), maj: maj)
            }
            
            if tileMatchItem.matchCount == matchCount {
                if (!tile.isJoker() && !tile.isFlower() && !tile.isBlankTile()) || (tile.isFlower() && withFlowers) {
                    if !maj.east.rack.exists(tile: tile) {
                        found = true
                        break
                    }
                }
            }
            tiles.append(tile)
        }
        return found ? tile : getRandomDiscard(maj: maj, withFlowers: withFlowers)
    }
    
    func getBestBotHand() -> TileSet {
        // If bot has already committed to a target hand, use it
        if let targetHand = botTargetHand {
            return targetHand
        }
        // Otherwise, find the best hand (preferring exposed hands)
        var bestBotHand = matchingTileSets.tileSets[0]
        for item in matchingTileSets.tileSets {
            bestBotHand = item
            if item.concealed == false  {
                break
            }
        }
        return bestBotHand
    }
    
    
    // MARK: - Bot Draw Methods
    
    func botDraw(_ maj: Maj) {
        draw(maj)
        botDrawExtra(maj)
    }
    
    private func botDrawExtra(_ maj: Maj) {
        // Only use extra draw when bot wins are enabled and difficulty is set to Better
        guard maj.settings.winBotEnabled && maj.settings.botDifficultyLevel == .better else { return }
        
        // Only proceed if wall has tiles and bot doesn't already have 14 matching tiles
        guard maj.wall.tiles.count > 0 else { return }
        
        // Only start looking at tiles from the end when wall has less than 70 tiles
        guard maj.wall.tiles.count < 60 else { return }
        
        // Stop when wall gets to 20 tiles
        guard maj.wall.tiles.count > 20 else { return }
        
        // Get current highest match count
        matchingTileSets.countMatches(hand: self, rack: rack, maj: maj)
        matchingTileSets.sort(settings: maj.settings)
        let currentMatchCount = getBestBotHand().matchCount
        
        // If bot already has 14 matching tiles, don't look for more tiles
        guard currentMatchCount < 14 else { return }
        
        // Ensure bot has exactly 14 tiles total (hand + rack) after normal draw
        let totalTiles = tiles.count + rack.tiles.count
        guard totalTiles == 14 else { return }
        
        // Try drawing a tile from the end of the wall
        let endTile = maj.wall.tiles.remove(at: maj.wall.tiles.count - 10)
        tiles.append(endTile)
        
        // Recalculate match count
        matchingTileSets.countMatches(hand: self, rack: rack, maj: maj)
        matchingTileSets.sort(settings: maj.settings)
        let newMatchCount = getBestBotHand().matchCount
        
        if newMatchCount == 14 {
            // Bot has mahjong - discard a tile that's not needed for the winning hand
            let winningHand = getBestBotHand()
            let unwantedTile = findUnneededTile(for: winningHand, maj: maj)
            maj.wall.tiles.append(unwantedTile)
            // Now we have 14 tiles (added endTile, removed unneeded tile)
        } else if newMatchCount > currentMatchCount && newMatchCount < 14 {
            // Improved - find a tile we don't want and put it at the end of the wall
            let unwantedTile = getRandomDiscard(maj: maj, withFlowers: true)
            maj.wall.tiles.append(unwantedTile)
            // Now we have 14 tiles again (added endTile, removed unwantedTile)
        } else {
            // Not improved or already at 14 - put back the tile we just drew
            if maj.settings.lefty {
                tiles.remove(at: 0)
            } else {
                tiles.remove(at: tiles.count - 1)
            }
            maj.wall.tiles.append(endTile)
            
            // Search through tiles 10-20 from the end of the wall (not the last 10)
            let maxSearch = min(20, maj.wall.tiles.count)
            let minSearch = min(11, maj.wall.tiles.count)
            var foundBetter = false
            
            for i in minSearch...maxSearch {
                let wallIndex = maj.wall.tiles.count - i
                let testTile = maj.wall.tiles[wallIndex]
                
                // Temporarily add the tile
                if maj.settings.lefty {
                    tiles.insert(testTile, at: 0)
                } else {
                    tiles.append(testTile)
                }
                
                // Check if it improves (and not already at 14)
                matchingTileSets.countMatches(hand: self, rack: rack, maj: maj)
                matchingTileSets.sort(settings: maj.settings)
                let testMatchCount = getBestBotHand().matchCount
                
                if testMatchCount == 14 {
                    // Bot has mahjong - discard a tile that's not needed for the winning hand
                    maj.wall.tiles.remove(at: wallIndex)
                    let winningHand = getBestBotHand()
                    let unwantedTile = findUnneededTile(for: winningHand, maj: maj)
                    maj.wall.tiles.append(unwantedTile)
                    foundBetter = true
                    break
                } else if testMatchCount > currentMatchCount && testMatchCount < 14 {
                    // This tile improves - keep it and put back an unwanted tile
                    maj.wall.tiles.remove(at: wallIndex)
                    let unwantedTile = getRandomDiscard(maj: maj, withFlowers: true)
                    maj.wall.tiles.append(unwantedTile)
                    foundBetter = true
                    break
                } else {
                    // Doesn't improve or already at 14 - remove it
                    if maj.settings.lefty {
                        tiles.remove(at: 0)
                    } else {
                        tiles.remove(at: tiles.count - 1)
                    }
                }
            }
            
            // If we didn't find a better tile, just keep the normal draw (no extra tile from end)
        }
    }
    
    // MARK: - Bot Calling Methods
    
    func skipHand(handId: Int) -> Bool {
        return (handId == 0) || (handId == 2) || (handId == 3) || (handId == 4) // todo fix 2022 joker calls
    }
    
    func call(maj: Maj, rack: Rack) -> Bool{
        // print("Call \(name)")
        if maj.discardTile != nil {
            let east = maj.card.getClosestHand(tiles: maj.east.tiles + maj.rackTiles() + [maj.discardTile])
            if east.matchCount == 14 {
                return false;   // bot cant call if east has mahjong
            }
            if maj.discardTile.isJoker() == false {
                // If bot has committed to a target hand, only call tiles that match it
                let tileSet: TileSet
                if let targetHand = botTargetHand {
                    tileSet = targetHand
                    // Check if the discarded tile is in the target hand
                    let matchId = maj.discardTile.id
                    if targetHand.tileVector.vector[matchId] == 0 {
                        return false  // Tile not in target hand, don't call
                    }
                } else {
                    tileSet = getHighestMatch(maj: maj)
                }
                
            if skipHand(handId: tileSet.handId) == false {
                		let matchMap = tileSet.tileVector
                    let matchId = maj.discardTile.id
                    let tilename = maj.discardTile.getDisplayName()
                            let handVector = TileVector(tiles: tiles)
        let rackVector = TileVector(rack: rack)
                    let matchCount = matchMap.vector[matchId]
                    let handCount = handVector.vector[matchId]
                    let rackCount = rackVector.vector[matchId]
                    let jokers = jokerCount()
                    maj.discardCalled = false
                    if rackCount != 0 {
                    }
                    else if (matchCount == 4) && (handCount == 3) {
                        maj.discardCalled = call(maj: maj, rack: rack, matchId: matchId, matchCount: matchCount, handCount: handCount)
                    }
                    else if (matchCount == 4) && (handCount == 2) && (jokers >= 1) {
                        maj.discardCalled = callWithJoker(maj: maj, rack: rack, matchId: matchId, matchCount: matchCount, handCount: handCount)
                    }
                    else if (matchCount == 4) && (handCount == 1) && (jokers >= 2) {
                        maj.discardCalled = callWith2Jokers(maj: maj, rack: rack, matchId: matchId, matchCount: matchCount, handCount: handCount)
                    }
                    else if (matchCount == 3) && (handCount == 2) {
                        maj.discardCalled = call(maj: maj, rack: rack, matchId: matchId, matchCount: matchCount, handCount: handCount)
                    }
                    else if (matchCount == 3) && (handCount == 1) && (jokers > 0) {
                        maj.discardCalled = callWithJoker(maj: maj, rack: rack, matchId: matchId, matchCount: matchCount, handCount: handCount)
                    } else if (matchCount == 2) && (handCount == 1){
                        maj.discardCalled = callPair(maj: maj, rack: rack, matchId: matchId, matchCount: matchCount, handCount: handCount)
                    } else {
                        // print("Pass \(name) id \(matchId) map \(matchCount) hand \(handCount) jokers \(jokers)" )
                    }
                    
                    if maj.discardCalled {
                        // Save target hand on first call
                        if botTargetHand == nil {
                            botTargetHand = tileSet
                        }
                        maj.clearMessages()
                        if maj.isWinBotEnabled() && maj.botWon() {
                            rack.message = "\(name) declared Mahjong"
                            print(rack.message)
                        } else {
                            rack.message = "\(name) called \(tilename)"
                            if maj.previousHandName == maj.south.rack.name {
                                maj.south.rack.message = "\(maj.south.rack.name) discarded \(tilename)"
                            } else if maj.previousHandName == maj.west.rack.name {
                                maj.west.rack.message = "\(maj.west.rack.name) discarded \(tilename)"
                            } else if maj.previousHandName == maj.north.rack.name {
                                maj.north.rack.message = "\(maj.north.rack.name) discarded \(tilename)"
                            }
                        }
                    }
                }
            }
        }
        return maj.discardCalled
    }
    
    private func call(maj: Maj, rack: Rack, matchId: Int, matchCount: Int, handCount: Int) -> Bool {
        var called = false
        if matchCount - handCount == 1 {
            if matchCount + rack.tiles.count < 14 {
                rackTiles(rack: rack, tileId: matchId, count: handCount)
                rack.tiles.append(Tile(maj.discardTile))
                maj.discardTile = getDiscard(maj: maj, rack: rack, withFlowers: true)
                called = true
            } else if maj.isWinBotEnabled() {
                // print("\(name) call for mahjong")
                rack.tiles.append(Tile(maj.discardTile))
                rackAllTiles()
                countMatches(maj: maj)
                called = true
            }
        }
        return called
    }
    
    private func callWithJoker(maj: Maj, rack: Rack, matchId: Int, matchCount: Int, handCount: Int) -> Bool {
        var called = false
        if (matchCount - handCount == 2) && (jokerCount() >= 1) && ((maj.wall.tiles.count < 90) || testJokerExchange) {
            if matchCount + rack.tiles.count < 14 {
                rackTiles(rack: rack, tileId: matchId, count: handCount)
                rackJokers(rack: rack, id: maj.discardTile.id, suit: maj.discardTile.suit, number: maj.discardTile.number, count: 1)
                rack.tiles.append(Tile(maj.discardTile))
                maj.discardTile = getDiscard(maj: maj, rack: rack, withFlowers: true)
                called = true
            } else if maj.isWinBotEnabled() {
                // print("\(name) call for mahjong")
                rack.tiles.append(Tile(maj.discardTile))
                rackAllTiles()
                countMatches(maj: maj)
                called = true
            }
        }
        return called
    }
    
    private func findUnneededTile(for tileSet: TileSet, maj: Maj) -> Tile {
        // Reuse the approach from getBestDiscard: try removing each tile and see if match count stays at 14
        // If it does, that tile is not needed for the winning hand
        let targetMatchCount = 14
        
        for index in 0..<tiles.count {
            let tile = tiles.remove(at: index)
            // Recalculate match count without this tile
            matchingTileSets.countMatchesForItem(hand: self, tiles: tiles + rack.tiles, tileSet: tileSet, jokerCount: jokerCount() + rack.jokerCount(), maj: maj)
            
            if tileSet.matchCount == targetMatchCount {
                // This tile is not needed - the match count stays at 14 without it
                return tile
            }
            
            // Put the tile back and try the next one
            tiles.insert(tile, at: index)
        }
        
        // If we can't find an unneeded tile (shouldn't happen with 15 tiles and 14 match), use random discard as fallback
        return getRandomDiscard(maj: maj, withFlowers: true)
    }
    
    private func callWith2Jokers(maj: Maj, rack: Rack, matchId: Int, matchCount: Int, handCount: Int) -> Bool {
        var called = false
        if (matchCount - handCount == 3) && (jokerCount() >= 2) && (((maj.wall.tiles.count > 20) && (maj.wall.tiles.count < 40)) || testJokerExchange) {
            if matchCount + rack.tiles.count < 14 {
                rackTiles(rack: rack, tileId: matchId, count: handCount)
                rackJokers(rack: rack, id: maj.discardTile.id, suit: maj.discardTile.suit, number: maj.discardTile.number, count: 2)
                rack.tiles.append(Tile(maj.discardTile))
                maj.discardTile = getDiscard(maj: maj, rack: rack, withFlowers: true)
                called = true
            } else if maj.isWinBotEnabled() {
                // print("\(name) call for mahjong")
                rack.tiles.append(Tile(maj.discardTile))
                rackAllTiles()
                countMatches(maj: maj)
                called = true
            }
        }
        return called
    }
    
    private func callPair(maj: Maj, rack: Rack, matchId: Int, matchCount: Int, handCount: Int) -> Bool {
        var called = false
        if maj.isWinBotEnabled() && (matchCount + rack.tiles.count == 14) {
            // print("\(name) call for mahjong")
            rack.tiles.append(Tile(maj.discardTile))
            rackAllTiles()
            countMatches(maj: maj)
            called = true
        }
        return called
    }
}

