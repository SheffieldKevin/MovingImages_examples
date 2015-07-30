require 'securerandom'
require 'moving_images'

# When creating the fourth movie. Run synchronously. use a window context so
# we can see progress.

include MovingImages
include MICGDrawing
include CommandModule
include MIMovie

class ZukiniDemoVideo
#  @@directory = File.expand_path(File.dirname(__FILE__))
  @@directory = '/Users/ktam/Dropbox/zukini ltd/WebsiteContent/demovideo'
  @@zukini_logo = File.join(@@directory, 'Zukini Logo-02.png')
  @@moving_logo = File.join(@@directory, 'Zukini Logo-04.png')
  @@moving_logo2 = File.join(@@directory, 'Zukini Logo-05.png')

  @@zukini_logo_identifier = SecureRandom.uuid
  @@moving_logo_identifier = SecureRandom.uuid
  @@moving_logo2_identifier = SecureRandom.uuid

#  @@zukini_logo_objectid = SmigIDHash.make_objectid(
#                    objecttype: :imageimporter, objectname: SecureRandom.uuid)
#  @@moving_logo_objectid = SmigIDHash.make_objectid(
#                    objecttype: :imageimporter, objectname: SecureRandom.uuid)

  # @@output_directory = Dir.tmpdir
  @@output_directory = File.expand_path("~/Desktop/tempmovies/")

  @@movies = [
    'Strawberries-0529.mov',
    'ChivesBed-0530.mov',
    'Epimedium+Fern-0545.mov',
    'BeehiveCompost-0536.mov'
  ]

  @@video_texts = [
"Made with MovingImages for Zukini   -   zukini.eu",
"You can add animations,
apply filters, and
draw text to Videos",
"",
"MovingImages
by
Zukini"
  ]

  @@video_processing_methods = []
  @@video_preroll_methods = []

  # Automatically removes logos from collection in cleanup commands.
  def self.add_logos_to_imagecollection(theCommands)
    zukiniObject = theCommands.make_createimporter(@@zukini_logo,
                                    addtocleanup: false)
    assignImage = CommandModule.make_assignimage_fromimporter_tocollection(
                                                zukiniObject,
                                    imageindex: 0,
                                    identifier: @@zukini_logo_identifier)
    theCommands.add_command(assignImage)
    close = CommandModule.make_close(zukiniObject)
    theCommands.add_command(close)
    movingObject = theCommands.make_createimporter(@@moving_logo,
                                    addtocleanup: false)
    assign2Image = CommandModule.make_assignimage_fromimporter_tocollection(
                                                movingObject,
                                    imageindex: 0,
                                    identifier: @@moving_logo_identifier)
    theCommands.add_command(assign2Image)
    close2 = CommandModule.make_close(movingObject)
    theCommands.add_command(close2)

    movingObject2 = theCommands.make_createimporter(@@moving_logo2,
                                    addtocleanup: false)
    assign3Image = CommandModule.make_assignimage_fromimporter_tocollection(
                                                movingObject2,
                                    imageindex: 0,
                                    identifier: @@moving_logo2_identifier)
    theCommands.add_command(assign3Image)
    close3 = CommandModule.make_close(movingObject2)
    theCommands.add_command(close3)

    theCommands.add_tocleanupcommands_removeimagefromcollection(
                                                    @@zukini_logo_identifier)
    theCommands.add_tocleanupcommands_removeimagefromcollection(
                                                    @@moving_logo_identifier)
    theCommands.add_tocleanupcommands_removeimagefromcollection(
                                                    @@moving_logo2_identifier)
  end

  def self.path_to_inputmovie_withindex(i)
    return nil if i < 0 || i >= @@movies.count
    return File.join(@@directory, @@movies[i])
  end

  def self.path_to_exportedmovie_withindex(i)
    return nil if i < 0 || i >= @@movies.count
    fileName = "Output#{@@movies[i]}"
    return File.join(@@output_directory, fileName)
  end

  def self.zukini_logo_path
    return @@zukini_logo
  end
  
  def self.moving_logo_path
    return @@moving_logo
  end
  
  def self.zukini_logo_objectid
    return @@zukini_logo_objectid
  end

  def self.movingimages_logo_objectid
    return SmigIDHash.make_objectid(objecttype: :imageimporter,
                                    objectname: @@moving_logo_identifier)
  end

  def self.videowidth
    return 1280
  end
  
  def self.videoheight
    return 720
  end

  def self.frame_duration
    return MIMovie::MovieTime.make_movietime(timevalue: 3002, timescale: 90000)
  end

  def self.frame_size
    return MIShapes.make_size(self.videowidth, self.videoheight)
  end
  
  def self.frame_rectangle
    return MIShapes.make_rectangle(size: frame_size)
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

  def self.preroll_movieindex0(commands, bitmap: nil)
    width = self.videowidth - 280
    bitmapSize = MIShapes.make_size(width, 100)
    bitmap2 = commands.make_createbitmapcontext(size: bitmapSize,
                            preset: :PlatformDefaultBitmapContext,
                      addtocleanup: true)
    rect = MIShapes.make_rectangle(width: width,
                                  height: 100, yloc: 0)
    drawTransparentFill = MIDrawElement.new(:fillrectangle)
    drawTransparentFill.rectangle = rect
    drawTransparentFill.fillcolor = MIColor.make_rgbacolor(0,0,0, a: 0)
    drawTransparentFill.blendmode = :kCGBlendModeCopy
    drawLinearFill = MILinearGradientFillElement.new
#    drawLinearFill.blendmode = :kCGBlendModeCopy
    colors = [
                MIColor.make_rgbacolor(0.14, 0.025, 0.16, a: 0.65),
                MIColor.make_rgbacolor(0.27, 0.05, 0.31, a: 0.65)
              ]
    locations = [0.0, 1.0]
    drawLinearFill.set_arrayoflocations_andarrayofcolors(locations, colors)
    startPoint = MIShapes.make_point(width * 0.5, 0)
    endPoint = MIShapes.make_point(width * 0.5, 100)
    drawLinearFill.line = MIShapes.make_line(startPoint, endPoint)
    thePath = MIPath.new
    thePath.add_roundedrectangle_withradiuses(rect,
                                    radiuses: [16.0, 16.0, 1.0, 1.0])
    drawLinearFill.arrayofpathelements = thePath
    drawLinearFill.startpoint = MIShapes.make_point(0, 0)

    drawText = MIDrawBasicStringElement.new
    drawText.stringtext = @@video_texts[0]
    drawText.fontsize = 48
    drawText.postscriptfontname = 'BrandonGrotesque-Bold'
#    drawText.postscriptfontname = 'Tahoma-Bold'
    drawText.fillcolor = MIColor.make_rgbacolor(0.85, 0.85, 0.75)
#    drawText.blendmode = :kCGBlendModeCopy
    drawText.textalignment = :kCTTextAlignmentRight
    boundingBox = MIShapes.make_rectangle(width: width - 20,
                                         height: 80,
                                           xloc: 0,
                                           yloc: 10)
    drawText.boundingbox = boundingBox
    
    textInnerShadow = MIShadow.new
    textInnerShadow.color = MIColor.make_rgbacolor(0.2,0.1,0)
    textInnerShadow.blur = 2
    textInnerShadow.offset = MIShapes.make_size(1, -1)
    drawText.innershadow = textInnerShadow
    drawElements = MIDrawElement.new(:arrayofelements)
#    drawElements.blendmode = :kCGBlendModeCopy
    drawElements.add_drawelement_toarrayofelements(drawTransparentFill)
    drawElements.add_drawelement_toarrayofelements(drawLinearFill)
    drawElements.add_drawelement_toarrayofelements(drawText)
    drawCommand = CommandModule.make_drawelement(bitmap2,
                              drawinstructions: drawElements,
                                   createimage: true)
    commands.add_command(drawCommand)
    bitmap2
  end

  def self.preroll_movieindex1(commands, bitmap: nil)
    nil
  end

  def self.preroll_movieindex2(commands, bitmap: nil)
    # Copy bitmap as image to image collection.
    # Use that image as input for input filter chain that we are going to
    # build up here. Return image identifier for image in image collection
    imageIdentifier = SecureRandom.uuid
    assignImageCommand = CommandModule.make_assignimage_tocollection(bitmap,
      identifier: imageIdentifier)
    commands.add_command(assignImageCommand)
    commands.add_tocleanupcommands_removeimagefromcollection(imageIdentifier)
    
    posterize = MIFilter.new(:CIColorPosterize, identifier: :posterize)
    filterImageID = SmigIDHash.make_imageidentifier(imageIdentifier)
    posterize.add_inputimage_property(filterImageID)

    bloom = MIFilter.new(:CIBloom, identifier: :bloom)
    bloom.add_inputimage_property(SmigIDHash.makeid_withfilternameid(
                                                                  :posterize))
    filterChain = MIFilterChain.new(bitmap)
    filterChain.add_filter(posterize)
    filterChain.add_filter(bloom)
    filterChain.use_srgbprofile = true
    filterChainObject = commands.make_createimagefilterchain(filterChain)
    { imageidentifier: imageIdentifier, filterchainobject: filterChainObject }
  end

=begin
  def self.create_maskimagefilterchain(commands, inputImageID,
                                        renderDestination)
    filterchain = MIFilterChain.new(renderDestination)

    heightfieldmask = MIFilter.new(:CIHeightFieldFromMask,
                       identifier: :heightfieldmask)
    heightfield_radiusproperty = MIFilterProperty.make_cinumberproperty(
                                                 key: :inputRadius, value: 5)
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

  def self.preroll_movieindex3(commands, bitmap: nil)
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

    movie_index = 3
    movieImporter = theCommands.make_createmovieimporter(
                            self.path_to_inputmovie_withindex(movie_index))
#    outputBitmap = theCommands.make_createbitmapcontext(size: self.frame_size,
#                    preset: :PlatformDefaultBitmapContext)
    outputBitmap = theCommands.make_createwindowcontext(rect: theRect,
      addtocleanup: false)
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
    {
      drawcontext: drawContext,
      imageidentifier1: imageIdentifier,
      movieimporter: movieImporter,
      pagecurlfilterchain_object: pageCurlFilterChainObject
    }
  end
=end

  def self.preroll_movieindex3(commands, bitmap: nil)

  end

  def self.process_frame_movieindex0(commands, bitmap: nil, frame_index: 0,
                                     extra_info: nil)
    return if frame_index == 0
    return if extra_info.nil?
    drawImageElement = MIDrawImageElement.new
    scrollDistance = self.videowidth - 280.0
    numEasingOutScrollFrames = 200
    x = 0
    if frame_index < numEasingOutScrollFrames
      x0 = -scrollDistance
      norm_index = frame_index.to_f / numEasingOutScrollFrames
      x = x0 + norm_index * (1.0 - norm_index * 0.5) * 2.0 * scrollDistance
    else
      x = 0
    end
    destRect = MIShapes.make_rectangle(width: 1000, height: 100,
                                        xloc: x, yloc: 40)
    drawImageElement.destinationrectangle = destRect
    drawImageElement.set_bitmap_imagesource(source_object: extra_info)

    theShadow = MIShadow.new
    theShadow.color = MIColor.make_rgbacolor(0,0,0, a: 0.8)
    theShadow.blur = 12
    theShadow.offset = MIShapes.make_size(6, -12)
    drawImageElement.shadow = theShadow
    
    drawCommand = CommandModule.make_drawelement(bitmap,
                              drawinstructions: drawImageElement)
    commands.add_command(drawCommand)
  end

  def self.process_frame_movieindex1(commands, bitmap: nil, frame_index: 0,
                                      extra_info: nil)
    drawElements = MIDrawElement.new(:arrayofelements)
    drawLogoElement = MIDrawImageElement.new
    drawLogoElement.set_imagecollection_imagesource(
                                  identifier: @@zukini_logo_identifier)
    logoDestRect = MIShapes.make_rectangle(width: 246.75,
                                          height: 79.5,
                                            xloc: 6,
                                            yloc: self.videoheight - 86)
    drawLogoElement.destinationrectangle = logoDestRect
    drawElements.add_drawelement_toarrayofelements(drawLogoElement)

    drawImageElement = MIDrawImageElement.new
    drawImageElement.set_imagecollection_imagesource(
                                  identifier: @@moving_logo2_identifier)
    destRect = MIShapes.make_rectangle(width: 222, height: 247)
    drawImageElement.destinationrectangle = destRect

    contextTransforms = MITransformations.make_contexttransformation
    translate2 = MIShapes.make_point(self.videowidth - (61.75 + 6),
                                     self.videoheight - (61.75 + 6))
    MITransformations.add_translatetransform(contextTransforms, translate2)
    rotation = -frame_index.to_f * Math::PI * 0.03
    MITransformations.add_rotatetransform(contextTransforms, rotation)
    scaleXY = MIShapes.make_point(0.5, 0.5)
    MITransformations.add_scaletransform(contextTransforms, scaleXY)
    translate = MIShapes.make_point(-111, -123.5)
    MITransformations.add_translatetransform(contextTransforms, translate)
    drawImageElement.contexttransformations = contextTransforms
    drawElements.add_drawelement_toarrayofelements(drawImageElement)
    
    if frame_index >= 59 && frame_index < 239
      maxFrames = 180
      framesPerString = 180 / 3
      indexOffset = frame_index - 59
      stringIndex = indexOffset / framesPerString
      alpha = 1.0 - 0.6 * (indexOffset % framesPerString).to_f/framesPerString
      textToDraw = @@video_texts[1].split("\n")[stringIndex]
      drawString = MIDrawBasicStringElement.new
      drawString.stringtext = textToDraw
      drawString.fillcolor = MIColor.make_rgbacolor(1,1,1, a: alpha)
      drawString.boundingbox = MIShapes.make_rectangle(width: 1200, height: 120,
                                            xloc: 40, yloc: 300)
       drawString.postscriptfontname = 'BrandonGrotesque-Bold'
       drawString.fontsize = 72
       drawString.textalignment = :kCTTextAlignmentCenter
       drawElements.add_drawelement_toarrayofelements(drawString)
    end
    drawCommand = CommandModule.make_drawelement(bitmap,
                              drawinstructions: drawElements)
    commands.add_command(drawCommand)
  end

  def self.process_frame_movieindex2(commands, bitmap: nil, frame_index: 0,
                                      extra_info: nil)
    filterChainObject = extra_info[:filterchainobject]
    imageIdentifier = extra_info[:imageidentifier]
    
    # First copy the bitmap image to the image collection with image id.
    assignImageCommand = CommandModule.make_assignimage_tocollection(
      bitmap, identifier: imageIdentifier)
    commands.add_command(assignImageCommand)

    posterizeValue = 19.0 - frame_index.to_f / 298 * 17
    posterizeValue = [4.0, posterizeValue].max
    # Now render the filter chain to the bitmap.
    renderFilterChain = MIFilterChainRender.new
    renderFilterChain.sourcerectangle = MIShapes.make_rectangle(
                                                  width: self.videowidth,
                                                 height: self.videoheight)
    posterizeProp = MIFilterRenderProperty.make_renderproperty_withfilternameid(
      key: :inputLevels, value: posterizeValue.to_i,
      filtername_id: :posterize)
    renderFilterChain.add_filterproperty(posterizeProp)
    bloomValue = 0.33 + frame_index.to_f / 300.0
    bloomValue = [1.0, bloomValue].min
    bloomProp = MIFilterRenderProperty.make_renderproperty_withfilternameid(
      key: :inputIntensity, value: bloomValue, filtername_id: :bloom)
    renderFilterChain.add_filterproperty(bloomProp)
    renderCommand = CommandModule.make_renderfilterchain(filterChainObject,
      renderinstructions: renderFilterChain)
    commands.add_command(renderCommand)
  end

  def self.process_frame_movieindex3(commands, bitmap: nil, frame_index: 0,
                                      extra_info: nil)
    
  end

  def self.pre_roll()
    @@video_processing_methods.push(method(:process_frame_movieindex0))
    @@video_processing_methods.push(method(:process_frame_movieindex1))
    @@video_processing_methods.push(method(:process_frame_movieindex2))
    @@video_processing_methods.push(method(:process_frame_movieindex3))
    
    @@video_preroll_methods.push(method(:preroll_movieindex0))
    @@video_preroll_methods.push(method(:preroll_movieindex1))
    @@video_preroll_methods.push(method(:preroll_movieindex2))
    @@video_preroll_methods.push(method(:preroll_movieindex3))
  end

  def self.create_intermediatemovies(theCommands, movie_index: nil)
    movieImporter = theCommands.make_createmovieimporter(
                                self.path_to_inputmovie_withindex(movie_index),
                                addtocleanup: false)

    bitmap = theCommands.make_createbitmapcontext(size: self.frame_size,
                  preset: :PlatformDefaultBitmapContext,
            addtocleanup: false)
#    bitmap = theCommands.make_createwindowcontext(rect: self.frame_rectangle)
     videoFramesWriter = theCommands.make_createvideoframeswriter(
                          self.path_to_exportedmovie_withindex(movie_index),
            addtocleanup: false)
    # MIMeta.listvideoframewriterpresets
    addVideoInputCommand = CommandModule.make_addinputto_videowritercommand(
                                    videoFramesWriter,
                            preset: :h264preset_hd,
                         framesize: self.frame_size,
                     frameduration: self.frame_duration)
    theCommands.add_command(addVideoInputCommand)

    extras = nil
    extras = @@video_preroll_methods[movie_index].call(theCommands,
                                          bitmap: bitmap)

    298.times do |i|
      drawFrameCommand = self.create_draw_nextframe_tobitmap_command(bitmap,
                                                              movieImporter)
      theCommands.add_command(drawFrameCommand)
      @@video_processing_methods[movie_index].call(theCommands,
                                           bitmap: bitmap,
                                      frame_index: i,
                                       extra_info: extras)

      addImageToWriterInput = CommandModule.make_addimageto_videoinputwriter(
                                                           videoFramesWriter,
                                             sourceobject: bitmap)
      theCommands.add_command(addImageToWriterInput)
    end
    saveMovie = CommandModule.make_finishwritingframescommand(videoFramesWriter)
    theCommands.add_command(saveMovie)
    close1 = CommandModule.make_close(movieImporter)
    theCommands.add_command(close1)
    close2 = CommandModule.make_close(bitmap)
    theCommands.add_command(close2)
    close4 = CommandModule.make_close(videoFramesWriter)
    theCommands.add_command(close4)
  end

  def self.make_videocomposition(commands)
    # import our four videos.
    numMovies = 4
    movieImporters = []
    numMovies.times do |i|
      filePath = path_to_exportedmovie_withindex(i)
      importer = commands.make_createmovieimporter(filePath)
      movieImporters.push(importer)
    end
    
    # Create the movie editor where the video composition will happen.
    movieEditorObject = commands.make_createmovieeditor()

    addVideoTrackCommand = CommandModule.make_createtrackcommand(
                                                movieEditorObject,
                                     mediatype: :vide)

    # Create two video tracks using the addVideoTrackCommand.
    commands.add_command(addVideoTrackCommand)
    commands.add_command(addVideoTrackCommand)

    track0 = MovieTrackIdentifier.make_movietrackid_from_mediatype(
                                        mediatype: :vide,
                                       trackindex: 0)

    track1 = MovieTrackIdentifier.make_movietrackid_from_mediatype(
                                        mediatype: :vide,
                                       trackindex: 1)

    tracks = [ track0, track1 ]

    numFrames = 298
    timeZero = MovieTime.make_movietime(timevalue: 0, timescale: 1)
    segmentDuration = MovieTime.make_movietime(timevalue: numFrames * 3002,
                                               timescale: 90000)

    segmentTimeRange = MovieTime.make_movie_timerange(start: timeZero,
                                                   duration: segmentDuration)
                                                   
    # Now add the movie segments.
#    numMovies.times do |movieIndex|
    4.times do |movieIndex|
      insertTrackSegmentCommand = CommandModule.make_inserttracksegment(
                            movieEditorObject, 
                     track: tracks[movieIndex % 2],
             source_object: movieImporters[3 - movieIndex],
              source_track: track0,
             insertiontime: self.segmentstart_movietime_forindex(movieIndex), 
          source_timerange: segmentTimeRange)
      commands.add_command(insertTrackSegmentCommand)
    end
    
    passThru1Dur = MovieTime.make_movietime(timevalue: 240 * 3002,
                                            timescale: 90000)
    passThru1 = VideoLayerInstructions.new
    passThru1.add_passthrulayerinstruction(track: track0)
    passThru1TimeRange = MovieTime.make_movie_timerange(start: timeZero,
                                                     duration: passThru1Dur)
    passThru1Command = CommandModule.make_addvideoinstruction(movieEditorObject,
                                                 timerange: passThru1TimeRange,
                                         layerinstructions: passThru1)
    commands.add_command(passThru1Command)

    # Now add a transform ramp layer instruction.
    trasition1Start = self.segmentstart_movietime_forindex(1)
    transitionDuration = MovieTime.make_movietime(timevalue: 58 * 3002,
                                                  timescale: 90000)

    transformRampTimeRange = MovieTime.make_movie_timerange(
                                              start: trasition1Start,
                                           duration: transitionDuration)

    identityTransform = MITransformations.make_affinetransform()
    endTransform = MITransformations.make_contexttransformation()
    translateLXPoint = MIShapes.make_point(-1279, 0)
    MITransformations.add_translatetransform(endTransform, translateLXPoint)
    
    startTransform = MITransformations.make_contexttransformation()
    translateRXpoint = MIShapes.make_point(1280, 0)
    MITransformations.add_translatetransform(startTransform, translateRXpoint)
    
    transformRamp = VideoLayerInstructions.new
    transformRamp.add_transformramplayerinstruction(
                                                track: track1,
                                  starttransformvalue: startTransform,
                                    endtransformvalue: identityTransform,
                                            timerange: transformRampTimeRange)

    transformRamp.add_transformramplayerinstruction(
                                                track: track0,
                                  starttransformvalue: identityTransform,
                                    endtransformvalue: endTransform,
                                            timerange: transformRampTimeRange)

    transformRampCommand = CommandModule.make_addvideoinstruction(
                                                     movieEditorObject,
                                          timerange: transformRampTimeRange,
                                  layerinstructions: transformRamp)
    commands.add_command(transformRampCommand)

    # Now add the second passthru
    passThru2Dur = MovieTime.make_movietime(timevalue: 182 * 3002,
                                            timescale: 90000)
    passThru2 = VideoLayerInstructions.new
    passThru2.add_passthrulayerinstruction(track: track1)
    startPassThruTime2 = self.segment_end_movietime_forindex(0)
    passThru2TimeRange = MovieTime.make_movie_timerange(
                                                start: startPassThruTime2,
                                             duration: passThru2Dur)
    passThru2Command = CommandModule.make_addvideoinstruction(movieEditorObject,
                                            timerange: passThru2TimeRange,
                                    layerinstructions: passThru2)
    commands.add_command(passThru2Command)

    # Now create a dissolve ramp layer instruction.
    dissolveRamp = VideoLayerInstructions.new
    dissolveTimeRange = MovieTime.make_movie_timerange(
                                start: self.segmentstart_movietime_forindex(2),
                             duration: transitionDuration)
    dissolveRamp.add_opacityramplayerinstruction(track: track1, 
                                     startopacityvalue: 1.0,
                                       endopacityvalue: 0.0,
                                             timerange: dissolveTimeRange)
    dissolveRamp.add_passthrulayerinstruction(track: track0)
    dissolveRampCommand = CommandModule.make_addvideoinstruction(
                                                      movieEditorObject,
                                           timerange: dissolveTimeRange,
                                   layerinstructions: dissolveRamp)
    commands.add_command(dissolveRampCommand)

    # Now add the third passthru
    passThru3Dur = MovieTime.make_movietime(timevalue: 182 * 3002,
                                            timescale: 90000)
    passThru3 = VideoLayerInstructions.new
    passThru3.add_passthrulayerinstruction(track: track0)
    startPassThruTime3 = self.segment_end_movietime_forindex(1)
    passThru3TimeRange = MovieTime.make_movie_timerange(
                                                start: startPassThruTime3,
                                             duration: passThru3Dur)
    passThru3Command = CommandModule.make_addvideoinstruction(movieEditorObject,
                                            timerange: passThru3TimeRange,
                                    layerinstructions: passThru3)
    commands.add_command(passThru3Command)

    # Now create a dissolve ramp layer instruction.
    cropRamp = VideoLayerInstructions.new
    cropTimeRange = MovieTime.make_movie_timerange(
                                start: self.segmentstart_movietime_forindex(3),
                             duration: transitionDuration)
    
    startCropRect = MIShapes.make_rectangle(width: self.videowidth,
                                           height: self.videoheight)
    endCropRect = MIShapes.make_rectangle(width: 0.0,
                                           height: self.videoheight)
    cropRamp.add_croprectramplayerinstruction(track: track0,
                                 startcroprectvalue: startCropRect,
                                   endcroprectvalue: endCropRect,
                                          timerange: cropTimeRange)
    cropRamp.add_passthrulayerinstruction(track: track1)
    cropRampCommand = CommandModule.make_addvideoinstruction(
                                                      movieEditorObject,
                                           timerange: cropTimeRange,
                                   layerinstructions: cropRamp)
    commands.add_command(cropRampCommand)

    # Now add the third passthru
    passThru4Dur = MovieTime.make_movietime(timevalue: 240 * 3002,
                                            timescale: 90000)
    passThru4 = VideoLayerInstructions.new
    passThru4.add_passthrulayerinstruction(track: track1)
    startPassThruTime4 = self.segment_end_movietime_forindex(2)
    passThru4TimeRange = MovieTime.make_movie_timerange(
                                                start: startPassThruTime4,
                                             duration: passThru4Dur)
    passThru4Command = CommandModule.make_addvideoinstruction(movieEditorObject,
                                            timerange: passThru4TimeRange,
                                    layerinstructions: passThru4)
    commands.add_command(passThru4Command)

    windowRect = MIShapes.make_rectangle(width: 1000, height: 600)
#    window = commands.make_createwindowcontext(rect: windowRect,
#                                          addtocleanup: false)
#    self.drawimage_from(movieEditorObject, towindow: window,
#                                            commands: commands)

    # Now lets export the movie. This command may take some time so it is added
    # to process commands.
    exportMovieCommand = CommandModule.make_movieeditor_export(
                                              movieEditorObject,
                                exportpreset: :AVAssetExportPreset1280x720,
                              exportfilepath: "~/Desktop/FirstTwo.mov",
                              exportfiletype: :'com.apple.quicktime-movie')
    commands.add_command(exportMovieCommand)

    commands
  end

  def self.segmentstart_movietime_forindex(index)
    return MovieTime.make_movietime(timevalue: 240 * 3002 * index,
                                    timescale: 90000)
  end

  def self.segment_end_movietime_forindex(index)
    return MovieTime.make_movietime(timevalue: 240 * 3002 * index + 298 * 3002,
                                    timescale: 90000)
  end

  def self.drawimage_from(object_id, towindow: nil, commands: nil)
    imageIdentifier = SecureRandom.uuid
    addCompositionImage = CommandModule.make_assignimage_tocollection(
                                                object_id,
                                    identifier: imageIdentifier)
    commands.add_command(addCompositionImage)

    drawFrameElement = MIDrawImageElement.new
    drawFrameElement.interpolationquality = :kCGInterpolationHigh
    destRect = MIShapes.make_rectangle(width: 1000, height: 600)
    drawFrameElement.destinationrectangle = destRect
    drawFrameElement.set_imagecollection_imagesource(
                                         identifier: imageIdentifier)
    drawImage = CommandModule.make_drawelement(towindow,
                    drawinstructions: drawFrameElement)
    commands.add_command(drawImage)
  end

  def self.run()
    pre_roll()
    theCommands = SmigCommands.new
#    add_logos_to_imagecollection(theCommands)
#    movie_index = 0
#    create_intermediatemovies(theCommands, movie_index: movie_index)
#    Smig.perform_commands(theCommands)
#    `open #{self.path_to_exportedmovie_withindex(movie_index)}`
#    numMovies = 4
#    (numMovies - 1).times do |j|
#      ZukiniDemoVideo.create_intermediatemovies(theCommands, movie_index: j)
#    end
    
    ZukiniDemoVideo.make_videocomposition(theCommands)
    # puts JSON.pretty_generate(theCommands.commandshash)
    Smig.perform_commands(theCommands)
    
    # Smig.perform_commands(theCommands)
    # puts JSON.pretty_generate(theCommands.commandshash)
  end
end

ZukiniDemoVideo.run()

