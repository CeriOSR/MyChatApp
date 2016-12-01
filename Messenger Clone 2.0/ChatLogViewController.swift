//
//  ChatLogViewController.swift
//  Messenger Clone 2.0
//
//  Created by Rey Cerio on 2016-11-26.
//  Copyright © 2016 CeriOS. All rights reserved.
//

import UIKit
import Firebase

class ChatLogViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    struct messageObject {
        
        var fromId: String?
        var toId: String?
        var text: String?
        var time: String?
        
    }
    let uid = FIRAuth.auth()?.currentUser?.uid
    
    var message: [messageObject] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var messageTextField: UITextField!
    
    @IBOutlet weak var chosenUserLabel: UINavigationItem!
    
    
    @IBAction func sendButton(_ sender: Any) {
        
        handleSend()
        messageTextField.text = ""
        
    }
    
    //@IBOutlet weak var inputContainerView: UIView!
/*
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
*/
    /*
    func setupInputComponents() {
        /*
        let inputContainerView = UIView()
        inputContainerView.backgroundColor = UIColor.white
        inputContainerView.translatesAutoresizingMaskIntoConstraints = true
 
        //view.addSubview(inputContainerView)
        
        //x, y, w, h
        inputContainerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        
        containerViewBottomAnchor = inputContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        containerViewBottomAnchor?.isActive = true
        
        inputContainerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        inputContainerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        */
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        
        inputContainerView.addSubview(sendButton)
        
        sendButton.rightAnchor.constraint(equalTo: inputContainerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: inputContainerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor).isActive = true

        inputContainerView.addSubview(inputTextField)
        
        //x, y, w, h
        self.inputTextField.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor, constant: 8).isActive = true
        self.inputTextField.centerYAnchor.constraint(equalTo: inputContainerView.centerYAnchor).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo: inputContainerView.heightAnchor).isActive = true
        
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor.lightGray
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        
        inputContainerView.addSubview(separatorLineView)
        
        separatorLineView.leftAnchor.constraint(equalTo: inputContainerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: inputContainerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: inputContainerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
    }
    
    */
    /*
    //replace with overflow menu
    @IBAction func backButton(_ sender: Any) {
        
        performSegue(withIdentifier: "backToUserCollectionViewSegue", sender: self)
        
    }
    */
    
    func handleSend() {
        
        let senderRef = FIRDatabase.database().reference().child("user_messages").child(uid!)
        let childRef = senderRef.childByAutoId()
        let values = ["fromId": uid!, "text": messageTextField.text!, "toId": chosenUser[0], "time": FIRServerValue.timestamp()] as [String : Any]
        childRef.updateChildValues(values)
        
        let recipientRef = FIRDatabase.database().reference().child("user_messages").child(chosenUser[0])
        let recipientChildRef = recipientRef.childByAutoId()
        let recipientValues = ["fromId": uid!, "text": messageTextField.text!, "toId": chosenUser[0], "time": FIRServerValue.timestamp()] as [String : Any]
        recipientChildRef.updateChildValues(recipientValues)

    
    }
    
    func fetchMessages() {
        
        let refTo = FIRDatabase.database().reference().child("user_messages").child(uid!)
        refTo.queryOrdered(byChild: "toId").queryEqual(toValue: chosenUser[0])
        refTo.queryLimited(toLast: 1000)
        refTo.observe(FIRDataEventType.childAdded, with: { (snapshot) in
            
            let dictionary = snapshot.value as! [String: AnyObject]
                
            let timeStamp = dictionary["time"] as! TimeInterval
            let isoDate = NSDate(timeIntervalSince1970: timeStamp / 1000)
            let stringDate = DateFormatter.localizedString(from: isoDate as Date, dateStyle: .short, timeStyle: .short)
            
            let messages = Messages()
            
            messages.fromId = dictionary["fromId"] as! String?
            messages.text = dictionary["text"] as! String?
            messages.time = stringDate as String?
            messages.toId = dictionary["toId"] as! String?
            
            //if messages.fromId == self.uid && messages.toId == self.uid{
                
            self.message.append(messageObject(fromId: messages.fromId, toId: messages.toId!, text: messages.text, time: messages.time!))
                
                    //sort ascending order
                /*
                 self.message.sorted(by: { (messageObject1, messageObject2) -> Bool in
                    messageObject1.time?.intValue < messageObject2.time?.intValue
                 })
                 */
            //}
                
                DispatchQueue.main.async(execute: {
                    
                    self.tableView?.reloadData()
                    
                })
            
        }, withCancel: nil)
    
    }
    
    
    //Enter key will press send. (set self as delegate for textField and added UITextFieldDelegate)
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        handleSend()
        messageTextField.text = ""
        return true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //setupInputComponents()
        
        messageTextField.delegate = self
        
        chosenUserLabel.title = chosenUser[1]

        fetchMessages()
        
        setupKeyBoardObservers()
        
    }
    
    func setupKeyBoardObservers() {
    
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
    
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    @IBOutlet weak var inputContainerViewBottomAnchor: NSLayoutConstraint!
    
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            
            let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
            
            inputContainerViewBottomAnchor?.constant = -keyboardHeight - 40
            
            UIView.animate(withDuration: keyboardDuration!) {
                self.view.layoutIfNeeded()
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
            
        inputContainerViewBottomAnchor?.constant = 0
        UIView.animate(withDuration: keyboardDuration!) {
                self.view.layoutIfNeeded()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return self.message.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageTableViewCell
        
        let messagesTo = message[indexPath.row]
        
        if messagesTo.fromId == uid {
            
            cell.fromMessageLabel.text = messagesTo.text
            
            cell.fromDateLabel.text = messagesTo.time! as String

            
        } else {
            
            
            cell.toMessageLabel.text = messagesTo.text
            
            cell.toDateLabel.text = messagesTo.time! as String
            
        }
        
        return cell
    }


}

