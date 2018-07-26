import Foundation
import CoreData

public class CoreDataObservable<T: NSManagedObject>: RequestObservable<T>, NSFetchedResultsControllerDelegate {

    // MARK: - Attributes

    internal let fetchRequest: NSFetchRequest<NSFetchRequestResult>
    internal var observer: ((ObservableChange<T>) -> Void)?
    internal let fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>
    private var batchChanges: [CoreDataChange<T>] = []


    // MARK: - Init

    internal init(request: FetchRequest<T>, context: NSManagedObjectContext) {

        let fetchRequest: NSFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: T.entityName)
        if let predicate = request.predicate {
            fetchRequest.predicate = predicate
        }
        if let sortDescriptor = request.sortDescriptor {
            fetchRequest.sortDescriptors = [sortDescriptor]
        }
        fetchRequest.fetchBatchSize = 0
        self.fetchRequest = fetchRequest
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        super.init(request: request)
        self.fetchedResultsController.delegate = self
    }


    // MARK: - Observable

    public override func observe(_ closure: @escaping (ObservableChange<T>) -> Void) {
        assert(self.observer == nil, "Observable can be observed only once")
        let initial = try! self.fetchedResultsController.managedObjectContext.fetch(self.fetchRequest) as! [T]
        closure(ObservableChange.initial(initial))
        self.observer = closure
        _ = try? self.fetchedResultsController.performFetch()
    }


    // MARK: - Dipose Method
    
    override func dispose() {
        self.fetchedResultsController.delegate = nil
    }


    // MARK: - NSFetchedResultsControllerDelegate
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            if let indexPath = indexPath {
                self.batchChanges.append(.delete(indexPath, anObject as! T))
            }
        case .insert:
            if let newIndexPath = newIndexPath {
                self.batchChanges.append(.insert(newIndexPath, anObject as! T))
            }
        case .update:
            if let indexPath = indexPath {
                self.batchChanges.append(.update(indexPath, anObject as! T))
            }
        default: break
        }
    }

    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.batchChanges = []
    }

    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let deleted = self.batchChanges.filter { $0.isDeletion }.map { $0.indexPath() }
        let inserted = self.batchChanges.filter { $0.isInsertion }.map { (index: $0.indexPath(), element: $0.object()) }
        let updated = self.batchChanges.filter { $0.isUpdate }.map { (index: $0.indexPath(), element: $0.object()) }
        self.observer?(ObservableChange.update(deletions: deleted, insertions: inserted, modifications: updated))
    }

}
