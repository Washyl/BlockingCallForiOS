//
//  ViewController.swift
//  CallBlock
//
//  Created by Washyl on 7/14/24.
//
import UIKit
import CallKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    var blockedNumbers: [Int64] = []
    let defaults = UserDefaults(suiteName: "Washyl.CallBlock")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadBlockedNumbers()
        setupUI()
        errorLabel.text = "" // Initially hide the error label
        
        // Register the cell identifier
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func loadBlockedNumbers() {
        blockedNumbers = defaults?.array(forKey: "blockedNumbers") as? [Int64] ?? []
        tableView.reloadData()
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        guard let numberText = phoneNumberTextField.text, !numberText.isEmpty else {
            displayError(message: "Phone number cannot be empty")
            return
        }
        
        guard let number = Int64(numberText), isValidPhoneNumber(numberText) else {
            displayError(message: "Invalid phone number")
            return
        }
        
        if blockedNumbers.contains(number) {
            displayError(message: "Phone number is already blocked")
            return
        }
        
        blockedNumbers.append(number)
        defaults?.set(blockedNumbers, forKey: "blockedNumbers")
        tableView.reloadData()
        reloadCallDirectoryExtension()
        phoneNumberTextField.text = ""
        hideError()
    }
    
    func reloadCallDirectoryExtension() {
        let callDirectoryManager = CXCallDirectoryManager.sharedInstance
        callDirectoryManager.reloadExtension(withIdentifier: "your.bundle.identifier.CallDirectoryExtension") { error in
            if let error = error {
                print("Error reloading extension: \(error.localizedDescription)")
            } else {
                print("Successfully reloaded extension")
            }
        }
    }
    
    func isValidPhoneNumber(_ number: String) -> Bool {
        let phoneRegex = "^[0-9]{7,15}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: number)
    }
    
    func displayError(message: String) {
        errorLabel.text = message
        errorLabel.textColor = .red
        UIView.animate(withDuration: 0.3) {
            self.errorLabel.alpha = 1.0
        }
    }
    
    func hideError() {
        UIView.animate(withDuration: 0.3) {
            self.errorLabel.alpha = 0.0
        }
    }
    
    func setupUI() {
        phoneNumberTextField.placeholder = "Enter phone number"
        errorLabel.alpha = 0.0 // Hide error label initially
    }
    
    // TableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blockedNumbers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = String(blockedNumbers[indexPath.row])
        return cell
    }
    
    // TableView Delegate Methods
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            blockedNumbers.remove(at: indexPath.row)
            defaults?.set(blockedNumbers, forKey: "blockedNumbers")
            tableView.deleteRows(at: [indexPath], with: .automatic)
            reloadCallDirectoryExtension()
        }
    }
}
