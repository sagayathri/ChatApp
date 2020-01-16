//
//  ViewController.swift
//  ChatApp
//


import UIKit
import Foundation
import CoreData
import RxSwift
import RxCocoa

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var animationLabel: UILabel!
    @IBOutlet weak var animateTrailing: NSLayoutConstraint!
    @IBOutlet weak var animateTop: NSLayoutConstraint!
    @IBOutlet weak var animationWidth: NSLayoutConstraint!

    @IBOutlet weak var animationLeading: NSLayoutConstraint!
    
    let avatarImageView = UIImageView(image:UIImage(named: "Avatar"))
    var model = [ChatModel]()
    var sectionHeaders = [TableAttributes]()
    var messages : [MessageAttributes] = []
    var dateLeft = ""
    var messageID = 0
    var sectionCount = 0, rowCount = 0
    
    var chatViewModel = ChatViewModel()
    var observedMessage: String? = ""
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.dataSource = self
        tableView.delegate = self
        chatTextView.delegate = self
        
        setUpNavigationBar()
        
        chatTextView.layer.cornerRadius = 10
        chatTextView.layer.borderWidth = 1
        chatTextView.layer.borderColor = UIColor.primaryColour().cgColor
        chatTextView.layer.masksToBounds = true
        
        animationLabel.layer.masksToBounds = true
        animationLabel.numberOfLines = 0
        animationLabel.sizeToFit()
        
        //MARK:- Gesture to hide active keyboard
        let gesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(gesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //MARK:-  Adding dummy messages
        model.append(ChatModel(messageID: 1, dateLeft: "12/12/2019", textMessage: "Hello", imageMessage: nil, status: "Incoming"))
        model.append(ChatModel(messageID: 2, dateLeft: "01/01/2019", textMessage: "Happy New Year!", imageMessage: nil, status: "Incoming"))
        
        dateLeft = model[0].dateLeft
        
        loadMessages()
        
        scrollTableToBottom()
        
        fetchNewMessage()
    }
    
    //MARK:- Sets up the navigation bar
    func setUpNavigationBar() {
        avatarImageView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        avatarImageView.layer.masksToBounds = true
        
        //MARK:- Resizing Avatar image to fit in navigation bar
        let size = CGSize(width: 40, height: 40)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        avatarImageView.draw(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        avatarImageView.image = newImage
       
        let title = UILabel()
        title.frame.size.width = 40
        title.frame.size.height = 20
        title.text = "David"
        title.font = UIFont.boldSystemFont(ofSize: 25)
        title.lineBreakMode = .byTruncatingTail
        title.textColor = .label
        title.textAlignment = .left
        
        let stackView = UIStackView(arrangedSubviews: [avatarImageView, title])
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.frame.size.width = avatarImageView.frame.width + title.frame.width
        stackView.frame.size.height = avatarImageView.frame.height
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        navigationItem.titleView = stackView
    }
    
    //MARK:- Loads the UI with dummy messages initially
    func loadMessages() {
        for i in 0 ..< model.count {
            if dateLeft == model[i].dateLeft {
                messages.append(MessageAttributes(status: model[i].status, text: model[i].textMessage ?? nil, imagename: model[i].imageMessage ?? nil))
                if i == model.count - 1 {
                    sectionHeaders.append(TableAttributes(header: dateLeft, messageAttributes: messages))
                    messages.removeAll()
                }
            }
            else {
                sectionHeaders.append(TableAttributes(header: dateLeft, messageAttributes: messages))
                messages.removeAll()
                messages.append(MessageAttributes(status: model[i].status, text: model[i].textMessage ?? nil, imagename: model[i].imageMessage ?? nil))
                if (i+1 < model.count) {
                    dateLeft = model[i+1].dateLeft
                }
                else {
                    dateLeft = model[model.count - 1].dateLeft
                }
            }
        }
        if !messages.isEmpty{
            sectionHeaders.append(TableAttributes(header: dateLeft, messageAttributes: messages))
            messages.removeAll()
        }
        sectionCount = sectionHeaders.count
        rowCount = sectionHeaders[sectionCount - 1].messageAttributes.count
    }
    
    //MARK:- Fetches the message being observed
    func fetchNewMessage() {
        _ = chatTextView.rx.text.map{ $0 ?? ""}.bind(to: chatViewModel.newMessage)
        chatViewModel.observedMessage.subscribe(onNext: {[unowned self] message in
           self.chatTextView.text = message
           self.observedMessage = message
        }).disposed(by: disposeBag)
    }
    
    //MARK:- Animates the UI
    func animates(text: String) {
        animationLabel.text = text
        animationLabel.numberOfLines = 0
        var constraint: CGFloat = 0, animateConstraint: CGFloat = 0
        self.animationLabel.isHidden = false
        animateTop.constant = self.view.frame.height - self.animationLabel.frame.height
        self.animationLeading.constant = self.view.frame.width - self.animationLabel.intrinsicContentSize.width
        constraint = CGFloat(self.view.frame.height - self.tableView.contentSize.height)
        if self.view.frame.height - constraint < self.view.frame.height - 200 {
            animateConstraint = self.view.frame.height - constraint
        }
        else {
            animateConstraint = self.view.frame.height - 175
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            self.animationLabel.isHidden = false
            self.animateTop.constant = animateConstraint + 10
            self.animationWidth.constant = self.animationLabel.intrinsicContentSize.width + 50
            self.animateTrailing.constant = 10
            self.animationLabel.backgroundColor = .fadeOut()
            self.view.layoutSubviews()
            self.view.layoutIfNeeded()
        }, completion: { (finished) in
            self.animationLabel.isHidden = true
            self.animateTop.constant = self.view.frame.height - 150
            self.animateTrailing.constant = 70
            self.animationWidth.constant = 330
            self.animationLeading.constant = 50
            self.animationLabel.backgroundColor = .systemBackground
            self.tableView.reloadData()
            self.scrollTableToBottom()
        })
    }
    
    //MARK:-  Scroll the tableView to its bottom
    func scrollTableToBottom() {
        DispatchQueue.main.async {
            let lastSectionIndex = self.tableView!.numberOfSections - 1
            let lastRowIndex = self.tableView.numberOfRows(inSection: lastSectionIndex) - 1
            let pathToLastRow = NSIndexPath(row: lastRowIndex, section: lastSectionIndex)
            self.tableView.scrollToRow(at: pathToLastRow as IndexPath, at: UITableView.ScrollPosition.none, animated: true)
        }
    }
    
    @IBAction func btnSendAction(_ sender: UIButton) {
        messages = []
        messageID =  model.count + 1
        
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let now = "\(hour):\(minutes)"
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        let today = "\(day)/ \(month)/\(year)"


        model.append(ChatModel(messageID:  messageID, dateLeft: "Today \(now)", textMessage: observedMessage, imageMessage: nil, status: "Outgoing"))

        for item in  model {
            if item.dateLeft == "Today \(now)" {
                messages.append(MessageAttributes(status: item.status, text: item.textMessage, imagename: item.imageMessage))
            }
        }
        if  sectionHeaders[ sectionHeaders.count - 1].header == "Today \(now)" {
            sectionHeaders.removeLast()
        }

        sectionHeaders.append(TableAttributes(header: "Today \(now)", messageAttributes:  messages))

        //MARK:-  Saves to persistant store
        chatViewModel.saveToCoreData(dateLeft: today, message: observedMessage!, status: "Outgoing")

        //MARK:-  Animate UI
        animates(text: observedMessage!)
        
        //MARK:-  Fetches data from persistance store
        chatViewModel.fetchMessagesFromCoreData()

        clearUI()
    }
    
    //MARK:- Clears the UI
    func clearUI() {
        chatTextView.text = "Aa"
        chatTextView.textColor = UIColor.lightGray
        btnSend.isUserInteractionEnabled = false
        btnSend.setTitleColor(.gray, for: .normal)
        chatTextView.resignFirstResponder()
        bottomConstraint.constant = 20
    }
}

extension ChatViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        chatTextView.text = ""
        chatTextView.textColor = UIColor.label
        btnSend.isUserInteractionEnabled = true
        btnSend.setTitleColor(UIColor.primaryColour(), for: .normal)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            chatTextView.resignFirstResponder()
            return false
        }
       return true
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            //MARK:-  Pushes the UI up to show keyboard
            bottomConstraint.constant = keyboardHeight
            //MARK:-  Scrolls tableView to its bottom
            self.scrollTableToBottom()
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        bottomConstraint.constant = 20
    }
}

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionHeaders.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionHeaders[section].header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 30))
        label.text =  self.tableView(tableView, titleForHeaderInSection: section)!
        label.numberOfLines = 2
        label.textColor = UIColor.gray
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        header.addSubview(label)
        header.bringSubviewToFront(label)
        return header
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionHeaders[section].messageAttributes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableView.automaticDimension
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! ChatsTableViewCell
        
        cell.sectionHeader = sectionHeaders[indexPath.section]
        cell.messageAttribute = sectionHeaders[indexPath.section].messageAttributes[indexPath.row]
        
        //MARK:-  Loads UI
        cell.loadRows()
        
        return cell
    }
}

