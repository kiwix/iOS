//
//  SearchNoTextController.swift
//  Kiwix
//
//  Created by Chris Li on 1/19/18.
//  Copyright © 2018 Chris Li. All rights reserved.
//

import UIKit
import CoreData

class SearchNoTextController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let tableView = UITableView(frame: .zero, style: .grouped)
    
    override func loadView() {
        view = tableView
        collectionView.delegate = self
        collectionView.dataSource = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LibraryBookCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - UICollectionViewDataSource & Delegate
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultController.sections?.first?.numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    // MARK: - UITableViewDataSource & Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultController.sections?.first?.numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! LibraryBookCell
        
        configure(bookCell: cell, indexPath: indexPath)
        return cell
    }
    
    func configure(bookCell cell: LibraryBookCell, indexPath: IndexPath, animated: Bool = false) {
        let book = fetchedResultController.object(at: IndexPath(item: indexPath.item, section: 0))
        cell.titleLabel.text = book.title
        cell.subtitleLabel.text = [book.fileSizeDescription, book.dateDescription, book.articleCountDescription].flatMap({$0}).joined(separator: ", ")
        cell.logoView.image = UIImage(data: book.favIcon ?? Data())
        cell.accessoryType = .checkmark
    }
    
    // MARK: - NSFetchedResultsController
    private let managedObjectContext = CoreDataContainer.shared.viewContext
    private lazy var fetchedResultController: NSFetchedResultsController<Book> = {
        let fetchRequest = Book.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Book.title, ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "stateRaw == %d", BookState.local.rawValue)
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: self.managedObjectContext,
                                                    sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        try? controller.performFetch()
        return controller as! NSFetchedResultsController<Book>
    }()
}
