# ParagraphTextKit

ParagraphTextStorage is a subclass of NSTextStorage class. It operates the whole paragraphs of text and notifies its paragraph delegate if user made any changes to any paragraph. Delegate receives only touched paragraph descriptors.

This behavior is important when the paragraph entity represents a specific object in your model. In many text editor cases it's much easier to operate individual paragraphs, not the complete attributed string. So, in case of ParagraphTextStorage, every single change to the text storage can be reflected in the specific object of your model.

As a result, you now get an opportunity to track changes paragraph-by-paragraph and reflect those changes in your model. That will make it easy not only to build a custom business logic with your model, but also to convert that model into a persistant state using Core Data, for example.

### Requirements

- iOS 13.0+ / macOS 10.15+
- Swift 5.2+

## Usage:
Basic code to make it work:

	// setup the system
	let textStorage = ParagraphTextStorage()
	let layoutManager = NSLayoutManager()
	textStorage.addLayoutManager(layoutManager)

If you need to sync your model with ParagraphTextStorage content, set the paragraphDelegate to adopt the ParagraphTextStorageDelegate protocol. It's just one method:
	
	func textStorage(_ textStorage: ParagraphTextStorage, didChangeParagraphs changes: [ParagraphTextStorage.ParagraphChange]) {
		for change in changes {
			switch change {
			case .insertedParagraph(index: let index, descriptor: let paragraphDescriptor):
				yourModel.insert(paragraphDescriptor.text, at: index)
				
			case .removedParagraph(index: let index):
				yourModel.remove(at: index)
		
			case .editedParagraph(index: let index, descriptor: let paragraphDescriptor):
				yourModel[index] = paragraphDescriptor.text
			}
		}
	}
	
Finally, set the paragraphDelegate property of the ParagraphTextStorage instance.

	textStorage.paragraphDelegate = yourDelegateObject

That's all you need to implement to make things work.

## Installation:
### Swift Package Manager
To integrate using Apple's Swift package manager, add the following as a dependency to your Package.swift:

	.package(url: "https://github.com/CineDev/ParagraphTextKit.git", .upToNextMajor(from: "1.0.0"))
	
Then, specify "ParagraphTextKit" as a dependency of the Target in which you wish to use ParagraphTextKit.

Lastly, run the following command:

	swift package update
	
