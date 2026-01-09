//
//  Tile.swift
//  Mahjong2017
//
//  Created by Ray on 8/10/16.
//  Copyright © 2017 EightBam LLC. All rights reserved.
//

enum TileId: Int {
    case soap = 10
    case flower = 35
    case joker = 36
}

enum History {
    case rack
    case east
    case wall
    case discard
    case bot
    case unknown
}

class Tile {
    var name: String = ""
    var number = 0
    var suit: String = ""
    var jokerSuit = ""
    var jokerNumber = 0
    var jokerId = 0
    var id = 0
    var sortId = 0
    var sortNumbers = 0
    var jokerFlag = false
    var blankTileFlag = false
    var history = History.wall
    
    func copy(_ copy: Tile) {
        name = copy.name
        number = copy.number
        suit = copy.suit
        jokerSuit = copy.jokerSuit
        jokerNumber = copy.jokerNumber
        jokerId = copy.jokerId
        id = copy.id
        sortId = copy.sortId
        sortNumbers = copy.sortNumbers
        jokerFlag = copy.jokerFlag
        history = copy.history
        blankTileFlag = copy.blankTileFlag
    }
    
    init() {
    }
    
    init(named: String, num: Int, suit: String, id: Int, sortId: Int, sortNum: Int) {
        self.name = named
        self.number = num
        self.suit = suit
        self.id = id
        self.sortId = sortId
        self.sortNumbers = sortNum
        if id == 36 {self.jokerFlag = true}
        if id == 37 {self.blankTileFlag = true}
    }
    
    init(_ tile: Tile) {
        self.name = tile.name
        self.number = tile.number
        self.suit = tile.suit
        self.id = tile.id
        self.sortId = tile.sortId
        self.sortNumbers = tile.sortNumbers
        self.jokerSuit = tile.jokerSuit
        self.jokerNumber = tile.jokerNumber
        self.jokerId = tile.jokerId
        self.jokerFlag = tile.jokerFlag
        self.history = tile.history
        self.blankTileFlag = tile.blankTileFlag
    }
    
    init(id: Int) {
        switch id {
        case 1:  self.set(named: "1dot", num: 1, suit: "dot", id: 1, sortId: 11, sortNum: 10)
        case 2:  self.set(named: "2dot", num: 2, suit: "dot", id: 2, sortId: 12, sortNum: 13)
        case 3:  self.set(named: "3dot", num: 3, suit: "dot", id: 3, sortId: 13, sortNum: 16)
        case 4:  self.set(named: "4dot", num: 4, suit: "dot", id: 4, sortId: 14, sortNum: 19)
        case 5:  self.set(named: "5dot", num: 5, suit: "dot", id: 5, sortId: 15, sortNum: 22)
        case 6:  self.set(named: "6dot", num: 6, suit: "dot", id: 6, sortId: 16, sortNum: 25)
        case 7:  self.set(named: "7dot", num: 7, suit: "dot", id: 7, sortId: 17, sortNum: 28)
        case 8:  self.set(named: "8dot", num: 8, suit: "dot", id: 8, sortId: 18, sortNum: 31)
        case 9:  self.set(named: "9dot", num: 9, suit: "dot", id: 9, sortId: 19, sortNum: 34)
        case 10: self.set(named: "soap", num: 10, suit: "dot", id: 10, sortId: 41, sortNum: 41)
        case 11: self.set(named: "1bam", num: 1, suit: "bam", id: 11, sortId: 21, sortNum: 11)
        case 12: self.set(named: "2bam", num: 2, suit: "bam", id: 12, sortId: 22, sortNum: 14)
        case 13: self.set(named: "3bam", num: 3, suit: "bam", id: 13, sortId: 23, sortNum: 17)
        case 14: self.set(named: "4bam", num: 4, suit: "bam", id: 14, sortId: 24, sortNum: 20)
        case 15: self.set(named: "5bam", num: 5, suit: "bam", id: 15, sortId: 25, sortNum: 23)
        case 16: self.set(named: "6bam", num: 6, suit: "bam", id: 16, sortId: 26, sortNum: 26)
        case 17: self.set(named: "7bam", num: 7, suit: "bam", id: 17, sortId: 27, sortNum: 29)
        case 18: self.set(named: "8bam", num: 8, suit: "bam", id: 18, sortId: 28, sortNum: 32)
        case 19: self.set(named: "9bam", num: 9, suit: "bam", id: 19, sortId: 29, sortNum: 35)
        case 20: self.set(named: "green", num: 10, suit: "bam", id: 20, sortId: 42, sortNum: 42)
        case 21: self.set(named: "1crak", num: 1, suit: "crak", id: 21, sortId: 31, sortNum: 12)
        case 22: self.set(named: "2crak", num: 2, suit: "crak", id: 22, sortId: 32, sortNum: 15)
        case 23: self.set(named: "3crak", num: 3, suit: "crak", id: 23, sortId: 33, sortNum: 18)
        case 24: self.set(named: "4crak", num: 4, suit: "crak", id: 24, sortId: 34, sortNum: 21)
        case 25: self.set(named: "5crak", num: 5, suit: "crak", id: 25, sortId: 35, sortNum: 24)
        case 26: self.set(named: "6crak", num: 6, suit: "crak", id: 26, sortId: 36, sortNum: 27)
        case 27: self.set(named: "7crak", num: 7, suit: "crak", id: 27, sortId: 37, sortNum: 30)
        case 28: self.set(named: "8crak", num: 8, suit: "crak", id: 28, sortId: 38, sortNum: 33)
        case 29: self.set(named: "9crak", num: 9, suit: "crak", id: 29, sortId: 39, sortNum: 36)
        case 30: self.set(named: "red", num: 10, suit: "crak", id: 30, sortId: 43, sortNum: 43)
        case 31: self.set(named: "north", num: 1, suit: "wnd", id: 31, sortId: 51, sortNum: 51)
        case 32: self.set(named: "south", num: 2, suit: "wnd", id: 32, sortId: 52, sortNum: 52)
        case 33: self.set(named: "west", num: 3, suit: "wnd", id: 33, sortId: 53, sortNum: 53)
        case 34: self.set(named: "east", num: 4, suit: "wnd", id: 34, sortId: 54, sortNum: 54)
        case 35: self.set(named: "f1", num: 12, suit: "flwr", id: 35, sortId: 1, sortNum: 1)
        case 36: self.set(named: "joker", num: 11, suit: "jrk", id: 36, sortId: 55, sortNum: 55)
        default:
            self.set(named: "unknown", num: 0, suit: "unk", id: id, sortId: 99, sortNum: 99)
        }
    }
    
    func set(named: String, num: Int, suit: String, id: Int, sortId: Int, sortNum: Int) {
        self.name = named
        self.number = num
        self.suit = suit
        self.id = id
        self.sortId = sortId
        self.sortNumbers = sortNum
    }
    
    func isJoker() -> Bool {
        return jokerFlag || (suit == "jrk") || (number == 11)
    }
    
    func isFlower() -> Bool {
        return suit == "flwr"
    }
    
    func isWind() -> Bool {
        return suit == "wnd"
    }
    
    func isBlankTile() -> Bool {
        return blankTileFlag || id == 37
    }
    
    func isEqual(_ tile: Tile) -> Bool {
        let sameSuit = tile.suit == suit
        let sameNumber = tile.number == number
        return sameSuit && sameNumber
    }
    
    func isEqual(_ suit: String, number: Int) -> Bool {
        let sameSuit = suit == self.suit
        let sameNumber = number == self.number
        return sameSuit && sameNumber
    }
    
    func setJokerSuit(_ suit: String, num: Int, id: Int) {
        if jokerSuit == "" {
            jokerSuit = suit
            jokerNumber = num
            jokerId = id
        }
    }
    
    func setJokerFields(_ tile: Tile) {
        if tile.isJoker() {
            jokerSuit = tile.jokerSuit
            jokerId = tile.jokerId
            jokerNumber = tile.jokerNumber
        } else {
            jokerSuit = tile.suit
            jokerId = tile.id
            jokerNumber = tile.number
        }
    }
    
    func clearJokerSuit() {
        jokerSuit = ""
        jokerNumber = 0
        jokerId = 0
    }
    
    func getImage(maj: Maj) -> String {
        var image = ""
        switch (maj.settings.dotTileStyle) {
        case TileStyle.largeFont: image = Tile.getImageNew(id)
        case TileStyle.designer: image = Tile.getImageDesigner(id)
        case TileStyle.designerLargeFont: image = Tile.getImageDesignerLargeFont(id)
        case TileStyle.darkModeClassic: image = Tile.getImageDark(id)
        case TileStyle.darkModeLargeFont: image = Tile.getImageDarkLargeFont(id)
        case TileStyle.darkModeDesigner: image = Tile.getImageDark(id)
        case TileStyle.darkModeDesignerLargeFont: image = Tile.getImageDarkLargeFont(id)
        case TileStyle.solidClassic: image = Tile.getImageSolidColor(id)
        case TileStyle.solidLargeFont: image = Tile.getImageSolidColor(id)
        case TileStyle.solidDesigner: image = Tile.getImageSolidColor(id)
        case TileStyle.solidDesignerLargeFont: image = Tile.getImageSolidColor(id)
        case TileStyle.solidDarkModeClassic: image = Tile.getImageSolidColor(id)
        case TileStyle.solidDarkModeLargeFont: image = Tile.getImageSolidColor(id)
        case TileStyle.solidDarkModeDesigner: image = Tile.getImageSolidColor(id)
        case TileStyle.solidDarkModeDesignerLargeFont: image = Tile.getImageSolidColor(id)
        case TileStyle.argon: image = Tile.getImageArgon(id)
        case TileStyle.accessable: image = Tile.getImageAccessable(id)
        default: image = name
        }
        if id == 30 && maj.settings.alternateRedDragon {
            image = "redAlt.png"
        }
        return image
    }
    
    static func getImage(id: Int, maj: Maj) -> String {
        var image = ""
        switch(maj.settings.dotTileStyle) {
        case TileStyle.largeFont: image = Tile.getImageNew(id)
        case TileStyle.designer: image = Tile.getImageDesigner(id)
        case TileStyle.designerLargeFont: image = Tile.getImageDesignerLargeFont(id)
        case TileStyle.darkModeClassic: image = Tile.getImageDark(id)
        case TileStyle.darkModeLargeFont: image = Tile.getImageDarkLargeFont(id)
        case TileStyle.darkModeDesigner: image = Tile.getImageDark(id)
        case TileStyle.darkModeDesignerLargeFont: image = Tile.getImageDarkLargeFont(id)
        case TileStyle.solidClassic: image = Tile.getImageSolidColor(id)
        case TileStyle.solidLargeFont: image = Tile.getImageSolidColor(id)
        case TileStyle.solidDesigner: image = Tile.getImageSolidColor(id)
        case TileStyle.solidDesignerLargeFont: image = Tile.getImageSolidColor(id)
        case TileStyle.solidDarkModeClassic: image = Tile.getImageSolidColor(id)
        case TileStyle.solidDarkModeLargeFont: image = Tile.getImageSolidColor(id)
        case TileStyle.solidDarkModeDesigner: image = Tile.getImageSolidColor(id)
        case TileStyle.solidDarkModeDesignerLargeFont: image = Tile.getImageSolidColor(id)
        case TileStyle.argon: image = Tile.getImageArgon(id)
        case TileStyle.accessable: image = Tile.getImageAccessable(id)
        default: image = Tile.getImage(id)
        }
        if id == 30 && maj.settings.alternateRedDragon {
            image = "redAlt.png"
        }
        return image
    }
    
    static func getImage(_ id: Int) -> String {
        var image = ""
        switch(id) {
        case 1: image = "1dot.png"
        case 2: image = "2dot.png"
        case 3: image = "3dot.png"
        case 4: image = "4dot.png"
        case 5: image = "5dot.png"
        case 6: image = "6dot.png"
        case 7: image = "7dot.png"
        case 8: image = "8dot.png"
        case 9: image = "9dot.png"
        case 10: image = "soap.png"
        case 11: image = "1bam.png"
        case 12: image = "2bam.png"
        case 13: image = "3bam.png"
        case 14: image = "4bam.png"
        case 15: image = "5bam.png"
        case 16: image = "6bam.png"
        case 17: image = "7bam.png"
        case 18: image = "8bam.png"
        case 19: image = "9bam.png"
        case 20: image = "green.png"
        case 21: image = "1crak.png"
        case 22: image = "2crak.png"
        case 23: image = "3crak.png"
        case 24: image = "4crak.png"
        case 25: image = "5crak.png"
        case 26: image = "6crak.png"
        case 27: image = "7crak.png"
        case 28: image = "8crak.png"
        case 29: image = "9crak.png"
        case 30: image = "red.png"
        case 31: image = "north.png"
        case 32: image = "south.png"
        case 33: image = "west.png"
        case 34: image = "east.png"
        case 35: image = "f1.png"
        case 36: image = "joker.png"
        case 37: image = "blank.png"
        default: image = ""
        }
        return image
    }
    
    static func getImageArgon(_ id: Int) -> String {
        var image = ""
        switch(id) {
        case 1: image = "1-Dot.png"
        case 2: image = "2-Dot.png"
        case 3: image = "3-Dot.png"
        case 4: image = "4-Dot.png"
        case 5: image = "5-Dot.png"
        case 6: image = "6-Dot.png"
        case 7: image = "7-Dot.png"
        case 8: image = "8-Dot.png"
        case 9: image = "9-Dot.png"
        case 10: image = "0-Dot.png"
        case 11: image = "1-Bam.png"
        case 12: image = "2-Bam.png"
        case 13: image = "3-Bam.png"
        case 14: image = "4-Bam.png"
        case 15: image = "5-Bam.png"
        case 16: image = "6-Bam.png"
        case 17: image = "7-Bam.png"
        case 18: image = "8-Bam.png"
        case 19: image = "9-Bam.png"
        case 20: image = "G-Bam.png"
        case 21: image = "1-Crak.png"
        case 22: image = "2-Crak.png"
        case 23: image = "3-Crak.png"
        case 24: image = "4-Crak.png"
        case 25: image = "5-Crak.png"
        case 26: image = "6-Crak.png"
        case 27: image = "7-Crak.png"
        case 28: image = "8-Crak.png"
        case 29: image = "9-Crak.png"
        case 30: image = "R-Crak.png"
        case 31: image = "N-Wind.png"
        case 32: image = "S-Wind.png"
        case 33: image = "W-Wind.png"
        case 34: image = "E-Wind.png"
        case 35: image = "F-Flower.png"
        case 36: image = "J-Joker.png"
        case 37: image = "blank.png"
        default: image = ""
        }
        return image
    }
            
    static func getImageAccessable(_ id: Int) -> String {
        var image = ""
        switch(id) {
        case 1: image = "1-Dot-acc.png"
        case 2: image = "2-Dot-acc.png"
        case 3: image = "3-Dot-acc.png"
        case 4: image = "4-Dot-acc.png"
        case 5: image = "5-Dot-acc.png"
        case 6: image = "6-Dot-acc.png"
        case 7: image = "7-Dot-acc.png"
        case 8: image = "8-Dot-acc.png"
        case 9: image = "9-Dot-acc.png"
        case 10: image = "Soap-acc.png"
        case 11: image = "1-Bam-acc.png"
        case 12: image = "2-Bam-acc.png"
        case 13: image = "3-Bam-acc.png"
        case 14: image = "4-Bam-acc.png"
        case 15: image = "5-Bam-acc.png"
        case 16: image = "6-Bam-acc.png"
        case 17: image = "7-Bam-acc.png"
        case 18: image = "8-Bam-acc.png"
        case 19: image = "9-Bam-acc.png"
        case 20: image = "GreenDragon-acc.png"
        case 21: image = "1-Crak-acc.png"
        case 22: image = "2-Crak-acc.png"
        case 23: image = "3-Crak-acc.png"
        case 24: image = "4-Crak-acc.png"
        case 25: image = "5-Crak-acc.png"
        case 26: image = "6-Crak-acc.png"
        case 27: image = "7-Crak-acc.png"
        case 28: image = "8-Crak-acc.png"
        case 29: image = "9-Crak-acc.png"
        case 30: image = "RedDragon-acc.png"
        case 31: image = "North-acc.png"
        case 32: image = "South-acc.png"
        case 33: image = "West-acc.png"
        case 34: image = "East-acc.png"
        case 35: image = "Flower-acc.png"
        case 36: image = "Joker-acc.png"
        case 37: image = "blank.png"
        default: image = ""
        }
        return image
    }
    
    
    static func getImageNew(_ id: Int) -> String {
        var image = ""
        switch(id) {
        case 1: image = "1dotnew.png"
        case 2: image = "2dotnew.png"
        case 3: image = "3dotnew.png"
        case 4: image = "4dotnew.png"
        case 5: image = "5dotnew.png"
        case 6: image = "6dotnew.png"
        case 7: image = "7dotnew.png"
        case 8: image = "8dotnew.png"
        case 9: image = "9dotnew.png"
        case 10: image = "soap.png"
        case 11: image = "1bamnew.png"
        case 12: image = "2bamnew.png"
        case 13: image = "3bamnew.png"
        case 14: image = "4bamnew.png"
        case 15: image = "5bamnew.png"
        case 16: image = "6bamnew.png"
        case 17: image = "7bamnew.png"
        case 18: image = "8bamnew.png"
        case 19: image = "9bamnew.png"
        case 20: image = "green.png"
        case 21: image = "1craknew.png"
        case 22: image = "2craknew.png"
        case 23: image = "3craknew.png"
        case 24: image = "4craknew.png"
        case 25: image = "5craknew.png"
        case 26: image = "6craknew.png"
        case 27: image = "7craknew.png"
        case 28: image = "8craknew.png"
        case 29: image = "9craknew.png"
        case 30: image = "red.png"
        case 31: image = "northnew.png"
        case 32: image = "southnew.png"
        case 33: image = "westnew.png"
        case 34: image = "eastnew.png"
        case 35: image = "flowernew.png"
        case 36: image = "joker.png"
        case 37: image = "blank.png"
        default: image = ""
        }
        return image
    }
    
    static func getImageDesigner(_ id: Int) -> String {
        var image = ""
        switch(id) {
        case 1: image = "1d.png"
        case 2: image = "2d.png"
        case 3: image = "3d.png"
        case 4: image = "4d.png"
        case 5: image = "5d.png"
        case 6: image = "6d.png"
        case 7: image = "7d.png"
        case 8: image = "8d.png"
        case 9: image = "9d.png"
        case 10: image = "0.png"
        case 11: image = "1b.png"
        case 12: image = "2b.png"
        case 13: image = "3b.png"
        case 14: image = "4b.png"
        case 15: image = "5b.png"
        case 16: image = "6b.png"
        case 17: image = "7b.png"
        case 18: image = "8b.png"
        case 19: image = "9b.png"
        case 20: image = "g.png"
        case 21: image = "1c.png"
        case 22: image = "2c.png"
        case 23: image = "3.png"
        case 24: image = "4c.png"
        case 25: image = "5c.png"
        case 26: image = "6c.png"
        case 27: image = "7c.png"
        case 28: image = "8c.png"
        case 29: image = "9c.png"
        case 30: image = "r.png"
        case 31: image = "n.png"
        case 32: image = "s.png"
        case 33: image = "w.png"
        case 34: image = "e.png"
        case 35: image = "f.png"
        case 36: image = "j.png"
        case 37: image = "blank.png"
        default: image = ""
        }
        return image
    }
    
    static func getImageDark(_ id: Int) -> String {
        var image = ""
        switch(id) {
        case 1: image = "1d-dark.png"
        case 2: image = "2d-dark.png"
        case 3: image = "3d-dark.png"
        case 4: image = "4d-dark.png"
        case 5: image = "5d-dark.png"
        case 6: image = "6d-dark.png"
        case 7: image = "7d-dark.png"
        case 8: image = "8d-dark.png"
        case 9: image = "9d-dark.png"
        case 10: image = "0-dark.png"
        case 11: image = "1b-dark.png"
        case 12: image = "2b-dark.png"
        case 13: image = "3b-dark.png"
        case 14: image = "4b-dark.png"
        case 15: image = "5b-dark.png"
        case 16: image = "6b-dark.png"
        case 17: image = "7b-dark.png"
        case 18: image = "8b-dark.png"
        case 19: image = "9b-dark.png"
        case 20: image = "g-dark.png"
        case 21: image = "1c-dark.png"
        case 22: image = "2c-dark.png"
        case 23: image = "3c-dark.png"
        case 24: image = "4c-dark.png"
        case 25: image = "5c-dark.png"
        case 26: image = "6c-dark.png"
        case 27: image = "7c-dark.png"
        case 28: image = "8c-dark.png"
        case 29: image = "9c-dark.png"
        case 30: image = "r-dark.png"
        case 31: image = "n-dark.png"
        case 32: image = "s-dark.png"
        case 33: image = "w-dark.png"
        case 34: image = "e-dark.png"
        case 35: image = "f-dark.png"
        case 36: image = "j-dark.png"
        case 37: image = "blank.png"
        default: image = ""
        }
        return image
    }
    
    static func getImageDesignerLargeFont(_ id: Int) -> String {
        var image = ""
        switch(id) {
        case 1: image = "1d-xl.png"
        case 2: image = "2d-xl.png"
        case 3: image = "3d-xl.png"
        case 4: image = "4d-xl.png"
        case 5: image = "5d-xl.png"
        case 6: image = "6d-xl.png"
        case 7: image = "7d-xl.png"
        case 8: image = "8d-xl.png"
        case 9: image = "9d-xl.png"
        case 10: image = "0-xl.png"
        case 11: image = "1b-xl.png"
        case 12: image = "2b-xl.png"
        case 13: image = "3b-xl.png"
        case 14: image = "4b-xl.png"
        case 15: image = "5b-xl.png"
        case 16: image = "6b-xl.png"
        case 17: image = "7b-xl.png"
        case 18: image = "8b-xl.png"
        case 19: image = "9b-xl.png"
        case 20: image = "g-xl.png"
        case 21: image = "1c-xl.png"
        case 22: image = "2c-xl.png"
        case 23: image = "3c-xl.png"
        case 24: image = "4c-xl.png"
        case 25: image = "5c-xl.png"
        case 26: image = "6c-xl.png"
        case 27: image = "7c-xl.png"
        case 28: image = "8c-xl.png"
        case 29: image = "9c-xl.png"
        case 30: image = "r-xl.png"
        case 31: image = "n-xl.png"
        case 32: image = "s-xl.png"
        case 33: image = "w-xl.png"
        case 34: image = "e-xl.png"
        case 35: image = "f-xl.png"
        case 36: image = "j-xl.png"
        case 37: image = "blank.png"
        default: image = ""
        }
        return image
    }
    
    static func getImageDarkLargeFont(_ id: Int) -> String {
        var image = ""
        switch(id) {
        case 1: image = "1d-xl-dark.png"
        case 2: image = "2d-xl-dark.png"
        case 3: image = "3d-xl-dark.png"
        case 4: image = "4d-xl-dark.png"
        case 5: image = "5d-xl-dark.png"
        case 6: image = "6d-xl-dark.png"
        case 7: image = "7d-xl-dark.png"
        case 8: image = "8d-xl-dark.png"
        case 9: image = "9d-xl-dark.png"
        case 10: image = "0-xl-dark.png"
        case 11: image = "1b-xl-dark.png"
        case 12: image = "2b-xl-dark.png"
        case 13: image = "3b-xl-dark.png"
        case 14: image = "4b-xl-dark.png"
        case 15: image = "5b-xl-dark.png"
        case 16: image = "6b-xl-dark.png"
        case 17: image = "7b-xl-dark.png"
        case 18: image = "8b-xl-dark.png"
        case 19: image = "9b-xl-dark.png"
        case 20: image = "g-xl-dark.png"
        case 21: image = "1c-xl-dark.png"
        case 22: image = "2c-xl-dark.png"
        case 23: image = "3c-xl-dark.png"
        case 24: image = "4c-xl-dark.png"
        case 25: image = "5c-xl-dark.png"
        case 26: image = "6c-xl-dark.png"
        case 27: image = "7c-xl-dark.png"
        case 28: image = "8c-xl-dark.png"
        case 29: image = "9c-xl-dark.png"
        case 30: image = "r-xl-dark.png"
        case 31: image = "n-xl-dark.png"
        case 32: image = "s-xl-dark.png"
        case 33: image = "w-xl-dark.png"
        case 34: image = "e-xl-dark.png"
        case 35: image = "f-xl-dark.png"
        case 36: image = "j-xl-dark.png"
        case 37: image = "blank.png"
        default: image = ""
        }
        return image
    }
       
    static func getImageSolidColor(_ id: Int) -> String {
        var image = ""
        switch(id) {
        case 1: image = "1d-super.png"
        case 2: image = "2d-super.png"
        case 3: image = "3d-super.png"
        case 4: image = "4d-super.png"
        case 5: image = "5d-super.png"
        case 6: image = "6d-super.png"
        case 7: image = "7d-super.png"
        case 8: image = "8d-super.png"
        case 9: image = "9d-super.png"
        case 10: image = "0-super.png"
        case 11: image = "1b-super.png"
        case 12: image = "2b-super.png"
        case 13: image = "3b-super.png"
        case 14: image = "4b-super.png"
        case 15: image = "5b-super.png"
        case 16: image = "6b-super.png"
        case 17: image = "7b-super.png"
        case 18: image = "8b-super.png"
        case 19: image = "9b-super.png"
        case 20: image = "g-super.png"
        case 21: image = "1c-super.png"
        case 22: image = "2c-super.png"
        case 23: image = "3c-super.png"
        case 24: image = "4c-super.png"
        case 25: image = "5c-super.png"
        case 26: image = "6c-super.png"
        case 27: image = "7c-super.png"
        case 28: image = "8c-super.png"
        case 29: image = "9c-super.png"
        case 30: image = "r-super.png"
        case 31: image = "n-super.png"
        case 32: image = "s-super.png"
        case 33: image = "w-super.png"
        case 34: image = "e-super.png"
        case 35: image = "f-super.png"
        case 36: image = "j-super-alt7.png"
        case 37: image = "blank.png"
        default: image = ""
        }
        return image
    }
    
    func getDisplayName() -> String {
        return getDisplayNameForId(id: id)
    }
    
    func getDisplayNameForJoker() -> String {
        return getDisplayNameForId(id: jokerId)
    }
    
    func getDisplayNameForId(id: Int) -> String {
        var  tileName = ""
        switch(id) {
        case 1: tileName = "1 Dot"
        case 2: tileName = "2 Dot"
        case 3: tileName = "3 Dot"
        case 4: tileName = "4 Dot"
        case 5: tileName = "5 Dot"
        case 6: tileName = "6 Dot"
        case 7: tileName = "7 Dot"
        case 8: tileName = "8 Dot"
        case 9: tileName = "9 Dot"
        case 10: tileName = "Soap"
        case 11: tileName = "1 Bam"
        case 12: tileName = "2 Bam"
        case 13: tileName = "3 Bam"
        case 14: tileName = "4 Bam"
        case 15: tileName = "5 Bam"
        case 16: tileName = "6 Bam"
        case 17: tileName = "7 Bam"
        case 18: tileName = "8 Bam"
        case 19: tileName = "9 Bam"
        case 20: tileName = "Green Dragon"
        case 21: tileName = "1 Crak"
        case 22: tileName = "2 Crak"
        case 23: tileName = "3 Crak"
        case 24: tileName = "4 Crak"
        case 25: tileName = "5 Crak"
        case 26: tileName = "6 Crak"
        case 27: tileName = "7 Crak"
        case 28: tileName = "8 Crak"
        case 29: tileName = "9 Crak"
        case 30: tileName = "Red Dragon"
        case 31: tileName = "North Wind"
        case 32: tileName = "South Wind"
        case 33: tileName = "West Wind"
        case 34: tileName = "East Wind"
        case 35: tileName = "Flower"
        case 36: tileName = "Joker"
        case 37: tileName = "blank.png"
        default: tileName = ""
        }
        return tileName
    }
    
    
}
