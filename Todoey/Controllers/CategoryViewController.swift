//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Giorgi Jashiashvili on 4/22/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework


class CategoryViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var categoryArray: Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.rowHeight = 80.0
        loadCategory()

    }
    
    

    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var storageTextField = UITextField()
        
        let alert = UIAlertController(title: "Add a new Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Done", style: .default) { (something) in
            
            
            let newCategory = Category()
            newCategory.name = storageTextField.text!
            newCategory.color = UIColor.randomFlat().hexValue()
            
            
            self.save(category: newCategory)
        }
        
        alert.addAction(action)
        
        alert.addTextField { (closureTextField) in
            
            storageTextField = closureTextField
            
            storageTextField.placeholder = "Create new categoty"
            
            
            
        }
        
        
        
        self.present(alert, animated: true, completion: nil)
        
    }



//MARK: - tablewview methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "No Categories added yet"
        cell.backgroundColor = UIColor(hexString: categoryArray?[indexPath.row].color ?? "#000000")
        
        
        
        return cell
        
    }
    
    
    //MARK: - TableView delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
            
            
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if let currentCategory = categoryArray?[indexPath.row] {
            
            do {
                try realm.write {
                    realm.delete(currentCategory)
                }
            } catch {
                print("Category delete went wrong")
            }
        }
        
        tableView.reloadData()
    }
    
    
//MARK: - Model Manipulation Methods
    
    func save(category: Category) {
        
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("error saving context")
        }
        
        self.tableView.reloadData()
        
    }
    
    func loadCategory() {
        
        categoryArray = realm.objects(Category.self)
        
        tableView.reloadData()

    }

}
