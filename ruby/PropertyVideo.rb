#!/usr/bin/env ruby

# This script takes movie files and combines them with images and branding.

require 'moving_images'

include MovingImages
include MICGDrawing
include CommandModule
include MIMovie

$movieDirectory = File.expand_path(File.join(File.dirname(__FILE__), "../movies"))
$imagesDirectory = File.expand_path(File.join(File.dirname(__FILE__), "../images"))
$svgDirectory = File.expand_path(File.join(File.dirname(__FILE__), "../json/PropertyVideo"))

$movies = [
  "IMG_0864.mov",     # 0, garden.
  "IMG_1189.mov",
  "IMG_1190.mov",
  "IMG_0546.mov"
]

$images = [
  "dsc08719.jpg",     # 0, kitchen.
  "dsc08709.jpg",     # 1, kitchen.
  "dsc08717.jpg",     # 2, lounge.
  "dsc08693.jpg",     # 3, bedreoom.
  "IMG_1191.JPG",     # 4
  "IMG_1192.JPG",     # 5
]

$movieFileExportFolder = File.expand_path("~/Desktop/")

class PropertyToSellVideo
  @@numFrames = 180
  @@videoWidth = 1280
  @@videoHeight = 720

  @@videoFrameSize = MIShapes.make_size(@@videoWidth, @@videoHeight)
  
  @@lowerThirdWidth = @@videoWidth
  @@lowerThirdHeight = 120 # Actually lower sixth.
  
  
  @@iconHeight = @@lowerThirdHeight * 0.6

  @@propertySVG = [
    "bed.json",             # 0 Bed - Colour (# rooms)
    "cars8.json",           # 1 Car in garage
    "close13.json",         # 2 Bed
    "for2.json",            # 3 For sale sign
    "housekey.json",        # 4 House key
    "signboard.json",       # 5 For rent
    "cottage.json",         # 6 Cottage - Colour
    "garage.json",          # 7 Garage - Colour
    "dollar12.json",        # 8 House price (house price)
    "shower_and_tub.json"   # 9 Bathroom - Colour (# rooms)
  ]

  @@videoTrack0Identifier = MovieTrackIdentifier.make_movietrackid_from_mediatype(
                                                mediatype: :vide, trackindex: 0)
  

  def self.printSVGViewBox()
    @@propertySVG.each do |filename|
      filePath = File.join($svgDirectory, filename)
      jsonContents = File.read(filePath)
      jsonHash = JSON.parse(jsonContents)
      viewBox = jsonHash["viewBox"]
      width = viewBox["size"]["width"]
      height = viewBox["size"]["height"]
      x = viewBox["origin"]["x"]
      y = viewBox["origin"]["y"]
      puts "filename: #{filename}"
      puts "  width: #{width}"
      puts "  height: #{height}"
      puts "  x: #{x}"
      puts "  y: #{y}"
    end
  end

  def self.printVideoContentFrameDuration()
    $movies.each do |filename|
      filePath = File.join($movieDirectory, filename)
      commands = SmigCommands.new
      movieImporter = commands.make_createmovieimporter(filePath)
      getFrameDuration = CommandModule.make_get_objectproperty(movieImporter,
                                              property: :minframeduration)
      getFrameDuration.add_option(key: :track, value: @@videoTrack0Identifier)
      commands.add_command(getFrameDuration)
      result = Smig.perform_commands(commands)
      puts result
    end
  end

  def self.printVideoContentProperties()
    $movies.each do |filename|
      filePath = File.join($movieDirectory, filename)
      commands = SmigCommands.new
      movieImporter = commands.make_createmovieimporter(filePath)
      getFrameDuration = CommandModule.make_get_objectproperties(movieImporter,
        saveresultstype: :jsonstring)
      getFrameDuration.add_option(key: :track, value: @@videoTrack0Identifier)
      commands.add_command(getFrameDuration)
      result = Smig.perform_commands(commands)
      puts result
      puts "==================================================================="
    end
  end
  
  def self.getIconSize(jsonHash)
    return jsonHash["viewBox"]["size"]
  end


  def self.scaleFactorForJSONToHeight(size: nil, height: nil)
    svgHeight = size["height"]
    return height.to_f / svgHeight
  end
  
  def self.jsonHashForIcon(index)
      filePath = File.join($svgDirectory, @@propertySVG[index])
      jsonContents = File.read(filePath)
      JSON.parse(jsonContents)
  end

  def self.draw_lineargradientbackground()
    origin = MIShapes.make_point(0, 0)
    fillRect = MIShapes.make_rectangle(origin: origin, width: @@videoWidth, height: @@lowerThirdHeight)
    linearGradient = MILinearGradientFillElement.new
    startPoint = MIShapes.make_point(640, 0)
    endPoint = MIShapes.make_point(640, @@lowerThirdHeight)
    linearGradient.line = MIShapes.make_line(startPoint, endPoint)
    path = MIPath.new
    path.add_rectangle(fillRect)
    linearGradient.arrayofpathelements = path
    linearGradient.startpoint = origin
    linearGradient.contextalpha = 0.45
    startColor = MIColor.make_rgbacolor(0.6, 0.3, 0.05)
    endColor = MIColor.make_rgbacolor(0.9, 0.45, 0.1)
    colors = [startColor, endColor]
    locations = [0, 1]
    linearGradient.set_arrayoflocations_andarrayofcolors(locations, colors)
    linearGradient
  end

  def self.draw_companylogo(logoidentifier: nil, arrayofelements: nil)
    scaleFactor = 0.25
    offset = 8
    width = 987 * scaleFactor
    height = 308 * scaleFactor
    bottom = 720 - (height + offset)
    destRect = MIShapes.make_rectangle(xloc: offset, yloc: bottom, width: width, height: height)
    drawImageElement = MIDrawImageElement.new
    drawImageElement.contextalpha = 0.7
    drawImageElement.set_imagecollection_imagesource(identifier: logoidentifier)
    drawImageElement.destinationrectangle = destRect
    arrayofelements.add_drawelement_toarrayofelements(drawImageElement)
  end

  def self.draw_icon(iconindex: 0, arrayofelements: nil, rightedge: nil)
    jsonHash = self.jsonHashForIcon(iconindex)
    iconSize = self.getIconSize(jsonHash)
    scale = self.scaleFactorForJSONToHeight(size: iconSize, height: @@iconHeight)
    scaledIconWidth = scale * iconSize["width"]
    transformations = MITransformations.make_contexttransformation
    translatePoint = MIShapes.make_point(@@videoWidth - scaledIconWidth - rightedge, 1.5 * @@iconHeight)
    MITransformations.add_translatetransform(transformations, translatePoint)
    MITransformations.add_scaletransform(transformations, MIShapes.make_point(scale, -scale))
    jsonHash[:contexttransformation] = transformations
    arrayofelements.add_drawelement_toarrayofelements(jsonHash)
    rightedge + scaledIconWidth
  end

  def self.draw_bed(arrayofelements: nil, rightedge: nil)
    self.draw_icon(iconindex: 0, arrayofelements: arrayofelements, rightedge: rightedge)
  end

  def self.draw_text_atpoint(text: nil, point: nil, fontsize: nil, font: nil)
    fontName = font unless font.nil?
    fontName = :'Tahoma-Bold' if font.nil?
    
    drawStringElement1 = MIDrawBasicStringElement.new
    drawStringElement1.point_textdrawnfrom = point
    drawStringElement1.fontsize = fontsize
    drawStringElement1.fillcolor = MIColor.make_rgbacolor(0.9,0.9,0.9, a: 1.0)
    drawStringElement1.blendmode = :kCGBlendModeNormal
    drawStringElement1.stringtext = text
    drawStringElement1.postscriptfontname = fontName
    drawStringElement1
  end

  def self.draw_text(text: nil, rightedge: nil, textwidth: nil)
    textPoint = MIShapes.make_point(@@videoWidth - textwidth - rightedge, 0.75 * @@iconHeight)
    self.draw_text_atpoint(text: text, point: textPoint, fontsize: 30)
  end

  def self.draw_numberofrooms(numRooms, arrayofelements: nil, rightedge: nil)
    textWidth = 40
    drawStringElement = self.draw_text(text: numRooms, rightedge: rightedge, textwidth: textWidth)
    arrayofelements.add_drawelement_toarrayofelements(drawStringElement)
    rightedge + textWidth
  end

  def self.draw_housepriceicon(arrayofelements: nil, rightedge: nil)
    self.draw_icon(iconindex: 8, arrayofelements: arrayofelements, rightedge: rightedge)
  end

  def self.draw_houseprice(arrayofelements: nil, rightedge: nil)
    textWidth = 140
    drawStringElement = self.draw_text(text: "£210,000", rightedge: rightedge, textwidth: textWidth)
    arrayofelements.add_drawelement_toarrayofelements(drawStringElement)
    rightedge + textWidth
  end

  def self.draw_promotext1(text: nil, arrayofelements: nil, textwidth: nil, rightedge: nil, alpha: 1)
    textPoint = MIShapes.make_point(@@videoWidth - textwidth - rightedge, @@iconHeight + 4)
    drawPromoText = self.draw_text_atpoint(text: text, point: textPoint, fontsize: 20)
    arrayofelements.add_drawelement_toarrayofelements(drawPromoText)
    rightedge + textwidth
  end

  def self.draw_promotext2(text: nil, arrayofelements: nil, textwidth: nil, rightedge: nil, alpha: 1)
    textPoint = MIShapes.make_point(@@videoWidth - textwidth - rightedge, @@iconHeight * 0.5 + 8)
    drawPromoText = self.draw_text_atpoint(text: text, point: textPoint, fontsize: 20)
    arrayofelements.add_drawelement_toarrayofelements(drawPromoText)
    rightedge + textwidth
  end

  def self.draw_garage(arrayofelements: nil, rightedge: nil)
    self.draw_icon(iconindex: 7, arrayofelements: arrayofelements, rightedge: rightedge)
  end

  def self.draw_bathroomicon(arrayofelements: nil, rightedge: nil)
    self.draw_icon(iconindex: 9, arrayofelements: arrayofelements, rightedge: rightedge)
  end

  def self.draw_cottageicon(arrayofelements: nil, rightedge: nil)
    self.draw_icon(iconindex: 6, arrayofelements: arrayofelements, rightedge: rightedge)
  end

  def self.draw_companyagent_details(arrayofelements: nil)
    textPoint = MIShapes.make_point(8, 8)
    text = "Advertized and promoted by The Real Estage Agency."
    drawText = self.draw_text_atpoint(text: text, point: textPoint, fontsize: 14, font: "Tahoma")
    arrayofelements.add_drawelement_toarrayofelements(drawText)
    contactText = "David Smith mobile: 079 999999, email: davids@therealestateagency.com"
    textPoint2 = MIShapes.make_point(810, 8)
    drawText2 = self.draw_text_atpoint(text: contactText, point: textPoint2, fontsize: 14, font: "Tahoma")
    arrayofelements.add_drawelement_toarrayofelements(drawText2)
  end

  def self.draw_lowerthird(bitmap, logoidentifier: nil, text1: nil, text2: nil)
    drawArrayOfElementsWrapper = MIDrawElement.new(:arrayofelements)
    linearGradient = self.draw_lineargradientbackground()
    drawArrayOfElementsWrapper.add_drawelement_toarrayofelements(linearGradient)    
    drawArrayOfElements = MIDrawElement.new(:arrayofelements)
    rightEdge = self.draw_numberofrooms("3", arrayofelements: drawArrayOfElements, rightedge: 10) + 16
    rightEdge = self.draw_bed(arrayofelements: drawArrayOfElements, rightedge: rightEdge) + 40
    rightEdge = self.draw_houseprice(arrayofelements: drawArrayOfElements, rightedge: rightEdge) + 16
    rightEdge = self.draw_housepriceicon(arrayofelements: drawArrayOfElements, rightedge: rightEdge) + 20
    rightEdge = self.draw_numberofrooms("2", arrayofelements: drawArrayOfElements, rightedge: rightEdge) + 12
    rightEdge = self.draw_bathroomicon(arrayofelements: drawArrayOfElements, rightedge: rightEdge) + 36
    rightEdge = self.draw_garage(arrayofelements: drawArrayOfElements, rightedge: rightEdge) + 50
    self.draw_promotext1(text: text1,
                          arrayofelements: drawArrayOfElements,
                                textwidth: 240,
                                rightedge: rightEdge,
                                    alpha: 1.0)
    rightEdge = self.draw_promotext2(text: text2,
                          arrayofelements: drawArrayOfElements,
                                textwidth: 240,
                                rightedge: rightEdge,
                                    alpha: 1.0) + 40
    self.draw_promotext1(text: "Sheffield",
                          arrayofelements: drawArrayOfElements,
                                textwidth: 160,
                                rightedge: rightEdge + 20,
                                    alpha: 1.0)
    rightEdge = self.draw_promotext2(text: "Ecclesfield",
                          arrayofelements: drawArrayOfElements,
                                textwidth: 160,
                                rightedge: rightEdge + 20,
                                    alpha: 1.0) + 40
    self.draw_cottageicon(arrayofelements: drawArrayOfElements, rightedge: @@videoWidth - 100)
    self.draw_companylogo(logoidentifier: logoidentifier, arrayofelements: drawArrayOfElementsWrapper)
    shadow = MIShadow.new
    shadow.blur = 2
    shadow.offset = MIShapes.make_size(1, -1)
    shadow.color = MIColor.make_rgbacolor(0.3,0.3,0.3)
    drawArrayOfElements.shadow = shadow
    
    transformations = MITransformations.make_contexttransformation
    translatePoint = MIShapes.make_point(0, 4)
    MITransformations.add_translatetransform(transformations, translatePoint)
    drawArrayOfElements.contexttransformations = transformations
    drawArrayOfElementsWrapper.add_drawelement_toarrayofelements(drawArrayOfElements)
    self.draw_companyagent_details(arrayofelements: drawArrayOfElementsWrapper)
#    puts JSON.pretty_generate(drawArrayOfElements.elementhash)
    drawCommand = CommandModule.make_drawelement(bitmap, drawinstructions: drawArrayOfElementsWrapper)
    drawCommand
  end

  def self.draw_videoframe_attime(videoImporter, videobitmap: nil, time: nil)
    drawVideoFrameBitmap = MIDrawImageElement.new
    drawVideoFrameBitmap.set_moviefile_imagesource(source_object: videoImporter,
                                                       frametime: time)
    drawVideoFrameBitmap.destinationrectangle = MIShapes.make_rectangle(width: @@videoWidth, height: @@videoHeight)
    drawVideoFrameCommand = CommandModule.make_drawelement(videobitmap, drawinstructions: drawVideoFrameBitmap)
    drawVideoFrameCommand
  end

  def self.draw_videoframe(videoImporter, videobitmap: nil)
    nextFrameTime = MovieTime.make_movietime_nextsample
    self.draw_videoframe_attime(videoImporter, videobitmap: videobitmap, time: nextFrameTime)
  end

  def self.draw_image(imageImporter, sourcerect: nil, videobitmap: nil)
    destinationRectangle = MIShapes.make_rectangle(width: @@videoWidth, height: @@videoHeight)
    drawImage = MIDrawImageElement.new
    drawImage.set_imagefile_imagesource(source_object: imageImporter, imageindex: 0)
    drawImage.destinationrectangle = destinationRectangle
    drawImage.sourcerectangle = sourcerect
    drawImageCommand = CommandModule.make_drawelement(videobitmap, drawinstructions: drawImage)
    drawImageCommand
  end

  def self.draw_image_withprogress(imageImporter, progress: nil, videobitmap: nil)
    # Source images have dimensions: 3648x2736 that's 12:9 aspect ratio.
    # 3648 / 1280 = 2.85
    # 2.85 * 720 = 2052
    # progress is a value between 0 and 1.
    sourceSize = MIShapes.make_size(3648, 2052)
    diff = 2736 - 2052
    y = diff * (1.0 - progress)
    sourceOrigin = MIShapes.make_point(0, y)
    sourceRect = MIShapes.make_rectangle(size: sourceSize, origin: sourceOrigin)
    self.draw_image(imageImporter, sourcerect: sourceRect, videobitmap: videobitmap)
  end

  def self.generateVideoCommands1()
    frameDuration = MIMovie::MovieTime.make_movietime(timevalue: 1, timescale: 30)

    theCommands = SmigCommands.new
    theCommands.run_asynchronously = true
    videoFrameBitmap = theCommands.make_createbitmapcontext(size: @@videoFrameSize)

    logoImporter = theCommands.make_createimporter(File.join($imagesDirectory, "Zukini Logo-02.png"), addtocleanup: false)
    imageIdentifier = SecureRandom.uuid
    addImageToCollectionCommand = CommandModule.make_assignimage_fromimporter_tocollection(logoImporter, identifier: imageIdentifier)
    theCommands.add_command(addImageToCollectionCommand)
    theCommands.add_tocleanupcommands_removeimagefromcollection(imageIdentifier)
    theCommands.add_command(CommandModule.make_close(logoImporter))
    videoFramesWriter = theCommands.make_createvideoframeswriter(File.join($movieFileExportFolder, "Video1.mov"))
    addVideoInputCommand = CommandModule.make_addinputto_videowritercommand(
                                                              videoFramesWriter,
                                                   framesize: @@videoFrameSize,
                                               frameduration: frameDuration)
    theCommands.add_command(addVideoInputCommand)
    
    imageImporter = theCommands.make_createimporter(File.join($imagesDirectory, $images[0]))
    
    @@numFrames.times do |index|
      progress = 1.0 * index / (@@numFrames - 1.0) * 1.0 / 1.0
      theCommands.add_command(self.draw_image_withprogress(imageImporter, progress: progress, videobitmap: videoFrameBitmap))
      theCommands.add_command(self.draw_lowerthird(videoFrameBitmap, logoidentifier: imageIdentifier,
        text1: "Ready to move right in", text2: "Bright practical kitchen"))
      addImageToWriterInput = CommandModule.make_addimageto_videoinputwriter(
          videoFramesWriter, sourceobject: videoFrameBitmap)
      theCommands.add_command(addImageToWriterInput)
    end

    finalize = CommandModule.make_finishwritingframescommand(videoFramesWriter)
    theCommands.add_command(finalize)
    theCommands
  end

  def self.generateVideoCommands2()
    frameDuration = MIMovie::MovieTime.make_movietime(timevalue: 1, timescale: 30)

    theCommands = SmigCommands.new
    theCommands.run_asynchronously = true
    videoFrameBitmap = theCommands.make_createbitmapcontext(size: @@videoFrameSize)

    logoImporter = theCommands.make_createimporter(File.join($imagesDirectory, "Zukini Logo-02.png"), addtocleanup: false)
    imageIdentifier = SecureRandom.uuid
    addImageToCollectionCommand = CommandModule.make_assignimage_fromimporter_tocollection(logoImporter, identifier: imageIdentifier)
    theCommands.add_command(addImageToCollectionCommand)
    theCommands.add_tocleanupcommands_removeimagefromcollection(imageIdentifier)
    theCommands.add_command(CommandModule.make_close(logoImporter))
    videoFramesWriter = theCommands.make_createvideoframeswriter(File.join($movieFileExportFolder, "Video2.mov"))
    addVideoInputCommand = CommandModule.make_addinputto_videowritercommand(
                                                              videoFramesWriter,
                                                   framesize: @@videoFrameSize,
                                               frameduration: frameDuration)
    theCommands.add_command(addVideoInputCommand)
    
    imageImporter = theCommands.make_createimporter(File.join($imagesDirectory, $images[1]))
    
    @@numFrames.times do |index|
      progress = 1.0 * index / (@@numFrames - 1.0) * 1.0 / 1.0
      theCommands.add_command(self.draw_image_withprogress(imageImporter, progress: progress, videobitmap: videoFrameBitmap))
      theCommands.add_command(self.draw_lowerthird(videoFrameBitmap, logoidentifier: imageIdentifier,
        text1: "Quiet pleasant location", text2: "Close to public transport"))
      addImageToWriterInput = CommandModule.make_addimageto_videoinputwriter(
          videoFramesWriter, sourceobject: videoFrameBitmap)
      theCommands.add_command(addImageToWriterInput)
    end

    finalize = CommandModule.make_finishwritingframescommand(videoFramesWriter)
    theCommands.add_command(finalize)
    theCommands
  end

  def self.generateVideoCommands4()
    frameDuration = MIMovie::MovieTime.make_movietime(timevalue: 1, timescale: 30)

    theCommands = SmigCommands.new
    theCommands.run_asynchronously = true
    videoFrameBitmap = theCommands.make_createbitmapcontext(size: @@videoFrameSize)

    logoImporter = theCommands.make_createimporter(File.join($imagesDirectory, "Zukini Logo-02.png"), addtocleanup: false)
    imageIdentifier = SecureRandom.uuid
    addImageToCollectionCommand = CommandModule.make_assignimage_fromimporter_tocollection(logoImporter, identifier: imageIdentifier)
    theCommands.add_command(addImageToCollectionCommand)
    theCommands.add_tocleanupcommands_removeimagefromcollection(imageIdentifier)
    theCommands.add_command(CommandModule.make_close(logoImporter))
    videoFramesWriter = theCommands.make_createvideoframeswriter(File.join($movieFileExportFolder, "Video4.mov"))
    addVideoInputCommand = CommandModule.make_addinputto_videowritercommand(
                                                              videoFramesWriter,
                                                   framesize: @@videoFrameSize,
                                               frameduration: frameDuration)
    theCommands.add_command(addVideoInputCommand)
    
    imageImporter = theCommands.make_createimporter(File.join($imagesDirectory, $images[3]))
    
    @@numFrames.times do |index|
      progress = 1.0 * index / (@@numFrames - 1.0) * 1.0 / 1.0
      theCommands.add_command(self.draw_image_withprogress(imageImporter, progress: progress, videobitmap: videoFrameBitmap))
      theCommands.add_command(self.draw_lowerthird(videoFrameBitmap, logoidentifier: imageIdentifier,
        text1: "Close to good schools", text2: ""))
      addImageToWriterInput = CommandModule.make_addimageto_videoinputwriter(
          videoFramesWriter, sourceobject: videoFrameBitmap)
      theCommands.add_command(addImageToWriterInput)
    end

    finalize = CommandModule.make_finishwritingframescommand(videoFramesWriter)
    theCommands.add_command(finalize)
    theCommands
  end

  def self.generateVideoCommands5()
    frameDuration = MIMovie::MovieTime.make_movietime(timevalue: 1, timescale: 30)

    theCommands = SmigCommands.new
    theCommands.run_asynchronously = false
    videoFrameBitmap = theCommands.make_createbitmapcontext(size: @@videoFrameSize)

    logoImporter = theCommands.make_createimporter(File.join($imagesDirectory, "Zukini Logo-02.png"), addtocleanup: false)
    imageIdentifier = SecureRandom.uuid
    addImageToCollectionCommand = CommandModule.make_assignimage_fromimporter_tocollection(logoImporter, identifier: imageIdentifier)
    theCommands.add_command(addImageToCollectionCommand)
    theCommands.add_tocleanupcommands_removeimagefromcollection(imageIdentifier)
    theCommands.add_command(CommandModule.make_close(logoImporter))
    videoFramesWriter = theCommands.make_createvideoframeswriter(File.join($movieFileExportFolder, "Video5.mov"))
    addVideoInputCommand = CommandModule.make_addinputto_videowritercommand(
                                                              videoFramesWriter,
                                                   framesize: @@videoFrameSize,
                                               frameduration: frameDuration)
    theCommands.add_command(addVideoInputCommand)
    
    imageImporter = theCommands.make_createimporter(File.join($imagesDirectory, $images[2]))
    
    @@numFrames.times do |index|
      progress = 1.0 * index / (@@numFrames - 1.0) * 1.0 / 1.0
      theCommands.add_command(self.draw_image_withprogress(imageImporter, progress: progress, videobitmap: videoFrameBitmap))
      theCommands.add_command(self.draw_lowerthird(videoFrameBitmap, logoidentifier: imageIdentifier,
        text1: "Well insulated property", text2: "and cheap to keep warm"))
      addImageToWriterInput = CommandModule.make_addimageto_videoinputwriter(
          videoFramesWriter, sourceobject: videoFrameBitmap)
      theCommands.add_command(addImageToWriterInput)
    end

    finalize = CommandModule.make_finishwritingframescommand(videoFramesWriter)
    theCommands.add_command(finalize)
    theCommands
  end
  
  # This takes as input a movie unlike the others which take images.
  def self.generateVideoCommands3()
    frameDuration = MIMovie::MovieTime.make_movietime(timevalue: 1, timescale: 30)

    theCommands = SmigCommands.new
    theCommands.run_asynchronously = false
    videoFrameBitmap = theCommands.make_createbitmapcontext(size: @@videoFrameSize)
    logoImporter = theCommands.make_createimporter(File.join($imagesDirectory, "Zukini Logo-02.png"), addtocleanup: false)
    imageIdentifier = SecureRandom.uuid
    addImageToCollectionCommand = CommandModule.make_assignimage_fromimporter_tocollection(logoImporter, identifier: imageIdentifier)
    theCommands.add_command(addImageToCollectionCommand)
    theCommands.add_tocleanupcommands_removeimagefromcollection(imageIdentifier)
    theCommands.add_command(CommandModule.make_close(logoImporter))
    videoFramesWriter = theCommands.make_createvideoframeswriter(File.join($movieFileExportFolder, "Video3.mov"))
    addVideoInputCommand = CommandModule.make_addinputto_videowritercommand(
                                                              videoFramesWriter,
                                                   framesize: @@videoFrameSize,
                                               frameduration: frameDuration)
    theCommands.add_command(addVideoInputCommand)
    
    movieImporter = theCommands.make_createmovieimporter(File.join($movieDirectory, $movies[0]))
    # draw a single frame immediately before the first frame we actually want.
    time = MovieTime.make_movietime_fromseconds(5.1)
    theCommands.add_command(self.draw_videoframe_attime(movieImporter, videobitmap: videoFrameBitmap, time: time))
    @@numFrames.times do |index|
      theCommands.add_command(self.draw_videoframe(movieImporter, videobitmap: videoFrameBitmap))
      theCommands.add_command(self.draw_lowerthird(videoFrameBitmap, logoidentifier: imageIdentifier,
        text1: "Lovely well kept garden", text2: "visible from conservatory"))
      addImageToWriterInput = CommandModule.make_addimageto_videoinputwriter(
          videoFramesWriter, sourceobject: videoFrameBitmap)
      theCommands.add_command(addImageToWriterInput)
    end

    finalize = CommandModule.make_finishwritingframescommand(videoFramesWriter)
    theCommands.add_command(finalize)
    theCommands
  end
  
  def self.createComposeSubMoviesCommands()
    theCommands = SmigCommands.new
    
    movieEditorObject = theCommands.make_createmovieeditor(addtocleanup: false)
    addVideoTrackCommand = CommandModule.make_createtrackcommand(
                                                movieEditorObject,
                                     mediatype: :vide)
    theCommands.add_command(addVideoTrackCommand)
    theCommands.add_command(addVideoTrackCommand)
    
    videoTrack0 = MovieTrackIdentifier.make_movietrackid_from_mediatype(
      mediatype: :vide, trackindex: 0)
    videoTrack1 = MovieTrackIdentifier.make_movietrackid_from_mediatype(
      mediatype: :vide, trackindex: 1)

    sourceMovie1 = File.join($movieFileExportFolder, "Video1.mov")
    movieImporter1 = theCommands.make_createmovieimporter(sourceMovie1)
    sourceMovie2 = File.join($movieFileExportFolder, "Video2.mov")
    movieImporter2 = theCommands.make_createmovieimporter(sourceMovie2)
    sourceMovie3 = File.join($movieFileExportFolder, "Video3.mov")
    movieImporter3 = theCommands.make_createmovieimporter(sourceMovie3)
    sourceMovie4 = File.join($movieFileExportFolder, "Video4.mov")
    movieImporter4 = theCommands.make_createmovieimporter(sourceMovie4)
    sourceMovie5 = File.join($movieFileExportFolder, "Video5.mov")
    movieImporter5 = theCommands.make_createmovieimporter(sourceMovie5)

    timeZero = MovieTime.make_movietime(timevalue: 0, timescale: 6000)
    sourceDuration = MovieTime.make_movietime(timevalue: 36000, timescale: 6000)
    sourceTimeRange = MovieTime.make_movie_timerange(start: timeZero,
                                                  duration: sourceDuration)
    insertionTime1 = MovieTime.make_movietime(timevalue: 0, timescale: 6000)
    insertTrackSegmentCommand1 = CommandModule.make_inserttracksegment(
                                movieEditorObject, 
                         track: videoTrack0,
                 source_object: movieImporter1,
                  source_track: videoTrack0,
                 insertiontime: timeZero, 
              source_timerange: sourceTimeRange)
    theCommands.add_command(insertTrackSegmentCommand1)

    insertionTime2 = MovieTime.make_movietime(timevalue: 30000, timescale: 6000)
    insertTrackSegmentCommand2 = CommandModule.make_inserttracksegment(
                                movieEditorObject, 
                         track: videoTrack1,
                 source_object: movieImporter2,
                  source_track: videoTrack0,
                 insertiontime: insertionTime2,
              source_timerange: sourceTimeRange)
    theCommands.add_command(insertTrackSegmentCommand2)

    insertionTime3 = MovieTime.make_movietime(timevalue: 60000, timescale: 6000)
    insertTrackSegmentCommand3 = CommandModule.make_inserttracksegment(
                                movieEditorObject, 
                         track: videoTrack0,
                 source_object: movieImporter3,
                  source_track: videoTrack0,
                 insertiontime: insertionTime3,
              source_timerange: sourceTimeRange)
    theCommands.add_command(insertTrackSegmentCommand3)

    insertionTime4 = MovieTime.make_movietime(timevalue: 90000, timescale: 6000)
    insertTrackSegmentCommand4 = CommandModule.make_inserttracksegment(
                                movieEditorObject, 
                         track: videoTrack1,
                 source_object: movieImporter4,
                  source_track: videoTrack0,
                 insertiontime: insertionTime4,
              source_timerange: sourceTimeRange)
    theCommands.add_command(insertTrackSegmentCommand4)

    insertionTime5 = MovieTime.make_movietime(timevalue: 120000, timescale: 6000)
    insertTrackSegmentCommand5 = CommandModule.make_inserttracksegment(
                                movieEditorObject, 
                         track: videoTrack0,
                 source_object: movieImporter5,
                  source_track: videoTrack0,
                 insertiontime: insertionTime5,
              source_timerange: sourceTimeRange)
    theCommands.add_command(insertTrackSegmentCommand5)
    
    fourSeconds = MovieTime.make_movietime(timevalue: 24000, timescale: 6000)
    oneSecond = MovieTime.make_movietime(timevalue: 6000, timescale: 6000)
    fiveSeconds = MovieTime.make_movietime(timevalue: 30000, timescale: 6000)

    li1 = VideoLayerInstructions.new
    li1.add_passthrulayerinstruction(track: videoTrack0)
    videoI1TimeRange = MovieTime.make_movie_timerange(start: timeZero,
                                                   duration: fiveSeconds)
    videoI1Command = CommandModule.make_addvideoinstruction(movieEditorObject,
                                                 timerange: videoI1TimeRange,
                                         layerinstructions: li1)
    theCommands.add_command(videoI1Command)

    li2 = VideoLayerInstructions.new
    startCropRect = MIShapes.make_rectangle(size: MIShapes.make_size(@@videoWidth, @@videoHeight))
    endCropRect = MIShapes.make_rectangle(size: MIShapes.make_size(4, @@videoHeight))
    li2.add_croprectramplayerinstruction(track: videoTrack0,
                            startcroprectvalue: startCropRect,
                              endcroprectvalue: endCropRect)
    li2.add_passthrulayerinstruction(track: videoTrack1)
    videoI2TimeRange = MovieTime.make_movie_timerange(start: fiveSeconds,
                                                   duration: oneSecond)
    videoI2Command = CommandModule.make_addvideoinstruction(movieEditorObject,
                                                 timerange: videoI2TimeRange,
                                         layerinstructions: li2)
    theCommands.add_command(videoI2Command)

    li3 = VideoLayerInstructions.new
    sixSeconds = MovieTime.make_movietime(timevalue: 36000, timescale: 6000)
    li3.add_passthrulayerinstruction(track: videoTrack1)
    videoI3TimeRange = MovieTime.make_movie_timerange(start: sixSeconds,
                                                   duration: fourSeconds)
    videoI3Command = CommandModule.make_addvideoinstruction(movieEditorObject,
                                                 timerange: videoI3TimeRange,
                                         layerinstructions: li3)
    theCommands.add_command(videoI3Command)

    li4 = VideoLayerInstructions.new
    tenSeconds = MovieTime.make_movietime(timevalue: 60000, timescale: 6000)
    li4.add_opacityramplayerinstruction(track: videoTrack1)
    li4.add_passthrulayerinstruction(track: videoTrack0)
    videoI4TimeRange = MovieTime.make_movie_timerange(start: tenSeconds,
                                                   duration: oneSecond)
    videoI4Command = CommandModule.make_addvideoinstruction(movieEditorObject,
                                                 timerange: videoI4TimeRange,
                                         layerinstructions: li4)
    theCommands.add_command(videoI4Command)

    li5 = VideoLayerInstructions.new
    elevenSeconds = MovieTime.make_movietime(timevalue: 66000, timescale: 6000)
    li5.add_passthrulayerinstruction(track: videoTrack0)
    videoI5TimeRange = MovieTime.make_movie_timerange(start: elevenSeconds,
                                                   duration: fourSeconds)
    videoI5Command = CommandModule.make_addvideoinstruction(movieEditorObject,
                                                 timerange: videoI5TimeRange,
                                         layerinstructions: li5)
    theCommands.add_command(videoI5Command)

    li6 = VideoLayerInstructions.new
    fifteenSeconds = MovieTime.make_movietime(timevalue: 90000, timescale: 6000)
    li6.add_opacityramplayerinstruction(track: videoTrack0)
    li6.add_passthrulayerinstruction(track: videoTrack1)
    videoI6TimeRange = MovieTime.make_movie_timerange(start: fifteenSeconds,
                                                   duration: oneSecond)
    videoI6Command = CommandModule.make_addvideoinstruction(movieEditorObject,
                                                 timerange: videoI6TimeRange,
                                         layerinstructions: li6)
    theCommands.add_command(videoI6Command)

    li7 = VideoLayerInstructions.new
    sixteenSeconds = MovieTime.make_movietime(timevalue: 96000, timescale: 6000)
    li7.add_passthrulayerinstruction(track: videoTrack1)
    videoI7TimeRange = MovieTime.make_movie_timerange(start: sixteenSeconds,
                                                   duration: fourSeconds)
    videoI7Command = CommandModule.make_addvideoinstruction(movieEditorObject,
                                                 timerange: videoI7TimeRange,
                                         layerinstructions: li7)
    theCommands.add_command(videoI7Command)

    li8 = VideoLayerInstructions.new
    twentySeconds = MovieTime.make_movietime(timevalue: 120000, timescale: 6000)
    li8.add_croprectramplayerinstruction(track: videoTrack1,
                            startcroprectvalue: startCropRect,
                              endcroprectvalue: endCropRect)
    li8.add_passthrulayerinstruction(track: videoTrack0)
    videoI8TimeRange = MovieTime.make_movie_timerange(start: twentySeconds,
                                                   duration: oneSecond)
    videoI8Command = CommandModule.make_addvideoinstruction(movieEditorObject,
                                                 timerange: videoI8TimeRange,
                                         layerinstructions: li8)
    theCommands.add_command(videoI8Command)

    li9 = VideoLayerInstructions.new
    twentyOneSeconds = MovieTime.make_movietime(timevalue: 126000, timescale: 6000)
    li9.add_passthrulayerinstruction(track: videoTrack0)
    videoI9TimeRange = MovieTime.make_movie_timerange(start: twentyOneSeconds,
                                                   duration: fiveSeconds)
    videoI9Command = CommandModule.make_addvideoinstruction(movieEditorObject,
                                                 timerange: videoI9TimeRange,
                                         layerinstructions: li9)
    theCommands.add_command(videoI9Command)

=begin
    imageIdentifier = SecureRandom.uuid
    addCompositionToImageCollection = CommandModule.make_assignimage_tocollection(
                                                movieEditorObject,
                                    identifier: imageIdentifier)
    theCommands.add_command(addCompositionToImageCollection)
    theCommands.add_tocleanupcommands_removeimagefromcollection(
                                                imageIdentifier)

    compMapFileName = "PropertyVideoCompositionMap.jpg"

    exportPath = File.join($movieFileExportFolder, compMapFileName)
    exporterObject = theCommands.make_createexporter(exportPath,
                                        export_type: "public.jpeg",
                                       addtocleanup: false)
    addImageToExporterCommand = CommandModule.make_addimage_fromimagecollection(
                                    exporterObject,
                   imageidentifier: imageIdentifier)
    theCommands.add_command(addImageToExporterCommand)
    exportCommand = CommandModule.make_export(exporterObject)
    theCommands.add_command(exportCommand)
=end
    movieFileName = "PropertyVideo.mp4"
    movieExportPath = File.join($movieFileExportFolder, movieFileName)
    # movieExportPath = File.join(File.expand_path("~/Desktop"), movieFileName)
    fileType = "public.mpeg-4"
    exportMovieCommand = CommandModule.make_movieeditor_export(
                                              movieEditorObject,
                                exportpreset: :AVAssetExportPreset1280x720,
                              exportfilepath: movieExportPath,
                              exportfiletype: fileType)
    theCommands.add_command(exportMovieCommand)
    theCommands
  end
end

theCommands1 = PropertyToSellVideo.generateVideoCommands1()
Smig.perform_commands(theCommands1)
theCommands2 = PropertyToSellVideo.generateVideoCommands2()
Smig.perform_commands(theCommands2)
theCommands3 = PropertyToSellVideo.generateVideoCommands3()
Smig.perform_commands(theCommands3)
theCommands4 = PropertyToSellVideo.generateVideoCommands4()
Smig.perform_commands(theCommands4)
theCommands5 = PropertyToSellVideo.generateVideoCommands5()
Smig.perform_commands(theCommands5)

finalCommands = PropertyToSellVideo.createComposeSubMoviesCommands()
Smig.perform_commands(finalCommands)

# puts JSON.pretty_generate(theCommands.commandshash)
# Smig.perform_commands(theCommands)

