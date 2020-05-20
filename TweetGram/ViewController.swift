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

class ViewController: NSViewController {

    @IBOutlet weak var loginLogoutButton: NSButton!
    
    let oauthswift = OAuth1Swift(
        consumerKey: "qMBDCwcGA0SJmHddUmBmA",
        consumerSecret: "OP9yTz5d0VEjAdT34clC1cXetgxKlWBTQEwU2HeZWI",
        requestTokenUrl: "https://api.twitter.com/oauth/request_token",
        authorizeUrl: "https://api.twitter.com/oauth/authorize",
        accessTokenUrl: "https://api.twitter.com/oauth/access_token")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logIn()
    }

    func logIn() {
        _ = oauthswift.authorize(withCallbackURL: "TweetGram://") {
             result in
                switch result {
                    case .success(let (_, _, _)):
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
                
                var imageURLs : [String] = []
                
                for (_, tweetJson):(String, JSON) in json {
                    let mediaJsonArray = tweetJson["entities"]["media"]
                    for (_,mediaJson):(String, JSON) in mediaJsonArray {
                        let imageURL = mediaJson["media_url_https"]
                        imageURLs.append(imageURL.stringValue)
                    }
                }
                
                print(imageURLs)
                
            case .failure(let error):
                print(error)
            }
        }
    }

    @IBAction func loginLogoutClicked(_ sender: Any) {
        
    }
    
}

