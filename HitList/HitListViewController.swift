//
//  HitListViewController.swift
//  HitList
//
//  Created by Turzion, Avihu on 1/22/16.
//  Copyright © 2016 Avihu Turzion. All rights reserved.
//

import UIKit
import CoreData

class HitListViewController: UIViewController {

  private var people = [NSManagedObject]()

  @IBOutlet private weak var tableView: UITableView!

  private var appDelegate: AppDelegate? {
    return UIApplication.sharedApplication().delegate as? AppDelegate
  }

  private lazy var managedContext: NSManagedObjectContext? = {
    guard let appDelegate = self.appDelegate else { return nil }
    return appDelegate.managedObjectContext
  }()

  private lazy var peopleFetchRequest: NSFetchRequest = {
    return NSFetchRequest(entityName: kPersonEntityName)
  }()

  private var commitOnReturnDelegate: CommitOnReturnTextFieldDelegate?

}

// MARK: View controller life cycle

extension HitListViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "\"The List\""
    tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: kSimpleCellName)
    commitOnReturnDelegate = CommitOnReturnTextFieldDelegate(handler: saveNameFromAlertTextField)
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    fetchPeopleFromLocalStore()
  }

}

// MARK: Outlet actions

private extension HitListViewController {
  @IBAction func addName(sender: UIBarButtonItem) {
    let addNameAlert = UIAlertController(title: "New Name", message: "Add a new name", preferredStyle: .Alert)
    let saveAction = UIAlertAction(title: "Save", style: UIAlertActionStyle.Default) { [weak self] action in
      guard let textField = addNameAlert.textFields?.first else { return }
      self?.saveNameFromAlertTextField(textField)
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { _ in }
    addNameAlert.addTextFieldWithConfigurationHandler { [weak self] textField in
      textField.delegate = self?.commitOnReturnDelegate
    }
    addNameAlert.addAction(saveAction)
    addNameAlert.addAction(cancelAction)

    presentViewController(addNameAlert, animated: true, completion: nil)
  }
}

// MARK: Conforming to UITableViewDataSource

extension HitListViewController: UITableViewDataSource {

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return people.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCellWithIdentifier(kSimpleCellName) else { return UITableViewCell() }
    let person = people[indexPath.row]
    cell.textLabel?.text = person.valueForKey(kPersonNameKey) as? String
    return cell
  }
  
}

// MARK: Private implementation

private extension HitListViewController {

  func fetchPeopleFromLocalStore() {
    guard let managedContext = managedContext else { return }
    do {
      if let results = try managedContext.executeFetchRequest(peopleFetchRequest) as? [NSManagedObject] {
        people = results
      }
    } catch let error as NSError {
      print("Could not fetch \(error), \(error.userInfo)")
    }
  }

  func saveNameFromAlertTextField(textField: UITextField) {
    guard let newName = textField.text else { return }
    dismissViewControllerAnimated(true, completion: nil)
    saveName(newName)
    tableView.reloadData()
  }

  func saveName(name: String) {
    guard let managedContext = managedContext, entity = NSEntityDescription.entityForName(kPersonEntityName, inManagedObjectContext: managedContext) else { return }

    let person = NSManagedObject(entity: entity, insertIntoManagedObjectContext: managedContext)
    person.setValue(name, forKey: kPersonNameKey)

    do {
      try managedContext.save()
      people.append(person)
    } catch let error as NSError {
      print("Could not save \(error). \(error.userInfo)")
    }
  }

}

// MARK: Constants

private let kPersonEntityName = "Person"
private let kPersonNameKey = "name"

private let kSimpleCellName = "Cell"
