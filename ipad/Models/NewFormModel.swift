//
//  NewFormModel.swift
//  ipad
//
//  Created by Amir Shayegh on 2020-07-17.
//  Copyright © 2020 Amir Shayegh. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class NewFormModel: Object, BaseRealmObject {
    @objc dynamic var userId: String = ""
    @objc dynamic var localId: String = {
        return UUID().uuidString
    }()
    
    override class func primaryKey() -> String? {
        return "localId"
    }
    
    @objc dynamic var remoteId: Int = -1
    @objc dynamic var shouldSync: Bool = false
    
    @objc dynamic var firstName: String = ""
    @objc dynamic var lastName: String = ""
    
    @objc dynamic var hasDriverLicence: Bool = false
    @objc dynamic var driverLicenceNumber: Int = 0
    
    
    func toDictionary() -> [String : Any] {
        return [
            "firstName": firstName,
            "lastName": lastName,
            "hasDriverLicence": hasDriverLicence,
            "driverLicenceNumber": driverLicenceNumber
        ]
    }
    
    // MARK: Setters
    func set(value: Any, for key: String) {
        if self[key] == nil {
            print("\(key) is nil")
            return
        }
        do {
            let realm = try Realm()
            try realm.write {
                self[key] = value
            }
        } catch let error as NSError {
            print("** REALM ERROR")
            print(error)
        }
    }
    
    func getFieldConfigs(editable: Bool) -> [InputItem] {
        var sectionItems: [InputItem] = []
        
        
        let lastNameField = TextInput(
            key: "lastName",
            header: "Last Name",
            editable: editable,
            value: firstName,
            width: .Half
        )
        sectionItems.append(lastNameField)
        
        let firstNameField = TextInput(
            key: "firstName",
            header: "First Name",
            editable: editable,
            value: firstName,
            width: .Half
        )
        sectionItems.append(firstNameField)
        
        let hasLicence = SwitchInput(
            key: "hasDriverLicence",
            header: "Licenced?",
            editable: editable,
            value: hasDriverLicence,
            width: .Third
        )
        sectionItems.append(hasLicence)
        
        let space = InputSpacer(width: .Third)
        sectionItems.append(space)
        
        let licenceNumber = IntegerInput(
            key: "driverLicenceNumber",
            header: "Licenced number",
            editable: editable,
            value: driverLicenceNumber,
            width: .Third
        )
        licenceNumber.dependency.append(InputDependency(to: hasLicence, equalTo: true))
        sectionItems.append(licenceNumber)
        return sectionItems
    }
   
}
