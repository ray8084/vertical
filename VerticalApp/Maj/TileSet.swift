import Foundation

class TileSet {
    var tileIds = [Int]()
    var tileVector = TileVector([])
    var matchCount = 0
    var handId = 0
    var concealed = false
    var family = 0
    var rackFilter = false
    var singles = Singles.normal
   
    init(tileIds: [Int], handIndex: Int, hand: Hand, singles: Int){
        self.tileIds = tileIds
        self.handId = handIndex
        self.family = hand.family
        self.concealed = hand.concealed
        self.tileVector = TileVector(tileIds)
        self.singles = singles
    }
    
    func rackFilter(_ rackVector: TileVector, year: Int) {
        rackFilter = false
        for i in 1...35 {
            if tileVector.vector[i] == 6 && rackVector.vector[i] == 3 {     // 2 sets of 3 flowers
                continue
            } else if handId == 2 && tileVector.vector[10] == 4 && tileVector.vector[35] == 4 && i == 10 {    // FFFF DDD 2023 DDD with Soaps on the rack
                continue
            } else if year == Year.y2025 && handId == ID_2025_222_555_DDDD && i == TileId.soap.rawValue && tileVector.vector[i] == 5 && rackVector.vector[i] == 4 {
                continue
            } else if year == Year.y2025 && handId == 15 {
                if filterFFFF_11_111_111_11(rackVector, index: i) == true {
                    rackFilter = true
                    break
                }
            } else if rackVector.vector[i] != 0 && rackVector.vector[i] != tileVector.vector[i] {
                rackFilter = true
                break
            }
        }
    }
    
    // Filter FFFF_11_111_111_11
    //
    // rackMap contains the array of tiles on the rack, with jokers exchanged for tiles
    // for example 4 one bams
    //     1,2,3,4,5,6,7,8,9,W, 1,2,3,4,5,6,7,8,9,G, 1,2,3,4,5,6,7,8,9,R, N,S,W,E,F,J
    // [0, 4,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0, 0,0,0,0,0,0]
    //
    // map.map contains the extact tils in a hand
    // for exmample FF 11 111 111 11
    //     1,2,3,4,5,6,7,8,9,W, 1,2,3,4,5,6,7,8,9,G, 1,2,3,4,5,6,7,8,9,R, N,S,W,E,F,J
    // [0, 4,0,0,0,0,0,0,0,0,0, 3,0,0,0,0,0,0,0,0,0, 3,0,0,0,0,0,0,0,0,0, 0,0,0,0,2,0]
    //
    // For this hand, if 4 tiles are the on rack remove the hand from matching hands
    // otherwise check that the right number of tiles are on the hand
    //
    func filterFFFF_11_111_111_11(_ rackVector: TileVector, index: Int) -> Bool {
        var filter = false
        if rackVector.vector[index] != 0 {
            if index < 35 && rackVector.vector[index] == 4 {
                filter = true
            } else if rackVector.vector[index] != tileVector.vector[index] {
                filter = true
            }
        }
        return filter
    }
    
    func areSinglesNormal(tileId: Int) -> Bool {
        var normalSingles = true
        if singles == Singles.normal {
            normalSingles = true
        } else if singles == tileId {
            normalSingles = false
        } else if singles == Singles.ff_2022_2022_2022 {
            normalSingles = tileId != 2 && tileId != 12 && tileId != 22 && tileId != 10
        }
        return normalSingles;
    }
}
