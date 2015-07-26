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
    "MovingImages by Zukini    -    Visit us at zukini.eu",
    "",
    "",
    ""
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
    return MIMovie::MovieTime.make_movietime(timevalue: 1, timescale: 30)
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

  def self.process_frame_movieindex0(commands, bitmap: nil, frame_index: 0)
    
  end

  def self.process_frame(commands, bitmap: nil, movie_index: 0, frame_index: 0)
    return if frame_index == 0
    width = self.videowidth.to_f * frame_index / 120.0
    width = [width, self.videowidth - 20].min
    drawLinearFill = MILinearGradientFillElement.new
    colors = [
                MIColor.make_rgbacolor(0.14, 0.025, 0.16, a: 0.65),
                MIColor.make_rgbacolor(0.27, 0.05, 0.31, a: 0.65)
              ]
    locations = [0.0, 1.0]
    drawLinearFill.set_arrayoflocations_andarrayofcolors(locations, colors)
    startPoint = MIShapes.make_point(width * 0.5, 40)
    endPoint = MIShapes.make_point(width * 0.5, 140)
    drawLinearFill.line = MIShapes.make_line(startPoint, endPoint)
    thePath = MIPath.new
    rect = MIShapes.make_rectangle(width: width,
                                  height: 100, yloc: 50)
    thePath.add_rectangle(rect)
    drawLinearFill.arrayofpathelements = thePath
    drawLinearFill.startpoint = MIShapes.make_point(0, 0)
    theShadow = MIShadow.new
    theShadow.color = MIColor.make_rgbacolor(0,0,0, a: 0.8)
    theShadow.blur = 12
    theShadow.offset = MIShapes.make_size(6, -12)
    drawLinearFill.shadow = theShadow
    
    drawText = MIDrawBasicStringElement.new
    drawText.stringtext = @@video_texts[movie_index]
    drawText.fontsize = 48
    drawText.postscriptfontname = 'BrandonGrotesque-Bold'
    drawText.fillcolor = MIColor.make_rgbacolor(0.85,0.85,0.75)
    drawText.textalignment = :kCTTextAlignmentRight
    boundingBox = MIShapes.make_rectangle(width: self.videowidth - 20,
                                         height: 70,
                                           xloc: width - self.videowidth,
                                           yloc: 60)
    drawText.boundingbox = boundingBox
    
    textInnerShadow = MIShadow.new
    textInnerShadow.color = MIColor.make_rgbacolor(0.2,0.1,0)
    textInnerShadow.blur = 2
    textInnerShadow.offset = MIShapes.make_size(0.5, -1)
    drawText.innershadow = textInnerShadow
    drawElements = MIDrawElement.new(:arrayofelements)
    drawElements.add_drawelement_toarrayofelements(drawLinearFill)
    drawElements.add_drawelement_toarrayofelements(drawText)
    drawCommand = CommandModule.make_drawelement(bitmap,
                              drawinstructions: drawElements)
    commands.add_command(drawCommand)
  end

  def self.create_intermediatemovies(movie_index: 0, async: true)
    theCommands = SmigCommands.new
    theCommands.run_asynchronously = async
    movieImporter = theCommands.make_createmovieimporter(
                                self.path_to_inputmovie_withindex(movie_index))

    bitmap = theCommands.make_createbitmapcontext(size: self.frame_size,
             preset: :PlatformDefaultBitmapContext)
#    bitmap = theCommands.make_createwindowcontext(rect: self.frame_rectangle) #unless async
    videoFramesWriter = theCommands.make_createvideoframeswriter(
                          self.path_to_exportedmovie_withindex(movie_index))
    # MIMeta.listvideoframewriterpresets
    addVideoInputCommand = CommandModule.make_addinputto_videowritercommand(
                                    videoFramesWriter,
                            preset: :h264preset_hd,
                         framesize: self.frame_size,
                     frameduration: self.frame_duration)
    theCommands.add_command(addVideoInputCommand)
#    298.times do |i|
    120.times do |i|
      drawFrameCommand = self.create_draw_nextframe_tobitmap_command(bitmap,
                                                              movieImporter)
      theCommands.add_command(drawFrameCommand)
      self.process_frame(theCommands, bitmap: bitmap,
                                 movie_index: movie_index,
                                 frame_index: i)
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

# puts "#{ZukiniDemoVideo.zukini_logo}"
# puts "#{ZukiniDemoVideo.moving_logo}"

1.times do |j|
#  ZukiniDemoVideo.create_intermediatemovies(movie_index: j, async: true)
  ZukiniDemoVideo.create_intermediatemovies(movie_index: j, async: false)
end
