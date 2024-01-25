//
//  MotionTcpClient.swift
//  Blendshape2Robot
//
//  Created by liu on 2023/02/10.
//

import Foundation
import NIO

class NikolaTcpClient {
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
    
    func send_ctl_cmd(_ dataArr: [Int]) {
        var str2send = "moveaxes"
        for (idx, cmd) in zip(dataArr.indices, dataArr) {
            str2send.append(" \(idx + 1) \(cmd) 100 200")
        }
        str2send.append("\n")
        if let buffer = channel?.allocator.buffer(string: str2send) {
            channel?.writeAndFlush(wrapOutboundOut(buffer), promise: nil)
        }
    }
}

extension NikolaTcpClient: ChannelInboundHandler {
    typealias InboundIn = ByteBuffer
    typealias OutboundOut = ByteBuffer
    
    func channelActive(context: ChannelHandlerContext) {
//        let message = "Motion Client"
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
        var _ = unwrapInboundIn(data)
    }
    
    func errorCaught(context: ChannelHandlerContext, error: Error) {
        messages.append("error: \(error.localizedDescription)")
        context.close(promise: nil)
    }
}
