//
//  GTAlertViewController.swift
//  GoalTracker
//
//  Created by 이종윤 on 2022/01/29.
//


import UIKit

class GTAlertViewController: UIViewController {
    
    var containerView:UIView!
    var alertBackgroundView:UIView!
    var dismissButton:UIButton!
    var cancelButton:UIButton!
    var buttonLabel:UILabel!
    var cancelButtonLabel:UILabel!
    var titleLabel:UILabel!
    var subTitleLabel:UILabel!
    var textLabel:UILabel!
    var verticalLine:UIView!
    var horizontalLine:UIView!
    var closeAction:(()->Void)!
    var cancelAction:(()->Void)!
    var completionHandler:(()->Void)!
    var isAlertOpen:Bool = false
    var noButtons: Bool = false
    var backgroundDismiss: Bool = false
    
    var isAttributedString:Bool = false
    
    var defaultColor: UIColor = .crayon//UIColorFromHex(0xffffff, alpha: 1)
    
    var backGroundColor: UIColor = .black.withAlphaComponent(0.1)
    
    public enum TextColorTheme {
        case dark, light
    }
    var darkTextColor = UIColorFromHex(0x000000, alpha: 0.75)
    var lightTextColor = UIColorFromHex(0xffffff, alpha: 0.9)
    
    enum ActionType {
        case close, cancel
    }
    
    let lineColour = UIColor.lightGray.withAlphaComponent(0.3)
    
    let baseHeight:CGFloat = 160.0
    var alertWidth:CGFloat = UIScreen.main.bounds.width - 80
    let buttonHeight:CGFloat = 56
    let padding:CGFloat = 16.0
    
    var viewWidth:CGFloat?
    var viewHeight:CGFloat?
    
    var titleFontSize : CGFloat = 14
    var textFontSize : CGFloat = 14
    var buttonFontSize : CGFloat = 14
    
    
    // Allow alerts to be closed/renamed in a chainable manner
    open class GlowAlertViewResponder {
        let alertview: GTAlertViewController
        
        public init(alertview: GTAlertViewController) {
            self.alertview = alertview
        }
        
        open func addAction(_ action: @escaping ()->Void) -> GlowAlertViewResponder {
            self.alertview.addAction(action)
            return GlowAlertViewResponder(alertview: alertview)
        }
        
        open func addCancelAction(_ action: @escaping ()->Void) -> GlowAlertViewResponder {
            self.alertview.addCancelAction(action)
            return GlowAlertViewResponder(alertview: alertview)
        }
        
        open func onCompletion(_ complition: @escaping ()->Void) -> GlowAlertViewResponder {
            self.alertview.addCompletionHandler(complition)
            return GlowAlertViewResponder(alertview: alertview)
        }
        
        open func show() {
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            let sceneDelegate = windowScene?.delegate as? SceneDelegate
            
            sceneDelegate?.window?.addSubview(alertview.view)
            sceneDelegate?.window?.rootViewController?.addChild(alertview)
        }
        
        open func setTextTheme(_ theme: TextColorTheme) {
            self.alertview.setTextTheme(theme)
        }
        
        @objc func close() {
            self.alertview.closeView(false)
        }
    
    }
    
    func setTextTheme(_ theme: TextColorTheme) {
        switch theme {
        case .light:
            recolorText(lightTextColor)
        case .dark:
            recolorText(darkTextColor)
        }
    }
    
    func recolorText(_ color: UIColor) {
        titleLabel.textColor = color
        if textLabel != nil {
            textLabel.textColor = color
        }
        if self.noButtons == false {
            buttonLabel.textColor = color
            if cancelButtonLabel != nil {
                cancelButtonLabel.textColor = color
            }
        }
        
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let size = self.screenSize()
        
        self.viewWidth = size.width
        self.viewHeight = size.height
        
        var yPos:CGFloat = 0.0
        let contentWidth:CGFloat = self.alertWidth - (self.padding*2)
        
        yPos += 45
        // position the title
        if self.titleLabel != nil {
            let titleString = titleLabel.text! as NSString
            let titleAttr = [NSAttributedString.Key.font:titleLabel.font!]
            let titleSize = CGSize(width: contentWidth, height: 60)
            let titleRect = titleString.boundingRect(with: titleSize, options: .usesLineFragmentOrigin, attributes: titleAttr, context: nil)
            
            self.titleLabel.frame = CGRect(
                x: self.padding,
                y: yPos,
                width: contentWidth,
                height: ceil(titleRect.size.height)
            )
            yPos += ceil(titleRect.size.height)
            yPos += 20
        }
        
        if self.subTitleLabel != nil {
            let titleString = subTitleLabel.text! as NSString
            let titleAttr = [NSAttributedString.Key.font:subTitleLabel.font!]
            let titleSize = CGSize(width: contentWidth, height: 80)
            let titleRect = titleString.boundingRect(with: titleSize, options: .usesLineFragmentOrigin, attributes: titleAttr, context: nil)
            
            self.subTitleLabel.frame = CGRect(
                x: self.padding,
                y: yPos,
                width: contentWidth,
                height: ceil(titleRect.size.height)
            )
            yPos += ceil(titleRect.size.height)
//            yPos += 10
        }
        
        
        // position text
        if self.textLabel != nil {
            if self.isAttributedString {
                let textString = textLabel.attributedText! as NSAttributedString

                let textSize = CGSize(width: contentWidth, height: CGFloat.greatestFiniteMagnitude)
                let textRect = textString.boundingRect(with: textSize, options: .usesLineFragmentOrigin, context: nil)
                self.textLabel.frame = CGRect(x: self.padding, y: yPos, width: contentWidth, height: ceil(textRect.height))
                yPos += ceil(textRect.height)
            }
            else {
                let textString = textLabel.text! as NSString
                let textAttr = [NSAttributedString.Key.font:self.textLabel.font!]
                let textSize = CGSize(width: contentWidth, height: CGFloat.greatestFiniteMagnitude)
                let textRect = textString.boundingRect(with: textSize, options: .usesLineFragmentOrigin, attributes: textAttr, context: nil)
                self.textLabel.frame = CGRect(x: self.padding, y: yPos+20, width: contentWidth, height: ceil(textRect.height))
                yPos += ceil(textRect.height)
            }
            yPos += 5
        }
        
        
        
        // position the buttons
        
        if self.noButtons == false {
            yPos += 32
            
            self.horizontalLine.frame = CGRect(x: 0, y: yPos-1, width: self.alertWidth, height: 0.5)
            
            var buttonWidth = self.alertWidth
            if self.cancelButton != nil {
                buttonWidth = self.alertWidth/2
                
                self.verticalLine.frame = CGRect(x: buttonWidth, y: yPos-1, width: 0.5, height: self.buttonHeight)
                self.verticalLine.isHidden = true
                self.cancelButton.frame = CGRect(x: 0, y: yPos, width: buttonWidth-0.5, height: self.buttonHeight)
                if self.cancelButtonLabel != nil {
                    self.cancelButtonLabel.frame = CGRect(x: 15, y: (self.buttonHeight/2) - 20, width: buttonWidth - 20, height: 30)
                }
            }
            else {
                self.verticalLine.isHidden = true
            }
            
            let buttonX = buttonWidth == self.alertWidth ? 0 : buttonWidth
            self.dismissButton.frame = CGRect(x: buttonX, y: yPos, width: buttonWidth, height: self.buttonHeight)
            if self.buttonLabel != nil {
                self.buttonLabel.frame = CGRect(x: 5, y: (self.buttonHeight/2) - 20, width: buttonWidth - 20, height: 30)
            }
            
            // set button fonts
            if self.buttonLabel != nil {
                buttonLabel.font = .sfPro(size: 16, family: .Thin)
            }
            if self.cancelButtonLabel != nil {
                cancelButtonLabel.font = .sfPro(size: 16, family: .Regular)
            }
            yPos += self.buttonHeight
        }else{
            yPos += self.padding
        }
        
        
        // size the background view
        self.alertBackgroundView.frame = CGRect(x: 0, y: 0, width: self.alertWidth, height: yPos)
        
        // size the container that holds everything together
        self.containerView.frame = CGRect(x: (self.viewWidth!-self.alertWidth)/2, y: (self.viewHeight! - yPos)/2, width: self.alertWidth, height: yPos)
    }
    
    open func make(
        title: String?=nil, titleFont: UIFont = .sfPro(size: 18, family: .Bold),
        subTitle: String?=nil, text: String?=nil,
        attributedString: NSAttributedString?=nil,
        noButtons: Bool?=false, buttonText: String?=nil, buttonFont: UIFont,
        cancelButtonText: String?=nil, color: UIColor?=nil,
        buttonTextColor: UIColor = .black, cancelButtonTextColor: UIColor = .black,
        backgroundDismiss: Bool = false) -> GlowAlertViewResponder {
            
            self.view.backgroundColor = backGroundColor
            
            var baseColor:UIColor?
            if let customColor = color {
                baseColor = customColor
            } else {
                baseColor = self.defaultColor
            }
            
            let sz = self.screenSize()
            self.viewWidth = sz.width
            self.viewHeight = sz.height
            
            self.view.frame.size = sz
            
            // Container for the entire alert modal contents
            self.containerView = UIControl()
            self.containerView.layer.cornerRadius = 18
            self.containerView.layer.masksToBounds = true
            self.view.addSubview(self.containerView!)
            
            // Background view/main color
            self.alertBackgroundView = UIView()
            alertBackgroundView.backgroundColor = baseColor
            alertBackgroundView.layer.cornerRadius = 0
            alertBackgroundView.layer.masksToBounds = true
            self.containerView.addSubview(alertBackgroundView!)
            
            // Title
            if let title = title {
                self.titleLabel = UILabel()
                titleLabel.textColor = .black
                titleLabel.numberOfLines = 0
                titleLabel.textAlignment = .center
                titleLabel.font = .sfPro(size: 18, family: .Medium)
                titleLabel.text = title
                self.containerView.addSubview(titleLabel)
            }
            
            if let subTitle = subTitle {
                self.subTitleLabel = UILabel()
                subTitleLabel.textColor = .black
                subTitleLabel.numberOfLines = 3
                subTitleLabel.textAlignment = .center
                subTitleLabel.font = .sfPro(size: 18, family: .Light)
                subTitleLabel.text = subTitle
                self.containerView.addSubview(subTitleLabel)
            }
            
            // View text
            if let text = text {
                self.textLabel = UILabel()
                textLabel.textColor = .darkGray
                textLabel.numberOfLines = 0
                textLabel.textAlignment = .center
                textLabel.font = .sfPro(size: 14, family: .Light)
                if let attributedString = attributedString {
                    textLabel.attributedText = attributedString
                    self.isAttributedString = true
                }
                else {
                    textLabel.text = text
                    self.isAttributedString = false
                }
                self.containerView.addSubview(textLabel)
            }
            
            // Button
            self.noButtons = true
            if noButtons == false {
                self.noButtons = false
                self.dismissButton = UIButton()
                let buttonColor = UIImage.withColor(.crayon)
                let buttonHighlightColor = UIImage.withColor(.crayon)
                dismissButton.setBackgroundImage(buttonColor, for: .normal)
                dismissButton.setBackgroundImage(buttonHighlightColor, for: .highlighted)
                dismissButton.addTarget(self, action: #selector(buttonTap), for: .touchUpInside)
                alertBackgroundView!.addSubview(dismissButton)
                // Button text
                self.buttonLabel = UILabel()
                buttonLabel.textColor = buttonTextColor
                buttonLabel.numberOfLines = 1
                buttonLabel.textAlignment = .center
                buttonLabel.setupShadowToDefaultLayer(alpha: 0.8, rd: 1, width: 1, height: 1)
                buttonLabel.font = buttonFont
                
                if let text = buttonText {
                    buttonLabel.text = text
                } else {
                    buttonLabel.text = "OK"
                }
                dismissButton.addSubview(buttonLabel)
                
                // Second cancel button
                if cancelButtonText != nil {
                    self.cancelButton = UIButton()
                    let buttonColor = UIImage.withColor(.crayon)
                    let buttonHighlightColor = UIImage.withColor(.crayon)
                    cancelButton.setBackgroundImage(buttonColor, for: .normal)
                    cancelButton.setBackgroundImage(buttonHighlightColor, for: .highlighted)
                    cancelButton.addTarget(self, action: #selector(cancelButtonTap), for: .touchUpInside)
                    alertBackgroundView!.addSubview(cancelButton)
                    // Button text
                    self.cancelButtonLabel = UILabel()
                    cancelButtonLabel.textColor = .black
                    cancelButtonLabel.numberOfLines = 1
                    cancelButtonLabel.textAlignment = .center
                    cancelButtonLabel.text = cancelButtonText
                    cancelButtonLabel.setupShadowToDefaultLayer(alpha: 0.5, rd: 1, width: 1, height: 1)
                    
                    cancelButton.addSubview(cancelButtonLabel)
                }
            }
            
            verticalLine = UIView()
            verticalLine.backgroundColor = lineColour
            self.containerView.addSubview(verticalLine!)
            
            horizontalLine = UIView()
            horizontalLine.isHidden = true
            horizontalLine.backgroundColor = lineColour
            self.containerView.addSubview(horizontalLine)
            
            
            // Animate it in
            self.view.alpha = 0
            UIView.animate(withDuration: 0.2, animations: {
                self.view.alpha = 1
            })
            self.containerView.frame.origin.x = self.view.center.x
            self.containerView.center.y = -500
            
            self.containerView.center = CGPoint(x: UIScreen.main.bounds.size.width / 2 , y: UIScreen.main.bounds.size.width / 2)
            
            isAlertOpen = true
            
            self.backgroundDismiss = backgroundDismiss
            return GlowAlertViewResponder(alertview: self)
        }
    
    func addAction(_ action: @escaping ()->Void) {
        self.closeAction = action
    }
    
    @objc func buttonTap() {
        self.closeView(true, source: .close);
    }
    
    func addCancelAction(_ action: @escaping ()->Void) {
        self.cancelAction = action
    }
    
    func addCompletionHandler(_ completion: @escaping ()->Void) {
        self.completionHandler = completion
    }
    
    @objc func cancelButtonTap() {
        self.closeView(true, source: .cancel);
    }
    
    @objc func backgroundTap() {
        if self.backgroundDismiss {
            UIView.animate(withDuration: 0.1, animations: {
                self.view.alpha = 0
                }, completion: { finished in
                    self.removeView()
            })
        }
    }
    
    func closeView(_ withCallback:Bool, source:ActionType = .close) {
        UIView.animate(withDuration: 0.1, animations: {
            self.view.alpha = 0
            }, completion: { finished in
                self.removeView()
                if withCallback {
                    if let action = self.closeAction, source == .close {
                        action()
                    }
                    else if let action = self.cancelAction, source == .cancel {
                        action()
                    }
                    if let completion = self.completionHandler {
                        completion()
                    }
                }
        })
    }
    
    func removeView() {
        isAlertOpen = false
        self.removeFromParent()
        self.view.removeFromSuperview()
    }
    

    
    func screenSize() -> CGSize {
        return UIScreen.main.bounds.size
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let locationPoint = touch.location(in: self.view)
            let converted = self.containerView.convert(locationPoint, from: self.view)
            if self.containerView.point(inside: converted, with: event){
                if self.noButtons == true {
                    closeView(true, source: .cancel)
                }
                
            }
            else {
                self.backgroundTap()
            }
        }
    }
    
    
    open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}





// Utility methods + extensions

// Extend UIImage with a method to create
// a UIImage from a solid color
//
// See: http://stackoverflow.com/questions/20300766/how-to-change-the-highlighted-color-of-a-uibutton
public extension UIImage {
    class func withColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}

// For any hex code 0xXXXXXX and alpha value,
// return a matching UIColor
public func UIColorFromHex(_ rgbValue:UInt32, alpha:Double=1.0)->UIColor {
    let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
    let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
    let blue = CGFloat(rgbValue & 0xFF)/256.0
    
    return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
}

// For any UIColor and brightness value where darker <1
// and lighter (>1) return an altered UIColor.
//
// See: http://a2apps.com.au/lighten-or-darken-a-uicolor/
public func adjustBrightness(_ color:UIColor, amount:CGFloat) -> UIColor {
    var hue:CGFloat = 0
    var saturation:CGFloat = 0
    var brightness:CGFloat = 0
    var alpha:CGFloat = 0
    if color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
        brightness += (amount-1.0)
        brightness = max(min(brightness, 1.0), 0.0)
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    return color
}
