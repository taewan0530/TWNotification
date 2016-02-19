//
//  ViewController.swift
//  TWPushNotification
//
//  Created by kimtaewan on 2016. 2. 19..
//  Copyright © 2016년 carq. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func didTapOpen(sender: AnyObject) {
        TWNotification.make(nil, title: "App", message: "가나다라", timeAgo: "지금") { () -> Void in
            print("tapp!!!!")
        }.show()
    }
}

