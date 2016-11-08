//
//  TWNotification.swift
//  TWPushNotification
//
//  Created by kimtaewan on 2016. 2. 19..
//  Copyright © 2016년 carq. All rights reserved.
//

import Foundation

import UIKit

open class TWNotification: NSObject {
    static var _notificationView: TWNotificationView?
    static var notificationView: TWNotificationView {
        if _notificationView == nil {
            _notificationView = TWNotificationView()
        }
        return _notificationView!
    }
    
    fileprivate static var currentNotification: TWNotification?
    fileprivate static var queue = [TWNotification]()
    fileprivate static var using = false
    
    var image: UIImage?
    var title: String?
    var message: String?
    var timeAgo: String?
    var willShow: (()->Void)?
    var callback: (()->Void)?
    var duration: Double = 2.0
    
    var removed = false
    
    open class func make(_ image: UIImage?, title: String?, message: String?, timeAgo: String?, duration: Double = 2, willShow: (()->Void)? = nil, callback: (()->Void)? = nil) -> TWNotification {
        let toast = TWNotification()
        toast.image = image
        toast.title = title
        toast.message = message
        toast.timeAgo = timeAgo
        toast.duration = duration
        toast.willShow = willShow
        toast.callback = callback
        return toast
    }
    
    open func show(){
        TWNotification.queue.append(self)
        TWNotification.showNotificationQueue()
    }
    
    
    open class func clearAll(){
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
    
    class func showToWindow(_ notification: TWNotification, callback: @escaping (()->Void)){
        if let window = UIApplication.shared.windows.last {
            window.addSubview(notificationView)
            notificationView.translatesAutoresizingMaskIntoConstraints = false
            
            let bindings = ["view": notificationView]
            let visualConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options:NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: bindings)
            
            window.addConstraints(visualConstraints)
            window.addConstraint( NSLayoutConstraint(item: notificationView, attribute: .top, relatedBy: .equal, toItem: window, attribute: .top, multiplier: 1, constant: 0))
            
            notification.willShow?()
            notificationView.notification = notification
            notificationView.show()
            
            
            let delayTime = DispatchTime.now() + Double(Int64(notification.duration * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                if !notification.removed {
                    notificationView.hide(callback)
                }
            }
            
        }
        
    }
}
