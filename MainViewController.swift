//
//  MainViewController.swift
//  testing
//
//  Created by Faraz on 3/3/20.
//  Copyright © 2020 Anthrax.inc. All rights reserved.
//
import UIKit
class MainViewController:UIViewController
{
    var reachability = try! Reachability()
    
    @IBOutlet weak var SoldierViewButton: UIButton!
    
    @IBOutlet weak var frontLogoImage: UIImageView!
    
    @IBOutlet weak var QuitButton: UIButton!
    @IBAction func QuitAction(_ sender: Any) {
        UIControl().sendAction(#selector(NSXPCConnection.suspend),
        to: UIApplication.shared, for: nil)
    }
    
    
    
    @IBAction func goToCommanderAction(_ sender: Any) {
        setReachabilityNotifier()

        if(reachability.connection.description=="WiFi")
        {
        performSegue(withIdentifier: "GoCommander", sender: self)
        }
        else{
            createAlert(title: "Error", message: "Network not reachable")
        }
    }
    
    @IBAction func goToSoldierAction(_ sender: Any) {
    
    setReachabilityNotifier()

                  if(reachability.connection.description=="WiFi")
                  {
                  performSegue(withIdentifier: "GoSoldier", sender: self)
                  }
                  else{
                      createAlert(title: "Error", message: "Network not reachable")
                  }
    
    }
    
    
    @IBOutlet weak var CommanderViewButton: UIButton!
    
    override func viewDidLoad() {
        
        SoldierViewButton.ButtonDesign()
        CommanderViewButton.ButtonDesign()
        QuitButton.ButtonDesign()
        frontLogoImage.layer.shadowColor = UIColor.brown.cgColor
        frontLogoImage.layer.shadowRadius = 6
        frontLogoImage.layer.shadowOpacity = 0.5
        frontLogoImage.layer.shadowOffset = CGSize(width: 0, height: 0)
        
        

        
        
        super.viewDidLoad()
    }
    
    func setReachabilityNotifier(){
                 NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
                 do{
                   try reachability.startNotifier()
                 }catch{
                   print("could not start reachability notifier")
                 }
             }
             
             @objc func reachabilityChanged(note: Notification) {

               let reachability = note.object as! Reachability

               switch reachability.connection {
               case .wifi:
                   print("Reachable via WiFi")
                 //   createAlert(title: "success", message: "Connected via wifi")

                   print(reachability.connection)
               case .cellular:
                   print("Reachable via Cellular")
               case .none:
                 print("Network not reachable")
                 createAlert(title: "Error", message: "Network not reachable")
               case .unavailable:
                 print("Network not reachable")
                 createAlert(title: "Error", message: "Network not reachable")

                 }
             }
             func createAlert (title:String, message: String){
                 let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
                 alert.addAction(UIAlertAction(title: "retry", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
                 self.present(alert,animated: true, completion: nil)
             }
    
    
    
    
    
    
    
    
    
    
    
    
    
}
extension UIButton{
    func ButtonDesign(){
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.shadowColor = UIColor.brown.cgColor
        
        self.layer.shadowRadius = 4
        
        self.layer.shadowOpacity = 0.5
        
        self.layer.shadowOffset = CGSize(width: 0,height: 0)
        
    }
    
}
