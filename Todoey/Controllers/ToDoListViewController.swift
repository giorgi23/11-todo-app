//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListViewController: UITableViewController {
    
    var todoItems: Results<Item>?
    var storedItemList : Results<Item>?
    let realm = try! Realm()
    
    var selectedCategory : Category? {
        
        didSet {
            print("This is \(selectedCategory!.name)")
            loadItems()
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        title = selectedCategory?.name
        
    }
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)  
        
        if let dataToShow = todoItems?[indexPath.row] {
            
            cell.textLabel?.text = dataToShow.title
            
            if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row) * 0.4/CGFloat(todoItems!.count)) {
                
                cell.backgroundColor = color
                
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
                
            }
            
            
            
            
            
            
            
            
            
            cell.accessoryType = dataToShow.done == true ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No items added"
        }
        
        
        return cell
    }
    
    //MARK: - Tableview delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            
            do {
                try realm.write{
                    //realm.delete(item)
                    item.done.toggle()
                }
            } catch {
                print("item selection went bad, \(error)")
            }
            
            tableView.reloadData()
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
                if let currentItem = todoItems?[indexPath.row] {
            
            do {
                try realm.write {
                    realm.delete(currentItem)
                }
            } catch {
                print("Category delete went wrong")
            }
        }
        
        tableView.reloadData()
    }

    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var storageTextField = UITextField() //need to copy the text field from the alert to be able to access the text at a later point
        
        let alert = UIAlertController(title: "Add a new item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Done", style: .default) { (something) in
            
            if let currentCategory = self.selectedCategory {
                
                do {
                    try self.realm.write {
                         let newItem = Item()
                         newItem.title = storageTextField.text!
                        let timestamp = NSDate().timeIntervalSince1970
                        let myTimeInterval = TimeInterval(timestamp)
                        let time = NSDate(timeIntervalSince1970: TimeInterval(myTimeInterval))
                        newItem.createdTime = time
                         currentCategory.items.append(newItem)
                    }
                } catch {
                    print("can't save items to the realm, \(error)")
                }
                
            }
            
            self.tableView.reloadData()
            
        }
        
        alert.addAction(action)
        
        alert.addTextField { (closureTextField) in
            
            closureTextField.placeholder = "Create new item"
            
            storageTextField = closureTextField
            
        }
        
        
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - Model Manipulation Methods
    
    
    
    func loadItems() {
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
        
    }
    
}

//MARK: - Search bar methods

extension ToDoListViewController: UISearchBarDelegate {
    

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        loadItems()
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()

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
