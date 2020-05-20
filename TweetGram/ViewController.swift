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
    
    var isLoggedIn = false
    
    let oauthswift = OAuth1Swift(
        consumerKey: "",
        consumerSecret: "",
        requestTokenUrl: "https://api.twitter.com/oauth/request_token",
        authorizeUrl: "https://api.twitter.com/oauth/authorize",
        accessTokenUrl: "https://api.twitter.com/oauth/access_token")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLogin()
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

