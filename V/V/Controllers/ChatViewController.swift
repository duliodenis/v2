//
//  ChatViewController.swift
//  V
//
//  Created by ddenis on 1/21/17.
//  Copyright © 2017 Dulio Denis. All rights reserved.
//

import UIKit
import JSQMessagesViewController


class ChatViewController: JSQMessagesViewController {
    
    // messages array of JSQMessages
    var messages = [JSQMessage]()
    
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        senderId = "Me"
        senderDisplayName = "ddApps"
    }
    
    
    // MARK: - JSQMessagesVC Class Methods
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text))
        collectionView.reloadData()
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    
    // MARK: - JSQMessages Collection View Delegate Methods
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        
        return bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor(red: 52/255, green: 73/255, blue: 94/255, alpha: 0.9))
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    
    // MARK: - Log out Method

    @IBAction func logout(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = loginController
    }
    
}


// MARK: - UIImagePickerControl Delegate Methods

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        let photo = JSQPhotoMediaItem(image: image)
        messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: photo))
        collectionView.reloadData()
        dismiss(animated: true)
    }
    
}
