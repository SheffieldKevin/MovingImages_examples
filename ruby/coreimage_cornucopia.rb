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

  @@video_texts = [
"MovingImages
by
Zukini"
  ]

  def self.create_imagefilterchain(commands, inputImageID, renderDestination)
    # Now set up the filter chain
    filterchain = MIFilterChain.new(renderDestination)
    filterchain.use_srgbprofile = true
=begin
    # Create the radial gradient filter description
    radial_gradient = MIFilter.new(:CIRadialGradient, identifier: :radialfilter)
    center_property = MIFilterProperty.make_civectorproperty_fromarray(
                                        key: 'inputCenter', value: [200, 200])
    radial_gradient.add_property(center_property)
    radius0_property = MIFilterProperty.make_cinumberproperty(
                                            key: :inputRadius0, value: 10)
    radial_gradient.add_property(radius0_property)
    radius1_property = MIFilterProperty.make_cinumberproperty(
                                            key: :inputRadius1, value: 200)
    radial_gradient.add_property(radius1_property)
    color0_property = MIFilterProperty.make_cicolorproperty_fromstring(
                                            key: :inputColor0, value: '1 1 1 1')
    radial_gradient.add_property(color0_property)
    color1_property = MIFilterProperty.make_cicolorproperty_fromstring(
                                            key: :inputColor1, value: '0 0 0 1')
    radial_gradient.add_property(color1_property)
    filterchain.add_filter(radial_gradient)

    # Now the radial gradient filter has been created & added to filter chain
    # Create the crop filter to set the bounds of the radial gradient filter.
    crop = MIFilter.new(:CICrop, identifier: :cropfilter)
    rectangle_property = MIFilterProperty.make_civectorproperty_fromstring(
                              key: :inputRectangle, value: "[0 0 400.0 400.0]")
    crop.add_property(rectangle_property)
    inputimage_property = MIFilterProperty.make_ciimageproperty(
            key: :inputImage,
          value: SmigIDHash.makeid_withfilternameid(:radialfilter))
    crop.add_property(inputimage_property)
    filterchain.add_filter(crop)
=end
    # The crop filter has been setup, now setup the height field mask filter
    heightfieldmask = MIFilter.new(:CIHeightFieldFromMask,
                       identifier: :heightfieldmask)
    heightfield_radiusproperty = MIFilterProperty.make_cinumberproperty(
                                                 key: :inputRadius, value: 5)
    heightfieldmask.add_property(heightfield_radiusproperty)
    inputImageID = SmigIDHash.make_imageidentifier(inputImageID)
    heightfieldmask.add_inputimage_property(inputImageID)
#    heightfield_inputimageproperty = MIFilterProperty.make_ciimageproperty(
#                                      key: :inputImage, value: window_objectid)
#    heightfieldmask.add_property(heightfield_inputimageproperty)
    filterchain.add_filter(heightfieldmask)
    imageFilter = commands.make_createimagefilterchain(filterchain)
    imageFilter
  end

  def self.render_filterchain(commands, filterChain)
    renderFilterChain = MIFilterChainRender.new
    renderCommand = CommandModule.make_renderfilterchain(filterChain,
                                     renderinstructions: renderFilterChain)
    commands.add_command(renderCommand)
  end

  def self.run()
    theCommands = SmigCommands.new
    theRect = MIShapes.make_rectangle(width: self.videowidth,
                                     height: self.videoheight)
    drawContext = theCommands.make_createwindowcontext(rect: theRect,
      addtocleanup: false)
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
    
    filterChainObject = self.create_imagefilterchain(theCommands,
                                                imageIdentifier, drawContext)
    self.render_filterchain(theCommands, filterChainObject)
    Smig.perform_commands(theCommands)
    sleep 7
    Smig.close_object(drawContext)
  end
end

ZukiniDemoVideo.run()
