//
//  BitArray.swift
//  BuildBloomFilteriOS
//
//  Created by Tim Palade on 3/14/17.
//  Copyright © 2017 Tim Palade. All rights reserved.
//

import Foundation

final class BitArray: NSObject, NSCoding {
    
    //Array of bits manipulation
    private var array: [UInt8] = []
    
    init(count:Int) {
        super.init()
        self.array = self.buildArray(count: count)
    }
    
    public func valueOfBit(at index:Int) -> Bool{
        return self.valueOfBit(in: self.array, at: index)
    }
    
    public func setValueOfBit(value:Bool, at index: Int){
        self.setValueOfBit(in: &self.array, at: index, value: value)
    }
    
    public func count() -> Int{
        return self.array.count * 8 - 1
    }
    
    //Archieve/Unarchive
    
    func archived() -> Data {
        return NSKeyedArchiver.archivedData(withRootObject: self)
    }
    
    class func unarchived(fromData data: Data) -> BitArray? {
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? BitArray
    }
    
    //NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.array, forKey:"internalBitArray")
    }
    
    init?(coder aDecoder: NSCoder) {
        super.init()
        let array:[UInt8] = aDecoder.decodeObject(forKey:"internalBitArray") as? [UInt8] ?? []
        self.array = array
    }
    
    //Private API
    
    private func valueOfBit(in array:[UInt8], at index:Int) -> Bool{
        checkIndexBound(index: index, lowerBound: 0, upperBound: array.count * 8 - 1)
        let (_arrayIndex, _bitIndex) = bitIndex(at:index)
        let bit = array[_arrayIndex]
        return valueOf(bit: bit, atIndex: _bitIndex)
    }
    
    private func setValueOfBit(in array: inout[UInt8], at index:Int, value: Bool){
        checkIndexBound(index: index, lowerBound: 0, upperBound: array.count * 8 - 1)
        let (_arrayIndex, _bitIndex) = bitIndex(at:index)
        let bit = array[_arrayIndex]
        let newBit = setValueFor(bit: bit, value: value, atIndex: _bitIndex)
        array[_arrayIndex] = newBit
    }
    
    //bit masks
    private let masks: [UInt8] = [
        0b10000000,
        0b01000000,
        0b00100000,
        0b00010000,
        0b00001000,
        0b00000100,
        0b00000010,
        0b00000001
    ]
    
    private let negative: [UInt8] = [
        0b01111111,
        0b10111111,
        0b11011111,
        0b11101111,
        0b11110111,
        0b11111011,
        0b11111101,
        0b11111110
    ]
    
    //return (arrayIndex for UInt8 containing the bit ,bitIndex inside the UInt8)
    private func bitIndex(at index:Int) -> (Int,Int){
        return(Int(floor(Double(index)/8)),index % 8)
    }
    
    private func buildArray(count:Int) -> [UInt8] {
        //words contain 8 bits each
        let numWords = Int(ceil(Double(count)/8))
        return Array.init(repeating: UInt8(0), count: numWords)
    }
    
    //Bit manipulation
    private func valueOf(bit: UInt8, atIndex index:Int) -> Bool {
        checkIndexBound(index: index, lowerBound: 0, upperBound: 7)
        return (bit & masks[index] != 0)
    }
    
    private func setValueFor(bit: UInt8, value: Bool,atIndex index: Int) -> UInt8{
        checkIndexBound(index: index, lowerBound: 0, upperBound: 7)
        if value {
            return (bit | masks[index])
        }
        return bit & negative[index]
    }
    
    //Util
    private func checkIndexBound(index:Int, lowerBound:Int, upperBound:Int){
        if(index < lowerBound || index > upperBound)
        {
            NSException.init(name: NSExceptionName(rawValue: "BitArray Exception"), reason: "index out of bounds", userInfo: nil).raise()
        }
    }
}
