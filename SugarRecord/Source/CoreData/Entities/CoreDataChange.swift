import Foundation

internal enum CoreDataChange<T> {
    
    case update(IndexPath, T)
    case delete(IndexPath, T)
    case insert(IndexPath, T)
    
    internal func object() -> T {
        switch self {
        case .update(_, let object): return object
        case .delete(_, let object): return object
        case .insert(_, let object): return object
        }
    }
    
    internal func indexPath() -> IndexPath {
        switch self {
        case .update(let index, _): return index
        case .delete(let index, _): return index
        case .insert(let index, _): return index
        }
    }
    
    internal var isDeletion: Bool {
        switch self {
        case .delete(_): return true
        default: return false
        }
    }
    
    internal var isUpdate: Bool {
        switch self {
        case .update(_): return true
        default: return false
        }
    }
    
    internal var isInsertion: Bool {
        switch self {
        case .insert(_): return true
        default: return false
        }
    }
    
}
