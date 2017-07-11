//
//  main.swift
//  BuildBloomFilteriOS
//
//  Created by Tim Palade on 3/13/17.
//  Copyright © 2017 Tim Palade. All rights reserved.
//

import Foundation

//load the txt file with the blacklist

//For now: load blacklist from disk

let path = "/Users/timpalade/src/BuildBloomFilteriOS/BuildBloomFilteriOS/blacklist.txt"

let raw_file_string = try String.init(contentsOfFile: path)

let lines = raw_file_string.components(separatedBy: .newlines)

let clean_lines = lines.map {string -> String in
    let components = string.components(separatedBy: "\t")
    return components.first ?? ""
}

//write the data to a specific path. In the browser create the bloomfilter from this file with unarchive. 
let writeURL = URL.init(fileURLWithPath: "/Users/timpalade/src/BuildBloomFilteriOS/BuildBloomFilteriOS/bloomData.bloom", isDirectory: false)


//create filter
let bloomFilter = BloomFilter(n: clean_lines.count, p: 0.000001)

bloomFilter.insert(clean_lines)

let bloomFilterData = bloomFilter.archived()

do {
   try bloomFilterData.write(to: writeURL)
}
catch let error as NSError{
    debugPrint(error.description)
}


//after this line , tests.
do {
    
    let secondData = try Data(contentsOf: writeURL)
    
    let secondBloomFilter = BloomFilter.unarchived(fromData: secondData)
    
    for line in clean_lines{
        let result = secondBloomFilter?.query(line)
        if result == false{
            NSException.init(name: NSExceptionName(rawValue: "Exception testing"), reason: "A site in the list returned false when queried", userInfo: nil).raise()
        }
    }
    
    print((secondBloomFilter?.query("google.com"))! as Bool)
}














