//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Giorgi Jashiashvili on 4/22/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    var categoryArray = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategory()

    }
    
    

    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var storageTextField = UITextField()
        
        let alert = UIAlertController(title: "Add a new Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Done", style: .default) { (something) in
            
            
            let newCategory = Category(context: self.context)
            newCategory.name = storageTextField.text!
            self.categoryArray.append(newCategory)
            
            self.saveCategory()
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
        categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categoryArray[indexPath.row].name
        
        return cell
        
    }
    
    
    //MARK: - TableView delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            
            destinationVC.selectedCategory = categoryArray[indexPath.row]
            
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        print("new function")
    }
    
    
//MARK: - Model Manipulation Methods
    
    func saveCategory() {
        
        do {
            try context.save()
        } catch {
            print("error saving context")
        }
        
        self.tableView.reloadData()
        
    }
    
    func loadCategory() {
        
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
          categoryArray = try context.fetch(request)
        } catch  {
            print("error fetching")
        }
        
        tableView.reloadData()

    }

}
