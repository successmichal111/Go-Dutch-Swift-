//
//  IncomingFileMessageTableViewCell.swift
//  SendBird-iOS
//
//  Created by Jed Kyung on 10/6/16.
//  Copyright © 2016 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import AlamofireImage

class IncomingFileMessageTableViewCell: UITableViewCell {
    weak var delegate: MessageDelegate?

    @IBOutlet weak var dateContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var dateContainerBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var messageContainerTopPadding: NSLayoutConstraint!
    @IBOutlet weak var nicknameLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var nicknameLabelBottomMargin: NSLayoutConstraint!
    @IBOutlet weak var fileContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var messageContainerBottomPadding: NSLayoutConstraint!
    @IBOutlet weak var dateContainerTopMargin: NSLayoutConstraint!
    
    @IBOutlet weak var dateSeperatorContainerView: UIView!
    @IBOutlet weak var dateSeperatorLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var filenameLabel: UILabel!
    @IBOutlet weak var fileTypeImageView: UIImageView!
    @IBOutlet weak var fileActionImageView: UIImageView!
    @IBOutlet weak var messageDateLabel: UILabel!
    @IBOutlet weak var messageContainerView: UIView!
    
    private var message: SBDFileMessage!
    private var prevMessage: SBDBaseMessage!

    static func nib() -> UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
    
    static func cellReuseIdentifier() -> String {
        return String(describing: self)
    }
    
    @objc private func clickProfileImage() {
        if self.delegate != nil {
            self.delegate?.clickProfileImage(viewCell: self, user: self.message!.sender!)
        }
    }
    
    @objc private func clickFileMessage() {
        if self.delegate != nil {
            self.delegate?.clickMessage(view: self, message: self.message!)
        }
    }
    
    func setModel(aMessage: SBDFileMessage) {
        self.message = aMessage
        
        self.profileImageView.af_setImage(withURL: URL(string: (self.message.sender?.profileUrl!)!)!, placeholderImage: UIImage(named: "img_profile"))
        
        let profileImageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickProfileImage))
        self.profileImageView.isUserInteractionEnabled = true
        self.profileImageView.addGestureRecognizer(profileImageTapRecognizer)
        
        let messageContainerTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickFileMessage))
        self.messageContainerView.isUserInteractionEnabled = true
        self.messageContainerView.addGestureRecognizer(messageContainerTapRecognizer)
        
        if self.message.type.hasPrefix("video") {
            self.fileTypeImageView.image = UIImage(named: "icon_video_chat")
            self.fileActionImageView.image = UIImage(named: "btn_play_chat")
        }
        else if self.message.type.hasPrefix("audio") {
            self.fileTypeImageView.image = UIImage(named: "icon_voice_chat")
            self.fileActionImageView.image = UIImage(named: "btn_play_chat")
        }
        else {
            self.fileTypeImageView.image = UIImage(named: "icon_file_chat")
            self.fileActionImageView.image = UIImage(named: "btn_download_chat")
        }
        
        var nicknameAttribute: [String:AnyObject]?
        switch (self.message.sender?.nickname?.characters.count)! % 5 {
        case 0:
            nicknameAttribute = [
                NSFontAttributeName: ChatConstants.nicknameFontInMessage(),
                NSForegroundColorAttributeName: ChatConstants.nicknameColorInMessageNo0()
            ]
            break;
        case 1:
            nicknameAttribute = [
                NSFontAttributeName: ChatConstants.nicknameFontInMessage(),
                NSForegroundColorAttributeName: ChatConstants.nicknameColorInMessageNo1()
            ]
            break;
        case 2:
            nicknameAttribute = [
                NSFontAttributeName: ChatConstants.nicknameFontInMessage(),
                NSForegroundColorAttributeName: ChatConstants.nicknameColorInMessageNo2()
            ]
            break;
        case 3:
            nicknameAttribute = [
                NSFontAttributeName: ChatConstants.nicknameFontInMessage(),
                NSForegroundColorAttributeName: ChatConstants.nicknameColorInMessageNo3()
            ]
            break;
        case 4:
            nicknameAttribute = [
                NSFontAttributeName: ChatConstants.nicknameFontInMessage(),
                NSForegroundColorAttributeName: ChatConstants.nicknameColorInMessageNo4()
            ]
            break;
        default:
            nicknameAttribute = [
                NSFontAttributeName: ChatConstants.nicknameFontInMessage(),
                NSForegroundColorAttributeName: ChatConstants.nicknameColorInMessageNo0()
            ]
            break;
        }
        
        self.nicknameLabel.attributedText = NSMutableAttributedString(string: (self.message.sender?.nickname)!, attributes: nicknameAttribute)
        self.filenameLabel.text = self.message.name
        
        // Message Date
        let messageDateAttribute = [
            NSFontAttributeName: ChatConstants.messageDateFont(),
            NSForegroundColorAttributeName: ChatConstants.messageDateColor()
        ]
        
        let messageTimestamp = Double(self.message.createdAt) / 1000.0
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.short
        let messageCreatedDate = NSDate(timeIntervalSince1970: messageTimestamp)
        let messageDateString = dateFormatter.string(from: messageCreatedDate as Date)
        let messageDateAttributedString = NSMutableAttributedString(string: messageDateString, attributes: messageDateAttribute)
        self.messageDateLabel.attributedText = messageDateAttributedString
        
        // Seperator Date
        let seperatorDateFormatter = DateFormatter()
        seperatorDateFormatter.dateStyle = DateFormatter.Style.medium
        self.dateSeperatorLabel.text = seperatorDateFormatter.string(from: messageCreatedDate as Date)
        
        // Relationship between the current message and the previous message
        self.profileImageView.isHidden = false
        self.nicknameLabelHeight.constant = 19.0
        self.nicknameLabelBottomMargin.constant = 10.0
        if self.prevMessage != nil {
            // Day Changed
            let prevMessageDate = NSDate(timeIntervalSince1970: Double(self.prevMessage.createdAt) / 1000.0)
            let currMessageDate = NSDate(timeIntervalSince1970: Double(self.message.createdAt) / 1000.0)
            let prevMessageDateComponents = NSCalendar.current.dateComponents([.day, .month, .year], from: prevMessageDate as Date)
            let currMessagedateComponents = NSCalendar.current.dateComponents([.day, .month, .year], from: currMessageDate as Date)
            
            if prevMessageDateComponents.year != currMessagedateComponents.year || prevMessageDateComponents.month != currMessagedateComponents.month || prevMessageDateComponents.day != currMessagedateComponents.day {
                // Show date seperator.
                self.dateSeperatorContainerView.isHidden = false
                self.dateContainerHeight.constant = 24.0
                self.dateContainerTopMargin.constant = 10.0
                self.dateContainerBottomMargin.constant = 10.0
            }
            else {
                // Hide date seperator.
                self.dateSeperatorContainerView.isHidden = true
                self.dateContainerHeight.constant = 0
                self.dateContainerBottomMargin.constant = 0
                
                // Continuous Message
                if self.prevMessage is SBDAdminMessage {
                    self.dateContainerTopMargin.constant = 10.0
                }
                else {
                    var prevMessageSender: SBDUser?
                    var currMessageSender: SBDUser?
                    
                    if self.prevMessage is SBDUserMessage {
                        prevMessageSender = (self.prevMessage as! SBDUserMessage).sender
                    }
                    else if self.prevMessage is SBDFileMessage {
                        prevMessageSender = (self.prevMessage as! SBDFileMessage).sender
                    }
                    
                    currMessageSender = self.message.sender
                    
                    if prevMessageSender != nil && currMessageSender != nil {
                        if prevMessageSender?.userId == currMessageSender?.userId {
                            // Reduce margin
                            self.dateContainerTopMargin.constant = 5.0
                            self.profileImageView.isHidden = true
                            self.nicknameLabelHeight.constant = 0
                            self.nicknameLabelBottomMargin.constant = 0
                        }
                        else {
                            // Set default margin.
                            self.profileImageView.isHidden = false
                            self.dateContainerTopMargin.constant = 10.0
                            self.nicknameLabelHeight.constant = 19.0
                            self.nicknameLabelBottomMargin.constant = 10.0
                        }
                    }
                    else {
                        self.dateContainerTopMargin.constant = 10.0
                    }
                }
            }
        }
        else {
            // Show date seperator.
            self.dateSeperatorContainerView.isHidden = false
            self.dateContainerHeight.constant = 24.0
            self.dateContainerTopMargin.constant = 10.0
            self.dateContainerBottomMargin.constant = 10.0
        }
        
        self.layoutIfNeeded()
    }
    
    func setPreviousMessage(aPrevMessage: SBDBaseMessage?) {
        self.prevMessage = aPrevMessage
    }
    
    func getHeightOfViewCell() -> CGFloat {
        let height = self.dateContainerTopMargin.constant + self.dateContainerHeight.constant + self.dateContainerBottomMargin.constant + self.messageContainerTopPadding.constant + self.nicknameLabelHeight.constant + self.nicknameLabelBottomMargin.constant + self.fileContainerHeight.constant + self.messageContainerBottomPadding.constant
        
        return height
    }
}
