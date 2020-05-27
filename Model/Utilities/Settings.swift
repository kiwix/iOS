//
//  Settings.swift
//  Kiwix
//
//  Created by Chris Li on 6/20/18.
//  Copyright © 2018 Chris Li. All rights reserved.
//

import Defaults
import SwiftyUserDefaults

extension DefaultsKeys {
    static let recentSearchTexts = DefaultsKey<[String]>("recentSearchTexts", defaultValue: [])
    static let backupDocumentDirectory = DefaultsKey<Bool>("backupDocumentDirectory", defaultValue: false)
    static let webViewZoomScale = DefaultsKey<Double?>("webViewZoomScale")
    static let externalLinkLoadingPolicy = DefaultsKey<Int>("externalLinkLoadingPolicy", defaultValue: 0)
    
    static let searchResultExcludeSnippet = DefaultsKey<Bool>("searchResultExcludeSnippet", defaultValue: false)
    static let searchResultSnippetMode = DefaultsKey<String>(
        "searchResultSnippetMode", defaultValue: Defaults[.searchResultExcludeSnippet]
            ? SearchResultSnippetMode.disabled .rawValue : SearchResultSnippetMode.matches.rawValue
    )
    
    static let libraryLastRefreshTime = DefaultsKey<Date?>("libraryLastRefreshTime")
    static let libraryHasShownLanguageFilterAlert = DefaultsKey<Bool>("libraryHasShownLanguageFilterAlert", defaultValue: false)
    static let libraryLanguageSortingMode = DefaultsKey<String>("libraryLanguageSortingMode", defaultValue: LibraryLanguageController.SortingMode.alphabetically.rawValue)
    static let libraryFilterLanguageCodes = DefaultsKey<[String]>("libraryFilterLanguageCodes", defaultValue: [])
    static let libraryAutoRefresh = DefaultsKey<Bool>("libraryAutoRefresh", defaultValue: true)
}

extension Defaults.Keys {
    // UI
    static let sideBarDisplayMode = Key<SideBarDisplayMode>("sideBarDisplayMode", default: .automatic)
    
    // search
    static let searchResultSnippetMode = Key<SearchResultSnippetMode>("searchResultSnippetMode", default: .matches)
    
    // library
    static let libraryFilterLanguageCodes = Key<[String]>("libraryFilterLanguageCodes", default: [])
}

extension Defaults {
    static subscript(key: Key<SideBarDisplayMode>) -> SideBarDisplayMode {
        get { SideBarDisplayMode(rawValue: key.suite.string(forKey: key.name) ?? "") ?? key.defaultValue }
        set { key.suite.set(newValue.rawValue, forKey: key.name) }
    }
    
    static subscript(key: Key<SearchResultSnippetMode>) -> SearchResultSnippetMode {
        get { SearchResultSnippetMode(rawValue: key.suite.string(forKey: key.name) ?? "") ?? key.defaultValue }
        set { key.suite.set(newValue.rawValue, forKey: key.name) }
    }
}
