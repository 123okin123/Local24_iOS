import UIKit

public struct Configuration {

  // MARK: Colors

  public static var backgroundColor = UIColor(red: 0.15, green: 0.19, blue: 0.24, alpha: 1)
  public static var mainColor = UIColor(red: 0.09, green: 0.11, blue: 0.13, alpha: 1)
  public static var noImagesColor = UIColor(red: 0.86, green: 0.86, blue: 0.86, alpha: 1)
  public static var noCameraColor = UIColor(red: 0.86, green: 0.86, blue: 0.86, alpha: 1)
  public static var settingsColor = UIColor.white

  // MARK: Fonts

  public static var numberLabelFont = UIFont(name: "HelveticaNeue-Bold", size: 19)!
  public static var doneButton = UIFont(name: "HelveticaNeue-Medium", size: 19)!
  public static var flashButton = UIFont(name: "HelveticaNeue-Medium", size: 12)!
  public static var noImagesFont = UIFont(name: "HelveticaNeue-Medium", size: 18)!
  public static var noCameraFont = UIFont(name: "HelveticaNeue-Medium", size: 18)!
  public static var settingsFont = UIFont(name: "HelveticaNeue-Medium", size: 16)!

  // MARK: Titles

  public static var OKButtonTitle = "OK"
  public static var cancelButtonTitle = "Abbrechen"
  public static var doneButtonTitle = "Fertig"
  public static var noImagesTitle = "Keine Bilder vorhanden"
  public static var noCameraTitle = "Kammera ist nicht verfügbar"
  public static var settingsTitle = "Einstellungen"
  public static var requestPermissionTitle = "Zugriff verweigert"
  public static var requestPermissionMessage = "Bitte erlauben Sie Local24 Zugriff auf Ihre Fotos"

  // MARK: Dimensions

  public static var cellSpacing: CGFloat = 2
  public static var indicatorWidth: CGFloat = 41
  public static var indicatorHeight: CGFloat = 8

  // MARK: Custom behaviour

  public static var canRotateCamera = true
  public static var collapseCollectionViewWhileShot = true
  public static var recordLocation = true

  // MARK: Images
    
  public static var indicatorView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.white.withAlphaComponent(0.6)
    view.layer.cornerRadius = 4
    view.translatesAutoresizingMaskIntoConstraints = false
        
    return view
  }()
}
