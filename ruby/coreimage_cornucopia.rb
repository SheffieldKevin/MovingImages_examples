require 'securerandom'
require 'moving_images'

# When creating the fourth movie. Run synchronously. use a window context so
# we can see progress.

include MovingImages
include MICGDrawing
include CommandModule

class ZukiniDemoVideo
  def self.videowidth
    return 1280
  end
  
  def self.videoheight
    return 720
  end

  def self.frame_size
    return MIShapes.make_size(self.videowidth, self.videoheight)
  end

  def self.frame_rectangle
    return MIShapes.make_rectangle(size: frame_size)
  end

  def self.frame_duration
    return MIMovie::MovieTime.make_movietime(timevalue: 3002, timescale: 90000)
  end

  @@directory = '/Users/ktam/Dropbox/zukini ltd/WebsiteContent/demovideo'
  @@output_directory = File.expand_path("~/Desktop/Current/tempmovies/")

  @@movies = [
    'BeehiveCompost-0536.mov'
  ]
  @@video_texts = [
"MovingImages
by
Zukini"
  ]

  def self.path_to_inputmovie_withindex(i)
    return nil if i < 0 || i >= @@movies.count
    return File.join(@@directory, @@movies[i])
  end

  def self.path_to_exportedmovie_withindex(i)
    return nil if i < 0 || i >= @@movies.count
    fileName = "Output#{@@movies[i]}"
    return File.join(@@output_directory, fileName)
  end

  def self.create_maskimagefilterchain(commands, inputImageID,
                                        renderDestination)
    filterchain = MIFilterChain.new(renderDestination)

    heightfieldmask = MIFilter.new(:CIHeightFieldFromMask,
                       identifier: :heightfieldmask)
    heightfield_radiusproperty = MIFilterProperty.make_cinumberproperty(
                                                 key: :inputRadius, value: 12)
    heightfieldmask.add_property(heightfield_radiusproperty)
    inputImageID = SmigIDHash.make_imageidentifier(inputImageID)
    heightfieldmask.add_inputimage_property(inputImageID)
    filterchain.add_filter(heightfieldmask)
    imageFilter = commands.make_createimagefilterchain(filterchain)
    imageFilter
  end

  def self.render_maskfilterchain(commands, filterChain)
    renderFilterChain = MIFilterChainRender.new
    renderCommand = CommandModule.make_renderfilterchain(filterChain,
                                     renderinstructions: renderFilterChain)
    commands.add_command(renderCommand)
  end

  def self.create_pagecurlfilterchain(commands,
            frontimageidentifier: nil,
            backsideimagecontext: nil,
           targetimageidentifier: nil,
                    outputbitmap: nil)
    filterchain = MIFilterChain.new(outputbitmap)
    filterchain.use_srgbprofile = true

    pageCurl = MIFilter.new(:CIPageCurlWithShadowTransition,
                identifier: :pagecurlwithshadow)
    # angle -π, 0, π
    angle = MIFilterProperty.make_cinumberproperty(key: :inputAngle,
                                                 value: -3.0)
    pageCurl.add_property(angle)
    
    extentRect = MIShapes.make_rectangle(size: self.frame_size)
    extent = MIFilterProperty.make_civectorproperty_fromrectangle(
                                                key: :inputExtent,
                                              value: extentRect)
    pageCurl.add_property(extent)

    # radius 0.01, 100, 400
    radius = MIFilterProperty.make_cinumberproperty(key: :inputRadius,
                                                  value: 150)
    pageCurl.add_property(radius)

    # shadow amount 0.0, 0.7, 1.0
    shadowAmount = MIFilterProperty.make_cinumberproperty(
                                                key: :inputShadowAmount,
                                              value: 0.7)
    pageCurl.add_property(shadowAmount)

    # shadow size 0.0, 0.5, 1.0
    shadowSize = MIFilterProperty.make_cinumberproperty(key: :inputShadowSize,
                                                      value: 0.5)
    pageCurl.add_property(shadowSize)
    backsideImage = MIFilterProperty.make_ciimageproperty(
                                                key: :inputBacksideImage,
                                              value: backsideimagecontext)
    pageCurl.add_property(backsideImage)

    inputImageID = SmigIDHash.make_imageidentifier(frontimageidentifier)
    inputImage = MIFilterProperty.make_ciimageproperty(key: :inputImage,
                                                     value: inputImageID)
    pageCurl.add_property(inputImage)
    
    targetImageID = SmigIDHash.make_imageidentifier(targetimageidentifier)
    targetImage = MIFilterProperty.make_ciimageproperty(key: :inputTargetImage,
                                                      value: targetImageID)
    pageCurl.add_property(targetImage)
    
    filterchain.add_filter(pageCurl)
    imageFilter = commands.make_createimagefilterchain(filterchain)
    imageFilter
  end

  def self.render_pagecurlfilterchain(commands, filterChain, progress)
    renderFilterChain = MIFilterChainRender.new
    prop = MIFilterRenderProperty.make_renderproperty_withfilternameid(
                                          key: :inputTime,
                                        value: progress,
                                filtername_id: :pagecurlwithshadow)
    renderFilterChain.add_filterproperty(prop)
    extentRect = MIShapes.make_rectangle(size: self.frame_size)
    renderFilterChain.destinationrectangle = extentRect
    renderFilterChain.sourcerectangle = extentRect
    renderCommand = CommandModule.make_renderfilterchain(filterChain,
                                     renderinstructions: renderFilterChain)
    commands.add_command(renderCommand)
  end

  def self.create_draw_nextframe_tobitmap_command(bitmap, movieImporter)
    drawFrameElement = MIDrawImageElement.new
    drawFrameElement.interpolationquality = :kCGInterpolationHigh
    drawFrameElement.destinationrectangle = self.frame_rectangle
    drawFrameElement.set_moviefile_imagesource(source_object: movieImporter,
        frametime: MIMovie::MovieTime.make_movietime_nextsample)
    drawImage = CommandModule.make_drawelement(bitmap,
                    drawinstructions: drawFrameElement)
    drawImage
  end

  def self.run()
    theCommands = SmigCommands.new
    theRect = MIShapes.make_rectangle(size: self.frame_size)
    drawContext = theCommands.make_createbitmapcontext(size: self.frame_size,
                                       preset: :PlatformDefaultBitmapContext)

    fillBlack = MIDrawElement.new(:fillrectangle)
    fillBlack.rectangle = theRect
    fillBlack.fillcolor = MIColor.make_rgbacolor(0, 0, 0)
    drawElements = MIDrawElement.new(:arrayofelements)
    drawElements.add_drawelement_toarrayofelements(fillBlack)
    
    drawText = MIDrawBasicStringElement.new
    drawText.stringtext = @@video_texts[0]
    drawText.fontsize = 110
    drawText.postscriptfontname = 'BrandonGrotesque-Bold'
    drawText.fillcolor = MIColor.make_rgbacolor(1,1,1)
    drawText.textalignment = :kCTTextAlignmentCenter
    drawText.boundingbox = MIShapes.make_rectangle(xloc: 150, yloc: 100,
                                              width: 980, height: 520)
    drawElements.add_drawelement_toarrayofelements(drawText)

    drawCommand = CommandModule.make_drawelement(drawContext,
      drawinstructions: drawElements)
    theCommands.add_command(drawCommand)
    imageIdentifier = SecureRandom.uuid
    assignImageCommand = CommandModule.make_assignimage_tocollection(
      drawContext, identifier: imageIdentifier)
    theCommands.add_command(assignImageCommand)
    theCommands.add_tocleanupcommands_removeimagefromcollection(imageIdentifier)
    
    filterChainObject = self.create_maskimagefilterchain(theCommands,
                                                imageIdentifier, drawContext)
    self.render_maskfilterchain(theCommands, filterChainObject)
    theCommands.add_command(assignImageCommand)
    # Now draw that image back to the bitmap but mirrored.
    drawMirrorImage = MIDrawImageElement.new
    drawMirrorImage.destinationrectangle = theRect
    drawMirrorImage.set_imagecollection_imagesource(identifier: imageIdentifier)
    transform = MITransformations.make_contexttransformation
    offset = MIShapes.make_point(self.videowidth, 0)
    MITransformations.add_translatetransform(transform, offset)
    scale = MIShapes.make_point(-1, 1)
    MITransformations.add_scaletransform(transform, scale)
    drawMirrorImage.contexttransformations = transform
    drawMirrorImageCommand = CommandModule.make_drawelement(drawContext,
      drawinstructions: drawMirrorImage)
    theCommands.add_command(drawMirrorImageCommand)

    movie_index = 0
    movieImporter = theCommands.make_createmovieimporter(
                            self.path_to_inputmovie_withindex(movie_index))
    outputBitmap = theCommands.make_createbitmapcontext(size: self.frame_size,
                    preset: :PlatformDefaultBitmapContext)
#    outputBitmap = theCommands.make_createwindowcontext(rect: theRect,
#      addtocleanup: false)
    movieInputImageID = SecureRandom.uuid
    assignImageCommand2 = CommandModule.make_assignimage_tocollection(
      outputBitmap, identifier: movieInputImageID)
    theCommands.add_command(assignImageCommand2)
    theCommands.add_tocleanupcommands_removeimagefromcollection(
                                                            movieInputImageID)

    pageCurlFilterChainObject = self.create_pagecurlfilterchain(theCommands,
                                       frontimageidentifier: imageIdentifier,
                                       backsideimagecontext: drawContext,
                                      targetimageidentifier: movieInputImageID,
                                               outputbitmap: outputBitmap)

     videoFramesWriter = theCommands.make_createvideoframeswriter(
                          self.path_to_exportedmovie_withindex(movie_index))
    addVideoInputCommand = CommandModule.make_addinputto_videowritercommand(
                                    videoFramesWriter,
                            preset: :h264preset_hd,
                         framesize: self.frame_size,
                     frameduration: self.frame_duration)
    theCommands.add_command(addVideoInputCommand)

    frameTime = MIMovie::MovieTime.make_movietime_nextsample
    180.times do |i|
      assignCommand = CommandModule.make_assignimage_frommovie_tocollection(
                                                   movieImporter,
                                        frametime: frameTime,
                                       identifier: movieInputImageID)
      theCommands.add_command(assignCommand)
      self.render_pagecurlfilterchain(theCommands, pageCurlFilterChainObject,
        i.to_f / (180.0 - 1))
      addImageToWriterInput = CommandModule.make_addimageto_videoinputwriter(
                                                           videoFramesWriter,
                                             sourceobject: outputBitmap)
      theCommands.add_command(addImageToWriterInput)
    end

    118.times do |i|
      drawFrameCommand = self.create_draw_nextframe_tobitmap_command(
        outputBitmap, movieImporter)
      theCommands.add_command(drawFrameCommand)
      addImageToWriterInput = CommandModule.make_addimageto_videoinputwriter(
                                                           videoFramesWriter,
                                             sourceobject: outputBitmap)
      theCommands.add_command(addImageToWriterInput)
    end

    saveMovie = CommandModule.make_finishwritingframescommand(videoFramesWriter)
    theCommands.add_command(saveMovie)

#    puts JSON.pretty_generate(theCommands.commandshash)

    Smig.perform_commands(theCommands)
    sleep 2
    # Smig.close_object(drawContext)
    # Smig.close_object(outputBitmap)
  end
end

ZukiniDemoVideo.run()
