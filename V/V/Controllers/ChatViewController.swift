//
//  ChatViewController.swift
//  V
//
//  Created by ddenis on 1/21/17.
//  Copyright © 2017 Dulio Denis. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import MobileCoreServices
import AVKit
import FirebaseDatabase


class ChatViewController: JSQMessagesViewController {
    
    // messages array of JSQMessages
    var messages = [JSQMessage]()
    
    // the root location of all the Messages
    var messageRef = FIRDatabase.database().reference().child("messages")
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        senderId = "Me"
        senderDisplayName = "ddApps"
        observeMessages()
    }
    
    
    // MARK: - Observe Messages Method
    
    func observeMessages() {
        messageRef.observe(.childAdded, with: { snapshot in
            if let message = snapshot.value as? [String: Any] {
                let mediaType = message["MediaType"] as! String
                let senderId = message["senderId"] as! String
                let displayName = message["senderDisplayName"] as! String
                let text = message["text"] as! String
                self.messages.append(JSQMessage(senderId: senderId, displayName: displayName, text: text))
                self.collectionView.reloadData()
            }
        })
    }
    
    
    // MARK: - JSQMessagesVC Class Methods
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let message = messageRef.childByAutoId()
        let messageData = ["text": text, "senderId": senderId, "senderDisplayName": senderDisplayName, "MediaType": "TEXT"]
        message.setValue(messageData)
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        // Put up an Action Sheet
        let sheet = UIAlertController(title: "Media Messages", message: "Select the type of Media you want to message.", preferredStyle: .actionSheet)
        // with cancel, phot, and video actions
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        let photo = UIAlertAction(title: "Photo", style: .default) { alert in
            self.getMediaFrom(type: kUTTypeImage)
        }
        
        let video = UIAlertAction(title: "Video", style: .default) { alert in
            self.getMediaFrom(type: kUTTypeMovie)
        }
        // add the actions and present the sheet
        sheet.addAction(cancel)
        sheet.addAction(photo)
        sheet.addAction(video)
        present(sheet, animated: true)
    }
    
    
    func getMediaFrom(type: CFString) {
        let mediaPicker = UIImagePickerController()
        mediaPicker.delegate = self
        mediaPicker.mediaTypes = [type as String]
        self.present(mediaPicker, animated: true)
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
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        let message = messages[indexPath.item]
        if message.isMediaMessage {
            if let mediaItem = message.media as? JSQVideoMediaItem {
                let player = AVPlayer(url: mediaItem.fileURL)
                let playerVC = AVPlayerViewController()
                playerVC.player = player
                self.present(playerVC, animated: true)
            }
        }
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
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let photo = JSQPhotoMediaItem(image: image)
            messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: photo))
            collectionView.reloadData()
        } else if let video = info[UIImagePickerControllerMediaURL] as? URL {
            let videoItem = JSQVideoMediaItem(fileURL: video, isReadyToPlay: true)
            messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: videoItem))
            collectionView.reloadData()
        }
        
        dismiss(animated: true)
    }
    
}
