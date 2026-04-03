import UIKit

class DashedButton: UIButton {
    private let dashedLayer = CAShapeLayer()
    override func layoutSubviews() {
        super.layoutSubviews()
        self.dashedLayer.frame = self.bounds
        self.dashedLayer.strokeColor = UIColor.systemGray2.cgColor
        self.dashedLayer.lineDashPattern = [6, 4]
        self.dashedLayer.fillColor = nil
        self.dashedLayer.lineWidth = 1.5
        
        self.dashedLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: 8).cgPath
        if self.dashedLayer.superlayer == nil {
            self.layer.addSublayer(self.dashedLayer)
        }
    }
}
