//
//  NFCManager.swift
//  app
//
//  Created by Jesus Lopez on 24/3/26.
//

import SwiftUI
import Foundation
import CoreNFC
import Combine

class NFCManager: NSObject, ObservableObject, NFCNDEFReaderSessionDelegate {
    @Published var scannedData: String = "No data scanned yet"
    
    private var session: NFCNDEFReaderSession?
    private var isWriting = false
    private var usernameToWrite = ""

    // Start a session to Read
    func startScanning() {
        isWriting = false
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        session?.alertMessage = "Hold your iPhone near the tag to read."
        session?.begin()
    }

    // Start a session to Write
    func startWriting(username: String) {
        isWriting = true
        usernameToWrite = username
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        session?.alertMessage = "Hold your iPhone near the tag to write data."
        session?.begin()
    }

    // MARK: - Delegate Methods
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        print("NFC session became active")
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        guard !isWriting else { return }

        guard let message = messages.first else {
            updateScannedData("Tag is empty.")
            return
        }

        updateScannedData(decodeMessage(message) ?? "Could not decode data.")
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        if tags.count > 1 {
            session.alertMessage = "More than one tag detected. Please present only one tag."
            session.restartPolling()
            return
        }

        guard let tag = tags.first else {
            session.invalidate(errorMessage: "No tag found.")
            return
        }

        session.connect(to: tag) { error in
            if let error = error {
                session.invalidate(errorMessage: "Connection failed: \(error.localizedDescription)")
                return
            }

            if self.isWriting {
                let dateString = ISO8601DateFormatter().string(from: Date())
                let jsonString = "{\"user\": \"\(self.usernameToWrite)\", \"date\": \"\(dateString)\"}"

                guard let payload = NFCNDEFPayload.wellKnownTypeTextPayload(
                    string: jsonString,
                    locale: Locale(identifier: "en")
                ) else {
                    session.invalidate(errorMessage: "Could not create the NDEF payload.")
                    return
                }

                let message = NFCNDEFMessage(records: [payload])

                tag.queryNDEFStatus { status, _, error in
                    if let error = error {
                        session.invalidate(errorMessage: "Could not query tag status: \(error.localizedDescription)")
                        return
                    }

                    switch status {
                    case .readWrite:
                        tag.writeNDEF(message) { error in
                            if let error = error {
                                session.invalidate(errorMessage: "Write failed: \(error.localizedDescription)")
                            } else {
                                session.alertMessage = "Successfully written!"
                                session.invalidate()
                            }
                        }
                    case .readOnly:
                        session.invalidate(errorMessage: "Tag is read-only.")
                    case .notSupported:
                        session.invalidate(errorMessage: "Tag does not support NDEF.")
                    @unknown default:
                        session.invalidate(errorMessage: "Tag status is unsupported.")
                    }
                }
            } else {
                tag.readNDEF { message, error in
                    if let error = error {
                        session.invalidate(errorMessage: "Read failed: \(error.localizedDescription)")
                        return
                    }
                    
                    if let message {
                        self.updateScannedData(self.decodeMessage(message) ?? "Could not decode data.")
                        session.alertMessage = "Tag Read!"
                        session.invalidate()
                    } else {
                        session.invalidate(errorMessage: "Tag is empty.")
                    }
                }
            }
        }
    }
    
    private func parseNDEFTextRecord(_ record: NFCNDEFPayload) -> String? {
        let textPayload = record.wellKnownTypeTextPayload()
        if let text = textPayload.0 {
            return text
        }

        let payload = record.payload
        guard payload.count > 0 else { return nil }
        
        // The first byte contains the length of the language code
        let statusByte = payload[0]
        let languageCodeLength = Int(statusByte & 0x3F) // First 6 bits
        let headerLength = 1 + languageCodeLength
        
        guard payload.count > headerLength else { return nil }
        
        // Grab everything after the header
        let data = payload.advanced(by: headerLength)
        return String(data: data, encoding: .utf8)
    }

    private func decodeRecord(_ record: NFCNDEFPayload) -> String? {
        if let text = parseNDEFTextRecord(record) {
            return text
        }

        if let utf8String = String(data: record.payload, encoding: .utf8),
           !utf8String.isEmpty {
            return utf8String
        }

        return nil
    }

    private func decodeMessage(_ message: NFCNDEFMessage) -> String? {
        let decodedRecords = message.records.compactMap(decodeRecord)
        guard !decodedRecords.isEmpty else { return nil }
        return decodedRecords.joined(separator: "\n\n")
    }

    private func updateScannedData(_ value: String) {
        DispatchQueue.main.async {
            self.scannedData = value
        }
    }

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print("Session invalidated: \(error.localizedDescription)")
    }
}
