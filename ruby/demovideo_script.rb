require 'securerandom'
require 'moving_images'

# When creating the fourth movie. Run synchronously. use a window context so
# we can see progress.

include MovingImages
include MICGDrawing
include CommandModule

class ZukiniDemoVideo
  @@filename = File.basename(__FILE__)
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
    File.join('Strawberries-0529.mov'),
    File.join('ChivesBed-0530.mov'),
    File.join('Epimedium+Fern-0545.mov'),
    File.join('BeehiveCompost-0536.mov')
  ]

  @@video_texts = [
"Made with MovingImages for Zukini   -   zukini.eu",
"You can add animations,
apply filters, and
draw text to Videos",
"",
""
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
    textInnerShadow.offset = MIShapes.make_size(0.5, -1)
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

    posterizeValue = 24.0 - frame_index.to_f / 298 * 20
    # Now render the filter chain to the bitmap.
    renderFilterChain = MIFilterChainRender.new
    renderFilterChain.sourcerectangle = MIShapes.make_rectangle(
                                                  width: self.videowidth,
                                                 height: self.videoheight)
    posterizeProp = MIFilterRenderProperty.make_renderproperty_withfilternameid(
      key: :inputLevels, value: posterizeValue.to_i,
      filtername_id: :posterize)
    renderFilterChain.add_filterproperty(posterizeProp)
    bloomValue = 0.25 + frame_index.to_f / 399.0
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
  
  def self.run()
    pre_roll()
    theCommands = SmigCommands.new
    add_logos_to_imagecollection(theCommands)
    movie_index = 2
    create_intermediatemovies(theCommands, movie_index: movie_index)
    Smig.perform_commands(theCommands)
    `open #{self.path_to_exportedmovie_withindex(movie_index)}`
=begin
    4.times do |j|
      ZukiniDemoVideo.create_intermediatemovies(theCommands, movie_index: 0)
    end
=end
    # puts JSON.pretty_generate(theCommands.commandshash)
  end
end

ZukiniDemoVideo.run()

