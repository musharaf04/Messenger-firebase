//
//  ChatViewController.swift
//  MessengerFireBase
//
//  Created by apple on 02/11/2021.
//  Copyright © 2021 apple. All rights reserved.
//

import UIKit
import MessageKit
struct Message : MessageType{
    var messageId: String
    var sender: SenderType
    var sentDate: Date
    var kind: MessageKind
}
struct Sender : SenderType {
    var senderId: String
    var photoURL: String
    var senderID: String
    var displayName: String
}
class ChatViewController: MessagesViewController {

    private var messages = [Message]()
    private let selfSender = Sender(senderId: "1", photoURL: "",senderID: "1",displayName: "Raja")
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapComposeButton))
        
        messages.append(Message(messageId: "1",
                                sender: selfSender,
                                sentDate: Date(),
                                kind: .text("Hello World message.")))
        messages.append(Message(messageId: "1",
                                sender: selfSender,
                                sentDate: Date(),
                                kind: .text("Hello World message.Hello World message.Hello World  message.")))
        view.backgroundColor = .red
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        // Do any additional setup after loading the view.
    }
    
    @objc func didTapComposeButton()
    {
        let vc = NewConversationViewController()
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC,animated: true)
    }
}
extension ChatViewController: MessagesDisplayDelegate, MessagesDataSource, MessagesLayoutDelegate
{
    func currentSender() -> SenderType {
        return selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}
