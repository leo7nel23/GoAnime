//
//  UIImageView+Ext.swift
//
//
//  Created by 賴柏宏 on 2022/7/18.
//

import Foundation
import UIKit
import CommonCrypto

public protocol ImageHandlerProtocol {
    func save(image: UIImage, key: String)
    func load(key: String) -> UIImage?
}

public final class ImageCacheHandler {
    public static let shared: ImageCacheHandler = ImageCacheHandler(handler: FileManager.default)
    
    let operation: OperationQueue = {
        let op = OperationQueue()
        op.maxConcurrentOperationCount = 10
        return op
    }()
    
    let imageHandler: ImageHandlerProtocol
    
    init(handler: ImageHandlerProtocol) {
        self.imageHandler = handler
    }
    
    func loadImage(url: URL) async throws -> UIImage {
        if let image = imageHandler.load(key: url.absoluteString) {
            return image
        }
        
        return try await withCheckedThrowingContinuation({ continuation in
            operation.addOperation { [weak self] in
                if let data = try? Data(contentsOf: url),
                   let image = UIImage(data: data) {
                    
                    self?.imageHandler.save(image: image, key: url.absoluteString)
                    continuation.resume(returning: image)
                } else {
                    continuation.resume(returning: UIImage())
                }
            }
        })
    }
}

public extension UIImageView {
    func setImage(
        _ path: String,
        handler: ImageCacheHandler = ImageCacheHandler.shared
    ) {
        guard let url = URL(string: path) else { return }
        Task {
            image = try? await handler.loadImage(url: url)
        }
    }
}

extension FileManager: ImageHandlerProtocol {
    public func save(image: UIImage, key: String) {
        do {
            let cacheDirectory = try url(
                for: .cachesDirectory,
                in: .userDomainMask,
                appropriateFor:nil,
                create:false
            )
            let fileURL = cacheDirectory.appendingPathComponent(key.imageFileName)
            if let imageData = image.jpegData(compressionQuality: 1) {
                try imageData.write(to: fileURL)
            }
        } catch {
            print(error)
        }
    }
    
    public func load(key: String) -> UIImage? {
        do {
            let cacheDirectory = try url(
                for: .cachesDirectory,
                in: .userDomainMask,
                appropriateFor:nil,
                create:false
            )
            let fileURL = cacheDirectory.appendingPathComponent(key.imageFileName)
            if fileExists(atPath: fileURL.path) {
                return UIImage(contentsOfFile: fileURL.path)
            }
        } catch {
            print(error)
        }
        return nil
    }
}

extension String {
    fileprivate var imageFileName: String { md5 + ".jpg" }
    
    private var md5: String {
        guard let data = data(using: .utf8) else {
            return self
        }
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
            return CC_MD5(bytes.baseAddress, CC_LONG(data.count), &digest)
        }
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
