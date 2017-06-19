//
//  Bitstream.swift
//  MIT License
//
//  Created by Dave Poirier on 2017-06-19.
//  Copyright © 2017 Dave Poirier.
//

import Foundation
import Bitter

class Bitstream : NSObject {

    private var data : Data

    private var bitsLeftInReadBuffer : Int = 0
    private var readByteIndex : Int = 0
    private var readBuffer : UInt8 = 0

    private var writeBuffer : UInt8 = 0
    private var bitsLeftInWriteBuffer : Int = 8

    init(data: Data ) {
        self.data = data
    }

    func getNextBit() -> UInt8! {
        if bitsLeftInReadBuffer == 0 && readByteIndex < data.count {
            readBuffer = data[readByteIndex]
            bitsLeftInReadBuffer = 8
            readByteIndex += 1
        }
        if bitsLeftInReadBuffer > 0 {
            let bit = readBuffer.b7
            readBuffer = readBuffer << 1
            bitsLeftInReadBuffer -= 1
            return bit
        }
        return nil
    }

    func getNextBits(_ bitsToRead : UInt8 ) -> UInt64! {
        if bitsToRead > 64 {
            return nil
        }

        var bitsLeft = bitsToRead
        var combinedValue : UInt64 = 0
        while bitsLeft > 0 {
            let bit = getNextBit()
            if bit == nil {
                return nil
            }
            combinedValue = combinedValue << 1
            combinedValue = combinedValue | bit!.toU64
            bitsLeft -= 1
        }
        return combinedValue
    }

    func setNextBit(_ bit : UInt8 ) {
        if( bitsLeftInWriteBuffer == 0 ) {
            data.append(writeBuffer)
            writeBuffer = 0
            bitsLeftInWriteBuffer = 8
        }
        writeBuffer = (writeBuffer << 1) | (bit & 0x01)
        bitsLeftInWriteBuffer -= 1
    }

    func setNextBits(_ bitsToWrite : UInt8, from bits: UInt64) {
        if( bitsToWrite > 64 ) {
            return
        }

        var shiftedBits = bits << (64-bitsToWrite.toU64)
        var bitsLeftToWrite = bitsToWrite
        while bitsLeftToWrite > 0 {
            let bit = shiftedBits >> 63
            setNextBit(bit.toU8)
            shiftedBits = shiftedBits << 1
            bitsLeftToWrite -= 1
        }
    }

    func finalizedData() -> Data {
        setNextBits(UInt8(bitsLeftInWriteBuffer), from: 0)
        let finalizedData = data
        return finalizedData
    }

    func dump() {
        var abort = false
        var bits = ""
        while abort == false {
            let bit = getNextBit()
            if bit == nil {
                abort = true
            } else {
                if bit! == 0 {
                    bits += "0"
                } else {
                    bits += "1"
                }
            }
        }
        print(bits)
    }
}
