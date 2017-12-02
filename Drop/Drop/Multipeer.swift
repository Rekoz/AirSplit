//
//  Multipeer.swift
//  Drop
//
//  Created by dingxingyuan on 11/3/17.
//  Copyright © 2017 Camille Zhang. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol MultipeerManagerDelegate {
    func deviceDetection(manager : MultipeerManager, detectedDevice: String)
    func loseDevice(manager : MultipeerManager, removedDevice: String)
}

/// Multipeer API delegate
class MultipeerManager : NSObject {
    
    private let serviceName = "AirSplit"
    private var myPeerId : MCPeerID
    private var serviceAdvertiser : MCNearbyServiceAdvertiser
    private var serviceBrowser : MCNearbyServiceBrowser
    
    var delegate : MultipeerManagerDelegate?
    
    /// constructor
    override init() {
        self.myPeerId = MCPeerID(displayName: UIDevice.current.name)
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: serviceName)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceName)
        super.init()
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    /// set the display peer name as one's full name
    ///
    /// - Parameter name: user's full name
    func setPeerDisplayName(name: String) {
        self.myPeerId = MCPeerID(displayName: name)
    }
    
    func getPeerDisplayName() -> String {
        return self.myPeerId.displayName
    }
    
    /// make one device visible by browser
    func startAdvertising() {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: serviceName)
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
    }
    
    /// enable one device to browse surrounding visible devices
    func startBrowsing() {
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceName)
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
    }
}

extension MultipeerManager : MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
    }
}

extension MultipeerManager : MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    /// When the browser detects a new device, we update the people collection view accordingly
    ///
    /// - Parameters:
    ///   - browser: MCNearbyServiceBrowser
    ///   - peerID: new device's peer ID
    ///   - info: browser's information
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        NSLog("%@", "invitePeer: \(peerID)")
        self.delegate?.deviceDetection(manager: self, detectedDevice: peerID.displayName)
    }
    
    /// When the browser detects a peer loss, we update the people collection view accordingly
    ///
    /// - Parameters:
    ///   - browser: MCNearbyServiceBrowser
    ///   - peerID: lost device's peer ID
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
        self.delegate?.loseDevice(manager: self, removedDevice: peerID.displayName)
    }
}

