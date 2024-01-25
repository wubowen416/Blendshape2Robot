//
//  SolverTcpClient.swift
//  Blendshape2Robot
//
//  Created by Bowen Wu on 2024/01/19.
//

import Foundation
import NIO

class SolverTcpClient {
    var connected = false
    var host = ""
    var port = 0
    var messages: [String] = []
    private let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    private var channel: Channel?
    private lazy var clientBootstrap = ClientBootstrap(group: group)
        .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
        .channelOption(ChannelOptions.socket(IPPROTO_TCP, TCP_NODELAY), value: 1)
        .channelOption(ChannelOptions.recvAllocator,
                       value: AdaptiveRecvByteBufferAllocator())
        .channelInitializer { channel in
            channel.pipeline.addHandler(self)
        }
    private var receiveBuffer: ByteBuffer?
    private var expectedLength: Int?
    private var semaphore = DispatchSemaphore(value: 0)
    
    deinit {
        do {
            try group.syncShutdownGracefully()
        } catch let error {
            messages.append("Could not shutdown gracefully - forcing exit (\(error.localizedDescription))!")
            exit(0)
        }
    }
    
    func connect_host() {
        do {
            messages.append("Try connect to \(self.host):\(self.port)")
            channel = try clientBootstrap.connect(host: self.host, port: self.port).wait()
            connected = true
        } catch let error {
            messages.append("Failed to connect! (\(error.localizedDescription)")
        }
    }
    
    func disconnect() {
        if connected {
            channel?.close(mode: .all, promise: nil)
            connected = false
        }
    }
    
    func create_packet_with_size(_ str: String) -> ByteBuffer? {
        // Ensure the channel is available
        guard let channel = channel else {
            return nil
        }

        // Allocate buffer for the input string
        var dataBuffer = channel.allocator.buffer(string: str)

        // Calculate the length of the data (in bytes)
        let dataLength = dataBuffer.readableBytes

        // Allocate a new buffer for the 4-byte length
        var lengthBuffer = channel.allocator.buffer(capacity: 4)
        lengthBuffer.writeInteger(UInt32(dataLength), endianness: .big, as: UInt32.self)

        // Create a new buffer to hold both the length and the data
        var packetBuffer = channel.allocator.buffer(capacity: 4 + dataLength)
        packetBuffer.writeBuffer(&lengthBuffer)
        packetBuffer.writeBuffer(&dataBuffer)

        return packetBuffer
    }
    
    func request_data_from_server(_ request: String) -> String {
        DispatchQueue.global(qos: .default).async {
            self.messages.append("Send request to server")
            let packet2send = self.create_packet_with_size(request)
            self.channel?.writeAndFlush(packet2send, promise: nil)
        }
        messages.append("Wating for all data...")
        semaphore.wait()
        let dataBuffer = receiveBuffer!
        receiveBuffer = nil
        expectedLength = nil
        return String(buffer: dataBuffer)
    }
}

extension SolverTcpClient: ChannelInboundHandler {
    typealias InboundIn = ByteBuffer
    typealias OutboundOut = ByteBuffer
    
    func channelActive(context: ChannelHandlerContext) {
//        let message = "Solver Client"
//        var buffer = context.channel.allocator.buffer(capacity: message.utf8.count)
//        buffer.writeString(message)
//        context.writeAndFlush(wrapOutboundOut(buffer), promise: nil)
        messages.append("Connected.")
    }
    
    public func channelInactive(context: ChannelHandlerContext) {
        context.close(mode: .all, promise: nil)
        messages.append("Connection closed.")
    }
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        var incomingData = self.unwrapInboundIn(data)
        
        // Append incoming data to the buffer
        if expectedLength == nil {
            guard let length = incomingData.readInteger(endianness: .big, as: UInt32.self) else {
                return
            }
            expectedLength = Int(length)
            receiveBuffer = context.channel.allocator.buffer(capacity: expectedLength!)
        }
        
        receiveBuffer?.writeBuffer(&incomingData)
        
        // Check if a complete message is received
        if receiveBuffer?.readableBytes == expectedLength {
            messages.append("All data received. Send signal.")
            semaphore.signal()
        }
    }
    
    func errorCaught(context: ChannelHandlerContext, error: Error) {
        messages.append("error: \(error.localizedDescription)")
        context.close(promise: nil)
    }
}
