import Foundation

// Year and YearSegment enums for managing different game years
class Year {
    static let uninitialized = 0
    static let y2018 = 1
    static let y2019 = 2
    static let y2020 = 3
    static let y2017 = 4
    static let y2021 = 5
    static let y2022 = 6
    static let y2023 = 7
    static let y2024 = 8
    static let y2025 = 9
}

class YearSegment {
    static let segment2017 = 0
    static let segment2018 = 1
    static let segment2019 = 2
    static let segment2020 = 3
    static let segment2021 = 4
    static let segment2022 = 5
    static let segment2023 = 6
    static let segment2024 = 7
    static let segment2025 = 8
}

// TileStyle enum for managing different tile appearance styles
class TileStyle {
    static let classic = 0
    static let largeFont = 1
    static let designer = 2
    static let designerLargeFont = 3
    static let darkModeClassic = 4
    static let darkModeLargeFont = 5
    static let darkModeDesigner = 6
    static let darkModeDesignerLargeFont = 7
    static let solidClassic = 8
    static let solidLargeFont = 9
    static let solidDesigner = 10
    static let solidDesignerLargeFont = 11
    static let solidDarkModeClassic = 12
    static let solidDarkModeLargeFont = 13
    static let solidDarkModeDesigner = 14
    static let solidDarkModeDesignerLargeFont = 15
    static let argon = 16
    static let accessable = 17
}

// SortStyle enum for managing tile sorting preferences
class SortStyle {
    static let suits = 0
    static let num = 1
}

// BotDifficultyLevel enum for managing bot difficulty levels
enum BotDifficultyLevel: Int {
    case easy = 0
    case better = 1
}

class Settings {
    // Year and feature toggles
    var year = Year.uninitialized
    var enable2020 = false
    var enable2021 = false
    var enable2022 = false
    var enable2023 = false
    var enable2024 = false
    var enable2025 = false
    
    // Game behavior settings
    var winBotEnabled = false
    var botDifficultyLevel = BotDifficultyLevel.easy
    var botDetailsEnabled = false
    var enableOpenPlay = false
    var enableCharlestonCategories = false
    var disableAutomaj = false
    var disableTapToDiscard = false
    var shuffleWithSeed = false
    var shuffleSeed = ""
    var stopSorting = false  // Always defaults to false (sorting enabled)
    var initialSortDone = false
    var handsInitialSortDone = false
    var probabilisticDistribution = false
    
    // UI visibility settings
    var hideNewGameButton = false
    var hideHandHideButton = false
    var hideHandLockButtons = false
    var hideHelp = false
    var hideSortMessage = false
    var hideChallengeHand = false
    var lefty = false
    var blankTiles = false
    var expertMode = false
    
    // Tile appearance settings
    var crakTileStyle = TileStyle.classic
    var flowerTileStyle = TileStyle.classic
    var windTileStyle = TileStyle.classic
    var dotTileStyle = TileStyle.classic
    var bamTileStyle = TileStyle.classic
    var alternateRedDragon = false
    
    // Display filters
    let displayFilters = DisplayFilters()
    
    // User preferences
    var username = ""
    var emailAddress = ""
    
    
    func copy(_ copy: Settings) {
        year = copy.year
        enable2020 = copy.enable2020
        enable2021 = copy.enable2021
        enable2022 = copy.enable2022
        enable2023 = copy.enable2023
        enable2024 = copy.enable2024
        enable2025 = copy.enable2025
        
        winBotEnabled = copy.winBotEnabled
        botDifficultyLevel = copy.botDifficultyLevel
        botDetailsEnabled = copy.botDetailsEnabled
        enableOpenPlay = copy.enableOpenPlay
        enableCharlestonCategories = copy.enableCharlestonCategories
        disableAutomaj = copy.disableAutomaj
        disableTapToDiscard = copy.disableTapToDiscard
        shuffleWithSeed = copy.shuffleWithSeed
        shuffleSeed = copy.shuffleSeed
        stopSorting = copy.stopSorting
        initialSortDone = copy.initialSortDone
        handsInitialSortDone = copy.handsInitialSortDone
        probabilisticDistribution = copy.probabilisticDistribution
        
        hideNewGameButton = copy.hideNewGameButton
        hideHandHideButton = copy.hideHandHideButton
        hideHandLockButtons = copy.hideHandLockButtons
        hideHelp = copy.hideHelp
        hideSortMessage = copy.hideSortMessage
        lefty = copy.lefty
        blankTiles = copy.blankTiles
        expertMode = copy.expertMode
        
        crakTileStyle = copy.crakTileStyle
        flowerTileStyle = copy.flowerTileStyle
        windTileStyle = copy.windTileStyle
        dotTileStyle = copy.dotTileStyle
        bamTileStyle = copy.bamTileStyle
        alternateRedDragon = copy.alternateRedDragon
        
        displayFilters.copy(copy.displayFilters)
        
        username = copy.username
        emailAddress = copy.emailAddress
    }
    
    // Load settings from UserDefaults
    func loadSavedValues() {
        let defaults = UserDefaults.standard
        
        year = defaults.integer(forKey: "year")
        if year == Year.uninitialized { year = Year.y2017 }
        
        enable2020 = defaults.bool(forKey: "enable2020")
        enable2021 = defaults.bool(forKey: "enable2021")
        enable2022 = defaults.bool(forKey: "enable2022")
        enable2023 = defaults.bool(forKey: "enable2023")
        enable2024 = defaults.bool(forKey: "enable2024")
        enable2025 = defaults.bool(forKey: "enable2025")
        
        winBotEnabled = defaults.bool(forKey: "winBotEnable")
        
        // Load bot difficulty level, default to .easy if not set
        if defaults.object(forKey: "botDifficultyLevel") != nil {
            let rawValue = defaults.integer(forKey: "botDifficultyLevel")
            botDifficultyLevel = BotDifficultyLevel(rawValue: rawValue) ?? .easy
        } else {
            botDifficultyLevel = .easy
        }
        botDetailsEnabled = defaults.bool(forKey: "botDetailsEnabled")
        enableOpenPlay = defaults.bool(forKey: "enableOpenPlay")
        enableCharlestonCategories = defaults.bool(forKey: "enableCharlestonCategories")
        disableAutomaj = defaults.bool(forKey: "disableAutomaj")
        disableTapToDiscard = defaults.bool(forKey: "disableTapToDiscard")
        shuffleWithSeed = defaults.bool(forKey: "shuffleWithSeed")
        shuffleSeed = defaults.string(forKey: "shuffleSeed") ?? ""
        // stopSorting always defaults to false (sorting enabled) - not persisted
        initialSortDone = defaults.bool(forKey: "initialSortDone")
        handsInitialSortDone = defaults.bool(forKey: "handsInitialSortDone")
        probabilisticDistribution = defaults.bool(forKey: "probabilisticDistribution")
        
        hideNewGameButton = defaults.bool(forKey: "hideNewGameButton")
        hideHandHideButton = defaults.bool(forKey: "hideHandHideButton")
        hideHandLockButtons = defaults.bool(forKey: "hideHandLockButtons")
        hideHelp = defaults.bool(forKey: "hideHelp")
        hideSortMessage = defaults.bool(forKey: "hideSortMessage")
        hideChallengeHand = defaults.bool(forKey: "hideChallengeHand")
        lefty = defaults.bool(forKey: "lefty")
        blankTiles = defaults.bool(forKey: "blankTiles")
        expertMode = defaults.bool(forKey: "expertMode")
        
        crakTileStyle = defaults.integer(forKey: "crakTileStyle")
        flowerTileStyle = defaults.integer(forKey: "flowerTileStyle")
        windTileStyle = defaults.integer(forKey: "windTileStyle")
        dotTileStyle = defaults.integer(forKey: "dotTileStyle")
        bamTileStyle = defaults.integer(forKey: "bamTileStyle")
        alternateRedDragon = defaults.bool(forKey: "alternateRedDragon")
        
        // Load display filters
        displayFilters.hideYears = defaults.bool(forKey: "filterYears")
        displayFilters.hide2468 = defaults.bool(forKey: "filter2468")
        displayFilters.hideLikeNumbers = defaults.bool(forKey: "filterLikeNumbers")
        displayFilters.hideAdditionHands = defaults.bool(forKey: "filterAddition")
        displayFilters.hideQuints = defaults.bool(forKey: "filterQuints")
        displayFilters.hideRuns = defaults.bool(forKey: "filterRuns")
        displayFilters.hide13579 = defaults.bool(forKey: "filter13579")
        displayFilters.hideWinds = defaults.bool(forKey: "filterWinds")
        displayFilters.hide369 = defaults.bool(forKey: "filter369")
        displayFilters.hidePairs = defaults.bool(forKey: "filterPairs")
        displayFilters.hideConcealed = defaults.bool(forKey: "filterConcealed")
        
        username = defaults.string(forKey: "username") ?? ""
        emailAddress = defaults.string(forKey: "emailAddress") ?? ""
    }
    
    // Year segment conversion
    func getYearSegment() -> Int {
        switch year {
        case Year.y2017: return YearSegment.segment2017
        case Year.y2018: return YearSegment.segment2018
        case Year.y2019: return YearSegment.segment2019
        case Year.y2020: return YearSegment.segment2020
        case Year.y2021: return YearSegment.segment2021
        case Year.y2022: return YearSegment.segment2022
        case Year.y2023: return YearSegment.segment2023
        case Year.y2024: return YearSegment.segment2024
        case Year.y2025: return YearSegment.segment2025
        default: return YearSegment.segment2017
        }
    }
    
    func setYearSegment(segment: Int) {
        switch segment {
        case YearSegment.segment2017: year = Year.y2017
        case YearSegment.segment2018: year = Year.y2018
        case YearSegment.segment2019: year = Year.y2019
        case YearSegment.segment2020: year = Year.y2020
        case YearSegment.segment2021: year = Year.y2021
        case YearSegment.segment2022: year = Year.y2022
        case YearSegment.segment2023: year = Year.y2023
        case YearSegment.segment2024: year = Year.y2024
        case YearSegment.segment2025: year = Year.y2025
        default: year = Year.y2017
        }
    }
    
    // Toggle methods for filters
    func toggleYearsFilter() {
        displayFilters.hideYears = !displayFilters.hideYears
        UserDefaults.standard.set(displayFilters.hideYears, forKey: "filterYears")
    }
    
    func toggle2468Filter() {
        displayFilters.hide2468 = !displayFilters.hide2468
        UserDefaults.standard.set(displayFilters.hide2468, forKey: "filter2468")
    }
    
    func toggleLikeNumbersFilter() {
        displayFilters.hideLikeNumbers = !displayFilters.hideLikeNumbers
        UserDefaults.standard.set(displayFilters.hideLikeNumbers, forKey: "filterLikeNumbers")
    }
    
    func toggleAdditionFilter() {
        displayFilters.hideAdditionHands = !displayFilters.hideAdditionHands
        UserDefaults.standard.set(displayFilters.hideAdditionHands, forKey: "filterAddition")
    }
    
    func toggleQuintFilter() {
        displayFilters.hideQuints = !displayFilters.hideQuints
        UserDefaults.standard.set(displayFilters.hideQuints, forKey: "filterQuints")
    }
    
    func toggleRunsFilter() {
        displayFilters.hideRuns = !displayFilters.hideRuns
        UserDefaults.standard.set(displayFilters.hideRuns, forKey: "filterRuns")
    }
    
    func toggle13579Filter() {
        displayFilters.hide13579 = !displayFilters.hide13579
        UserDefaults.standard.set(displayFilters.hide13579, forKey: "filter13579")
    }
    
    func toggleConcealedFilter() {
        displayFilters.hideConcealed = !displayFilters.hideConcealed
        UserDefaults.standard.set(displayFilters.hideConcealed, forKey: "filterConcealed")
    }
    
    func toggleWindsFilter() {
        displayFilters.hideWinds = !displayFilters.hideWinds
        UserDefaults.standard.set(displayFilters.hideWinds, forKey: "filterWinds")
    }
    
    func toggle369Filter() {
        displayFilters.hide369 = !displayFilters.hide369
        UserDefaults.standard.set(displayFilters.hide369, forKey: "filter369")
    }
    
    func togglePairFilter() {
        displayFilters.hidePairs = !displayFilters.hidePairs
        UserDefaults.standard.set(displayFilters.hidePairs, forKey: "filterPairs")
    }
    
    func hasDisabledFilters() -> Bool {
        return displayFilters.hideYears ||
               displayFilters.hide2468 ||
               displayFilters.hideLikeNumbers ||
               displayFilters.hideAdditionHands ||
               displayFilters.hideQuints ||
               displayFilters.hideRuns ||
               displayFilters.hide13579 ||
               displayFilters.hideConcealed ||
               displayFilters.hideWinds ||
               displayFilters.hide369 ||
               displayFilters.hidePairs
    }
    
    func toggleChallengeHand() {
        hideChallengeHand = !hideChallengeHand
        UserDefaults.standard.set(hideChallengeHand, forKey: "hideChallengeHand")
    }
    
    // Toggle methods for other settings
    func toggleWinBot() {
        winBotEnabled = !winBotEnabled
        UserDefaults.standard.set(winBotEnabled, forKey: "winBotEnable")
    }
    
    // Bot difficulty level methods
    func setBotDifficultyLevel(_ level: BotDifficultyLevel) {
        botDifficultyLevel = level
        UserDefaults.standard.set(botDifficultyLevel.rawValue, forKey: "botDifficultyLevel")
    }
    
    func setBotDetailsEnabled(_ enabled: Bool) {
        botDetailsEnabled = enabled
        UserDefaults.standard.set(botDetailsEnabled, forKey: "botDetailsEnabled")
    }
    
    func setOpenPlay(_ enabled: Bool) {
        enableOpenPlay = enabled
        UserDefaults.standard.set(enableOpenPlay, forKey: "enableOpenPlay")
    }
    
    func setCharlestonCategories(_ enabled: Bool) {
        enableCharlestonCategories = enabled
        UserDefaults.standard.set(enableCharlestonCategories, forKey: "enableCharlestonCategories")
    }
    
    func setDisableTapToDiscard(_ disabled: Bool) {
        disableTapToDiscard = disabled
        UserDefaults.standard.set(disableTapToDiscard, forKey: "disableTapToDiscard")
    }
    
    func setDisableAutomaj(_ disabled: Bool) {
        disableAutomaj = disabled
        UserDefaults.standard.set(disableAutomaj, forKey: "disableAutomaj")
    }
    
    func setHideNewGameButton(_ hidden: Bool) {
        hideNewGameButton = hidden
        UserDefaults.standard.set(hideNewGameButton, forKey: "hideNewGameButton")
    }
    
    func setHideHandHideButton(_ hidden: Bool) {
        hideHandHideButton = hidden
        UserDefaults.standard.set(hideHandHideButton, forKey: "hideHandHideButton")
    }
    
    func setHideHandLockButtons(_ hidden: Bool) {
        hideHandLockButtons = hidden
        UserDefaults.standard.set(hideHandLockButtons, forKey: "hideHandLockButtons")
    }
    
    func setHideHelp(_ hidden: Bool) {
        hideHelp = hidden
        UserDefaults.standard.set(hideHelp, forKey: "hideHelp")
    }
    
    func setHideChallengeHand(_ hidden: Bool) {
        hideChallengeHand = hidden
        UserDefaults.standard.set(hideChallengeHand, forKey: "hideChallengeHand")
    }
    
    func setLefty(_ leftHanded: Bool) {
        lefty = leftHanded
        UserDefaults.standard.set(lefty, forKey: "lefty")
    }
    
    func setBlankTiles(_ enabled: Bool) {
        blankTiles = enabled
        UserDefaults.standard.set(blankTiles, forKey: "blankTiles")
    }
    
    func setExpertMode(_ enabled: Bool) {
        expertMode = enabled
        UserDefaults.standard.set(expertMode, forKey: "expertMode")
    }
    
    func setShuffleWithSeed(_ enabled: Bool) {
        shuffleWithSeed = enabled
        UserDefaults.standard.set(shuffleWithSeed, forKey: "shuffleWithSeed")
    }
    
    func setShuffleSeed(_ seed: String) {
        shuffleSeed = seed
        UserDefaults.standard.set(shuffleSeed, forKey: "shuffleSeed")
    }
    
    func setStopSorting(_ stop: Bool) {
        stopSorting = stop
        // Don't persist stopSorting - always defaults to false on restart
    }
    
    func resetInitialSort() {
        initialSortDone = false
        handsInitialSortDone = false
        UserDefaults.standard.set(initialSortDone, forKey: "initialSortDone")
        UserDefaults.standard.set(handsInitialSortDone, forKey: "handsInitialSortDone")
    }
    
    func setDotTileStyle(style: Int) {
        dotTileStyle = style
        UserDefaults.standard.set(dotTileStyle, forKey: "dotTileStyle")
    }
    
    func setAlternateRedDragon(_ alternate: Bool) {
        alternateRedDragon = alternate
        UserDefaults.standard.set(alternateRedDragon, forKey: "alternateRedDragon")
    }
    
    // Check if leaderboard is supported
    func isLeaderboardSupported() -> Bool {
        if #available(iOS 15.0, *) {
            return year == Year.y2024 || year == Year.y2025
        } else {
            return false
        }
    }
    
    // Check if tile style is designer
    func isTileDesigner() -> Bool {
        switch(dotTileStyle) {
        case TileStyle.classic: return false
        case TileStyle.largeFont: return false
        case TileStyle.designer: return true
        case TileStyle.designerLargeFont: return true
        case TileStyle.darkModeClassic: return false
        case TileStyle.darkModeLargeFont: return false
        case TileStyle.darkModeDesigner: return true
        case TileStyle.darkModeDesignerLargeFont: return true
        case TileStyle.solidClassic: return false
        case TileStyle.solidLargeFont: return false
        case TileStyle.solidDesigner: return true
        case TileStyle.solidDesignerLargeFont: return true
        case TileStyle.solidDarkModeClassic: return false
        case TileStyle.solidDarkModeLargeFont: return false
        case TileStyle.solidDarkModeDesigner: return true
        case TileStyle.solidDarkModeDesignerLargeFont: return true
        case TileStyle.argon: return true
        case TileStyle.accessable: return true
        default: return false
        }
    }
    
    func getYearText() -> String {
        switch year {
        case Year.y2017: return "2017"
        case Year.y2018: return "2018"
        case Year.y2019: return "2019"
        case Year.y2020: return "2020"
        case Year.y2021: return "2021"
        case Year.y2022: return "2022"
        case Year.y2023: return "2023"
        case Year.y2024: return "2024"
        case Year.y2025: return "2025"
        default: return ""
        }
    }
    
    func setCrakTileStyle(style: Int) {
        crakTileStyle = style
        UserDefaults.standard.set(crakTileStyle, forKey: "crakTileStyle")
    }
    
    func setFlowerTileStyle(style: Int) {
        flowerTileStyle = style
        UserDefaults.standard.set(flowerTileStyle, forKey: "flowerTileStyle")
    }
    
    func setWindTileStyle(style: Int) {
        windTileStyle = style
        UserDefaults.standard.set(windTileStyle, forKey: "windTileStyle")
    }
    
    func setBamTileStyle(style: Int) {
        bamTileStyle = style
        UserDefaults.standard.set(bamTileStyle, forKey: "bamTileStyle")
    }
    
    func setUsername(_ username: String) {
        self.username = username
        UserDefaults.standard.set(self.username, forKey: "username")
    }
    
    func setEmailAddress(_ email: String) {
        emailAddress = email
        UserDefaults.standard.set(emailAddress, forKey: "emailAddress")
    }
    
    func setProbabilisticDistribution(_ enabled: Bool) {
        probabilisticDistribution = enabled
        UserDefaults.standard.set(probabilisticDistribution, forKey: "probabilisticDistribution")
    }
}

// Move DisplayFilters class here
class DisplayFilters {
    var hideYears = false
    var hide2468 = false
    var hideLikeNumbers = false
    var hideAdditionHands = false
    var hideQuints = false
    var hideRuns = false
    var hide13579 = false
    var hideWinds = false
    var hide369 = false
    var hidePairs = false
    var hideConcealed = false
    
    init() {}
    
    func copy(_ copy: DisplayFilters) {
        hideYears = copy.hideYears
        hide2468 = copy.hide2468
        hideLikeNumbers = copy.hideLikeNumbers
        hideAdditionHands = copy.hideAdditionHands
        hideQuints = copy.hideQuints
        hideRuns = copy.hideRuns
        hide13579 = copy.hide13579
        hideWinds = copy.hideWinds
        hide369 = copy.hide369
        hidePairs = copy.hidePairs
        hideConcealed = copy.hideConcealed
    }

    // Determines whether a TileSet should be filtered out given current display filter settings
    // rackCount allows applying the concealed filter rule when the rack isn't full
    func isHidden(tileSet: TileSet, rackCount: Int) -> Bool {
        var filterOut = false
        if hideConcealed && tileSet.concealed {
            filterOut = true
        }
        if (rackCount > 0) && (rackCount < 14) && tileSet.concealed {
            filterOut = true
        }
        if hideQuints && (tileSet.family == Family.quints) {
            filterOut = true
        }
        if hidePairs && (tileSet.family == Family.pairs) {
            filterOut = true
        }
        if hideYears && (tileSet.family == Family.year) {
            filterOut = true
        }
        if hideWinds && (tileSet.family == Family.winds) {
            filterOut = true
        }
        if hide2468 && (tileSet.family == Family.f2468) {
            filterOut = true
        }
        if hideLikeNumbers && (tileSet.family == Family.likeNumbers) {
            filterOut = true
        }
        if hideAdditionHands && (tileSet.family == Family.addition) {
            filterOut = true
        }
        if hideRuns && (tileSet.family == Family.run) {
            filterOut = true
        }
        if hide13579 && (tileSet.family == Family.f13579) {
            filterOut = true
        }
        if hide369 && (tileSet.family == Family.f369) {
            filterOut = true
        }
        return filterOut
    }
}

