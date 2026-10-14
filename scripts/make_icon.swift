import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

// Padel Board app icon: a top-down slice of the blue court, the net, one of your players
// (rose) moving up with a dashed arrow, an opponent (dark brown) and the ball.
let size = 1024
let s = CGFloat(size)
let space = CGColorSpace(name: CGColorSpace.sRGB)!
// No alpha channel: App Store icons must be opaque.
let ctx = CGContext(data: nil, width: size, height: size, bitsPerComponent: 8, bytesPerRow: 0,
                    space: space, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
// Flip so y grows downwards like the app's coordinates.
ctx.translateBy(x: 0, y: s)
ctx.scaleBy(x: 1, y: -1)

func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> CGColor {
    CGColor(colorSpace: space, components: [r, g, b, a])!
}

let court = rgb(0.184, 0.373, 0.525)
let white = rgb(1, 1, 1)
let lines = rgb(1, 1, 1, 0.92)
let rose = rgb(0.912, 0.288, 0.413)
let roseLight = rgb(0.952, 0.608, 0.677)
let brown = rgb(0.240, 0.193, 0.160)
let ball = rgb(0.866, 0.937, 0.223)

// Turf
ctx.setFillColor(court)
ctx.fill(CGRect(x: 0, y: 0, width: s, height: s))

// Service lines and centre line
ctx.setStrokeColor(lines)
ctx.setLineWidth(22)
ctx.setLineCap(.butt)
ctx.move(to: CGPoint(x: 0, y: 150)); ctx.addLine(to: CGPoint(x: s, y: 150))
ctx.move(to: CGPoint(x: 0, y: 874)); ctx.addLine(to: CGPoint(x: s, y: 874))
ctx.move(to: CGPoint(x: s / 2, y: 150)); ctx.addLine(to: CGPoint(x: s / 2, y: 874))
ctx.strokePath()

// Net, with a soft shadow
ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -10), blur: 18, color: rgb(0, 0, 0, 0.35))
ctx.setFillColor(brown)
ctx.fill(CGRect(x: 0, y: s / 2 - 18, width: s, height: 36))
ctx.restoreGState()

func token(_ center: CGPoint, radius: CGFloat, fill: CGColor) {
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -12), blur: 24, color: rgb(0, 0, 0, 0.35))
    ctx.setFillColor(white)
    ctx.fillEllipse(in: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
    ctx.restoreGState()
    let inner = radius - 26
    ctx.setFillColor(fill)
    ctx.fillEllipse(in: CGRect(x: center.x - inner, y: center.y - inner, width: inner * 2, height: inner * 2))
}

let you = CGPoint(x: 300, y: 730)
let ballCenter = CGPoint(x: 540, y: 360)

// Opponent near their baseline
token(CGPoint(x: 740, y: 280), radius: 112, fill: brown)
// Your player
token(you, radius: 118, fill: rose)

// The shot: a dashed arc from your player over the net towards the ball
let arcStart = CGPoint(x: 360, y: 610)
let arcControl = CGPoint(x: 380, y: 430)
let arcEnd = CGPoint(x: 450, y: 395)
ctx.setStrokeColor(roseLight)
ctx.setLineWidth(22)
ctx.setLineCap(.round)
ctx.setLineDash(phase: 0, lengths: [30, 34])
ctx.move(to: arcStart)
ctx.addQuadCurve(to: arcEnd, control: arcControl)
ctx.strokePath()
ctx.setLineDash(phase: 0, lengths: [])
// Arrowhead along the curve's end tangent
let dx = arcEnd.x - arcControl.x, dy = arcEnd.y - arcControl.y
let len = (dx * dx + dy * dy).squareRoot()
let ux = dx / len, uy = dy / len
let tip = CGPoint(x: arcEnd.x + ux * 34, y: arcEnd.y + uy * 34)
let back = CGPoint(x: arcEnd.x - ux * 22, y: arcEnd.y - uy * 22)
ctx.setFillColor(roseLight)
ctx.move(to: tip)
ctx.addLine(to: CGPoint(x: back.x - uy * 40, y: back.y + ux * 40))
ctx.addLine(to: CGPoint(x: back.x + uy * 40, y: back.y - ux * 40))
ctx.closePath()
ctx.fillPath()

// Ball, with its shadow on the court below it
ctx.setFillColor(rgb(0, 0, 0, 0.28))
ctx.fillEllipse(in: CGRect(x: ballCenter.x - 40, y: ballCenter.y + 70, width: 80, height: 26))
ctx.setFillColor(white)
ctx.fillEllipse(in: CGRect(x: ballCenter.x - 62, y: ballCenter.y - 62, width: 124, height: 124))
ctx.setFillColor(ball)
ctx.fillEllipse(in: CGRect(x: ballCenter.x - 48, y: ballCenter.y - 48, width: 96, height: 96))

let image = ctx.makeImage()!
let out = URL(fileURLWithPath: CommandLine.arguments[1])
let dest = CGImageDestinationCreateWithURL(out as CFURL, UTType.png.identifier as CFString, 1, nil)!
CGImageDestinationAddImage(dest, image, nil)
CGImageDestinationFinalize(dest)
print("wrote \(out.path)")
