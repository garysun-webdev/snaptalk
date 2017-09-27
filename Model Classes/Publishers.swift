//
//  Publishers.swift
//  PrettyApple
//
//  Created by Duc Tran on 7/21/15.
//  Copyright © 2015 Developer Inspirus. All rights reserved.
//

import UIKit

class Publishers
{
    fileprivate var publishers = [Publisher]()
    fileprivate var immutablePublishers = [Publisher]()
    fileprivate var sections = [String]()
    
    // MARK: - Public
    
    var numberOfPublishers: Int {
        return publishers.count
    }
    
    var numberOfSections: Int {
        return sections.count
    }
    
    init()
    {
        publishers = createPublishers()
        immutablePublishers = publishers
        sections = ["My Favorites", "Politics", "Travel", "Technology"]
    }
    
    func deleteItemsAtIndexPaths(_ indexPaths: [IndexPath])
    {
        var indexes = [Int]()
        for indexPath in indexPaths {
            indexes.append(absoluteIndexForIndexPath(indexPath))
        }
        var newPublishers = [Publisher]()
        for (index, publisher) in publishers.enumerated() {
            if !indexes.contains(index) {
                newPublishers.append(publisher)
            }
        }
        publishers = newPublishers
    }
    
    func movePublisherFromIndexPath(_ indexPath: IndexPath, toIndexPath newIndexPath: IndexPath) {
        if indexPath != newIndexPath {
            let index = absoluteIndexForIndexPath(indexPath)
            let publisher = publishers[index]
            publisher.section = sections[(newIndexPath as NSIndexPath).section]
            let newIndex = absoluteIndexForIndexPath(newIndexPath)
            publishers.remove(at: index)
            publishers.insert(publisher, at: newIndex)
        }
    }
    
    func indexPathForNewRandomPublisher() -> IndexPath
    {
        let index = Int(arc4random_uniform(UInt32(immutablePublishers.count)))
        let publisherToCopy = immutablePublishers[index]
        let newPublisher = Publisher(copies: publisherToCopy)
        publishers.append(newPublisher)
        publishers.sort { $0.section < $1.section }
        return indexPathForPublisher(newPublisher)
    }
    
    func indexPathForPublisher(_ publisher: Publisher) -> IndexPath
    {
        let section = sections.index(of: publisher.section)
        var item = 0
        for (index, currentPublisher) in publishersForSection(section!).enumerated() {
            if currentPublisher === publisher {
                item = index
                break
            }
        }
        return IndexPath(item: item, section: section!)
    }
    
    func numberOfPublishersInSection(_ index: Int) -> Int {
        let publishers = publishersForSection(index)
        return publishers.count
    }
    
    func publisherForItemAtIndexPath(_ indexPath: IndexPath) -> Publisher? {
        if (indexPath as NSIndexPath).section > 0 {
            let publishers = publishersForSection((indexPath as NSIndexPath).section)
            return publishers[(indexPath as NSIndexPath).item]
        } else {
            return publishers[(indexPath as NSIndexPath).item]
        }
    }
    
    func titleForSectionAtIndexPath(_ indexPath: IndexPath) -> String?
    {
        if (indexPath as NSIndexPath).section < sections.count {
            return sections[(indexPath as NSIndexPath).section]
        }
        return nil
    }
    
    // MARK: - Private
    
    fileprivate func createPublishers() -> [Publisher]
    {
        var newPublishers = [Publisher]()
        newPublishers += MyFavorites.publishers()
        newPublishers += Politics.publishers()
        newPublishers += Travel.publishers()
        newPublishers += Technology.publishers()
        return newPublishers
    }
    
    fileprivate func absoluteIndexForIndexPath(_ indexPath: IndexPath) -> Int
    {
        var index = 0
        for i in 0..<(indexPath as NSIndexPath).section {
            index += numberOfPublishersInSection(i)
        }
        index += (indexPath as NSIndexPath).item
        return index
    }
    
    fileprivate func publishersForSection(_ index: Int) -> [Publisher] {
        let section = sections[index]
        let publishersInSection = publishers.filter {
            (publisher: Publisher) -> Bool in return publisher.section == section
        }
        return publishersInSection
    }
}

class MyFavorites
{
    class func publishers() -> [Publisher]
    {
        var publishers = [Publisher]()
        publishers.append(Publisher(title: "TIME", url: "http://time.com", image: UIImage(named: "TIME")!, section: "My Favorites"))
        publishers.append(Publisher(title: "TED", url: "https://www.ted.com", image: UIImage(named: "TED")!, section: "My Favorites"))
        publishers.append(Publisher(title: "Re/code", url: "http://recode.net", image: UIImage(named: "Recode")!, section: "My Favorites"))
        publishers.append(Publisher(title: "WIRED", url: "http://www.wired.com", image: UIImage(named: "WIRED")!, section: "My Favorites"))
        return publishers
    }
}

class Politics
{
    class func publishers() -> [Publisher]
    {
        var publishers = [Publisher]()
        publishers.append(Publisher(title: "The Atlantic", url: "http://www.theatlantic.com", image: UIImage(named: "The Atlantic")!, section: "Politics"))
        publishers.append(Publisher(title: "The Hill", url: "http://thehill.com", image: UIImage(named: "The Hill")!, section: "Politics"))
        publishers.append(Publisher(title: "Daily Intelligencer", url: "http://nymag.com/daily/intelligencer/", image: UIImage(named: "Daily Intelligencer")!, section: "Politics"))
        publishers.append(Publisher(title: "Vanity Fair", url: "http://recode.net", image: UIImage(named: "Vanity Fair")!, section: "Politics"))
        publishers.append(Publisher(title: "The Huffington Post", url: "http://www.huffingtonpost.com", image: UIImage(named: "The Huffington Post")!, section: "Politics"))
        return publishers
    }
}

class Travel
{
    class func publishers() -> [Publisher]
    {
        var publishers = [Publisher]()
        publishers.append(Publisher(title: "AFAR", url: "http://www.afar.com", image: UIImage(named: "AFAR")!, section: "Travel"))
        publishers.append(Publisher(title: "The New York Times", url: "http://www.nytimes.com", image: UIImage(named: "The New York Times")!, section: "Travel"))
        publishers.append(Publisher(title: "Men’s Journal", url: "http://www.mensjournal.com", image: UIImage(named: "Men’s Journal")!, section: "Travel"))
        publishers.append(Publisher(title: "Smithsonian", url: "http://www.smithsonianmag.com/?no-ist", image: UIImage(named: "Smithsonian")!, section: "Travel"))
        publishers.append(Publisher(title: "Wallpaper", url: "http://www.wallpaper.com", image: UIImage(named: "Wallpaper")!, section: "Travel"))
        publishers.append(Publisher(title: "Sunset", url: "http://www.sunset.com", image: UIImage(named: "Sunset")!, section: "Travel"))
        return publishers
    }
}

class Technology
{
    class func publishers() -> [Publisher]
    {
        var publishers = [Publisher]()
        publishers.append(Publisher(title: "WIRED", url: "http://www.wired.com", image: UIImage(named: "WIRED")!, section: "Technology"))
        publishers.append(Publisher(title: "Quartz", url: "http://qz.com", image: UIImage(named: "Quartz")!, section: "Technology"))
        publishers.append(Publisher(title: "Daring Fireball", url: "http://daringfireball.net", image: UIImage(named: "Daring Fireball")!, section: "Technology"))
        publishers.append(Publisher(title: "MIT Technology Review", url: "http://www.technologyreview.com", image: UIImage(named: "MIT Technology Review")!, section: "Technology"))
        return publishers
    }
}















