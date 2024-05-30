//
//  RestaurantTableTableViewController.swift
//  FoodPin
//
//  Created by PhuongDo on 20/05/2024.
//

import UIKit
import CoreData

class RestaurantTableViewController: UITableViewController{
    @IBOutlet var emptyRestaurantView:UIView!
    lazy var dataSource = configureDataSource()
    var restaurants:[Restaurant] = []
    var fetchResultController:NSFetchedResultsController<Restaurant>!
    
    
//MARK: - ViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchRestaurantData()
        //Prepare if no have restaurant
        tableView.backgroundView = emptyRestaurantView
        if(restaurants.count == 0  ){
            tableView.backgroundView?.isHidden = false
        }
        else{
            tableView.backgroundView?.isHidden = true
        }
    
        
        // Enable large title for navigation bar
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.hidesBarsOnSwipe = true
        
        // Set up the data source of the table view
        tableView.dataSource = dataSource
        tableView.separatorStyle = .none
        
        //custom apperance of navigation bar
        navigationItem.backButtonTitle = ""
        if let apperance = navigationController?.navigationBar.standardAppearance{
            apperance.configureWithTransparentBackground()
            if let customFont = UIFont(name: "Nunito-Bold", size: 45.0){
                apperance.titleTextAttributes = [.foregroundColor: UIColor(named: "NavigationBarTitle")!]
                apperance.largeTitleTextAttributes = [.foregroundColor: UIColor(named: "NavigationBarTitle")!,.font:customFont]
            }
            navigationController?.navigationBar.standardAppearance = apperance
            navigationController?.navigationBar.compactAppearance = apperance
            navigationController?.navigationBar.scrollEdgeAppearance = apperance
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = true
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
//MARK: - TableviewDiffable Datasource
    
    func configureDataSource() -> RestaurantDiffableDataSource {
        let cellIdentifier = "favoritecell"
        let dataSource = RestaurantDiffableDataSource(
            tableView: tableView, cellProvider: { tableView, indexPath, restaurant in
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! RestaurantTableViewCell
                cell.nameLabel.text = restaurant.name
                cell.thumbnailImageView.image = UIImage(data: restaurant.image)
                cell.locationLabel.text = restaurant.location
                cell.typeLabel.text = restaurant.type
                cell.favoriteImageView.isHidden = restaurant.isFavorite ? false : true
                return cell
            }
        )
        return dataSource
    }

//MARK: - Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRestaurantDetail"{
            if let indexPath = tableView.indexPathForSelectedRow{
                let destinationController = segue.destination as! RestaurantDetailViewController
                destinationController.restaurant = self.restaurants[indexPath.row]
            }
        }
    }
    
//MARK: - UitableView delegate protocol
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let restaurant = self.dataSource.itemIdentifier(for: indexPath) else{
            return UISwipeActionsConfiguration()
        }
        
        //delete action
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {( action, sourceView, completionHandler ) in
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
                let context = appDelegate.persistentContainer.viewContext
                context.delete(restaurant)
                appDelegate.saveContext()
                
                //Update view after delete
                self.updateSnapshot(animatingChange: true)
            }
            
            completionHandler(true)
        }
        deleteAction.backgroundColor = UIColor.systemRed
        deleteAction.image = UIImage(systemName: "trash")
        
        //share action
        let shareAction = UIContextualAction(style: .normal, title: "Share") {( action, sourceView, completionHandler )in
            let defaultText = "Checking in at " + restaurant.name
            let activityController: UIActivityViewController
            //share image
            if let imageToShare = UIImage(data: restaurant.image){
                activityController = UIActivityViewController(activityItems: [defaultText,imageToShare], applicationActivities: nil)
            }
            else{
                activityController = UIActivityViewController(activityItems: [defaultText], applicationActivities: nil)
            }
        
        self.present(activityController, animated: true,completion: nil)
        completionHandler(true)
    }
        shareAction.backgroundColor = UIColor.systemOrange
        shareAction.image = UIImage(systemName: "square.and.arrow.up")
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction,shareAction])
        return swipeConfiguration
    }
        
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        //favorite action
        let favoriteAction = UIContextualAction(style: .normal, title: nil) {( action, sourceView, completionHandler )in
            let cell = tableView.cellForRow(at: indexPath) as! RestaurantTableViewCell
            cell.favoriteImageView.isHidden = self.restaurants[indexPath.row].isFavorite
            self.restaurants[indexPath.row].isFavorite = self.restaurants[indexPath.row].isFavorite ? false : true
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
                appDelegate.saveContext()
                //Update view after toggle favorite
                self.updateSnapshot(animatingChange: true)
            }
        
            completionHandler(true)
        }
        
        favoriteAction.backgroundColor = UIColor.systemPink
        favoriteAction.image = self.restaurants[indexPath.row].isFavorite ? UIImage(systemName: "heart.slash.fill") : UIImage(systemName: "heart.fill")
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [favoriteAction])
        return swipeConfiguration
        
    }
    
    @IBAction func unwindSegue(segue:UIStoryboardSegue){
        dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: - Fetch Restaurant Data from Core Data
    func fetchRestaurantData(){
        let fetchRequest: NSFetchRequest<Restaurant> = Restaurant.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate){
            
            let context = appDelegate.persistentContainer.viewContext
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            
            do{
                try fetchResultController.performFetch()
                updateSnapshot()
            }
            catch{
                print(error)
            }
        }
    }
    //update view when core data update data
    func updateSnapshot(animatingChange:Bool = false){
        if let fetchedObjects = fetchResultController.fetchedObjects{
            restaurants = fetchedObjects
        }
        
        // Create a snapshot and populate the data
        var snapshot = NSDiffableDataSourceSnapshot<Section, Restaurant>()
        snapshot.appendSections([.all])
        snapshot.appendItems(restaurants, toSection: .all)

        dataSource.apply(snapshot, animatingDifferences: animatingChange)

        tableView.backgroundView?.isHidden = restaurants.count == 0 ? false : true
    }
    



}
extension RestaurantTableViewController:NSFetchedResultsControllerDelegate{
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateSnapshot()
    }
    
}

