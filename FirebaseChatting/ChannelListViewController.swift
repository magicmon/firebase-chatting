//
//  ChannelListViewController.swift
//  Chatting
//
//  Created by magicmon on 2017. 4. 17..
//  Copyright © 2017년 magicmon. All rights reserved.
//

import UIKit
import Firebase

enum Section: Int {
    case createNewChannelSection = 0
    case currentChannelsSection
}

class ChannelListViewController: UITableViewController {
    
    var senderDisplayName: String?
    fileprivate var channels: [Channel] = []

    fileprivate lazy var channelRef: FIRDatabaseReference = FIRDatabase.database().reference().child("channels")
    fileprivate var channelRefHandle: FIRDatabaseHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        observeChannels()
    }
    
    deinit {
        if let refHandle = channelRefHandle {
            channelRef.removeObserver(withHandle: refHandle)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let channel = sender as? Channel {
            let chatVc = segue.destination as! ChatViewController
            
            chatVc.senderDisplayName = senderDisplayName ?? "guest"
            chatVc.channel = channel
            chatVc.channelRef = channelRef.child(channel.id)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let currentSection = Section(rawValue: section) else {
            return 0
        }
        
        switch currentSection {
        case .createNewChannelSection:
            return 1
        case .currentChannelsSection:
            return channels.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = (indexPath as NSIndexPath).section == Section.createNewChannelSection.rawValue ? "NewChannel" : "ExistingChannel"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        if (indexPath as NSIndexPath).section == Section.createNewChannelSection.rawValue {
            if let createNewChannelCell = cell as? CreateChannelCell {
                createNewChannelCell.touchedCell = { [weak self] name in
                    guard let name = name else {
                        return
                    }
                    
                    let channelItem = ["name": name]
                    self?.channelRef.childByAutoId().setValue(channelItem)
                }
            }
        } else if (indexPath as NSIndexPath).section == Section.currentChannelsSection.rawValue {
            cell.textLabel?.text = channels[(indexPath as NSIndexPath).row].name
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 1
        // WARNING: Don't actually do this in production!
        let fetchDuration: TimeInterval = 0
        FIRRemoteConfig.remoteConfig().fetch(withExpirationDuration: fetchDuration) { (status, error) in
            
            guard error == nil else {
                print ("Uh-oh. Got an error fetching remote values \(error)")
                return
            }
            
            // 2
            FIRRemoteConfig.remoteConfig().activateFetched()
            print ("Retrieved values from the cloud!")
            
            let title = FIRRemoteConfig.remoteConfig().configValue(forKey: "alertTitle")
            
            if title.stringValue == "true" {
                if (indexPath as NSIndexPath).section == Section.currentChannelsSection.rawValue {
                    let channel = self.channels[(indexPath as NSIndexPath).row]
                    self.performSegue(withIdentifier: "ShowChannel", sender: channel)
                }
            }
        }
    }
}

extension ChannelListViewController {
    func observeChannels() {
        channelRefHandle = channelRef.observe(.childAdded, with: { (snapshot) in
            print("snapshot.value: \(snapshot.value)")
            guard let channelData = snapshot.value as? Dictionary<String, Any> else {
                return
            }
            
            guard let name = channelData["name"] as? String, name.characters.count > 0 else {
                print("Error! Could not decode channel data")
                return
            }
            
            self.channels.append(Channel(id: snapshot.key, name: name))
            self.tableView.reloadData()
        })
    }
}
