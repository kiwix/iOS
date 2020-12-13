//
//  ButtonProvider.swift
//  Kiwix
//
//  Created by Chris Li on 12/13/20.
//  Copyright © 2020 Chris Li. All rights reserved.
//

import UIKit
import WebKit
import RealmSwift

class ButtonProvider {
    unowned var webView: WKWebView
    weak var rootViewController: RootViewController? { didSet { setupTargetActions() } }
    
    private let chevronLeftButton = BarButton(imageName: "chevron.left")
    private let chevronRightButton = BarButton(imageName: "chevron.right")
    private let outlineButton = BarButton(imageName: "list.bullet")
    private let bookmarkButton = BookmarkButton(imageName: "star", bookmarkedImageName: "star.fill")
    private let diceButton = BarButton(imageName: "die.face.5")
    private let houseButton = BarButton(imageName: "house")
    private let libraryButton = BarButton(imageName: "folder")
    private let settingButton = BarButton(imageName: "gear")
    private let bookmarkLongPressGestureRecognizer = UILongPressGestureRecognizer()
    
    var navigationLeftButtons: [BarButton] { [chevronLeftButton, chevronRightButton, outlineButton, bookmarkButton] }
    var navigationRightButtons: [BarButton] { [diceButton, houseButton, libraryButton, settingButton] }
    var toolbarButtons: [BarButton] {
        if #available(iOS 14.0, *) {
            return [chevronLeftButton, chevronRightButton, outlineButton, bookmarkButton, diceButton, houseButton]
        } else {
            return [chevronLeftButton, chevronRightButton, outlineButton, bookmarkButton, libraryButton, settingButton]
        }
    }
    
    private let onDeviceZimFiles = Queries.onDeviceZimFiles()?.sorted(byKeyPath: "size", ascending: false)
    private var webViewURLObserver: NSKeyValueObservation?
    private var webViewCanGoBackObserver: NSKeyValueObservation?
    private var webViewCanGoForwardObserver: NSKeyValueObservation?
    private var bookmarksObserver: NotificationToken?
    private var onDeviceZimFilesObserver: NotificationToken?
    
    init(webView: WKWebView) {
        self.webView = webView
        
        bookmarkButton.addGestureRecognizer(bookmarkLongPressGestureRecognizer)
        
        webViewURLObserver = webView.observe(\.url, changeHandler: { webView, _ in
            guard let url = webView.url else { return }
            self.bookmarkButton.isBookmarked = BookmarkService().get(url: url) != nil
        })
        webViewCanGoBackObserver = webView.observe(\.canGoBack, options: [.initial, .new], changeHandler: { (webView, _) in
            self.chevronLeftButton.isEnabled = webView.canGoBack
        })
        webViewCanGoForwardObserver = webView.observe(\.canGoForward, options: [.initial, .new], changeHandler: { (webView, _) in
            self.chevronRightButton.isEnabled = webView.canGoForward
        })
        bookmarksObserver = BookmarkService.list()?.observe { change in
            guard case .update = change, let url = webView.url else { return }
            self.bookmarkButton.isBookmarked = BookmarkService().get(url: url) != nil
        }
        onDeviceZimFilesObserver = Queries.onDeviceZimFiles()?
            .sorted(byKeyPath: "size", ascending: false)
            .observe { change in
                switch change {
                case .initial, .update:
                    if #available(iOS 14.0, *) {
                        self.configureDiceButtonMenu()
                        self.configureHouseButtonMenu()
                    }
                default:
                    break
                }
            }
    }
    
    private func setupTargetActions() {
        guard let controller = rootViewController else { return }
        chevronLeftButton.addTarget(controller, action: #selector(controller.goBack), for: .touchUpInside)
        chevronRightButton.addTarget(controller, action: #selector(controller.goForward), for: .touchUpInside)
        outlineButton.addTarget(controller, action: #selector(controller.toggleOutline), for: .touchUpInside)
        bookmarkButton.addTarget(controller, action: #selector(controller.bookmarkButtonPressed), for: .touchUpInside)
        diceButton.addTarget(controller, action: #selector(controller.diceButtonTapped), for: .touchUpInside)
        houseButton.addTarget(controller, action: #selector(controller.houseButtonTapped), for: .touchUpInside)
        libraryButton.addTarget(controller, action: #selector(controller.openLibrary), for: .touchUpInside)
        settingButton.addTarget(controller, action: #selector(controller.openSettings), for: .touchUpInside)
        
        bookmarkLongPressGestureRecognizer.addTarget(controller, action: #selector(controller.bookmarkButtonLongPressed))
    }
    
    @available(iOS 14.0, *)
    private func configureDiceButtonMenu() {
        if let zimFiles = onDeviceZimFiles, !zimFiles.isEmpty {
            let items = zimFiles.map { zimFile in
                UIAction(title: zimFile.title) { _ in self.rootViewController?.openRandomPage(zimFileID: zimFile.id) }
            }
            diceButton.menu = UIMenu(children: Array(items))
        } else {
            let items = [UIAction(title: "No Zim File Available", attributes: .disabled, handler: { _ in })]
            diceButton.menu = UIMenu(children: items)
        }
    }
    
    @available(iOS 14.0, *)
    func configureHouseButtonMenu() {
        var items = [UIMenuElement]()
        if let zimFiles = onDeviceZimFiles, !zimFiles.isEmpty {
            items.append(UIMenu(options: .displayInline, children: zimFiles.map { zimFile in
                UIAction(title: zimFile.title) { _ in self.rootViewController?.openMainPage(zimFileID: zimFile.id) }
            }))
        } else {
            items.append(UIAction(title: "No Zim File Available", attributes: .disabled, handler: { _ in }))
        }
        if self.rootViewController?.traitCollection.horizontalSizeClass == .compact {
            items.append(UIMenu(options: .displayInline, children: [
                UIAction(title: "Open Library", image: UIImage(systemName: "books.vertical"), handler: { _ in self.rootViewController?.openLibrary() }),
                UIAction(title: "Open Settings", image: UIImage(systemName: "gear"), handler: { _ in self.rootViewController?.openSettings() }),
            ]))
        }
        houseButton.menu = UIMenu(children: items)
    }
}
