# ParagraphTextKit

ParagraphTextStorage is a subclass of NSTextStorage class. It operates the whole paragraphs of text and notifies its paragraph delegate if user made any changes to any paragraph. Delegate receives only touched paragraph descriptors.

This behavior is important when the paragraph entity represents a specific object in your model. In many text editor cases it's much easier to operate individual paragraphs, not the complete attributed string. So, in case of ParagraphTextStorage, every single change to the text storage can be reflected in the specific object of your model.

As a result, you now get an opportunity to track changes paragraph-by-paragraph and reflect those changes in your model. That will make it easy not only to build a custom business logic with your model, but also to convert that model into a persistant state using Core Data, for example.

### Requirements

- iOS 13.0+ / macOS 10.15+
- Swift 5.1+
- Xcode 11.0+

## Usage:
Basic code to make it work:

	// setup the system
	let textStorage = ParagraphTextStorage()
	textStorage.paragraphDelegate = self
	
	let layoutManager = NSLayoutManager()
	textStorage.addLayoutManager(layoutManager)
	
	let textContainer = NSTextContainer()
	layoutManager.addTextContainer(textContainer)

	let textView = NSTextView(frame: someFrame, textContainer: textContainer)
	someScrollView.documentView = textView


If you need to sync your model with ParagraphTextStorage content, set the paragraphDelegate to adopt the ParagraphTextStorageDelegate protocol.
It's just two methods:
	
	var presentedParagraphs: [AttributedRepresentable] {
		yourModel.paragraphs
	}
	
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

### Important changes in version 1.2:
This version introduces the AttributedRepresentable protocol that defines the attributed string representation of any model. In our case we use this protocol to create even stronger syncronization between a delegate and ParagraphTextStorage.

Updated delegate protocol with new requrements of the model which now should adopt AttributedRepresentable protocol allows ParagraphTextKit to load the initial state of your model into its underlying text storage property.

In previous versions ParagraphTextKit was able to do its job only if your initial text model was empty. If you've already had some paragraphs in your model then you'd need to set ParagraphTextStorage content by yourself right after the initialization. Now ParagraphTextKit takes that onto itself completely.

Note: the required #paragraphCount()# method is now replaced with the #presentedParagraphs# computed property.

### Important changes in version 1.1:
In version 1.0 paragraph diffs algorhythm was too basic. It did the job but its flaw was its abstraction, since the purpose of the algorhythm was not the accuracy of paragraph indexes in diff calculation but the integrity of delegate notifications that end up equal with NSTextStorage edited ranges. It means that paragraph indexes during the storage mutation waere calculated with sacrification of the exact accuracy of paragraph indexes in which changes had been made, but the ending delegate notofications still guaranteed the sync with the NSTextStorage object.

But that logic leads to some confusing behaviour when you need to update your model with exact paragraph indexes and, for example, calculate the style for next paragraph.

In version 1.1 that flaw is fixed. Now your delegate object gets notified of the exact changes happened in the NSTextStorage object.

And even more good news: unit tests now track aforementioned integrity of operations.

## Installation:
### Swift Package Manager
To integrate using Apple's Swift package manager, add the following as a dependency to your Package.swift:

	.package(url: "https://github.com/CineDev/ParagraphTextKit.git", .upToNextMajor(from: "1.0.0"))
	
Then, specify "ParagraphTextKit" as a dependency of the Target in which you wish to use ParagraphTextKit.

Lastly, run the following command:

	swift package update
	
