/*
 File: ContactsManager
 Author: CoDex
 Purpose: This part is used to manage the contact.
 */
import Foundation
import Contacts

class ContactsManager: NSObject {
    
    /**
     * Singleton
     */
    static let sharedManager = ContactsManager()
    
    private let contactStore: CNContactStore!
    
    override init() {
        contactStore = CNContactStore()
        
        super.init()
    }
    
    /**
     * Request for contact access
     */
    func requestAutorizationForContactsAddressBook(completion: @escaping (_ granted: Bool, _ e: NSError?) -> Void) {
        contactStore.requestAccess(for: .contacts) { (granted, e) -> Void in
            completion(granted, e as NSError?)
        }
    }
    
    /**
     * Request contact fetch
     */
    func fetchValidAddressBookContacts(completion: (_ contacts: [CNContact]?, _ e: NSError?) -> Void) {
        
        do {
            var validContacts: [CNContact] = []
            
            // Specify the key fields that you want to be fetched. 
            // Note: if you didn't specify your specific field request. your app will crash
            let fetchRequest = CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey as CNKeyDescriptor, CNContactMiddleNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor, CNContactEmailAddressesKey as CNKeyDescriptor, CNContactPhoneNumbersKey as CNKeyDescriptor, CNContactImageDataKey as CNKeyDescriptor, CNContactThumbnailImageDataKey as CNKeyDescriptor])
            
            try contactStore.enumerateContacts(with: fetchRequest, usingBlock: { (contact, error) -> Void in
                
                // Lets filter (optional)
                if !contact.emailAddresses.isEmpty || !contact.phoneNumbers.isEmpty {
                    validContacts.append(contact)
                }
            })
            
            // throws contacts on completion handler
            completion(validContacts, nil)
        }catch let e as NSError {
            completion(nil, e)
        }
    }
}
