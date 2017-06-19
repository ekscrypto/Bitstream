# Bitstream
Swift API to easily pack/unpack individual bits as NSData

Dependencies:
    Bitter - https://github.com/uraimo/Bitter

## Usage

### Writing
    let stream = Bitstream.init(data: Data())
    stream.setNextBit(1)
    stream.setNextbit(0)
    stream.setNextBit(1)
    let streamData = stream.finalizedData()
    // streamData = 101 with padding 00000 -> 10100000b -> 0xA0

    let stream2 = Bitstream.init(data: Data())
    stream.setNextBits( 4, 0x12345678) // uses lowest 4 bits of provided value
    stream.setNextBits( 2, 0x00ABCDEF) // uses lowest 2 bits of provided value
    stream.setNextBit(0)
    stream.setNextBit(1)
    let stream2Data = stream2.finalizedData()
    // stream2Data = 1000 11 0 1 -> 10001101b -> 0x8D

### Reading

    // streamData == Data() with content: 01 23 45 67 89 AB CD EF
    let stream = Bitstream.init(data: streamData)
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
