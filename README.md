# Bitstream
Swift API to easily pack/unpack data 1 to 64 bits at a time.

<p>
<a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/Swift4-compatible-orange.svg?style=flat" alt="Swift 4 compatible" /></a>
<a href="https://raw.githubusercontent.com/ekscrypto/Bitstream/master/LICENSE"><img src="http://img.shields.io/badge/license-MIT-blue.svg?style=flat" alt="License: MIT" /></a>
</p>

## Motivation
Under certain circumstances packing data in as little data bytes as possible becomes critical.  While data compression can typically do a pretty good job, if you know a value has a possible value range between 0 and 25, storing this value in 5 bits rather than a typical 8-bit integer represents a 37% saving.  A variable with range 1-3 would be stored in a 2 bits and represents a 75% saving.  When used appropriately, this technique can dramatically improve data cache hits, data storage requirements and cut down on bandwidth costs.

This library was originally developed for Piti Piti Pa Djembe Studio, which uses it to compress musical instrument partitions into QRCodes.

## Bit-Packing Pattern
Stream stores bits MSB-first, extracted values are returned LSB-aligned for ease of use.

## TODO:
* Add support for LSB-first packing

Dependencies:
- Bitter: https://github.com/uraimo/Bitter

## Usage

### Writing
    let stream = Bitstream()
    stream.setNextBit(1)
    stream.setNextbit(0)
    stream.setNextBit(1)
    let streamData = stream.finalizedData()
    // streamData = 101 with padding 00000 -> 10100000b -> 0xA0

    let stream2 = Bitstream(data: Data())
    stream.setNextBits( 4, 0x12345678) // uses lowest 4 bits of provided value
    stream.setNextBits( 2, 0x00ABCDEF) // uses lowest 2 bits of provided value
    stream.setNextBit(0)
    stream.setNextBit(1)
    let stream2Data = stream2.finalizedData()
    // stream2Data = 1000 11 0 1 -> 10001101b -> 0x8D

### Reading

    // streamData == Data() with content: 01 23 45 67 89 AB CD EF
    let stream = Bitstream(data: streamData)
    let v1 = stream.getNextBits(4)
    let v2 = stream.getNextBits(8)
    let v3 = stream.getNextBits(3)
    let v4 = stream.getNextBit()
    let v5 = stream.getNextBits(12)
    // v1 = 0000b
    // v2 = 00010010b
    // v3 = 001b
    // v4 = 1b
    // v5 = 010001010110b
