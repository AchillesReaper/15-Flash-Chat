//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    var messages:[Message] = []
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        
        messageTextfield.delegate = self
        
        tableView.dataSource = self
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        loadMessage()
    }
    
    func loadMessage(){
        db.collection(K.FStore.collectionName).order(by: K.FStore.dateField).addSnapshotListener { qSnapshot, error in
            if let e = error {
                print("loading error: \(e)")
            } else {
                if let snapshotDocuments = qSnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let messageSender = data[K.FStore.senderField] as? String, let messageBody = data[K.FStore.bodyField] as? String{
                            let message = Message(sender: messageSender, body: messageBody)
                            self.messages.append(message)
                        }
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            
                            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                        }
                    }
                    
                }
            }
        }
        
    }
    
    @IBAction func logOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    

}

extension ChatViewController: UITextFieldDelegate {
    @IBAction func sendPressed(_ sender: UIButton) {
        messageTextfield.endEditing(true)
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        messageTextfield.endEditing(true)
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let messageBody = messageTextfield.text, messageBody.count > 0, let messageSender = Auth.auth().currentUser?.email {
            db.collection(K.FStore.collectionName).addDocument(data: [
                K.FStore.dateField: Date().timeIntervalSince1970,
                K.FStore.senderField: messageSender,
                K.FStore.bodyField: messageBody
            ]){ err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added")
                    DispatchQueue.main.async {
                        self.messageTextfield.text = ""
                    }
                }
            }
            
        } else {
            messageTextfield.placeholder = "no message is typed"
        }
    }
    
}

extension ChatViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = self.messages[indexPath.row]
       
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        if message.sender == Auth.auth().currentUser?.email {
            cell.imageViewLeft.isHidden = true
            cell.imageViewRight.isHidden = false
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
            cell.messageContent.textColor = UIColor(named: K.BrandColors.purple)
        } else {
            cell.imageViewLeft.isHidden = false
            cell.imageViewRight.isHidden = true
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.purple)
            cell.messageContent.textColor = UIColor(named: K.BrandColors.lightPurple)
        }
        
        cell.messageContent.text = message.body
        
        return cell
    }

}
