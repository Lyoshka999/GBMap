//
//  RoudingEdges.swift
//  GBMap
//
//  Created by Алексей on 22.04.2023.
//

import UIKit

 class RoudingEdgesView: UIView {
    @IBInspectable var borderColor: UIColor = .gray
    @IBInspectable var borderWidth: CGFloat = 1.5
    
    override func awakeFromNib() {
        self.layer.cornerRadius = self.frame.height / 3
        self.layer.masksToBounds = true
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
    }
    
}

class RoudingEdgesButton: UIButton {
    @IBInspectable var borderColor: UIColor = .white
    @IBInspectable var borderWidth: CGFloat = 1.5
   
   override func awakeFromNib() {
       self.layer.cornerRadius = self.frame.height / 3
       self.layer.masksToBounds = true
       self.layer.borderWidth = borderWidth
       self.layer.borderColor = borderColor.cgColor
    }
   
}


class RoudingEdgesLabel: UILabel {
    @IBInspectable var borderColor: UIColor = .white
    @IBInspectable var borderWidth: CGFloat = 1.5
   
   override func awakeFromNib() {
       self.layer.cornerRadius = self.frame.height / 3
       self.layer.masksToBounds = true
       self.layer.borderWidth = borderWidth
       self.layer.borderColor = borderColor.cgColor
    }
   
}

class RoudingEdgesImage: UIImageView {
   @IBInspectable var borderColor: UIColor = .gray
   @IBInspectable var borderWidth: CGFloat = 1.5
   
   override func awakeFromNib() {
       self.layer.cornerRadius = self.frame.height / 2
       self.layer.masksToBounds = true
       self.layer.borderWidth = borderWidth
       self.layer.borderColor = borderColor.cgColor
   }
}

func drawImageToframeImage(image: UIImage, frameImage: UIImage) -> UIImage {

    let frameImageView = UIImageView(image: frameImage)
    let imageView = UIImageView(image: image)
    imageView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
    imageView.layer.cornerRadius = imageView.frame.width/2
    imageView.clipsToBounds = true
    
    frameImageView.addSubview(imageView)
    imageView.center.x = frameImageView.center.x
    imageView.center.y = frameImageView.center.y - 7

    frameImageView.setNeedsLayout()
    imageView.setNeedsLayout()

    let newImage = imageWithView(view: frameImageView)
    return newImage
}

func imageWithView(view: UIView) -> UIImage {
    var image: UIImage?
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
    if let context = UIGraphicsGetCurrentContext() {
        view.layer.render(in: context)
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    return image ?? UIImage()
}

extension UIImage {
    func imageResized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
