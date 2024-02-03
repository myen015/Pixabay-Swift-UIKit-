//
//  PixabayAPI.swift
//  pixabay
//
//  Created by yernar on 19.10.2023.
//

import Foundation

class PixabayAPI{
    static let share = PixabayAPI()
    
    func fetchRandomImagesFromPixabay(completion: @escaping ([String]) -> Void) {
            let apiKey = "40281882-47dcd566a544bd6419def5351"
            let urlString = "https://pixabay.com/api/?key=\(apiKey)&order=popular&per_page=10"
            
            guard let url = URL(string: urlString) else {
                completion([])
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let error = error {
                    print("Error fetching images: \(error)")
                    completion([])
                    return
                }
                
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        if let hits = json?["hits"] as? [[String: Any]] {
                            let imageUrls = hits.compactMap { $0["webformatURL"] as? String }
                            completion(imageUrls)
                        }
                    } catch {
                        print("Error decoding JSON: \(error)")
                        completion([])
                    }
                }
            }.resume()
        }
        
    }

