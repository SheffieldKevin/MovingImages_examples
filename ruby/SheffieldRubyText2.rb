#!/usr/bin/env ruby

# This script takes a movie file and adds a small annotation that fades in and then back out again.

require 'moving_images'

include MovingImages
include MICGDrawing
include CommandModule
include MIMovie

$movieDirectory = File.expand_path(File.join(File.dirname(__FILE__), "../movies"))
$movieFileName = "IMG_0874.MOV"
$movieFilePath = File.join($movieDirectory, $movieFileName)

$movieFileExportPath = File.expand_path("~/Desktop/SheffieldRuby.mov")

class DrawTextOnVideoFrames
  @@textBitmapWidth = 200
  @@textBitmapHeight = 90
  @@videoWidth = 1280
  @@videoHeight = 720

  @@numberOfFramesToProcess = 300
  
  def self.drawto_textbitmap(text1: nil, text2: nil, bitmap: nil)
    drawArrayOfElements = MIDrawElement.new(:arrayofelements)
    borderWidth = 3
    blackColor = MIColor.make_rgbacolor(0,0,0, a: 1.0)

    drawRect = MIShapes.make_rectangle(xloc: 0,
                                       yloc: 0,
                                      width: @@textBitmapWidth,
                                     height: @@textBitmapHeight)
    fillBitmap = MIDrawElement.new(:fillrectangle)
    fillBitmap.rectangle = drawRect
    fillBitmap.strokecolor = blackColor
    fillBitmap.blendmode = :kCGBlendModeCopy
    drawArrayOfElements.add_drawelement_toarrayofelements(fillBitmap)

    drawText1Background = MIDrawElement.new(:fillrectangle)
    text2BackgroundRect = MIShapes.make_rectangle(xloc: borderWidth,
                                                  yloc: borderWidth,
                                                 width: @@textBitmapWidth - 2 * borderWidth,
                                                height: @@textBitmapHeight * 0.5 -  borderWidth)
    text1BackgroundRect = MIShapes.make_rectangle(xloc: borderWidth,
                                                  yloc: @@textBitmapHeight * 0.5,
                                                 width: @@textBitmapWidth - 2 * borderWidth,
                                                height: @@textBitmapHeight * 0.5 -  borderWidth)
    textBox1 = MIShapes.make_rectangle(xloc: borderWidth,
                                                  yloc: @@textBitmapHeight * 0.5 + borderWidth,
                                                 width: @@textBitmapWidth - 2 * borderWidth,
                                                height: @@textBitmapHeight * 0.5 - 2 * borderWidth)
    textBox2 = MIShapes.make_rectangle(xloc: borderWidth,
                                                  yloc: borderWidth + borderWidth,
                                                 width: @@textBitmapWidth - 2 * borderWidth,
                                                height: @@textBitmapHeight * 0.5 - 2 * borderWidth)

    drawText1Background.rectangle = text1BackgroundRect
    drawText1Background.fillcolor = blackColor
    drawText1Background.blendmode = :kCGBlendModeCopy
    drawArrayOfElements.add_drawelement_toarrayofelements(drawText1Background)
    
    drawStringElement1 = MIDrawBasicStringElement.new
    drawStringElement1.boundingbox = textBox1
    drawStringElement1.fontsize = 30
    drawStringElement1.fillcolor = MIColor.make_rgbacolor(0.5,0.5,0.5, a: 0.0)
    drawStringElement1.blendmode = :kCGBlendModeCopy
    drawStringElement1.stringtext = text1
    drawStringElement1.postscriptfontname = :'Tahoma-Bold'
    drawStringElement1.textalignment = :kCTTextAlignmentCenter
    drawArrayOfElements.add_drawelement_toarrayofelements(drawStringElement1)

    drawText2Background = MIDrawElement.new(:fillrectangle)
    drawText2Background.rectangle = text2BackgroundRect
    drawText2Background.fillcolor = MIColor.make_rgbacolor(0.5,0.5,0.5, a: 0.0)
    drawText2Background.blendmode = :kCGBlendModeCopy
    drawArrayOfElements.add_drawelement_toarrayofelements(drawText2Background)
    
    drawStringElement2 = MIDrawBasicStringElement.new
    drawStringElement2.boundingbox = textBox2
    drawStringElement2.fontsize = 30
    drawStringElement2.fillcolor = MIColor.make_rgbacolor(1.0,1.0,1.0, a: 1.0)
    drawStringElement2.blendmode = :kCGBlendModeCopy
    drawStringElement2.stringtext = text2
    drawStringElement2.postscriptfontname = :'Tahoma-Bold'
    drawStringElement2.textalignment = :kCTTextAlignmentCenter
    drawArrayOfElements.add_drawelement_toarrayofelements(drawStringElement2)
    
    drawElementCommand = CommandModule.make_drawelement(bitmap, drawinstructions: drawArrayOfElements)
    drawElementCommand
  end

  def self.draw_textbitmap(videoFrameBitmap, textbitmap: nil, fraction: nil)
    drawTextBitmap = MIDrawImageElement.new
    drawTextBitmap.set_bitmap_imagesource(source_object: textbitmap)
    height = @@textBitmapHeight
    width = @@textBitmapWidth
    destRect = MIShapes.make_rectangle(xloc: 60,
                                       yloc: 30,
                                      width: width,
                                     height: height)
    drawTextBitmap.destinationrectangle = destRect
    drawTextBitmap.contextalpha = fraction
    drawElementCommand = CommandModule.make_drawelement(videoFrameBitmap, drawinstructions: drawTextBitmap)
    drawElementCommand
  end

  def self.draw_videoframe(videoImporter, videobitmap: nil)
    nextFrameTime = MovieTime.make_movietime_nextsample
    drawVideoFrameBitmap = MIDrawImageElement.new
    drawVideoFrameBitmap.set_moviefile_imagesource(source_object: videoImporter,
                                                       frametime: nextFrameTime)
    drawVideoFrameBitmap.destinationrectangle = MIShapes.make_rectangle(width: @@videoWidth, height: @@videoHeight)
    drawVideoFrameCommand = CommandModule.make_drawelement(videobitmap, drawinstructions: drawVideoFrameBitmap)
    drawVideoFrameCommand
  end

  def self.make_drawtext_on_videoframes_commands()
    textBitmapSize = MIShapes.make_size(@@textBitmapWidth, @@textBitmapHeight)
    videoFrameSize = MIShapes.make_size(@@videoWidth, @@videoHeight)
    
    frameDuration = MIMovie::MovieTime.make_movietime(timevalue: 1, timescale: 30)
    
    theCommands = SmigCommands.new
    textBitmap = theCommands.make_createbitmapcontext(size: textBitmapSize)
    videoFrameBitmap = theCommands.make_createbitmapcontext(size: videoFrameSize)
    
    movieImporter = theCommands.make_createmovieimporter($movieFilePath)
    
    videoFramesWriter = theCommands.make_createvideoframeswriter($movieFileExportPath)
    addVideoInputCommand = CommandModule.make_addinputto_videowritercommand(
                                                              videoFramesWriter,
                                                   framesize: videoFrameSize,
                                               frameduration: frameDuration)
    theCommands.add_command(addVideoInputCommand)
    JSON.pretty_generate(theCommands.commandshash)
    @@numberOfFramesToProcess.times do |index|
      drawVideoFrameCommand = self.draw_videoframe(movieImporter, videobitmap: videoFrameBitmap)
      theCommands.add_command(drawVideoFrameCommand)
      drawTextCommand = self.drawto_textbitmap(text1: "Sheffield", text2: "garden", bitmap: textBitmap)
      theCommands.add_command(drawTextCommand)
      nm1 = @@numberOfFramesToProcess - 1.0
      fraction = 1.0 - 4.0 * (index - nm1*0.5) * (index - nm1*0.5) / (nm1 * nm1)
      drawTextBitmapToVideoFrameCommand = self.draw_textbitmap(videoFrameBitmap,
                                                   textbitmap: textBitmap,
                                                     fraction: fraction)
      theCommands.add_command(drawTextBitmapToVideoFrameCommand)
      addImageToWriterInput = CommandModule.make_addimageto_videoinputwriter(
          videoFramesWriter, sourceobject: videoFrameBitmap)
      theCommands.add_command(addImageToWriterInput)
    end
    finalize = CommandModule.make_finishwritingframescommand(videoFramesWriter)
    theCommands.add_command(finalize)
    theCommands
  end
  
end

theCommands = DrawTextOnVideoFrames.make_drawtext_on_videoframes_commands()

# puts JSON.pretty_generate(theCommands.commandshash)
Smig.perform_commands(theCommands)

`open #{$movieFileExportPath}`
