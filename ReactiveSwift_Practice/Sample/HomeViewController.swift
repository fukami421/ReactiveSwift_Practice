//
//  HomeViewController.swift
//  ReactiveSwift_Practice
//
//  Created by 深見龍一 on 2020/02/02.
//  Copyright © 2020 深見龍一. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

class HomeViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    private var viewModel: HomeViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindViewModel()
        self.tableView.dataSource = self
    }
    
    private func bindViewModel()
    {
        let searchStrings = self.searchBar.reactive.continuousTextValues
        self.viewModel = HomeViewModel(searchStrings: searchStrings)
        
        // viewModelの値をtitleにbind
        self.reactive.title <~ self.viewModel.searchStrings
        
        self.viewModel.trackChangeset.producer.startWithValues { edits in
                    self.tableView.update(with: edits)
        }
    }
}

extension HomeViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "myCell")
        let home = self.viewModel.tracks[indexPath.row]
        cell.textLabel?.text = home.trackName
        cell.textLabel?.textColor = .black
        cell.detailTextLabel?.text = home.artistName
        return cell
    }
}
