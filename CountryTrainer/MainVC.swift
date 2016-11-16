//
//  ViewController.swift
//  CountryTrainer
//
//  Created by Ben Sullivan on 11/08/2016.
//  Copyright © 2016 Ben Sullivan. All rights reserved.
//

//BRANCH TEST

import UIKit
import QuartzCore
import SceneKit
import pop

protocol gradientBro {
  func getGradient() -> CAGradientLayer
}

extension gradientBro {
  
  func getGradient() -> CAGradientLayer {
    
    let gradientLayer: CAGradientLayer = {
      
      $0.startPoint = CGPoint(x: 1, y: 0)
      $0.endPoint = CGPoint(x: 0, y: 1)
      $0.cornerRadius = 8.0
      
      return $0
      
    }(CAGradientLayer())
    
    return gradientLayer
  }
}

class GradientButton: UIButton, gradientBro {
  
  private var gradientLayer: CAGradientLayer?

  override func awakeFromNib() {
    super.awakeFromNib()
    
//    configureView()
    
    gradientLayer = getGradient()
    
    layer.shouldRasterize = true
    layer.rasterizationScale = UIScreen.main.scale
    
  }
  
  var colors = [#colorLiteral(red: 0, green: 0.4526865697, blue: 0.8437882798, alpha: 1).cgColor, #colorLiteral(red: 0, green: 0.3394995246, blue: 0.6328125, alpha: 1).cgColor]
  
  override func layoutSublayers(of layer: CALayer) {
    
    let rect = layer.bounds
    
    gradientLayer?.frame = rect
    
    gradientLayer?.colors = colors
    
    if layer.sublayers == nil {
      
      layer.addSublayer(gradientLayer!)
    }
    
    layoutSubviews()
    
    for i in subviews {
      
      if i.isKind(of: UILabel.self) {
        bringSubview(toFront: i)
      }
    }
  }
}

class MainVC: UIViewController, UITableViewDelegate, UITableViewDataSource, MainVCInterface, MenuTableViewCellDelegate {
  
  @IBOutlet weak var tableView: COBezierTableView!
  @IBOutlet weak var flagBg: UIImageView!
  @IBOutlet weak var splashBackground: UIImageView!
  
  internal var mainInteractor: MainInteractorInterface?
  internal var mainWireframe: MainWireframe?
  
  fileprivate var circleViewCache = NSCache<NSString, CircleView>()

  fileprivate var games: [Game] {
    return mainInteractor?.games ?? [Game]()
  }
  
  fileprivate var menuTitles = MenuItems.all
  
  
  //MARK: - VC LIFECYCLE
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if #available(iOS 10.0, *) {
      setupGlobe()
      flagBg.alpha = 0
    } else {
      flagBg.alpha = 1
    }
    
    self.navigationController?.isNavigationBarHidden = true
    
    configureTablePath()
    setInitialTableRow()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    tableViewFrameOrigin = tableView.frame
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
   
    UIView.animate(withDuration: 0.5, delay: 1, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: { animation in
      
      self.splashBackground.alpha = 0
      
      if #available(iOS 10.0, *) {
        self.toggleMenu.alpha = 1
      }
    })
    
  }
  
  var indexPathForCustomGame: IndexPath?
  
  //Trying to save the index path of each cell, then use rectForIndexPath whenever one of the menu buttons are pressed
  
  //MARK: - OUTLET ACTIONS
  
  @IBAction func newGameButtonPressed(_ sender: AnyObject) {
    mainInteractor?.getNewGameData(numberOfFlags: 5, continent: nil, difficulty: Difficulty.allDifficulties.rawValue)
  }
  
  @IBOutlet weak var toggleMenu: UIButton!
  
  var tableViewFrameOrigin: CGRect!

  @IBOutlet weak var tableViewTrailing: NSLayoutConstraint!
  @IBOutlet weak var tableViewLeading: NSLayoutConstraint!
  
  @IBAction func toggleMenuToShowGlobe(_ sender: Any) {
    
    UIView.animate(withDuration: 0.4, animations: {
    
      self.tableViewLeading.constant = self.tableViewLeading.constant == 0 ? 414 : 0
      self.tableViewTrailing.constant = self.tableViewTrailing.constant == 0 ? -414 : 0
      self.scnView?.allowsCameraControl = self.scnView?.allowsCameraControl == true ? false : true

      self.view.layoutIfNeeded()

    })
    
//    UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
//      
//      let offScreenRect = CGRect(x: self.tableViewFrameOrigin.origin.x + 400, y: self.tableViewFrameOrigin.origin.y, width: self.tableViewFrameOrigin.width, height: self.tableViewFrameOrigin.height)
//      self.tableView.frame = self.tableView.frame != self.tableViewFrameOrigin ? self.tableViewFrameOrigin : offScreenRect
//    
//    }) { action in
//      
//      
//    }
    
  }
  
  //MARK: - INTERFACE FUNCTIONS
  
  internal func presentFilterFlags(indexPath: IndexPath) {
    
    let rect = tableView.rectForRow(at: indexPath)
    
    mainWireframe?.presentFilterFlagsInterface(withCountries: (mainInteractor?.countries)!, location: rect)
  }
  
  internal func presentHowToPlay() {
    mainWireframe?.presentHowToPlay()
  }
  
  internal func presentCustomGame() {
    mainWireframe?.presentCustomGame(withCountries: (mainInteractor?.allCountries)!)
  }

  internal func reloadTableData() {
    tableView.reloadData()
  }
  
  internal func prepareGameData(game: Game) {
    mainWireframe?.presentGameInterface(withGame: game)
  }
  
  internal func displayGameOptionsActionSheet(game: Game, title: String) {
    
    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
      
      self.mainInteractor?.deleteGame(game: game)
    }))
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    
    present(alert, animated: true, completion: nil)
    
  }
  
  internal func updateCountriesAfterFilter(countries: [Country]) {
    mainInteractor?.updateCountries(countries: countries)
  }
  
  internal func populateGames(game: Game) {
    mainInteractor?.populateGamesForMainVCTable(game: game)
    tableView.reloadData()
  }
  
  
  //MARK: - PRIVATE FUNCTIONS
  
  private func configureTablePath() {
    UIView.BezierPoints.p1 = CGPoint(x: 148, y: 0)
    UIView.BezierPoints.p2 = CGPoint(x: -52, y: 233)
    UIView.BezierPoints.p3 = CGPoint(x: 25, y: 308)
    UIView.BezierPoints.p4 = CGPoint(x: 200, y: 568)
  }

  private func setInitialTableRow() {
    
    //The table should always default to a position which displays some menu and some main cells
    
    let indexPath: IndexPath

    if games.count > 3 {
      
      indexPath = IndexPath(row: 1, section: 0)

    } else {
      
      indexPath = IndexPath(row: 2, section: 2)
    }
    
    tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.top)
  }
  
  
  //MARK: - TABLE VIEW
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 3
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    switch section {
    case 0:
      return menuTitles.count
    case 1:
      return games.count
    case 2:
      return 3
      
    default: return 0
    }

  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if indexPath.section == 0 {
      
      let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell") as! MenuTableViewCell
      
      cell.menuTableViewCellDelegate = self
      cell.configureCell(title: menuTitles[indexPath.row], indexPath: indexPath)
      cell.mainInteractor = mainInteractor
      cell.mainWireframe = mainWireframe
      
      return cell
      
    } else if indexPath.section == 1 {
      
      let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! MainTableViewCell
      
//      if let circle = circleViewCache.object(forKey: games[indexPath.row].uid) {
//
//        cell.configureCell(game: games[indexPath.row], circleView: circle)
//
//      } else {
//        
//       let circle = CircleView(frame: CGRect(x: 8, y: 17, width: 47, height: 47), lineWidth: 2.0)
//
//        circleViewCache.setObject(circle, forKey: games[indexPath.row].uid)
//        
        cell.configureCell(game: games[indexPath.row], circleView: nil)
//
//      }
      
      cell.mainWireframe = mainWireframe
      cell.mainVCInterface = self
      
      return cell
    }
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "placeholderCell")!
    
    return cell
    
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  
  
  
  
  
  
  var scnView: SCNView?

  let materialPrefixes : [String] = [
                                     "oakfloor2",
                                     "scuffed-plastic",
                                     "rustediron-streaks"];
  func setupGlobe() {
    
    if #available(iOS 10.0, *) {
      
      // create a new scene
      let scene = SCNScene(named: "sphere.obj")!
      
      // select the sphere node - As we know we only loaded one object
      // we select the first item on the children list
      let sphereNode = scene.rootNode.childNodes[0]
      
      // create and add a camera to the scene
      let cameraNode = SCNNode()
      cameraNode.camera = SCNCamera()
      scene.rootNode.addChildNode(cameraNode)
      
      // place the camera
      cameraNode.position = SCNVector3(x: 0, y: 0, z: 10.5)
      
      let material = sphereNode.geometry?.firstMaterial
      
      // Declare that you intend to work in PBR shading mode
      // Note that this requires iOS 10 and up
      material?.lightingModel = SCNMaterial.LightingModel.physicallyBased
      
      // Setup the material maps for your object
      let materialFilePrefix = materialPrefixes[2]
      material?.diffuse.contents = #imageLiteral(resourceName: "bkflagMapWithCaps")
      material?.roughness.contents = UIImage(named: "\(materialFilePrefix)-roughness.png")
      material?.metalness.contents = UIImage(named: "\(materialFilePrefix)-metal.png")
      
      material?.normal.contents = UIImage(named: "\(materialFilePrefix)-normal.png")
      
      // Setup background - This will be the beautiful blurred background
      // that assist the user understand the 3D envirnoment
      let bg = UIImage(named: "sphericalBlurred.png")
      scene.background.contents = bg;
      
      // Setup Image Based Lighting (IBL) map
      let env = UIImage(named: "spherical.jpg")
      scene.lightingEnvironment.contents = env
      scene.lightingEnvironment.intensity = 2.0
      
      
      // retrieve the SCNView
      scnView = self.view as! SCNView?
      
      // set the scene to the view
      scnView?.scene = scene
      
      // allows the user to manipulate the camera
      scnView?.allowsCameraControl = false
      
      
      /*
       * The following was not a part of my blog post but are pretty easy to understand:
       * To make the Orb cool, we'll add rotation animation to it
       */
      
      sphereNode.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 1, z: 0, duration: 10)))
    }
  }
}
