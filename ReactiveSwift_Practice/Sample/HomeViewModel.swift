//
//  HomeViewModel.swift
//  ReactiveSwift_Practice
//
//  Created by 深見龍一 on 2020/02/02.
//  Copyright © 2020 深見龍一. All rights reserved.
//

import Foundation
import ReactiveSwift
import ReactiveCocoa
import Changeset

class HomeViewModel{
    var tracks: [Home]
    {
        didSet {
            self.trackChangeset.value = Changeset.edits(
            from: oldValue,
            to: tracks)
        }
    }
    var searchStrings: Signal<String?, Never>

    let trackChangeset = MutableProperty([Changeset<[Home]>.Edit]())
    
    init(searchStrings: Signal<String?, Never>)
    {
        self.tracks = []
        self.searchStrings = searchStrings
        
        let searchResults = searchStrings
            .flatMap(.latest) { (query: String?) -> SignalProducer<(Data, URLResponse), Error> in
                let request = self.makeSearchRequest(escapedQuery: query)
                return URLSession.shared.reactive
                    .data(with: request!)
                    .retry(upTo: 2)
                    .flatMapError { error in
                        print("Network error occurred: \(error)")
                        return SignalProducer.empty
                }
            }
            .map { (data, response) -> [Home] in
                return self.searchResults(from: data)
            }
            .observe(on: UIScheduler())

        searchResults.observe { event in
            switch event {
            case let .value(results):
                self.tracks = results
                print(self.tracks.count)
            case let .failed(error):
                print("Search error: \(error)")

            case .completed, .interrupted:
                break
            }
        }
    }
    
    private func makeSearchRequest(escapedQuery: String?) -> URLRequest? {
        if var urlComponents = URLComponents(string: "https://itunes.apple.com/search"), let escapedQuery = escapedQuery {
            urlComponents.query = "media=music&entity=song&term=\(escapedQuery)"
            guard let url = urlComponents.url else { return nil }

            return URLRequest(url: url)
        } else {
            return nil
        }

    }

    private func searchResults(from json: Data) -> [Home] {
        var resultTracks = [Home]()

        do {
            guard let json = try JSONSerialization.jsonObject(with: json, options: []) as? [String: Any] else {return []}

            if let results = json["results"] as? [Dictionary<String, Any>] {
                _ = results.map({ dict in
                    let home = Home(dict: dict)
                    resultTracks.append(home)
                })
            }

        } catch let jsonErr {
            print("Error serializing json: ", jsonErr)
        }

        return resultTracks
    }
}
