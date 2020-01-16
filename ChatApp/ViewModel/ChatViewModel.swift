//
//  ChatViewModel.swift
//  ChatApp
//

import Foundation
import RxSwift
import CoreData

class ChatViewModel {
    
    var delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var context: NSManagedObjectContext? = nil
    var entity: NSEntityDescription? = nil
    
    let newMessage = BehaviorSubject<String>(value: "")
    
    init() {
        context = delegate.persistentStore?.context
        entity = NSEntityDescription.entity(forEntityName: "Chats", in: context!)
    }

    var observedMessage:Observable<String> {
        return newMessage.asObservable()
    }
    
    func saveToCoreData(dateLeft: String, message: String, status: String) {
        let text = NSManagedObject(entity: entity!, insertInto: context)
        text.setValue(dateLeft, forKey: "dateLeft")
        text.setValue(message, forKey: "message")
        text.setValue(status, forKey: "status")
        do {
            try context?.save()
        } catch {
            print("Failed to saved your message")
        }
    }
    
    func fetchMessagesFromCoreData() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Chats")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context!.fetch(request)
            for data in result as! [NSManagedObject] {
              print("All messages: ", data.value(forKey: "message") as! String)
            }
        } catch {
           print("Failed")
        }
    }
}
