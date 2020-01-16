//
//  ChatsTableViewCell.swift
//  ChatApp
//

import UIKit
import Foundation

class ChatsTableViewCell: UITableViewCell {

    @IBOutlet var parentView: UIView!
    @IBOutlet var parentLeading: NSLayoutConstraint!
    @IBOutlet var parentTrailing: NSLayoutConstraint!
    @IBOutlet weak var parentHeight: NSLayoutConstraint!
    @IBOutlet weak var parentWidth: NSLayoutConstraint!
    
    @IBOutlet weak var reportLabel: UILabel!
    @IBOutlet weak var reportLabelHeight: NSLayoutConstraint!
    
    @IBOutlet weak var testLabel: UILabel!
    @IBOutlet var testLabelLeading: NSLayoutConstraint!
    @IBOutlet var testLabelTrailing: NSLayoutConstraint!
   
    var delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var sectionHeader: TableAttributes?
    var messageAttribute: MessageAttributes?
    var messageText = ""
    var dispatchGroup = DispatchGroup()

    func loadRows() {
        
        messageText = messageAttribute?.text ?? ""
        self.reportLabel.text = "\u{2713} Read"
        self.reportLabel.font = UIFont.boldSystemFont(ofSize: 13)
        
        //MARK:- Clears all exsisting subviews
        for view in parentView.subviews {
            if view.tag == 1 {
                view.removeFromSuperview()
            }
        }
        
        if messageText != "" {
            self.showMessageText(text: messageText)
        }
    }
    
    func showMessageText(text: String) {
        
        let bubbleView = BubbleView()
        bubbleView.tag = 1
        
        testLabel.text = text
        testLabel.numberOfLines = 0
        testLabel.sizeToFit()
        
        if messageAttribute?.status == "Incoming" {
            bubbleView.isIncoming = true
            reportLabel.isHidden = true
            reportLabelHeight.constant = 0
            self.testLabel!.textColor = .black

            parentTrailing.isActive = false
            parentLeading.isActive = true
            parentLeading.constant = 20
        }
        else {
            bubbleView.isIncoming = false
            reportLabel.isHidden = false
            reportLabelHeight.constant = 10
            self.testLabel!.textColor = .white
            
            parentLeading.isActive = false
            parentTrailing.isActive = true
            parentTrailing.constant = 10
        }
        
        //MARK:-  Loads bubbleView in async thread
        DispatchQueue.main.async {
            let bubbleSize = CGSize(width: self.parentView.frame.width, height: self.parentView.frame.height)

            bubbleView.frame.size = CGSize(width: bubbleSize.width, height: bubbleSize.height)
            bubbleView.frame.size = bubbleSize
            bubbleView.backgroundColor = .clear
                       
            self.testLabel!.center = self.parentView.center
            self.parentView.addSubview(bubbleView)
            self.parentView.bringSubviewToFront(self.testLabel!)
        }
    }
    
    func updateReadReport() {
        self.dispatchGroup.enter()
        self.reportLabel.text = "Delivered"
        self.dispatchGroup.leave()
        self.dispatchGroup.notify(queue: .main){
            self.delegate.run(delaySeconds: 1) {
                self.animateUI()
            }
        }
    }
    
    func animateUI() {
        UIView.animate(withDuration: 0.5, animations: {
            self.reportLabelHeight.constant = 0
            self.layoutSubviews()
            self.layoutIfNeeded()
        }, completion: { (finished) in
            self.reportLabelHeight.constant = 20
            self.reportLabel.text = "\u{2713} Read"
        })
    }
}
