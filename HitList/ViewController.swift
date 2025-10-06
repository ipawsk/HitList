//
//  ViewController.swift
//  HitList
//
//  Created by iPaw on 02/10/25.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    var people: [NSManagedObject] = []

    @IBOutlet weak var tableview: UITableView!
    
    @IBAction func addNameButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Name", message: "Add a new name", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            [unowned self] action in
            guard let textField = alert.textFields?.first,
            let nameToSave = textField.text else {
                return
            }
            
            self.save(name: nameToSave)
            self.tableview.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    func setUpView() {
        title = "The List"
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    func save(name : String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let manageContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Person", in: manageContext)! //Crea un objeto y lo inserta en el contexto
        
        let person = NSManagedObject(entity: entity, insertInto: manageContext)
        
        person.setValue(name, forKey: "name") // se configura el atributo , se pone el nombre exactamente como en el modelo
        
        do { //Los cambios se confirman en person y se guardan
            try manageContext.save()
            people.append(person)
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchPeople()
    }
    
    func fetchPeople() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { // se obtiene la referencia del contenedor
            return
        }
        
        let manageContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person") // Para la obtencion de datos
        
        do {
            people = try manageContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")

        }
    }
}

// MARK: - TableView DataSource
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let person = people[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = person.value(forKeyPath: "name") as? String
        return cell
    }
}
