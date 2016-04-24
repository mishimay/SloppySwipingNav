import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = String(navigationController?.viewControllers.count ?? 0)

        let colors: [UIColor] = [
            UIColor(red: 251, green: 202, blue: 77),
            UIColor(red: 163, green: 111, blue: 162),
            UIColor(red: 236, green: 211, blue: 24),
            UIColor(red: 244, green: 163, blue: 70),
            UIColor(red: 78, green: 45, blue: 31),
            UIColor(red: 133, green: 127, blue: 142),
            UIColor(red: 15, green: 144, blue: 120),
            UIColor(red: 193, green: 0, blue: 43),
            UIColor(red: 145, green: 54, blue: 11),
            UIColor(red: 168, green: 225, blue: 205),
            UIColor(red: 239, green: 137, blue: 132),
            UIColor(red: 58, green: 73, blue: 157),
            UIColor(red: 216, green: 12, blue: 24),
            UIColor(red: 0, green: 133, blue: 163),
            UIColor(red: 233, green: 71, blue: 9),
            UIColor(red: 211, green: 84, blue: 153),
            UIColor(red: 227, green: 49, blue: 125),
            UIColor(red: 228, green: 94, blue: 57),
            UIColor(red: 250, green: 190, blue: 0),
            UIColor(red: 125, green: 0, blue: 62),
            UIColor(red: 0, green: 128, blue: 200),
            UIColor(red: 165, green: 154, blue: 202),
            UIColor(red: 244, green: 219, blue: 173),
            UIColor(red: 0, green: 141, blue: 120),
            UIColor(red: 183, green: 22, blue: 73),
            UIColor(red: 244, green: 179, blue: 194),
            UIColor(red: 248, green: 204, blue: 220),
            UIColor(red: 182, green: 221, blue: 202),
            UIColor(red: 157, green: 195, blue: 23),
            UIColor(red: 237, green: 121, blue: 120),
            UIColor(red: 255, green: 222, blue: 0),
            UIColor(red: 199, green: 203, blue: 17),
            UIColor(red: 148, green: 48, blue: 50),
            UIColor(red: 136, green: 161, blue: 79),
            UIColor(red: 239, green: 138, blue: 150),
            UIColor(red: 202, green: 232, blue: 237),
            UIColor(red: 0, green: 72, blue: 122),
            UIColor(red: 0, green: 94, blue: 70),
            UIColor(red: 246, green: 171, blue: 0),
            UIColor(red: 202, green: 46, blue: 90),
            ]
        view.backgroundColor = colors[Int(arc4random_uniform(UInt32(colors.count)))]
    }

}

extension UIColor {
    convenience init(red: UInt8, green: UInt8, blue: UInt8) {
        self.init(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: 1)
    }
}
