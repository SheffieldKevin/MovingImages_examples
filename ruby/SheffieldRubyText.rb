require 'moving_images'

include MovingImages
include MICGDrawing
include CommandModule
include MIMovie

$videoWidth = 1280
$videoHeight = 720

class DrawTextOnVideoFrames()
  
  def self.draw_text(theText, textBottom)
    drawStringElement = MIDrawBasicStringElement.new
    textBox = MIShapes.make_rectangle(xloc: 0,
                                      yloc: textBottom,
                                     width: 1260,
                                    height: 100)
    drawStringElement.boundingbox = textBox
    drawStringElement.fontsize = 72
    drawStringElement.fillcolor = MIColor.make_rgbacolor(1,1,1)
    drawStringElement.stringtext = theText
    drawStringElement.postscriptfontname = :'Tahoma-Bold'
    drawStringElement.textalignment = :kCTTextAlignmentCenter
    drawStringElement
  end
  
  # progress is a value from 0.0 to 1.0 and reflects how far through the
  # video we are.
  def self.draw_textbitmap(textBitmap, progress)
    drawElements = MIDrawElement.new(:arrayofelements)
    
    # First thing is need to make black transparent.
    makeTransparentElement = MIDrawElement.new(:fillrectangle)
    drawRect = MIShapes.make_rectangle(xloc: 0, yloc: 0, width: 1280, height: 720)
    makeTransparentElement.rectangle = drawRect
    makeTransparentElement.blendmode = :kCGBlendModeCopy
    transparentColor = MIColor.make_rgbacolor(0,0,0, a: 0)
    makeTransparentElement.fillcolor = transparentColor
    drawElements.add_drawelement_toarrayofelements(makeTransparentElement)
    
    moveDistance = 740.0
    textToDraw = [
      "Not very long ago",
      "In a garden",
      "close by, there was",
      "a shady border.",
      "",
      "The shady border",
      "contained plants like",
      "Astrantia, Damson,",
      "Sarcococca confusa",
      "Epimediums and Ferns"
    ]
    
    numTexts = textToDraw.count.to_f
    progressBase = moveDistance * progress
    textToDraw.count.times do |i|
  #    textBase = progressBase - i.to_f * moveDistance / numTexts
      textBase = progressBase - i.to_f * 80
      drawStringElement = draw_text(textToDraw[i], textBase)
      drawElements.add_drawelement_toarrayofelements(drawStringElement)
    end
    drawCommand = CommandModule.make_drawelement(textBitmap,
                               drawinstructions: drawElements)
    drawCommand
  end
  
  def self.drawmovieframe_tobitmap(movie, bitmap, frametime)
    track_id = MovieTrackIdentifier.make_movietrackid_from_mediatype(
                                              mediatype: :vide,
                                             trackindex: 0)
    rect = MIShapes.make_rectangle(width: 1280, height: 720)
    drawFrameElement = MIDrawImageElement.new
    drawFrameElement.destinationrectangle = rect
    drawFrameElement.set_moviefile_imagesource(source_object: movie,
                                                   frametime: frametime,
                                                      tracks: [ track_id ])
    drawCommand = CommandModule.make_drawelement(bitmap,
                               drawinstructions: drawFrameElement)
    drawCommand
  end
  
  def self.make_applyfilter()
    # Constants
    instructionHash = {}
    begin
      setupCommands = SmigCommands.new
      movieImporter = setupCommands.make_createmovieimporter("~/DummyMovie.mov",
                                               addtocleanup: false)
  
      frameSize = MIShapes.make_size($videoWidth, $videoHeight)
      bitmap = setupCommands.make_createbitmapcontext(
                                size: frameSize,
                              preset: :PlatformDefaultBitmapContext,
                        addtocleanup: false)
  
      textBitmap = setupCommands.make_createbitmapcontext(
                                size: frameSize,
                              preset: :PlatformDefaultBitmapContext,
                        addtocleanup: false)
  
      perspectiveFilter = make_perspectivetransformfilter(textBitmap, bitmap)
      filterChain = setupCommands.make_createimagefilterchain(perspectiveFilter,
                                              addtocleanup: false)
  
      movieWriter = setupCommands.make_createvideoframeswriter(
                                            '~/DummyOutputName.mov',
                              addtocleanup: false,
                               utifiletype: 'com.apple.quicktime-movie',
                       pathsubstitutionkey: :exportfilepath)
  
      frameDuration = MovieTime.make_movietime(timevalue: 1201, timescale: 36000)
      addVideoInputCommand = CommandModule.make_addinputto_videowritercommand(
                                      movieWriter,
                              preset: :h264preset_hd,
                           framesize: frameSize,
                       frameduration: frameDuration,
                       cleanaperture: nil,
                         scalingmode: nil)
      setupCommands.add_command(addVideoInputCommand)
  
      drawElement = MIDrawElement.new(:fillrectangle)
      red = MIColor.make_rgbacolor(0.5, 0.0, 0.0)
      drawElement.fillcolor = red
      destRect = MIShapes.make_rectangle(size: frameSize)
      drawElement.rectangle = destRect
      drawRect = CommandModule.make_drawelement(bitmap,
                              drawinstructions: drawElement)
      setupCommands.add_command(drawRect)
  
      imageIdentifier = SecureRandom.uuid
      assignImageToCollection = CommandModule.make_assignimage_tocollection(
                                                      bitmap,
  #                                                    textBitmap,
                                          identifier: imageIdentifier)
      setupCommands.add_command(assignImageToCollection)
  
      processCommands = SmigCommands.new
      processCommands.run_asynchronously = true
  
      # All the demo videos are 10 seconds long and at a frame rate of 29.97
      # frames a second that is 300 frames to process. There are two videos at
      # a slightly lower frame rate but I'm asking for frames at specific times
      # so every 10th frame will be repeated in output video.
      numFrames = 299
      
      numFrames.times do |i|
        fT = MovieTime.make_movietime(timevalue: 1001 * i,
                                             timescale: 30000)
        # nextFrame = MovieTime.make_movietime_nextsample()
        drawFrameCommand = drawmovieframe_tobitmap(movieImporter, bitmap, fT)
        processCommands.add_command(drawFrameCommand)
        progress = i.to_f / numFrames.to_f
        drawTextCommand = draw_textbitmap(textBitmap, progress)
        processCommands.add_command(drawTextCommand)
        processCommands.add_command(render_filterchain(filterChain))
  
        processCommands.add_command(assignImageToCollection)
        # All the drawing is done now. Need to add the drawing to the video writer
        addImageToWriterInput = CommandModule.make_addimageto_videoinputwriter(
            movieWriter, sourceobject: bitmap)
        processCommands.add_command(addImageToWriterInput)
      end
      
      # The process commands are now done.
      # Create finalize commands list. Save the movie, close objects.
      finalizeCommands = SmigCommands.new
      saveMovie = CommandModule.make_finishwritingframescommand(movieWriter)
      finalizeCommands.add_command(saveMovie)
      finalizeCommands.add_tocleanupcommands_closeobject(movieImporter)
      finalizeCommands.add_tocleanupcommands_closeobject(bitmap)
      finalizeCommands.add_tocleanupcommands_closeobject(textBitmap)
      finalizeCommands.add_tocleanupcommands_closeobject(movieWriter)
      finalizeCommands.add_tocleanupcommands_closeobject(filterChain)
      finalizeCommands.add_tocleanupcommands_removeimagefromcollection(
                                                            imageIdentifier)
      drawToView = MIDrawImageElement.new
      drawToView.set_imagecollection_imagesource(
                                    identifier: imageIdentifier)
  
      scaleFactor = $videoHeight.to_f / $videoWidth.to_f
      destinationRect = MIShapes.make_rectangle(
                         width: "$width",
                        height: "$width * #{scaleFactor}",
                          xloc: 0,
                          yloc: "($height - $width * #{scaleFactor}) * 0.5")
      drawToView.destinationrectangle = destinationRect
  
      variables = [
        {
          maxvalue: 200.0,
          variablekey: :topwidth,
          defaultvalue: 150.0,
          minvalue: 100.0
        },
        {
          maxvalue: 300.0,
          variablekey: :bottom,
          defaultvalue: 0.0,
          minvalue: 0.0
        },
        {
          maxvalue: 720.0,
          variablekey: :top,
          defaultvalue: 730.0,
          minvalue: 420.0
        }
      ]
  
      instructionHash = { setup: setupCommands.commandshash,
                        process: processCommands.commandshash,
                       finalize: finalizeCommands.commandshash,
               drawinstructions: drawToView.elementhash,
                      variables: variables,
                 exportfilename: "TextWithPerspectiveMovie.mov"}
    end
    instructionHash
  end
end

puts JSON.pretty_generate(DrawTextOnVideoFrames.make_applyfilter())
