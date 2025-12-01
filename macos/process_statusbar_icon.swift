import AppKit

guard CommandLine.arguments.count == 3 else {
    print("Usage: process_statusbar_icon <input_path> <output_path>")
    exit(1)
}

let inputPath = CommandLine.arguments[1]
let outputPath = CommandLine.arguments[2]

guard let image = NSImage(contentsOfFile: inputPath) else {
    print("Error: Could not load image at \(inputPath)")
    exit(1)
}

let size = image.size
let maxDim = max(size.width, size.height)
let newSize = NSSize(width: maxDim, height: maxDim)

let targetRect = NSRect(
    x: (maxDim - size.width) / 2,
    y: (maxDim - size.height) / 2,
    width: size.width,
    height: size.height
)

let newImage = NSImage(size: newSize)
newImage.lockFocus()
image.draw(in: targetRect, from: NSRect(origin: .zero, size: size), operation: .copy, fraction: 1.0)
newImage.unlockFocus()

guard let tiffData = newImage.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiffData),
      let pngData = bitmap.representation(using: .png, properties: [:]) else {
    print("Error: Could not create PNG data")
    exit(1)
}

do {
    try pngData.write(to: URL(fileURLWithPath: outputPath))
    print("Successfully processed status bar icon to \(outputPath)")
} catch {
    print("Error: Could not write to \(outputPath): \(error)")
    exit(1)
}
