//
//  Bitstream.swift
//  MIT License
//
//  Created by Dave Poirier on 2017-06-19.
//  Copyright © 2017 Dave Poirier.
//

import Foundation
import Bitter

public class Bitstream: NSObject {

    private var data: Data
    private var bitsLeftInReadBuffer: Int = 0
    private var readByteIndex: Int = 0
    private var readBuffer: UInt8 = 0
    private var writeBuffer: UInt8 = 0
    private var bitsLeftInWriteBuffer: Int = 8

    enum Mode {
        case readOnly
        case writeOnly
    }
    let mode: Mode

    public override init() {
        self.data = Data()
        self.mode = .writeOnly
    }

    public init(data: Data) {
        self.data = data
        self.mode = .readOnly
    }

    public func getNextBit() -> UInt8? {
        guard mode == .readOnly else { return nil }
        if bitsLeftInReadBuffer == 0, readByteIndex < data.count {
            readBuffer = data[readByteIndex]
            bitsLeftInReadBuffer = 8
            readByteIndex += 1
        }
        guard bitsLeftInReadBuffer > 0 else { return nil }
        let bit = readBuffer.b7
        readBuffer = readBuffer << 1
        bitsLeftInReadBuffer -= 1
        return bit
    }

    public func getNextBits(_ bitsToRead: UInt8 ) -> UInt64? {
        guard
            mode == .readOnly,
            bitsToRead <= 64
            else { return nil }
        var bitsLeft = bitsToRead
        var combinedValue: UInt64 = 0
        while bitsLeft > 0 {
            guard let bit = getNextBit() else { return nil }
            combinedValue = combinedValue << 1
            combinedValue = combinedValue | bit.toU64
            bitsLeft -= 1
        }
        return combinedValue
    }

    public func setNextBit(_ bit: UInt8 ) {
        guard mode == .writeOnly else { return }
        if bitsLeftInWriteBuffer == 0 {
            data.append(writeBuffer)
            writeBuffer = 0
            bitsLeftInWriteBuffer = 8
        }
        writeBuffer = (writeBuffer << 1) | (bit & 0x01)
        bitsLeftInWriteBuffer -= 1
    }

    public func setNextBits(_ bitsToWrite: UInt8, from bits: UInt64) {
        guard
            mode == .writeOnly,
            bitsToWrite <= 64
            else { return }
        var shiftedBits = bits << (64 - bitsToWrite.toU64)
        var bitsLeftToWrite = bitsToWrite
        while bitsLeftToWrite > 0 {
            let bit = shiftedBits >> 63
            setNextBit(bit.toU8)
            shiftedBits = shiftedBits << 1
            bitsLeftToWrite -= 1
        }
    }

    public func finalizedData() -> Data {
        guard
            mode == .writeOnly
            else { return data }
        setNextBits(UInt8(bitsLeftInWriteBuffer), from: 0)
        if bitsLeftInWriteBuffer != 8 {
            data.append(writeBuffer)
        }
        let finalizedData = data
        return finalizedData
    }

    public func dump() {
        var bits = ""
        while let bit = getNextBit() {
            bits += "\(bit)"
        }
        print(bits)
    }
}
