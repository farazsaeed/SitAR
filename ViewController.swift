import UIKit
import SceneKit
import ARKit
import ARCL
import CoreLocation
import BestPackage



class ViewController: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate {
    @IBOutlet var filterRangeTextField: UILabel!
    var filterRange = 0.0
    
    
    
    @IBAction func onStepperButton(_ sender: UIStepper) {
        filterRangeTextField.text="Visible range: \(sender.value)KM"
        filterRange = Double(sender.value)
        print(filterRange)
    }
    var  targetImage=resizeImage(image: UIImage(named: "target")!, targetSize: CGSize(width:150, height:150))
    let historyImage=resizeImage(image: UIImage(named: "history")!, targetSize: CGSize(width:10.0, height: 10.0))
    var dbCount = 0
    
    // @IBOutlet var sceneView: ARSCNView!
    var myTargets = [Target]()
    var myTargetsHistory = [LocationAnnotationNode]()
    var dataAccessor = BestPackage.myservice()
    
    var iter = 0
    @IBOutlet weak var ContentView: UIView!
    var visiblearray = [Bool]()
    
    let locManager = CLLocationManager()
    
    var sceneLocationView = SceneLocationView()
    
    
    var latestDisplayedIndex = -1
    
    var myImageView = UIImageView()
    var upLeft = UILabel()
    var upRight = UILabel()
    var downLeft = UILabel()
    var downRight = UILabel()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        sceneLocationView.run()
        myImageView = addImageView(imageName: "compass")
        upLeft = addLabel(defaultText: "0.0", xPos: 90, yPos: 90)
         upRight = addLabel(defaultText: "0.0", xPos: 150, yPos: 90)
        downLeft = addLabel(defaultText: "0.0", xPos: 90, yPos: 150)
         downRight = addLabel(defaultText: "0.0", xPos: 150, yPos: 150)
       sceneLocationView.addSubview(myImageView)
        sceneLocationView.addSubview(upLeft)
        sceneLocationView.addSubview(upRight)
        sceneLocationView.addSubview(downLeft)
        sceneLocationView.addSubview(downRight)
        ContentView.addSubview(sceneLocationView)
        
        self.filterRangeTextField.layer.cornerRadius=5
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(sender:)))
        
        //for object heading
        if (CLLocationManager.headingAvailable()) {
                locManager.headingFilter = 1
                locManager.startUpdatingHeading()
                locManager.delegate = self

            }
        //
        
        view.addGestureRecognizer(pinch)
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//
//            let myHeading = Double(self.locManager.heading?.trueHeading ?? 0.0)
//                self.changeLabelColor(heading: myHeading)
//        }
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) {
            // this is the code that the timer runs every second
            (_:Timer)->Void in //  the Timer object is passed in, but we ignore it
            let myHeading = Double(self.locManager.heading?.trueHeading ?? 0.0)
            self.changeLabelColor(heading: myHeading)
            var counter1 = 0
            var counter2 = 0
            var counter3 = 0
            var counter4 = 0
            
            for iter in 0..<self.myTargets.count{
                let mylat = self.myTargets[iter].Node.location.coordinate.latitude
                let mylong = self.myTargets[iter].Node.location.coordinate.longitude
                
                let temp = self.getMyLocation(loc: self.locManager)
                let lat = temp.0
                let long = temp.1
                if (mylat>lat && mylong>long){
                    counter1+=1
                    self.upRight.text = String(counter1)
                    
                    
                    
                }
               else if (mylat>lat && mylong<long){
                    counter2+=1
                    self.upLeft.text = String(counter2)
                    
                    
                    
                }
               else if (mylat<lat && mylong>long){
                    counter3+=1
                    self.downRight.text = String(counter3)
                    
                    
                    
                }
                else if (mylat<lat && mylong<long){
                    counter4+=1
                    self.downLeft.text = String(counter4)
                    
                    
                    
                }
                
            }
            
            
            
        }
        
        let queue = DispatchQueue(label:"DatabaseData",attributes: .concurrent)
        queue.async {
            while(true){
                
                autoreleasepool{

                    self.dataAccessor.doSomething()
                    self.dataAccessor.semaphore.wait()
  
//                    if self.iter == 6 {
//                        self.sceneLocationView.removeAllNodes()
//                        self.iter = 0
//                    }
//                    self.iter += 1
                    let ARobject=self.filltargets(data: self.dataAccessor)
                    
                    var flag=0
                    let totalelem=self.myTargets.count
                    
                    for data in 0..<totalelem{
                        
                        if self.myTargets[data].id==ARobject.id {
                            var recentTapHistory = false
                            if(self.visiblearray[data]==false){// removing old tapped textnode
                                self.myTargets[data].Textnode.removeFromParentNode()
                                recentTapHistory = true
                            }
                            self.visiblearray[data]=true
                            self.myTargets[data].Node.removeFromParentNode()
                            
                            self.myTargets[data]=ARobject
                            //print("Received at index: \(data)")
                            self.latestDisplayedIndex=data // storing index of latest displayed object
                            
                            if(recentTapHistory){ // checking if textnode was displayed for previous node location
                                self.myTargets[data].Node.addChildNode(self.myTargets[data].Textnode)
                                self.visiblearray[data] = false
                            }
                            
                            
                            flag=1
                            break
                        }
                        
                        
                    }
                    if flag==0{
                        self.myTargets.append(ARobject)
                        self.visiblearray.append(true)
                        self.latestDisplayedIndex=self.myTargets.count-1
                        // print("Received at index: \(self.latestDisplayedIndex)")
                        
                        
                    }
                    
//                    for temp in 0..<self.myTargetsHistory.count{
//
//                        self.myTargetsHistory[temp].removeFromParentNode()
//
//
//                    }
//
                    let totalelements=self.myTargets.count
                    if (!self.myTargets.isEmpty){
                        
                        for data in 0..<totalelements{
                            
                            let innerTotal = self.myTargetsHistory.count
                            if (innerTotal != 0){
                              let myloc = self.getMyLocation(loc: self.locManager)
                                let location1 = myloc.0
                                let location2 = myloc.1
                                let dist = self.calculateDisplacement(la1: location1, lo1: location2, la2: self.myTargetsHistory[data].location.coordinate.latitude,lo2: self.myTargetsHistory[data].location.coordinate.longitude)
                                if self.filterRange>=(dist){
                                self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: self.myTargetsHistory[innerTotal-1])
                                    
                                }
                            
                            }
                            let toDisplay = self.latestDisplayedIndex
                            //print("displayed of index: \(toDisplay)")
                            
     
                            
                            let myloc = self.getMyLocation(loc: self.locManager)
                            let location1 = myloc.0
                            let location2 = myloc.1
                            
                            let dist = self.calculateDisplacement(la1: location1, lo1: location2, la2: self.myTargets[data].Node.location.coordinate.latitude, lo2: self.myTargets[data].Node.location.coordinate.longitude)
                          
                            
                            
                            print(dist)
                            if self.filterRange>=(dist){
                                print(self.filterRange)
                                let myHeading = Double(self.locManager.heading?.trueHeading ?? 0.0)
                                let objHeading = self.myTargets[toDisplay].heading
                                self.targetImage=resizeImage(image: UIImage(named: self.getImageByName(myHeading: Int(myHeading), objHeading: Int(objHeading)))!, targetSize: CGSize(width:150, height:150))
                                
                                
                                
                                self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: self.myTargets[toDisplay].Node)}
                            self.insertToHistory(at: data)
                            
                        }
                        
                        
                    }
                    //print("Removed of index: \(self.latestDisplayedIndex)")
                    
                }
                
            }
        }
        
        
        
        // Set the view's delegate
        // sceneView.delegate = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        sceneLocationView.addGestureRecognizer(tapGestureRecognizer) // added in scenelocation instead of sceneview as it was not working in the 2nd one
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading heading: CLHeading) {
        //if this function is removed device heading won't work
       // print(heading.trueHeading)
    }
    func changeLabelColor(heading: Double){
        //print(heading)
        if(heading>0 && heading<=90 )
        {
            self.upRight.textColor = .red
            self.downRight.textColor = .black
            self.downLeft.textColor = .black
            self.upLeft.textColor = .black
            
        }
        else if(heading>90 && heading<=180)
        {
            self.upRight.textColor = .black
            self.downRight.textColor = .red
            self.downLeft.textColor = .black
            self.upLeft.textColor = .black
        }
        else if(heading>180 && heading<=270){
            self.upRight.textColor = .black
            self.downLeft.textColor = .red
            self.downRight.textColor = .black
            self.upLeft.textColor = .black
        }
        else{
            self.upRight.textColor = .black
            self.downLeft.textColor = .black
            self.downRight.textColor = .black
            self.upLeft.textColor = .red
        }
    }
    func mapValueToScale(heading: Int)->Int{
        if(heading<=45 || heading>315 )
        {
            return 0
        }
        else if(heading>45 && heading<=135)
        {
            return 90
        }
        else if(heading>135 && heading<=225){
            return 180
        }
        else if(heading>225 && heading<=315){
            return -90
        }
        else{
            return 0
        }
        
    }
    func getImageRotationAngle(myHeading: Int, objheading: Int)-> Int{
        
        let tilda = (mapValueToScale(heading: myHeading)-mapValueToScale(heading: objheading))
        if (tilda == 0){
            return -180
        }
        return tilda

        
    }
    func getImageByName(myHeading: Int, objHeading: Int)->String{
        let tilda = getImageRotationAngle(myHeading: myHeading, objheading: objHeading)
        if (tilda == 90){
            return "ninety" //angle name w.r.t true north
        }
        else if (tilda == -180){
            return "zero"
        }
        else if (tilda == 180){
            return "oneEighty"
        }
        else{
            return "minusNinety"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        _ = ARWorldTrackingConfiguration()
        
        // Run the view's session
        //   sceneView.session.run(configuration)
        
    }
    
    var ViewScale: CGFloat = 1.0
    let maxScale: CGFloat = 4.0
    let minScale: CGFloat = 1.0
    
    @objc func handlePinch(sender: UIPinchGestureRecognizer)
    {
        guard sender.view != nil else{return}
        if sender.state == .began || sender.state == .changed{
            let pinchScale: CGFloat = sender.scale
            if ViewScale * pinchScale < maxScale && ViewScale * pinchScale > minScale {
            ViewScale *= pinchScale
            sender.view?.transform = (sender.view?.transform.scaledBy(x: pinchScale, y: pinchScale))!
            }
            sender.scale = 1.0
        }
    }
    func filltargets(data :BestPackage.myservice)->Target{
        let newobj = Target(id: data.trackid,alt:Double(data.altitudes),heading: data.headings,speed:data.speeds,long:data.longs,lat:data.lats,image: targetImage)
        
        return newobj
        
    }
    
    
    
    //    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
    //        //  print("rendering")
    //
    //
    //        sceneLocationView.run()
    //
    //    }
    
    @objc func handleTap(sender:UITapGestureRecognizer) // this function handles the touch gestures
    {
        let sceneViewTappedOn=sender.view as! SceneLocationView
        let touchedCordinates = sender.location(in: sceneViewTappedOn)
        let hitTest = sceneViewTappedOn.hitTest(touchedCordinates)
        
        if hitTest.isEmpty{
            print("didn't touch")
            
        }
            
        else
        {
            
            let results = hitTest.first?.node.parent as? LocationAnnotationNode // Getting the node which got touched
            
            
            if let obj = results{
        
                let index=findIndex(toFind: obj)
           
                self.showDetails(myindex: index)
                // sending array of targets and object to show or hide its detail object
                
                
            }
            
            
        }
        
    }
    func addImageView(imageName: String)->UIImageView{
        let xPos = 20
        let yPos = 20
        let width = 200
        let height = 200
        
        let image = UIImage(named: imageName)
        let uiImageView = UIImageView(image: image)
        uiImageView.frame = CGRect(x: xPos, y: yPos, width: width, height: height)
        return uiImageView
        
    }
    func addLabel(defaultText: String, xPos: Int, yPos: Int )->UILabel{
        let label = UILabel(frame: CGRect(x:0, y:0, width: 50, height: 50))
        label.center = CGPoint(x: xPos, y: yPos)
        label.textAlignment = .center
        label.text = defaultText
        label.textColor = .black
        return label
    }
    
    func findIndex(toFind:LocationAnnotationNode)->Int{
        
        var foundID = -1
        for i in 0..<myTargets.count{
            if myTargets[i].Node == toFind{
                foundID=i
                break
                
            }
            
        }
        return foundID
        
    }
    
    func showDetails(myindex: Int){
        
        if(myindex == -1)
        {
            return
        }
        if visiblearray[myindex] == true {
            
            //sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: myTargets[myindex].Textnode)
            self.myTargets[myindex].Node.addChildNode(self.myTargets[myindex].Textnode)
            visiblearray[myindex]=false
            
        }
        else {
            myTargets[myindex].Textnode.removeFromParentNode()
            visiblearray[myindex]=true
        }
        
    }
    
    func insertToHistory(at data:Int)
    {
        let locationOfText = CLLocation(coordinate: CLLocationCoordinate2D(latitude: self.myTargets[data].Node.location.coordinate.latitude,longitude: self.myTargets[data].Node.location.coordinate.longitude), altitude: CLLocationDistance(myTargets[data].Node.location.altitude))
        let newobj = LocationAnnotationNode(location: locationOfText, image: historyImage)
        self.myTargetsHistory.append(newobj)
        
    }
    
    func getMyLocation(loc: CLLocationManager)->(Double,Double){
        let  locValue: CLLocationCoordinate2D = loc.location?.coordinate ?? CLLocationCoordinate2D()
        let mylat = Double(locValue.latitude)
        let mylong = Double(locValue.latitude)
        return (mylat,mylong)
    }
    
    

    func calculateDisplacement(la1: Double,lo1: Double,  la2: Double,lo2: Double) -> Double {

        let dLat = (la1 - la2) * Double.pi / 180.0
        let dLon = (lo1 - lo2) * Double.pi / 180.0
        
        let lat1 = (la1) * Double.pi / 180.0
        let lat2 = (la2) * Double.pi / 180.0
        let a = (pow(sin(dLat / 2), 2) +
        pow(sin(dLon / 2), 2) *
            cos(lat1) * cos(lat2))
        let rad = 6371.0
        let c = 2 * asin(sqrt(a))
        return rad * c

    }
//    func toRadians(degree: Double)-> Double{
//        let radians = degree*(.pi/180)
//        return radians
//    }
    
    
    func getCoordinates(MyNode:SCNNode)
    {
        print(MyNode.presentation.position.x,MyNode.presentation.position.y,MyNode.presentation.position.z)
        
        print(MyNode.presentation.worldPosition.x,MyNode.presentation.worldPosition.y,MyNode.presentation.worldPosition.z)
    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sceneLocationView.frame = view.bounds
    }
}
