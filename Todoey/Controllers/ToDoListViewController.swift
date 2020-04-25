//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    
    var selectedCategory : Category? {
        
        didSet {
            print("This is \(selectedCategory!.name ?? "nothing")")
            loadItems()
        }
        
    }
    
    //let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
    }
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)  
        
        let dataToShow = itemArray[indexPath.row]
        
        cell.textLabel?.text = dataToShow.title
        
        cell.accessoryType = dataToShow.done == true ? .checkmark : .none
        
        return cell
    }
    
    //MARK: - Tableview delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //context.delete(itemArray[indexPath.row])
        //itemArray.remove(at: indexPath.row)
        
        
        itemArray[indexPath.row].done.toggle()
        
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }

    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var storageTextField = UITextField() //need to copy the text field from the alert to be able to access the text at a later point
        
        let alert = UIAlertController(title: "Add a new item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Done", style: .default) { (something) in
            
            
            let newItem = Item(context: self.context)
            newItem.title = storageTextField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem)
            
            self.saveItems()
        }
        
        alert.addAction(action)
        
        alert.addTextField { (closureTextField) in
            
            closureTextField.placeholder = "Create new item"
            
            storageTextField = closureTextField
            
        }
        
        
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - Model Manipulation Methods
    
    func saveItems() {
        
        do {
            try context.save()
        } catch {
            print("error saving context")
        }
        
        self.tableView.reloadData()
        
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest()) {
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if request.predicate != nil {
            //Search bar request came in, assemble complex preidcate
            
            let andPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [categoryPredicate, request.predicate!])
            
            request.predicate = andPredicate
            
        } else {
            //Default request, load only category relevant items
            
            request.predicate = categoryPredicate
        }
        
        
        do {
          itemArray = try context.fetch(request)
        } catch  {
            print("error fetching")
        }
        
        tableView.reloadData()

    }
    
}

//MARK: - Search bar methods

extension ToDoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        } else {
            searchBarSearchButtonClicked(searchBar)
        }
    }
}
