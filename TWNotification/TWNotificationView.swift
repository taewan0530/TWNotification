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
    
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var timeAgoLabel: UILabel!
    
    private var heightConstraint: NSLayoutConstraint!
    
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
        let size = containerView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        let ty = size.height
        
        transform = CGAffineTransformMakeTranslation(0, -ty)
        UIView.animateWithDuration(0.5) { () -> Void in
            self.transform = CGAffineTransformIdentity
        }
    }
    
    func hide(callback: (()->Void)?) {
        let size = systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        let tx = transform.tx
        let ty = size.height
        notification?.removed = true
        
        UIView.animateWithDuration(0.4,
            animations: { () -> Void in
                self.transform = CGAffineTransformMakeTranslation(tx, -ty)
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
        if notification?.removed ?? false { return }
        let point = sender.translationInView(self)
        let ty = point.y
        let height = CGRectGetHeight(containerView.bounds)
        
        guard let superview = self.superview else { return }
        
        switch sender.state {
        case .Began: break
        case .Changed:
            if ty + height < height {
                transform = CGAffineTransformMakeTranslation(0, ty)
            } else {
                heightConstraint.constant = ty + height
            }
        case .Ended:
            let rate = ty/height
            if rate < -0.3 ||  2 < rate {
                if 2 < rate  {
                    didTap?()
                }
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    if 2 < rate  {
                        self.transform = CGAffineTransformMakeTranslation(0, -(ty + height))
                    } else {
                        self.transform = CGAffineTransformMakeTranslation(0, -height)
                    }
                    
                    }) { (finish) -> Void in
                       
                        self.notification?.removed = true
                        self.removeFromSuperview()
                        TWNotification.hideNotificationQueue()
                }
            } else {
                superview.layoutIfNeeded()
                UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: { () -> Void in
                    self.transform = CGAffineTransformIdentity
                    self.heightConstraint.constant = height
                    superview.layoutIfNeeded()
                    }, completion: nil)
            }
            break
        case .Cancelled,.Failed:
            superview.layoutIfNeeded()
            UIView.animateWithDuration(0.4) { () -> Void in
                self.transform = CGAffineTransformIdentity
                self.heightConstraint.constant = height
                superview.layoutIfNeeded()
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
        
        
        heightConstraint =  NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .GreaterThanOrEqual, toItem: nil, attribute: .Height, multiplier: 1, constant: 58)
        
        self.addConstraint(heightConstraint)
        
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