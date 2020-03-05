//
//  Targets.swift
//  testing
//
//  Created by Azeem Lodhi on 12/12/2019.
//  Copyright © 2019 Anthrax.inc. All rights reserved.
//
import UIKit
import SceneKit
import ARKit
import ARCL
import CoreLocation
import BestPackage
import Foundation


class Target {
    var id: Int32
    var heading: Int32
    var speed: Int32
   
    var Textnode: LocationAnnotationNode
    var Node:LocationAnnotationNode
    var pin:UIImage
    init(id: Int32, alt: Double, heading: Int32, speed: Int32, long: Double, lat: Double, image:UIImage)
     {
        self.id=id
        self.heading=heading
  
        self.speed=speed
        self.pin=image
        
        let st="       TRACK ID: \(self.id) \n LON: \(long)       LAT: \(lat)" +
        "\nHEADING: \(self.heading)  SPEED: \(self.speed) \n ALTITUDE: \(alt)                              "
        
        
        
        var myimage = textToImage(drawText: st,inImage: UIImage(named: "white")!, atPoint: CGPoint(x: 0, y: 10))
        
        //myimage = resizeImage(image: myimage, targetSize: CGSize(width: 50,height: 50))
        let   loc = CLLocation(coordinate: CLLocationCoordinate2D(latitude: lat,longitude: long), altitude: CLLocationDistance(alt))

        self.Textnode=LocationAnnotationNode(location: loc, image: myimage)
        Textnode.position.y = -8.5
        
        self.Node=LocationAnnotationNode(location: loc, image: pin)
     //   Node.addChildNode(Textnode)

     }

    func popuString() -> String {
        
        return  "       TRACK ID: \(self.id) \n LON: \(self.Textnode.location.coordinate.longitude)       LAT: \(self.Textnode.location.coordinate.latitude)" +
        "\n HEADING: \(self.heading)  SPEED: \(self.speed) \n ALTITUDE: \(self.Textnode.location.altitude)"
    }
    
    
}

  func textToImage(drawText text: String, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {
      let textColor = UIColor.green
      let textFont = UIFont(name: "Helvetica Bold", size: 70)!

      let scale = UIScreen.main.scale
      UIGraphicsBeginImageContextWithOptions(image.size, false, scale)

      let textFontAttributes = [
          NSAttributedString.Key.font: textFont,
          NSAttributedString.Key.foregroundColor: textColor,
          NSAttributedString.Key.backgroundColor: UIColor.darkGray.withAlphaComponent(0.9)
          ] as [NSAttributedString.Key : Any]
      image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))

      let rect = CGRect(origin: point, size: image.size)
      text.draw(in: rect, withAttributes: textFontAttributes)

      let newImage = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()

      return newImage!
  }
  
func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
    let size = image.size

    let widthRatio  = targetSize.width  / size.width
    let heightRatio = targetSize.height / size.height

    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if(widthRatio > heightRatio) {
        newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
    } else {
        newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
    }

    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return newImage!
}

