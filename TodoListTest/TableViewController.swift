//
//  TableViewController.swift
//  TodoListTest
//
//  Created by Антон Баскаков on 24.08.2024.
//

import UIKit
import CoreData

let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

class TableViewController: UITableViewController {
    
    
    let persistentStoreCoordinator = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.persistentStoreCoordinator
    
    var todos = [TodoItem]()
    
    var modelIsEmpty: Bool {
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TodoItem")
            let count = try context.count(for: request)
            return count == 0
        } catch {
            return true
        }
    }
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)
        
        title = "Tasks"
        
        let url = URL(string: "https://dummyjson.com/todos")!
        
        DispatchQueue.global().async { [weak self] in
            if self!.modelIsEmpty {
                if let data = try? Data(contentsOf: url) {
                    let decoder = JSONDecoder()
                    
                    if let decodedData = try? decoder.decode(DataModel.self, from: data) {
                        for todo in decodedData.todos {
                            let todoItem = TodoItem(context: context)
                            todoItem.id = Int64(todo.id)
                            todoItem.todo = todo.todo
                            todoItem.completed = todo.completed
                            todoItem.userId = Int64(todo.userId)
                            todoItem.todoDescription = "No description"
                            todoItem.dateAdded = Date.now
                        }
                        
                        do {
                            try context.save()
                        } catch {
                            print("Unable to save after parsing")
                        }
                        
                        self?.fetchItems()
                    } else {
                        print("Failed to decode")
                        return
                    }
                }
            }
        }
        
        
        fetchItems()
        
        let deleteAllBarButton = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: self, action: #selector(deleteAll))
        deleteAllBarButton.tintColor = .systemRed
        navigationItem.leftBarButtonItem = deleteAllBarButton
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showAdd))
        
    }
    
    @objc func loadList(notification: NSNotification){
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func fetchItems() {
        
        do {
            self.todos = try context.fetch(TodoItem.fetchRequest())
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print("Unable to fetch items from storage")
        }
        
    }
    
    @objc func showAdd() {
        let alertController = UIAlertController(title: "Add a task", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Name"
            textField.autocapitalizationType  = .sentences
        }
        alertController.addTextField { textField in
            textField.placeholder = "Description"
            textField.autocapitalizationType  = .sentences
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alertController.addAction(UIAlertAction(title: "Add", style: .default, handler: { _ in
            guard let todoText = alertController.textFields?[0].text else { return }
            guard let todoDescriptionText = alertController.textFields?[1].text else { return }
            
            let newItem = TodoItem(context: context)
            newItem.todo = todoText
            newItem.todoDescription = todoDescriptionText
            newItem.completed = false
            newItem.dateAdded = Date.now
            context.insert(newItem)
            do {
                try context.save()
            } catch {
                print("Unable to save a new item")
            }
            
            self.fetchItems()
            
        }))
        
        present(alertController, animated: true)
    }
    
    @objc func deleteAll() {
        let alertController = UIAlertController(title: "Delete all tasks?", message: "This action cannot be undone", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TodoItem")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try self.persistentStoreCoordinator.execute(deleteRequest, with: context)
            } catch {
                print("Unable to delete all items from CoreData")
            }
            
            self.fetchItems()
            
        }))
        
        present(alertController, animated: true)
    }
    
    
    
    // MARK: - Table view data source
    
    //    override func numberOfSections(in tableView: UITableView) -> Int {
    //        // #warning Incomplete implementation, return the number of sections
    //        return 0
    //    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let item = todos[indexPath.row]
        
        cell.textLabel?.text = item.todo
        cell.detailTextLabel?.text = item.dateAdded?.formatted()
        cell.imageView?.image = UIImage(systemName: item.completed ? "checkmark" : "xmark")
        cell.imageView?.tintColor = item.completed ? .systemGreen : .secondaryLabel
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: (todos[indexPath.row].completed) ? "Uncomplete" : "Complete") { action, view, completionHandler in
            
            
            
            let itemToRemove = self.todos[indexPath.row]
            
            itemToRemove.completed.toggle()
            
            do {
                try context.save()
            } catch {
                print("Unable to save")
            }
            
            self.fetchItems()
        }
        
        action.backgroundColor = (todos[indexPath.row].completed) ? .systemOrange : .systemGreen
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { action, view, completionHandler in
            
            let itemToRemove = self.todos[indexPath.row]
            
            context.delete(itemToRemove)
            
            do {
                try context.save()
            } catch {
                print("Unable to save")
            }
            
            self.fetchItems()
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            viewController.taskItem = todos[indexPath.row]
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
