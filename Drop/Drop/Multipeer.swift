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
}

class MultipeerManager : NSObject {
    
    private let serviceName = "AirSplit"
    private var myPeerId : MCPeerID
    private var serviceAdvertiser : MCNearbyServiceAdvertiser
    private var serviceBrowser : MCNearbyServiceBrowser
    private var session : MCSession
    
    var delegate : MultipeerManagerDelegate?
    
    override init() {
        self.myPeerId = MCPeerID(displayName: UIDevice.current.name)
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: serviceName)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceName)
        self.session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .required)
        super.init()
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    func setPeerDisplayName(name: String) {
        self.myPeerId = MCPeerID(displayName: name)
    }
    
    func setSession() {
        self.session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
    }
    
    func startAdvertising() {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: serviceName)
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
    }
    
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
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        NSLog("%@", "invitePeer: \(peerID)")
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 120)
        self.delegate?.deviceDetection(manager: self, detectedDevice: peerID.displayName)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
    }
}

