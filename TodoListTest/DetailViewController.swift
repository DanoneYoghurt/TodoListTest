//
//  DetailViewController.swift
//  TodoListTest
//
//  Created by Антон Баскаков on 25.08.2024.
//

import UIKit

class DetailViewController: UIViewController {

    var taskItem: TodoItem?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet var nameTextField: UITextView!
    @IBOutlet var descriptionTextField: UITextView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = false
        title = "Edit task"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        
        nameTextField.borderStyle = .none
        
        if let taskItem = taskItem {
            nameTextField.text = taskItem.todo
            descriptionTextField.text = taskItem.todoDescription
        }
        

    }
    
    @objc func save() {
        
        taskItem?.todo = nameTextField.text
        taskItem?.todoDescription = descriptionTextField.text
        
        do {
            try context.save()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
        } catch {
            print("Unable to save an edited item")
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
