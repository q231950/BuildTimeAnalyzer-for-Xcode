import Foundation
import PeerKit
import MultipeerConnectivity

enum Event: String {
    case take
}

struct ConnectionManager {

    // MARK: Properties
    fileprivate static var peers: [MCPeerID] {
        return PeerKit.session?.connectedPeers as [MCPeerID]? ?? []
    }

    // MARK: Start
    static func start() {
        PeerKit.transceive(serviceType: "buildtime")
    }

    // MARK: Event Handling
    static func onConnect(_ run: PeerBlock?) {
        PeerKit.onConnect = run
    }

    static func onDisconnect(_ run: PeerBlock?) {
        PeerKit.onDisconnect = run
    }

    static func onEvent(_ event: Event, run: ObjectBlock?) {
        print("event: \(event) run: \(run)")
        if let run = run {
            PeerKit.eventBlocks[event.rawValue] = run
        } else {
            PeerKit.eventBlocks.removeValue(forKey: event.rawValue)
        }
    }

    // MARK: Sending
    static func sendEvent(_ event: Event, object: [String: String]? = nil,
                          toPeers peers: [MCPeerID]? = PeerKit.session?.connectedPeers) {
        let o = object ?? [:]
        PeerKit.sendEvent(event.rawValue, object: o as AnyObject , toPeers: peers)
    }

    static func sendEventForEach(_ event: Event, objectBlock: () -> ([String: String])) {
        for peer in ConnectionManager.peers {
            ConnectionManager.sendEvent(event, object: objectBlock(), toPeers: [peer])
        }
    }
}
