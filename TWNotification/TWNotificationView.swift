//
//  TWPushNotification.swift
//  TWPushNotification
//
//  Created by kimtaewan on 2016. 2. 19..
//  Copyright © 2016년 carq. All rights reserved.
//
//  helped - Morten Bøgh
//  NibDesignable.swift
//  https://github.com/mbogh/NibDesignable

import UIKit

@IBDesignable
class TWNotificationView: UIView {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var timeAgoLabel: UILabel!
    
    var didTap: (()->Void)?
    
    
    
    var notification: TWNotification? {
        didSet {
            imageView.image = notification?.image
            titleLabel.text = notification?.title
            messageLabel.text = notification?.message
            timeAgoLabel.text = notification?.timeAgo
            didTap = notification?.callback
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupNib()
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupNib()
        setupLayout()
    }
    
    func show() {
        setNeedsLayout()
        layoutIfNeeded()
        let size = systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        let ty = size.height
        
        transform = CGAffineTransformMakeTranslation(0, -ty)
        UIView.animateWithDuration(0.5) { () -> Void in
            self.transform = CGAffineTransformIdentity
        }
    }
    
    func hide(callback: (()->Void)?) {
        let size = systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        let ty = size.height
        notification?.removed = true
        UIView.animateWithDuration(0.4,
            animations: { () -> Void in
                self.transform = CGAffineTransformMakeTranslation(0, -ty)
            })
            { (finish) -> Void in
                self.removeFromSuperview()
                callback?()
        }
        
    }
    
    override func intrinsicContentSize() -> CGSize {
        var size = super.intrinsicContentSize()
        
        size.height = max(58, size.height)
        
        return size
    }
    
    
}


//MARK: - gesture Recognizer
extension TWNotificationView {
    @IBAction func didTapView(sender: AnyObject) {
        didTap?()
        hide(nil)
        TWNotification.hideNotificationQueue()
    }
    
    
    @IBAction func panGusture(sender: UIPanGestureRecognizer) {
        let point = sender.translationInView(self)
        let tx = max(0, point.x)
        debugPrint(point)
        let w = CGRectGetWidth(bounds)
        switch sender.state {
        case .Began: break
        case .Changed:
            transform = CGAffineTransformMakeTranslation(tx, 0)
        case .Ended:
            if 0.4 < tx/w {
                UIView.animateWithDuration(0.4, animations: { () -> Void in
                    self.transform = CGAffineTransformMakeTranslation(w, 0)
                    }) { (finish) -> Void in
                        self.notification?.removed = true
                        self.removeFromSuperview()
                        TWNotification.hideNotificationQueue()
                }
            } else {
                UIView.animateWithDuration(0.4) { () -> Void in
                    self.transform = CGAffineTransformIdentity
                }
            }
            break
        case .Cancelled,.Failed:
            UIView.animateWithDuration(0.4) { () -> Void in
                self.transform = CGAffineTransformIdentity
            }
        default: break
        }
    }
}


//========================================NibDesignable================================================
private extension TWNotificationView {
    func setupLayout(){
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 4
    }
    
    func setupNib() {
        self.backgroundColor = UIColor.clearColor()
        let view = self.loadNib()
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        let bindings = ["view": view]
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views: bindings))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views: bindings))
    }
}

private extension UIView {
    func loadNib() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: self.nibName(), bundle: bundle)
        return nib.instantiateWithOwner(self, options: nil)[0] as! UIView
    }
    func nibName() -> String {
        return self.dynamicType.description().componentsSeparatedByString(".").last!
    }
}