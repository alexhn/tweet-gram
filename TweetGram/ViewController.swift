//
//  ViewController.swift
//  TweetGram
//
//  Created by Aleksandr Nikiforov on 18.05.2020.
//  Copyright © 2020 Aleksandr Nikiforov. All rights reserved.
//

import Cocoa
import OAuthSwift
import SwiftyJSON
import Kingfisher

class ViewController: NSViewController, NSCollectionViewDataSource, NSCollectionViewDelegate {
    
    @IBOutlet weak var loginLogoutButton: NSButton!
    
    var isLoggedIn = false
    
    @IBOutlet weak var collectionView: NSCollectionView!
    
    var imageURLs : [String] = []
    
    let oauthswift = OAuth1Swift(
        consumerKey: "",
        consumerSecret: "",
        requestTokenUrl: "https://api.twitter.com/oauth/request_token",
        authorizeUrl: "https://api.twitter.com/oauth/authorize",
        accessTokenUrl: "https://api.twitter.com/oauth/access_token")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = NSCollectionViewFlowLayout()
        layout.itemSize = NSSize(width: 100, height: 100)
        layout.sectionInset = NSEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumLineSpacing = 5.0
        layout.minimumInteritemSpacing = 5.0
        collectionView.collectionViewLayout = layout
        collectionView.dataSource = self
        collectionView.delegate = self
        checkLogin()
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLs.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TweetGramItem"), for: indexPath)
        let url = URL(string: imageURLs[indexPath.item])
        item.imageView?.kf.setImage(with: url)
        return item
    }
    
    func checkLogin() {
        if let oauthToken = UserDefaults.standard.string(forKey: "oauthToken") {
            if let oauthTokenSecret = UserDefaults.standard.string(forKey: "oauthTokenSecret") {
                oauthswift.client.credential.oauthToken = oauthToken
                oauthswift.client.credential.oauthTokenSecret = oauthTokenSecret
                loginLogoutButton.title = "Logout"
                isLoggedIn = true
                getImages()
            }
        }
    }

    func logIn() {
        _ = oauthswift.authorize(withCallbackURL: "TweetGram://") {
             result in
                switch result {
                    case .success(let (credential, _, _)):
                        let oauthToken = credential.oauthToken
                        let oauthTokenSecret = credential.oauthTokenSecret
                        UserDefaults.standard.set(oauthToken, forKey: "oauthToken")
                        UserDefaults.standard.set(oauthTokenSecret, forKey: "oauthTokenSecret")
                        UserDefaults.standard.synchronize()
                        self.isLoggedIn = true
                        self.loginLogoutButton.title = "Logout"
                        self.getImages()
                    case .failure(let error):
                      print(error.localizedDescription)
                }
        }
    }
    
    func getImages() {
        let _ = oauthswift.client.get("https://api.twitter.com/1.1/statuses/home_timeline.json",parameters: ["tweet_mode":"extended"]) { result in
            switch result {
            case .success(let response):
                let json = JSON(response.data)
                
                for (_, tweetJson):(String, JSON) in json {
                    let mediaJsonArray = tweetJson["entities"]["media"]
                    for (_,mediaJson):(String, JSON) in mediaJsonArray {
                        let imageURL = mediaJson["media_url_https"]
                        self.imageURLs.append(imageURL.stringValue)
                    }
                }
                
                print(self.imageURLs)
                
                self.collectionView.reloadData()
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func logOut() {
        isLoggedIn = false
        loginLogoutButton.title = "Login"
        UserDefaults.standard.removeObject(forKey: "oauthToken")
        UserDefaults.standard.removeObject(forKey: "oauthTokenSecret")
    }

    @IBAction func loginLogoutClicked(_ sender: Any) {
        if isLoggedIn {
            logOut()
        } else {
            logIn()
        }
    }
    
}

