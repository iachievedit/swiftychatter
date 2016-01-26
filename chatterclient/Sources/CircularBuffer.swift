//
//  CircularBuffer.swift
//  CircularBuffer
//
//  Created by Tomasz Piekarczyk on 29/11/14.
//  Copyright (c) 2014 Tomasz Piekarczyk. All rights reserved.
//

//TODO: subscript
//TODO: redesign so that reading does not consume elements (this will make it concise with enumeration

import Foundation

struct CircularBuffer<T>: SequenceType {
    
    typealias Generator = CircularBufferGenerator<T>
    
    private var data: Array<T?>
    private var nextReadIndex: Int = 0
    private var nextWriteIndex: Int = 0

    
    //count of filled slots
    var count: Int {
        
        get {
            return self.asArray().count
        }
        
    }
    
    
    //size of the whole buffer
    var size: Int {
        
        get {
            return data.count
        }
        
    }
    
    
    // MARK: initializers
    init(array: Array<T>) {
        
        self.init(array:array, size: array.count)
        
    }
    
    
    init(size: Int) {
        
        self.init(array: Array<T>(), size:size)
        
    }
    
    
    init(array: Array<T>, size: Int) {
        
        //TODO: assert that size it at least == array.count
        data = Array<T?>(array.map{Optional<T>($0)})
        
        for _ in array.count ..< size {
            data.append(nil)
        }
        
    }

    // MARK: accessing elements
    mutating func readNext() -> T? {
        
        if data[nextReadIndex] != nil  { //nextWriteIndex
            
            var empty = Optional<T>()
            swap(&data[nextReadIndex], &empty)
            nextReadIndex = (nextReadIndex + 1) % data.count
            return empty
            
        }
        else {
            
            return nil
            
        }
    }
    
    
    mutating func writeNext(element: T) -> Void {
        
        let eldestElement = data[nextWriteIndex]
        let prevWriteIndex = nextWriteIndex
        
        data[nextWriteIndex] = element
        
        nextWriteIndex = (nextWriteIndex + 1) % data.count
        
        if prevWriteIndex == nextReadIndex && eldestElement != nil { //if eldest was overwritten and was not empty - advance
            nextReadIndex = nextWriteIndex
        }
        
    }
    
    // MARK: utility methods
    func isFull() -> Bool {
        
        return self.asArray().count == data.count
        
    }
    
    
    func isEmpty() -> Bool {
        
        return self.asArray().count == 0
        
    }
    

    //returns only existing elements, index 0 is eldest
    func asArray() -> Array<T>
    {
        
        return data.filter{$0 != nil}.map{$0!}
        
    }

    
    func generate() -> Generator {
        
        //TODO: copies self, issue?
        return Generator(buffer: self)
        
    }
}



// MARK: - Generator for supporting enumeration
struct CircularBufferGenerator<T>: GeneratorType {

    typealias Element = T
    var buffer: CircularBuffer<T>
    
    
    init(buffer: CircularBuffer<T>) {
        
        self.buffer = buffer
        
    }
    
    
    mutating func next() -> Element? {
        
        return buffer.readNext()
        
    }
}


// MARK: - ArrayLiteralConvertible extension
extension CircularBuffer: ArrayLiteralConvertible {
    
    init(arrayLiteral elements: T...) {
        
        self.init(array:elements)

    }
}



