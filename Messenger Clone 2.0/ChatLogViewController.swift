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
    
    @IBOutlet weak var chosenUserNameLabel: UILabel!
    
    @IBAction func sendButton(_ sender: Any) {
        
        handleSend()
        messageTextField.text = ""
        
    }
    
    //replace with overflow menu
    @IBAction func backButton(_ sender: Any) {
        
        performSegue(withIdentifier: "backToUserCollectionViewSegue", sender: self)
        
    }
    
    
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
        
        chosenUserNameLabel.text = chosenUser[1]

        fetchMessages()
        
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

