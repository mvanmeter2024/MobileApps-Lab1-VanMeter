//
//  ViewController.swift
//  Lab1-Scavenger-Hunt
//
//  Created by Mackenzie VanMeter on 9/19/26.
//

import UIKit


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    let tasks = [

            ("Find a Statue", "Take a picture of a statue"),

            ("Find a Beach", "Take a picture of the beach"),

            ("Find a Restaurant", "Take a picture of a restaurant"),

            ("Find a Park", "Take a picture of a park"),

            ("Find a Landmark", "Take a picture of a landmark")

        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "Scavenger Hunt"

        tableView.delegate = self
        tableView.dataSource = self
    }
    func tableView(

        _ tableView: UITableView,

        numberOfRowsInSection section: Int

    ) -> Int {

        return tasks.count

    }

    func tableView(

        _ tableView: UITableView,

        cellForRowAt indexPath: IndexPath

    ) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            
            withIdentifier: "TaskCell",
            
            for: indexPath
            
        )
        
        let task = tasks[indexPath.row]
        
        cell.textLabel?.text = task.0
        
        cell.detailTextLabel?.text = task.1
        let isCompleted = UserDefaults.standard.bool(
            forKey: "taskCompleted_\(indexPath.row)"
        )

        if isCompleted {
            cell.accessoryType = .checkmark
            cell.textLabel?.textColor = .secondaryLabel
            cell.detailTextLabel?.textColor = .secondaryLabel
        } else {
            cell.accessoryType = .none
            cell.textLabel?.textColor = .label
            cell.detailTextLabel?.textColor = .secondaryLabel
        }
        
        return cell
    }
    func tableView(

        _ tableView: UITableView,

        didSelectRowAt indexPath: IndexPath

    ) {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let detailViewController = storyboard.instantiateViewController(

            withIdentifier: "TaskDetailViewController"

        )

        if let detailViewController = detailViewController as? TaskDetailViewController {
            detailViewController.taskIndex = indexPath.row
            detailViewController.taskTitle = tasks[indexPath.row].0
            detailViewController.taskDescription = tasks[indexPath.row].1
        }
        
        navigationController?.pushViewController(

            detailViewController,

            animated: true

        )

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
}

