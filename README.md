# MCMachineCode

## A IOS two-dimensional code and bar code scanning tools to support most types of common

MCMachineCode can allow you to quickly add `scan code` to your project, the use of simple and convenient, currently provides four types of scan code style, please look at the picture.

[![Alt][screenshot1_thumb]][screenshot1]    [![Alt][screenshot2_thumb]][screenshot2]    [![Alt][screenshot3_thumb]][screenshot3]    

[screenshot1_thumb]: https://raw.github.com/agelessman/MCMachineCode/master/Screenshots/Photo_0527_1a(1).jpg
[screenshot1]: https://raw.github.com/agelessman/MCMachineCode/master/Screenshots/Photo_0527_1a.jpg
[screenshot2_thumb]: https://raw.github.com/agelessman/MCMachineCode/master/Screenshots/Photo_0527_2a(1).jpg
[screenshot2]: https://raw.github.com/agelessman/MCMachineCode/master/Screenshots/Photo_0527_2a.jpg
[screenshot3_thumb]: https://raw.github.com/agelessman/MCMachineCode/master/Screenshots/Photo_0527_3a(1).jpg
[screenshot3]: https://raw.github.com/agelessman/MCMachineCode/master/Screenshots/Photo_0527_3a.jpg

## Usage


``` swift
// type 0
let machineCodeVc = MCMachineCodeViewController(lineType: LineType.LineScan, moveType: MoveType.Default)
self.navigationController?.pushViewController(machineCodeVc, animated: true)

machineCodeVc.didGetMachineCode = { code in

self.resultLabel.text = code
}

// type 1
let machineCodeVc = MCMachineCodeViewController(lineType: LineType.Grid, moveType: MoveType.Default)
self.navigationController?.pushViewController(machineCodeVc, animated: true)

machineCodeVc.didGetMachineCode = { code in

self.resultLabel.text = code
}

// type 2
let machineCodeVc = MCMachineCodeViewController(lineType: LineType.Default, moveType: MoveType.Default)
self.navigationController?.pushViewController(machineCodeVc, animated: true)

machineCodeVc.didGetMachineCode = { code in

self.resultLabel.text = code
}
```

Installation
==============
<!---->
<!--### CocoaPods-->
<!---->
<!--1. Add `pod 'YYModel'` to your Podfile.-->
<!--2. Run `pod install` or `pod update`.-->
<!--3. Import \<YYModel/YYModel.h\>.-->
<!---->

### Manually

1. Download all the files in the MCMachineCodeDemo subdirectory.
2. Add the source files to your Xcode project.



## Author

M.C, chaoma0609@gmail.com

## If you feel helpful, please point a Star~ thank you.. Please contact me with any questions.