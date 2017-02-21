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
import FirebaseStorage
import FirebaseAuth


class ChatViewController: JSQMessagesViewController {
    
    // messages array of JSQMessages
    var messages = [JSQMessage]()
    
    // dictionary of user avatars
    var avatars = [String: JSQMessagesAvatarImage]()
    
    // the root location of all the Messages
    var messageRef = FIRDatabase.database().reference().child("messages")
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let currentUser = FIRAuth.auth()?.currentUser {
            if currentUser.isAnonymous == true {
                senderDisplayName = "Anonymous"
            } else {
                if let displayName = currentUser.displayName {
                    senderDisplayName = "\(displayName)"
                }	
            }
            senderId = currentUser.uid
        }
        
        observeMessages()
    }
    
    
    // MARK: - Observe User Method
    
    func observeUser(with id: String) {
        FIRDatabase.database().reference().child("users").child(id).observe(.value, with: { snapshot in
            if let userDictionary = snapshot.value as? [String:AnyObject] {
                let imageURL = userDictionary["profileImageURL"] as! String
                self.setupAvatar(with: imageURL, for: id)
            }
        })
    }
    
    
    // MARK: - Setup Avatar
    
    func setupAvatar(with imageURL: String, for messageID: String) {
        if imageURL != "" {
            let fileURL = URL(string: imageURL)
            let data = NSData(contentsOf: fileURL!) as! Data
            let image = UIImage(data: data)
            let userImage = JSQMessagesAvatarImageFactory.avatarImage(with: image, diameter: 30)
            avatars[messageID] = userImage
        } else {
            avatars[messageID] = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "profileImage"), diameter: 30)
        }
        collectionView.reloadData()
    }
    
    
    // MARK: - Observe Messages Method
    
    func observeMessages() {
        messageRef.observe(.childAdded, with: { snapshot in
            if let message = snapshot.value as? [String: Any] {
                let mediaType = message["MediaType"] as! String
                let senderId = message["senderId"] as! String
                let displayName = message["senderDisplayName"] as! String
                
                self.observeUser(with: senderId)
                
                switch mediaType {
                    
                case "TEXT":
                    let text = message["text"] as! String
                    self.messages.append(JSQMessage(senderId: senderId, displayName: displayName, text: text))
                    
                case "PHOTO":
                    let fileURL = message["fileURL"] as! String
                    let url = URL(string: fileURL)
                    let data = NSData(contentsOf: url!) as! Data
                    let photo = UIImage(data: data)
                    let media = JSQPhotoMediaItem(image: photo)
                    
                    if self.senderId == senderId {
                        media?.appliesMediaViewMaskAsOutgoing = true
                    } else {
                        media?.appliesMediaViewMaskAsOutgoing = false
                    }
                    
                    self.messages.append(JSQMessage(senderId: senderId, displayName: displayName, media: media))
                    
                case "VIDEO":
                    let fileURL = message["fileURL"] as! String
                    let videoURL = URL(string: fileURL)
                    let videoMedia = JSQVideoMediaItem(fileURL: videoURL, isReadyToPlay: true)
                    
                    if self.senderId == senderId {
                        videoMedia?.appliesMediaViewMaskAsOutgoing = true
                    } else {
                        videoMedia?.appliesMediaViewMaskAsOutgoing = false
                    }
                    
                    self.messages.append(JSQMessage(senderId: senderId, displayName: displayName, media: videoMedia))
                    
                default:
                    print("Observed Message With Unknown Type")
                }
                
                self.collectionView.reloadData()
            }
        })
    }
    
    
    // MARK: - JSQMessagesVC Class Methods
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let message = messageRef.childByAutoId()
        let messageData = ["text": text, "senderId": senderId, "senderDisplayName": senderDisplayName, "MediaType": "TEXT"]
        message.setValue(messageData)
        self.finishSendingMessage()
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
    
    
    func sendMedia(photo: UIImage?, video: URL?) {
        if let photo = photo {
            let filePath = "\(FIRAuth.auth()?.currentUser?.uid)/\(Date.timeIntervalSinceReferenceDate)"
            let data = UIImageJPEGRepresentation(photo, 0.6)
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpg"
            FIRStorage.storage().reference().child(filePath).put(data!, metadata: metadata) { (storageMetadata, error) in
                if error != nil {
                    print(error?.localizedDescription)
                    return
                }
                let fileURL = storageMetadata!.downloadURLs?.first?.absoluteString
                
                let message = self.messageRef.childByAutoId()
                let messageData = ["fileURL": fileURL, "senderId": self.senderId, "senderDisplayName": self.senderDisplayName, "MediaType": "PHOTO"]
                message.setValue(messageData)
            }
        } else if let video = video {
            let filePath = "\(FIRAuth.auth()?.currentUser?.uid)/\(Date.timeIntervalSinceReferenceDate)"
            let data = NSData(contentsOf: video) as! Data
            let metadata = FIRStorageMetadata()
            metadata.contentType = "video/mp4"
            FIRStorage.storage().reference().child(filePath).put(data, metadata: metadata) { (storageMetadata, error) in
                if error != nil {
                    print(error?.localizedDescription)
                    return
                }
                let fileURL = storageMetadata?.downloadURLs?.first?.absoluteString
                let message = self.messageRef.childByAutoId()
                let messageData = ["fileURL": fileURL, "senderId": self.senderId, "senderDisplayName": self.senderDisplayName, "MediaType": "VIDEO"]
                message.setValue(messageData)
            }
        }
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
        let message = messages[indexPath.item]
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        
        if message.senderId == self.senderId {
            return bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor(red: 52/255, green: 73/255, blue: 94/255, alpha: 0.9))
        } else {
            return bubbleFactory?.incomingMessagesBubbleImage(with: UIColor(red: 149/255, green: 165/255, blue: 166/255, alpha: 0.9))
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = messages[indexPath.item]
        return avatars[message.senderId]
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
        do {
            try FIRAuth.auth()?.signOut()
        } catch let error {
            print(error.localizedDescription)
        }

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
            sendMedia(photo: image, video: nil)
        } else if let video = info[UIImagePickerControllerMediaURL] as? URL {
            sendMedia(photo: nil, video: video)
        }
        
        dismiss(animated: true)
    }
    
}
