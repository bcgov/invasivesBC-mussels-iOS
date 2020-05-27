# Forms
The forms in the app are created with the help of a framework created for this application called `InputGroupView`.&nbsp;
- An`InputGroupView` is a collection of fields for a section of the form.
- Under the hood, an`InputGroupView` is a `UIView` that contains a `UICollectionView` that contains the fields for the group in its `UICollectionViewCell` cells.
### Input Types and Cells
| `InputItemType` | Type | Cell | Description |
| ------ | ------ | ------ | ------ |
| `.Date` | Date | [Date Input](https://github.com/bcgov/invasivesBC-mussels-iOS/tree/master/ipad/Views/Form/Input%20Cells/Date%20Input)  | Date Input displayes a Date datepicker through a popover on the delegate.|
| `.Double` | Double | [Double Input](https://github.com/bcgov/invasivesBC-mussels-iOS/tree/master/ipad/Views/Form/Input%20Cells/Double%20Input) | A textfield that only allows double numbers as input. |
| `.Dropdown` | Code Table (String indicating code table value) | [Dropdown](https://github.com/bcgov/invasivesBC-mussels-iOS/tree/master/ipad/Views/Form/Input%20Cells/Dropdown) | A textfield that when tapped, displays a dropdown through a popover via the deleage|
| `.Int` | Integer | [Integer Input](https://github.com/bcgov/invasivesBC-mussels-iOS/tree/master/ipad/Views/Form/Input%20Cells/Integer%20Input) | A textfield that only allows Integer numbers as input.
| `.Stepper` | Integer | [Integer Stepper](https://github.com/bcgov/invasivesBC-mussels-iOS/tree/master/ipad/Views/Form/Input%20Cells/Integer%20Stepper) | A textfield with stepper buttons that allow user to increase or decrease the integer value. |
| `.RadioBoolean` | Boolean | [Radio Boolean](https://github.com/bcgov/invasivesBC-mussels-iOS/tree/master/ipad/Views/Form/Input%20Cells/Radio%20Boolean) | A single radio button to allow users to selecg a boolean value|
| `.RadioSwitch` | Boolean | [Radio Switch Input](https://github.com/bcgov/invasivesBC-mussels-iOS/tree/master/ipad/Views/Form/Input%20Cells/Radio%20Switch%20Input) | 2 yes / no radio buttons to allow users to select a boolean value.|
| `.Switch` | Boolean | [Switch Input](https://github.com/bcgov/invasivesBC-mussels-iOS/tree/master/ipad/Views/Form/Input%20Cells/Switch%20Input) | A switch button to allow users to select a boolean value. |
| `.Text` | String | [Text Input](https://github.com/bcgov/invasivesBC-mussels-iOS/tree/master/ipad/Views/Form/Input%20Cells/Text%20Input) | A regular Text field that allows users to type a string. Text Input also supports 2 types of validation that limit what the user can input: Passport Nunber & Alpha numberic|
| `.TextArea` | String | [TextArea Input](https://github.com/bcgov/invasivesBC-mussels-iOS/tree/master/ipad/Views/Form/Input%20Cells/TextArea%20Input) | A multi-line text field that allows users to enter any string. Generally used for comment fields |
| `.Time` | [.Time](https://github.com/bcgov/invasivesBC-mussels-iOS/blob/master/ipad/Views/Form/Input%20Cells/Time%20Input/Time%20Picker/TimePickerViewController.swift) | [Time Input](https://github.com/bcgov/invasivesBC-mussels-iOS/tree/master/ipad/Views/Form/Input%20Cells/Time%20Input)  | Time Input displayes a Time Picker through a popover on the delegate. |
| `.Spacer` | -  |   |   |
| `.Title` | -  |   |   |
| `.ViewField` |  - |   |   |

You can change the UI Appearance of each input type, by changing the corresponding cell's XIB file.
### Creating an InputGroup

1 - Create an `InputGroupView`
```swift
let inputGroup: InputGroupView = InputGroupView()
```
2 - Initialize 
```swift
inputGroup.initialize(with Items: [InputItem], delegate: InputDelegate, in container: UIView)
```
- `Items` is an array of `InputItem` (fields) for the section. 
- `delegate` is a [`BaseViewController`](https://github.com/bcgov/invasivesBC-mussels-iOS/blob/master/ipad/ViewControllers/BaseViewController.swift) for displaying popovers
- `container` is a `UIView`that the `InputGroupView` will be displayed in

### Defining `InputItem`s for an `InputGroupView`  
-  Fields for the Watercraft Inspection form are defined [here](https://github.com/bcgov/invasivesBC-mussels-iOS/tree/master/ipad/Models/Waterfract%20Inspection/Form%20Fields).
- Fields for the shift form are defined [here](https://github.com/bcgov/invasivesBC-mussels-iOS/tree/master/ipad/Models/Shift/Form%20Fields)

There is a function for each section of the form, to grab the fields for that section.

```swift
class WatercraftInspectionFormHelper {
    
    static func getPassportFields(
        for object:WatercradftInspectionModel? = nil,
        editable: Bool? = true) -> [InputItem] {
    }
}
```

These functions supply the `InputItem`s that will be added in a `InputGroupView` for the given section.
- `object`, or model is added to read the values in the fields. 
- `editable` flag indicates if the fields should be editable.

This structure makes it easy to to add a group of fields, using `InputGroupView`, to a `UITableViewCell` or `UICollectionViewCell`.

These functions are also used to grab the fields in a section and estimate their heights for displaying in a `UITableViewCell` or `UICollectionViewCell` using

```swift
InputGroupView.estimateContentHeight(for items: [InputItem]) -> CGFloat {}
```
### Defining `InputItem`s 

```swift
// Create an empty array
var items: [InputItem] = []

// Create field
let isPassportHolder = RadioSwitchInput(
    key: "isPassportHolder",
    header: WatercraftFieldHeaderConstants.Passport.isPassportHolder,
    editable: editable ?? true,
    value: object?.isPassportHolder ?? nil,
    width: .Full
)
// Append
items.append(isPassportHolder)

// Create another field
...
// Append
...
```
 - `key` is the variable name in the model
 - `header` is the header text disolayed for the field
 - `editable` is a flag that indicates if the field should be editable
 - `value` is the initial value for the field. read this from the model
 - `width` is the width size of the field:
    - `.Full` - a full row
    - `.Half` - half row
    - `.Third` - third of row
    - `.Forth` - forth of row
    - `.Fill` - fill remaining size of row

`InputGroupView` displays the fields in the same order they've been added to the array.

### Dependency
When adding a field, you can also make it depend of the value of one or more other fields: the field will be displayed when the dependencies are satisfied.
```swift
// Define field
let isNewPassportIssued = RadioSwitchInput(
    key: "isNewPassportIssued",
    header: WatercraftFieldHeaderConstants.Passport.isNewPassportIssued,
    editable: editable ?? true,
    value: object?.isNewPassportIssued ?? nil,
    width: .Full
)
// Add a dependency to isPassportHolder
isNewPassportIssued.dependency.append(InputDependency(to: isPassportHolder, equalTo: true))
// Add field
items.append(isNewPassportIssued)
```
This means that the `isNewPassportIssued` field will be displayed when the value of `isPassportHolder` is `true`. This is also handled by the size estimation function described earlier.
```swift
InputGroupView.estimateContentHeight(for items: [InputItem]) -> CGFloat {}
```

### Listening to field value changes
There are 2 notifcations that all `InputGroupView`s emit through `NotificationCenter`:
- `.InputItemValueChanged` - When a field value changes.
    - store new value.
- `.ShouldResizeInputGroup` - When a dependency changes.
    - tell `UICollectionView` or `UITableView` to resize.

The `.InputItemValueChanged` notification will include the `InputItem` that can be unwrapped.
```swift
@objc func inputItemValueChanged(notification: Notification) {
        guard var item: InputItem = notification.object as? InputItem,
        let model = self.model else {return}
}
```
In this function, we can extract the value from the changed `InputItem` and store it in our model:
```swift
model.set(value: item.value.get(type: item.type) as Any, for: item.key)
```
or we can also handle other changes we need to make to the view based on the new value before storing it.

### Changing a field type
You can easily change the type of a field by changing the `InputItem` type it uses.&nbsp;
&nbsp;
If the type of variable in the model doesnt need to change, then you only need to change the field type.&nbsp;
For example: We have many ways to display a boolean field. if we want to change the `isNewPassportIssued` field to use a regular switch instead of using radio buttons, we can do the following:

```swift
// Before
let isNewPassportIssued = RadioSwitchInput( // radio buttons
    key: "isNewPassportIssued",
    header: WatercraftFieldHeaderConstants.Passport.isNewPassportIssued,
    editable: editable ?? true,
    value: object?.isNewPassportIssued ?? nil,
    width: .Full
)
items.append(isNewPassportIssued)
```
```swift
// After
let isNewPassportIssued = SwitchInput( // switch button
    key: "isNewPassportIssued",
    header: WatercraftFieldHeaderConstants.Passport.isNewPassportIssued,
    editable: editable ?? true,
    value: object?.isNewPassportIssued ?? nil,
    width: .Full
)
items.append(isNewPassportIssued)
```
That's it. we only changed `RadioSwitchInput` to `SwitchInput`.&nbsp;&nbsp;

If the we wanted `isNewPassportIssued` to be a `string` instead of a `boolean`, we would first need to update our data model:
```swift
// Before
class WatercradftInspectionModel: Object, BaseRealmObject {
    ...
    // Passport issue flag
    @objc dynamic var isNewPassportIssued: Bool = false
    ...
}
```
```swift
// After
class WatercradftInspectionModel: Object, BaseRealmObject {
    ...
    // Passport issue flag
    @objc dynamic var isNewPassportIssued: String = ""
    ...
}
```

And then change the field type:
```swift
let isNewPassportIssued = TextInput( // text input
    key: "isNewPassportIssued",
    header: WatercraftFieldHeaderConstants.Passport.isNewPassportIssued,
    editable: editable ?? true,
    value: object?.isNewPassportIssued ?? nil,
    width: .Full
)
items.append(isNewPassportIssued)
```

You can follow the same easy steps to change a field to a dropdown in the future as requirements change.&nbsp;&nbsp;

Note: When you change the model, you also need to add [a migration](https://realm.io/docs/swift/latest/#migrations), otherwise the application will crash. A quick workaround would be to re-install the application.
