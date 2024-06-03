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
    var searchController:UISearchController!
    
//MARK: - ViewController lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
//        UserDefaults.standard.set(false, forKey: "hasViewedWalkthrough")
        if UserDefaults.standard.bool(forKey: "hasViewedWalkthrough") {
                return
            }
        
        
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        if let walkthroughViewController = storyboard.instantiateViewController(withIdentifier: "WalkthroughViewController") as? WalkthroughViewController{
            walkthroughViewController.modalPresentationStyle = .fullScreen
            present(walkthroughViewController, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Enable large title for navigation bar
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.hidesBarsOnSwipe = true
        navigationItem.backButtonTitle = ""
        
        // Customize the navigation bar appearance
        if let appearance = navigationController?.navigationBar.standardAppearance {
        
            appearance.configureWithTransparentBackground()
            
            if let customFont = UIFont(name: "Nunito-Bold", size: 45.0) {
                
                appearance.titleTextAttributes = [.foregroundColor: UIColor(named: "NavigationBarTitle")!]
                appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(named: "NavigationBarTitle")!, .font: customFont]
            }
            
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }

        // Set up the data source of the table view
        tableView.dataSource = dataSource
        tableView.separatorStyle = .none
        tableView.cellLayoutMarginsFollowReadableWidth = true
        
        // Prepare the empty view
        tableView.backgroundView = emptyRestaurantView
        tableView.backgroundView?.isHidden = restaurants.count == 0 ? false : true
        
        fetchRestaurantData()
        
        // Add a search bar
        searchController = UISearchController(searchResultsController: nil)
        self.navigationItem.searchController = searchController
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search restaurants..."
        searchController.searchBar.backgroundImage = UIImage()
        searchController.searchBar.tintColor = UIColor(named: "NavigationBarTitle")
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
        
        if searchController.isActive{
            return UISwipeActionsConfiguration()
        }
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
    func fetchRestaurantData(searchText:String = ""){
        let fetchRequest: NSFetchRequest<Restaurant> = Restaurant.fetchRequest()
        //sort ascending by name
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if !searchText.isEmpty{
            var predicates: [NSPredicate] = []
            let namePredicate = NSPredicate(format: "name CONTAINS[c]%@", searchText)
            predicates.append(namePredicate)
            let locationPredicate = NSPredicate(format: "location CONTAINS[c]%@", searchText)
            predicates.append(locationPredicate)
            fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
        }
    
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate){
            
            let context = appDelegate.persistentContainer.viewContext
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            
            do{
                try fetchResultController.performFetch()
                updateSnapshot(animatingChange: searchText.isEmpty ? false : true)
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

extension RestaurantTableViewController:UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else{
            return
        }
        fetchRestaurantData(searchText: searchText)
    }
}

