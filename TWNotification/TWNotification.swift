//
//  TWNotification.swift
//  TWPushNotification
//
//  Created by kimtaewan on 2016. 2. 19..
//  Copyright © 2016년 carq. All rights reserved.
//

import Foundation

import UIKit

public class TWNotification: NSObject {
    static var _notificationView: TWNotificationView?
    static var notificationView: TWNotificationView {
        if _notificationView == nil {
            _notificationView = TWNotificationView()
        }
        return _notificationView!
    }
    
    private static var currentNotification: TWNotification?
    private static var queue = [TWNotification]()
    private static var using = false
    
    var image: UIImage?
    var title: String?
    var message: String?
    var timeAgo: String?
    var callback: (()->Void)?
    var duration: Double = 2.0
    
    var removed = false
    
    public class func make(image: UIImage?, title: String?, message: String?, timeAgo: String?, duration: Double = 2, callback: (()->Void)?) -> TWNotification {
        let toast = TWNotification()
        toast.image = image
        toast.title = title
        toast.message = message
        toast.timeAgo = timeAgo
        toast.duration = duration
        toast.callback = callback
        return toast
    }
    
    public func show(){
        TWNotification.queue.append(self)
        TWNotification.showNotificationQueue()
    }
    
    
    public class func clearAll(){
        queue.removeAll()
        currentNotification = nil
        if let notificationView = _notificationView {
            notificationView.removeFromSuperview()
            _notificationView = nil
        }
    }
    
}

extension TWNotification {
    class func showNotificationQueue() {
        if queue.count == 0 || using == true { return }
        using = true
        let notification = queue.removeFirst()
        currentNotification = notification
        TWNotification.showToWindow(notification) { () -> Void in
            hideNotificationQueue()
        }
    }
    
    class func hideNotificationQueue() {
        currentNotification = nil
        using = false
        if queue.count == 0 {
            _notificationView = nil
            return
        }
        TWNotification.showNotificationQueue()
        
    }
    
    class func showToWindow(notification: TWNotification, callback: (()->Void)){
        if let window = UIApplication.sharedApplication().windows.last {
            window.addSubview(notificationView)
            notificationView.translatesAutoresizingMaskIntoConstraints = false
            
            let bindings = ["view": notificationView]
            let visualConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options:NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings)
            
            window.addConstraints(visualConstraints)
            window.addConstraint( NSLayoutConstraint(item: notificationView, attribute: .Top, relatedBy: .Equal, toItem: window, attribute: .Top, multiplier: 1, constant: 0))
            
            notificationView.notification = notification
            notificationView.show()
            
            
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(notification.duration * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                if !notification.removed {
                    notificationView.hide(callback)
                }
            }
            
        }
        
    }
}
