//
//  ExplorePageData.swift
//  ARExperiment
//
//  Created by David Drobny on 20/11/2024.
//
import UIKit

struct BlobAnimation: Codable {
    // TODO: this should be uniform data format for all the possible data given:
    // Supports .mp3, .mov, .gif, .svg, etc.
}

struct AnimationPreview {
    // uniform UID
    let uid: String
    
    // data
    let animation: BlobAnimation? // this will be fetched as the last thing
    let thumbnail: UIImage
    
    // texts
    let name: String
    let author: String
    
}

protocol ExplorePageData {
    var previews: [AnimationPreview] { get }
    // var animations: [Animation] { get }
    
    func fetchPreviews(completion: @escaping (Result<[AnimationPreview], Error>) -> Void)
    func fetchPreview(uid: String, completion: @escaping (Result<AnimationPreview, Error>) -> Void)
    func fetchAnimation(uid: String, completion: @escaping (Result<BlobAnimation, Error>) -> Void)
}

class MockExplorePageData: ExplorePageData {
    var previews: [AnimationPreview] = []
    
    func fetchPreviews(completion: @escaping (Result<[AnimationPreview], any Error>) -> Void) {
        
    }
    
    func fetchPreview(uid: String, completion: @escaping (Result<AnimationPreview, any Error>) -> Void) {
        
    }
    
    func fetchAnimation(uid: String, completion: @escaping (Result<BlobAnimation, any Error>) -> Void) {
        
    }
}
