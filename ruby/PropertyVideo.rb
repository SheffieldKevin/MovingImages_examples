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
  "IMG_1187.mov",
  "IMG_1189.mov",
  "IMG_1190.mov",
  "IMG_0546.mov"
]

$imageFiles = [
  "IMG_1191.JPG",       # 0
  "IMG_1192.JPG",       # 1
  "Zukini Logo-02.png"  # 2
]

$movieFileExportPath = File.expand_path("~/Desktop/PropertyVideo.mov")

class PropertyToSellVideo
  @@videoWidth = 1280
  @@videoHeight = 720
  
  @@lowerThirdWidth = @@videoWidth
  @@lowerThirdHeight = 144 # Actually lower fifth.
  
  @@iconHeight = @@lowerThirdHeight * 0.5

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
    linearGradient.contextalpha = 0.7
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
    text = "Advertized and promoted by The Real Estage Agency. If you are interested in this property please call Dave on 079 999999 or e-mail dave@therealestateagency.com"
    drawText = self.draw_text_atpoint(text: text, point: textPoint, fontsize: 14, font: "Tahoma")
    arrayofelements.add_drawelement_toarrayofelements(drawText)
  end

  def self.draw_lowerthird(bitmap, logoidentifier: nil)
    drawArrayOfElementsWrapper = MIDrawElement.new(:arrayofelements)
    linearGradient = self.draw_lineargradientbackground()
    drawArrayOfElementsWrapper.add_drawelement_toarrayofelements(linearGradient)    
    drawArrayOfElements = MIDrawElement.new(:arrayofelements)
    rightEdge = self.draw_numberofrooms("3", arrayofelements: drawArrayOfElements, rightedge: 10) + 16
    rightEdge = self.draw_bed(arrayofelements: drawArrayOfElements, rightedge: rightEdge) + 40
    rightEdge = self.draw_houseprice(arrayofelements: drawArrayOfElements, rightedge: rightEdge) + 16
    rightEdge = self.draw_housepriceicon(arrayofelements: drawArrayOfElements, rightedge: rightEdge) + 20
    rightEdge = self.draw_numberofrooms("2", arrayofelements: drawArrayOfElements, rightedge: rightEdge) + 16
    rightEdge = self.draw_bathroomicon(arrayofelements: drawArrayOfElements, rightedge: rightEdge) + 20
    rightEdge = self.draw_garage(arrayofelements: drawArrayOfElements, rightedge: rightEdge) + 40
    self.draw_promotext1(text: "Pleasant quiet location",
                          arrayofelements: drawArrayOfElements,
                                textwidth: 240,
                                rightedge: rightEdge,
                                    alpha: 1.0)
    rightEdge = self.draw_promotext2(text: "Close to public transport",
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
    translatePoint = MIShapes.make_point(0, 18)
    MITransformations.add_translatetransform(transformations, translatePoint)
    drawArrayOfElements.contexttransformations = transformations
    drawArrayOfElementsWrapper.add_drawelement_toarrayofelements(drawArrayOfElements)
    self.draw_companyagent_details(arrayofelements: drawArrayOfElementsWrapper)
#    puts JSON.pretty_generate(drawArrayOfElements.elementhash)
    drawCommand = CommandModule.make_drawelement(bitmap, drawinstructions: drawArrayOfElementsWrapper)
    drawCommand
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

  def self.generateVideoCommands()
    lowerThirdSize = MIShapes.make_size(@@lowerThirdWidth, @@lowerThirdHeight)
    lowerThirdRect = MIShapes.make_rectangle(size: lowerThirdSize)
    videoFrameSize = MIShapes.make_size(@@videoWidth, @@videoHeight)
    videoWindowRect = MIShapes.make_rectangle(size: videoFrameSize)
    frameDuration = MIMovie::MovieTime.make_movietime(timevalue: 1, timescale: 30)

    theCommands = SmigCommands.new
    # videoFrameBitmap = theCommands.make_createbitmapcontext(size: videoFrameSize)
    videoFrameBitmap = theCommands.make_createwindowcontext(rect: videoWindowRect,
      addtocleanup: false)
    movieImporter = theCommands.make_createmovieimporter(File.join($movieDirectory, $movies[0]))
    logoImporter = theCommands.make_createimporter(File.join($imagesDirectory, $imageFiles[2]), addtocleanup: false)
    imageIdentifier = SecureRandom.uuid
    addImageToCollectionCommand = CommandModule.make_assignimage_fromimporter_tocollection(logoImporter, identifier: imageIdentifier)
    theCommands.add_command(addImageToCollectionCommand)
    theCommands.add_tocleanupcommands_removeimagefromcollection(imageIdentifier)
    theCommands.add_command(CommandModule.make_close(logoImporter))
    theCommands.add_command(self.draw_videoframe(movieImporter, videobitmap: videoFrameBitmap))
    theCommands.add_command(self.draw_lowerthird(videoFrameBitmap, logoidentifier: imageIdentifier))
    begin
      Smig.perform_commands(theCommands)
      sleep 10
    ensure
      Smig.close_object(videoFrameBitmap)
    end
  end
end

# PropertyToSellVideo.printVideoContentProperties()
# PropertyToSellVideo.printVideoContentFrameDuration()
# PropertyToSellVideo.printSVGViewBox()
# theCommands = PropertyToSellVideo.generateVideoCommands()
PropertyToSellVideo.generateVideoCommands()

# puts JSON.pretty_generate(theCommands.commandshash)
# Smig.perform_commands(theCommands)

