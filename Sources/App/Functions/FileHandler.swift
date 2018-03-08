
import Multipart
import Foundation
import Node
import Vapor
import MapKit
import CoreLocation

class FileHandler {
    
    
    static func getFilesInDir(dirname: String) throws -> [String] {
        let fileMngr=FileManager.default;
        return try fileMngr.contentsOfDirectory(atPath:dirname);
    }
    
    fileprivate static func createDir(dirName: String) throws {
        
        if FileManager.default.fileExists(atPath: dirName) { return }
        do {
            try FileManager.default.createDirectory(atPath: dirName, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            throw error
        }
    }

    static func uploadBase64File(user : User, file _file : Data, filename : String) throws -> File {
        let workDir = Config.workingDirectory()
        var _filename = filename
        try FileHandler.createDir(dirName: "\(workDir)public/uploads/\(user.username!)/")
        _filename = _filename.replacingOccurrences(of: " ", with: "_")
        
        if _filename.string.count > 15 {
            _filename.insert("-", at: _filename.index(_filename.startIndex, offsetBy: 15))
        }
        if _filename.string.count > 30 {
            _filename.insert("-", at: _filename.index(_filename.startIndex, offsetBy: 30))
        }
        
        try _file.write(to: URL(fileURLWithPath: "\(workDir)public/uploads/\(user.username!)/\(_filename)"))
        
        let fileModel = File.init(name: _filename, path: "/uploads/\(user.username!)/\(_filename)", absolutePath: "\(workDir)public/uploads/\(user.username!)/\(_filename)", user_id: user.id!, type: .image)
        
        try fileModel.save()
        
        return fileModel
    }
    
    static func uploadFile(user: User , request: Request) throws -> File {
        
        guard let file = request.formData?["file"], var fileName = file.filename else {
            throw Abort(.badRequest, reason: "No file! 😱")
        }
        let workDir = Config.workingDirectory()
        
        try FileHandler.createDir(dirName: "\(workDir)public/uploads/\(user.username!)/")
        fileName = fileName.replacingOccurrences(of: " ", with: "_")
        
        if fileName.string.count > 15 {
            fileName.insert("-", at: fileName.index(fileName.startIndex, offsetBy: 15))
        }
        if fileName.string.count > 30 {
            fileName.insert("-", at: fileName.index(fileName.startIndex, offsetBy: 30))
        }
        
        try Data(file.part.body).write(to: URL(fileURLWithPath: "\(workDir)public/uploads/\(user.username!)/\(fileName)"))
        
        
        let fileModel = File.init(name: fileName, path: "/uploads/\(user.username!)/\(fileName)", absolutePath: "\(workDir)public/uploads/\(user.username!)/\(fileName)", user_id: user.id!, type: .image)
        
        try fileModel.save()
        
        return fileModel
        
    }
    
    static func getCoordinatesForFile(file _file: File) -> CLLocationCoordinate2D? {
        let url = NSURL(string: "http://localhost:8080\(_file.path)")
        let imageSource = CGImageSourceCreateWithURL(url!, nil)
        let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource!, 0, nil)! as NSDictionary;
        
        guard let exifDict = imageProperties.value(forKey: "{GPS}")  as? NSDictionary else {
            return nil
        }
        
        var _lat : Double = 0.0
        var _long : Double = 0.0
        var _longRef = ""
        var _latRef = ""
        
        for (k,v) in exifDict {
            switch k as! String{
            case "Latitude" :
                _lat = v as! Double
            case "Longitude" :
                _long = v as! Double
            case "LatitudeRef" :
                _latRef = v as! String
            case "LongitudeRef" :
                _longRef = v as! String
            default: break
            }
        }
        
        if _longRef == "W" {
            _long = _long * -1
        }
        if _latRef == "S" {
            _lat = _lat * -1
        }
        
        if (_lat == 0.0 || _long == 0.0) {
            return nil
        }
        
        let coords = CLLocationCoordinate2DMake(_lat, _long)
        return  coords
        
    }
    
//    static func getPlacesFor(Coordinates _coord: CLLocationCoordinate2D) throws{
//      
//        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(_coord.latitude),\(_coord.longitude)&radius=20&key=AIzaSyAknKg8MG0bW9uzXrUJC88fx0U480P3ctI"
//        print(urlString)
//        let url2 = URL(string: urlString)
//        URLSession.shared.dataTask(with:url2!) { (data, response, error) in
//            if error != nil {
//                print(error ?? "")
//            } else {
//                
//                guard let responseData = data else {
//                    print("Error: did not receive data")
//                    return
//                }
//                
//                let decoder = JSONDecoder()
//                do {
//                    
//                    let pois = try decoder.decode(ApiResult.self, from: responseData)
//                    print(pois)
//                } catch {
//                    print("error trying to convert data to JSON")
//                    print(error)
//                }
//            }
//            
//            }.resume()
//    }
    

}
