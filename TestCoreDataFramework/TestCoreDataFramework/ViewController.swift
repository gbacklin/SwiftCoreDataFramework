//
//  ViewController.swift
//  TestCoreDataFramework
//
//  Created by Gene Backlin on 7/10/15.
//  Copyright (c) 2015 Gene Backlin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var queryResults: [String : AnyObject]? = nil

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - @IBAction methods

    @IBAction func search(sender: AnyObject) {
        
        var inputTextField: UITextField?
        var alertController: UIAlertController = UIAlertController(title: "Query Contacts", message: "Enter the Email", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { action in
            NSLog("Cancel clicked")
        }
        
        let otherAction = UIAlertAction(title: "Search", style: .Default) { action in
            let email: String = inputTextField!.text
            var error: NSError? = nil
            let controller: ContactsCoreDataController = ContactsCoreDataController()
            var results: [String : AnyObject]? = [String : AnyObject]()
            
            results = controller.fetchPersonUsingEmail(email, error: &error)
            self.queryResults = results
            if error == nil {
                if results != nil {
                    for key: String in results!.keys.array as [String] {
                        let person: [String : AnyObject] = self.queryResults![key] as! [String : AnyObject]
                        self.emailLabel.text = person["email"] as? String
                        self.firstNameLabel.text = person["firstName"] as? String
                        self.lastNameLabel.text = person["lastName"] as? String
                        self.phoneLabel.text = person["phone"] as? String
                        
                        self.tableView.reloadData()
                    }
                } else {
                    self.clearDisplay()
                    self.tableView.reloadData()
                }
            } else {
                let title: String = error?.userInfo![NSURLErrorFailingURLStringErrorKey] as! String
                self.didReceiveErrorMessage(error?.localizedDescription, title: title)
            }

        }
        alertController.addTextFieldWithConfigurationHandler { textField in
            textField.placeholder = "Enter Email Here"
            inputTextField = textField
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(otherAction)

        presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func addContact(sender: AnyObject) {
        var error: NSError? = nil
        let controller: ContactsCoreDataController = ContactsCoreDataController()
        controller.addPersonUsingEmail(self.emailTextField.text, firstName: self.firstNameTextField.text, lastName: self.lastNameTextField.text, phone: self.phoneTextField.text, error: &error)
        self.checkForErrorAndRefresh(error, coreDataController: controller)
    }
    
    @IBAction func updateContact(sender: AnyObject) {
        var error: NSError? = nil
        let controller: ContactsCoreDataController = ContactsCoreDataController()
        controller.updatePersonUsingEmail(self.emailTextField.text, firstName: self.firstNameTextField.text, lastName: self.lastNameTextField.text, phone: self.phoneTextField.text, error: &error)
        self.checkForErrorAndRefresh(error, coreDataController: controller)
}
    
    @IBAction func deleteContact(sender: AnyObject) {
        var error: NSError? = nil
        let controller: ContactsCoreDataController = ContactsCoreDataController()
        controller.deletePersonUsingEmail(self.emailTextField.text, error: &error)
        self.checkForErrorAndRefresh(error, coreDataController: controller)
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let results = self.queryResults?.keys.array
        var count = 0
        
        if results != nil {
            count = results!.count
        }
        
        return count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let keys = self.queryResults?.keys.array
        let key = keys![indexPath.row]
        let connectionInfo: [String : AnyObject] = self.queryResults![key] as! [String : AnyObject]
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
        let email = connectionInfo["email"] as? String
        let firstName = connectionInfo["firstName"] as? String
        let lastName = connectionInfo["lastName"] as? String
        let phone = connectionInfo["phone"] as? String
        
        cell.textLabel!.text = connectionInfo["email"] as? String
        cell.detailTextLabel!.text = "\(firstName!) - \(lastName!) - \(phone!)"
        
        return cell;
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let keys = self.queryResults?.keys.array
        let key = keys![indexPath.row]
        let connectionInfo: [String : AnyObject] = self.queryResults![key] as! [String : AnyObject]
        
        self.emailLabel.text = connectionInfo["email"] as? String
        self.firstNameLabel.text = connectionInfo["firstName"] as? String
        self.lastNameLabel.text = connectionInfo["lastName"] as? String
        self.phoneLabel.text = connectionInfo["phone"] as? String

        self.emailTextField.text = connectionInfo["email"] as? String
        self.firstNameTextField.text = connectionInfo["firstName"] as? String
        self.lastNameTextField.text = connectionInfo["lastName"] as? String
        self.phoneTextField.text = connectionInfo["phone"] as? String
    }

    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // MARK: - Utility methods
    
    func checkForErrorAndRefresh(error: NSError?, coreDataController: ContactsCoreDataController?) {
        let email: String = self.emailTextField.text!
        
        if error == nil {
            var queryError: NSError? = nil
            self.queryResults = coreDataController!.fetchPersonUsingEmail(email, error: &queryError)
            self.clearDisplay()
            self.tableView.reloadData()
        } else {
            let title: String = error?.userInfo![NSURLErrorFailingURLStringErrorKey] as! String
            self.didReceiveErrorMessage(error?.localizedDescription, title: title)
        }
    }
    
    func clearDisplay() {
        self.emailLabel.text = ""
        self.firstNameLabel.text = ""
        self.lastNameLabel.text = ""
        self.phoneLabel.text = ""
        
        self.emailTextField.text = ""
        self.firstNameTextField.text = ""
        self.lastNameTextField.text = ""
        self.phoneTextField.text = ""
        
        self.emailTextField.resignFirstResponder()
        self.firstNameTextField.resignFirstResponder()
        self.lastNameTextField.resignFirstResponder()
        self.phoneTextField.resignFirstResponder()
    }
    
    // MARK: - Error Handling
    
    func didReceiveErrorMessage(message: String!, title: String!) {
        var alertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .Cancel) { action in
            NSLog("Button clicked")
        }
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
}

