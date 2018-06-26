//
//  AppDelegate.swift
//  PizzaWallet
//
//  Created by Elina Talashka on 20/06/2018.
//  Copyright © 2018 Elina Talashka. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        do {
            _ = try Realm()
        } catch {
            print("Error initializing new realm \(error)")
        }
        
        selectInitialView()
        
        return true
    }
    
    func selectInitialView() {
        var members: Results<Member>?
        let realm = try! Realm()
        members = realm.objects(Member.self)
        var membersList : [String] = []
        membersList = (members?.map({$0.name}))!
        
        // Changing initial view based on data from DB -------------------------
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        if (membersList).isEmpty {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "WelcomeViewController")
            self.window?.rootViewController = initialViewController
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "ViewController")
            self.window?.rootViewController = initialViewController
        }
        
        self.window?.makeKeyAndVisible()
    }

    func applicationWillResignActive(_ application: UIApplication) {

    }

    func applicationDidEnterBackground(_ application: UIApplication) {

    }

    func applicationWillEnterForeground(_ application: UIApplication) {

    }

    func applicationDidBecomeActive(_ application: UIApplication) {

    }

    func applicationWillTerminate(_ application: UIApplication) {

    }


}

