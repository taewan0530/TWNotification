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
    
    fileprivate var heightConstraint: NSLayoutConstraint!
    
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
        let size = containerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        let ty = size.height
        
        transform = CGAffineTransform(translationX: 0, y: -ty)
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.transform = CGAffineTransform.identity
        }) 
    }
    
    func hide(_ callback: (()->Void)?) {
        let size = systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        let tx = transform.tx
        let ty = size.height
        notification?.removed = true
        
        UIView.animate(withDuration: 0.4,
            animations: { () -> Void in
                self.transform = CGAffineTransform(translationX: tx, y: -ty)
            }, completion: { (finish) -> Void in
                self.removeFromSuperview()
                callback?()
        })
            
        
    }
    
    override var intrinsicContentSize : CGSize {
        var size = super.intrinsicContentSize
        
        size.height = max(58, size.height)
        
        return size
    }
    
    
}


//MARK: - gesture Recognizer
extension TWNotificationView {
    @IBAction func didTapView(_ sender: AnyObject) {
        didTap?()
        hide(nil)
        TWNotification.hideNotificationQueue()
    }
    
    
    @IBAction func panGusture(_ sender: UIPanGestureRecognizer) {
        if notification?.removed ?? false { return }
        let point = sender.translation(in: self)
        let ty = point.y
        let height = containerView.bounds.height
        
        guard let superview = self.superview else { return }
        
        switch sender.state {
        case .began: break
        case .changed:
            if ty + height < height {
                transform = CGAffineTransform(translationX: 0, y: ty)
            } else {
                heightConstraint.constant = ty + height
            }
        case .ended:
            let rate = ty/height
            if rate < -0.3 ||  2 < rate {
                if 2 < rate  {
                    didTap?()
                }
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    if 2 < rate  {
                        self.transform = CGAffineTransform(translationX: 0, y: -(ty + height))
                    } else {
                        self.transform = CGAffineTransform(translationX: 0, y: -height)
                    }
                    
                    }, completion: { (finish) -> Void in
                       
                        self.notification?.removed = true
                        self.removeFromSuperview()
                        TWNotification.hideNotificationQueue()
                }) 
            } else {
                superview.layoutIfNeeded()
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { () -> Void in
                    self.transform = CGAffineTransform.identity
                    self.heightConstraint.constant = height
                    superview.layoutIfNeeded()
                    }, completion: nil)
            }
            break
        case .cancelled,.failed:
            superview.layoutIfNeeded()
            UIView.animate(withDuration: 0.4, animations: { () -> Void in
                self.transform = CGAffineTransform.identity
                self.heightConstraint.constant = height
                superview.layoutIfNeeded()
            }) 
        default: break
        }
    }
}


//========================================NibDesignable================================================
private extension TWNotificationView {
    func setupLayout(){
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 4
        
        
        heightConstraint =  NSLayoutConstraint(item: self, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .height, multiplier: 1, constant: 58)
        
        self.addConstraint(heightConstraint)
        
    }
    
    func setupNib() {
        self.backgroundColor = UIColor.clear
        let view = self.loadNib()
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        let bindings = ["view": view]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views: bindings))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views: bindings))
    }
}

private extension UIView {
    func loadNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: self.nibName(), bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil)[0] as! UIView
    }
    func nibName() -> String {
        return type(of: self).description().components(separatedBy: ".").last!
    }
}
