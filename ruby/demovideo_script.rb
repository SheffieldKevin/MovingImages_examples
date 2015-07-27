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

  @@zukini_logo_objectid = SmigIDHash.make_objectid(
                    objecttype: :imageimporter, objectname: SecureRandom.uuid)
  @@moving_logo_identifier = SmigIDHash.make_objectid(
                    objecttype: :imageimporter, objectname: SecureRandom.uuid)

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
    "",
    "",
    ""
  ]

  @@video_processing_methods = []
  @@video_preroll_methods = []

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

  def self.preroll_movieindex0(commands)
    width = self.videowidth - 280
    bitmapSize = MIShapes.make_size(width, 100)
    bitmap = commands.make_createbitmapcontext(size: bitmapSize,
                            preset: :PlatformDefaultBitmapContext)
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
    drawCommand = CommandModule.make_drawelement(bitmap,
                              drawinstructions: drawElements,
                                   createimage: true)
    commands.add_command(drawCommand)
    bitmap
  end

  def self.preroll_movieindex1(commands)
  
  end

  def self.preroll_movieindex2(commands)
  
  end

  def self.preroll_movieindex3(commands)
  
  end

  def self.process_frame_movieindex0(commands, bitmap: nil, frame_index: 0,
                                     bitmap2: nil)
    return if frame_index == 0
    return if bitmap2.nil?
    drawImageElement = MIDrawImageElement.new
    scrollDistance = self.videowidth - 280.0
#    numFullScrollFrames = 100
    numFullScrollFrames = 0
#    numEasingOutScrollFrames = numFullScrollFrames
    numEasingOutScrollFrames = 200
    x = 0
    if frame_index < numFullScrollFrames
      x = scrollDistance * (frame_index / (numFullScrollFrames * 1.5) - 1.0)
    elsif frame_index < (numFullScrollFrames + numEasingOutScrollFrames)
#      x0 = -0.3333333333333 * scrollDistance
      x0 = -scrollDistance
      index = frame_index - numFullScrollFrames
      norm_index = index.to_f / numEasingOutScrollFrames
#     x = x0 + norm_index * (1.0 - norm_index * 0.5) * 0.666666 * scrollDistance
     x = x0 + norm_index * (1.0 - norm_index * 0.5) * 2.0 * scrollDistance
    else
      x = 0
    end
    # x = (self.videowidth - 280.0) * (frame_index.to_f / 150.0 - 1.0)
    # x = [x, 0.0].min
    destRect = MIShapes.make_rectangle(width: 1000, height: 100,
                                        xloc: x, yloc: 40)
    drawImageElement.destinationrectangle = destRect
    drawImageElement.set_bitmap_imagesource(source_object: bitmap2)

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
                                      bitmap2: nil)
    
  end

  def self.process_frame_movieindex2(commands, bitmap: nil, frame_index: 0,
                                      bitmap2: nil)
    
  end

  def self.process_frame_movieindex3(commands, bitmap: nil, frame_index: 0,
                                      bitmap2: nil)
    
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

  def self.process_frame(commands, bitmap: nil, movie_index: 0, frame_index: 0,
                         bitmap2: nil)
    @@video_processing_methods[movie_index].call(commands,
                                         bitmap: bitmap,
                                    frame_index: frame_index,
                                        bitmap2: bitmap2)
  end

  def self.create_intermediatemovies(movie_index: 0, async: true)
    theCommands = SmigCommands.new
    theCommands.run_asynchronously = async
    movieImporter = theCommands.make_createmovieimporter(
                                self.path_to_inputmovie_withindex(movie_index))

    bitmap = theCommands.make_createbitmapcontext(size: self.frame_size,
             preset: :PlatformDefaultBitmapContext)
#    bitmap = theCommands.make_createwindowcontext(rect: self.frame_rectangle)
     videoFramesWriter = theCommands.make_createvideoframeswriter(
                          self.path_to_exportedmovie_withindex(movie_index))
    # MIMeta.listvideoframewriterpresets
    addVideoInputCommand = CommandModule.make_addinputto_videowritercommand(
                                    videoFramesWriter,
                            preset: :h264preset_hd,
                         framesize: self.frame_size,
                     frameduration: self.frame_duration)
    theCommands.add_command(addVideoInputCommand)
    bitmap2 = nil
    
    bitmap2 = @@video_preroll_methods[movie_index].call(theCommands)
#    if movie_index == 0
#      bitmap2 = self.preroll_movieindex0(theCommands)
#    end

    298.times do |i|
      drawFrameCommand = self.create_draw_nextframe_tobitmap_command(bitmap,
                                                              movieImporter)
      theCommands.add_command(drawFrameCommand)
      self.process_frame(theCommands, bitmap: bitmap,
                                 movie_index: movie_index,
                                 frame_index: i,
                                     bitmap2: bitmap2)
      addImageToWriterInput = CommandModule.make_addimageto_videoinputwriter(
                                                           videoFramesWriter,
                                             sourceobject: bitmap)
      theCommands.add_command(addImageToWriterInput)
    end
    saveMovie = CommandModule.make_finishwritingframescommand(videoFramesWriter)
    theCommands.add_command(saveMovie)
    # puts JSON.pretty_generate(theCommands.commandshash)
    Smig.perform_commands(theCommands)
    `open #{self.path_to_exportedmovie_withindex(movie_index)}`
  end
end

ZukiniDemoVideo.pre_roll()

1.times do |j|
#  ZukiniDemoVideo.create_intermediatemovies(movie_index: j, async: true)
  ZukiniDemoVideo.create_intermediatemovies(movie_index: j, async: false)
end
