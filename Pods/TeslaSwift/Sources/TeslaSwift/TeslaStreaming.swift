//
//  TeslaStreaming.swift
//  TeslaSwift
//
//  Created by Joao Nunes on 23/04/2017.
//  Copyright © 2017 Joao Nunes. All rights reserved.
//

import Foundation
import Starscream

public struct TeslaStreamAuthentication {
    
    let email: String
    let vehicleToken: String
    let vehicleId: String
    
    public init(email: String, vehicleToken: String, vehicleId: String) {
        self.email = email
        self.vehicleToken = vehicleToken
        self.vehicleId = vehicleId
    }
}

/*
 * Streaming class takes care of the different types of data streaming from Tesla servers
 *
 */
public class TeslaStreaming {
    
    var debuggingEnabled = true
    var httpStreaming: WebSocket
    
    public init() {
        httpStreaming = WebSocket(url: URL(string: "wss://streaming.vn.teslamotors.com/streaming/")!)
    }
    
    public func openStream(authentication: TeslaStreamAuthentication, dataReceived: @escaping (TeslaStreamingEvent) -> Void) {
        
        let url = httpStreaming.currentURL
        
        logDebug("Opening Stream to: \(url)", debuggingEnabled: debuggingEnabled)
        
        httpStreaming.onConnect = { [weak self] in
            guard let strongSelf = self else { return }
            
            DispatchQueue.main.async {
                
                logDebug("Stream open", debuggingEnabled: strongSelf.debuggingEnabled)
                
                if let authMessage = StreamAuthentication(email: authentication.email, vehicleToken: authentication.vehicleToken, vehicleId: authentication.vehicleId), let string = try? teslaJSONEncoder.encode(authMessage) {
                    
                    strongSelf.httpStreaming.write(data: string)
                    dataReceived(TeslaStreamingEvent.open)
                } else {
                    dataReceived(TeslaStreamingEvent.error(NSError(domain: "TeslaSwift", code: 0, userInfo: ["errorDescription" : "Failed to parse authentication data"])))
                    strongSelf.closeStream()
                }
            }
        }

        httpStreaming.onData = { (data: Data) in
            
            logDebug("Stream data: \(data.count)", debuggingEnabled: self.debuggingEnabled)
            
            guard let message = try? teslaJSONDecoder.decode(StreamMessage.self, from: data) else { return }
            
            DispatchQueue.main.async {
                let type = message.messageType
                switch type {
                case "control:hello":
                    logDebug("Stream got hello", debuggingEnabled: self.debuggingEnabled)
                    break
                case "data:update":
                    let values = message.value
                    let event = StreamEvent(values: values)
                    logDebug("Stream got data: \(values)", debuggingEnabled: self.debuggingEnabled)
                    dataReceived(TeslaStreamingEvent.event(event))
                case "data:error":
                    logDebug("Stream got data error: \(message.value), \(String(describing: message.errorType))", debuggingEnabled: self.debuggingEnabled)
                    dataReceived(TeslaStreamingEvent.error(NSError(domain: "TeslaError", code: 0, userInfo: [message.value : message.errorType ?? ""])))
                    break
                default:
                    break
                }
            }
        }
        
        httpStreaming.onDisconnect = { (error: Error?) in
            DispatchQueue.main.async {
                if let error = error {
                    logDebug("Stream error: \(String(describing: error))", debuggingEnabled: self.debuggingEnabled)
                    dataReceived(TeslaStreamingEvent.error(error))
                } else {
                    logDebug("Stream disconnected", debuggingEnabled: self.debuggingEnabled)
                    dataReceived(TeslaStreamingEvent.disconnected)
                }
            }
        }
        
        httpStreaming.onPong = { [weak self] (data: Data?) in
            guard let strongSelf = self else { return }
            
            DispatchQueue.main.async {
                
                logDebug("Stream Pong", debuggingEnabled: strongSelf.debuggingEnabled)
                
                strongSelf.httpStreaming.write(pong: Data())
            }
        }
		
		httpStreaming.connect()
	}
	
	public func closeStream() {
		httpStreaming.disconnect()
		logDebug("Stream closed", debuggingEnabled: self.debuggingEnabled)
	}

}
