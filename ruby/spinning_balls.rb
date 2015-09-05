#!/usr/bin/env ruby

require 'securerandom'
require 'moving_images'

include MovingImages
include MICGDrawing
include CommandModule

class SpinningBalls  
  @@video_width = 1280
  @@video_height = 720
  @@video_size = MIShapes.make_size(@@video_width, @@video_height)
  @@frame_duration = MIMovie::MovieTime.make_movietime(timevalue: 200,
                                                       timescale: 6000)
  @@window = nil
  @@bitapcontext = nil
  @@videoframeswriter = nil
  @@save_moviepath = File.expand_path("~/Desktop/Current/spinning_balls.mov")
  
  @@cleanup_commands = SmigCommands.new
  
  def self.make_window(commands)
    windowRect = MIShapes.make_rectangle(size: @@video_size)
    @@window = commands.make_createwindowcontext(rect: windowRect,
                                         addtocleanup: false)
    @@cleanup_commands.add_tocleanupcommands_closeobject(@@window)
  end

  def self.make_bitmapcontext(commands)
    @@bitmapcontext = commands.make_createbitmapcontext(size: @@video_size,
                                                addtocleanup: false)
    @@cleanup_commands.add_tocleanupcommands_closeobject(@@bitmapcontext)
  end

  def self.make_videoframeswriter(commands)
    @@videoframeswriter = commands.make_createvideoframeswriter(@@save_moviepath,
                                                  addtocleanup: false)
    addInputCommand = CommandModule.make_addinputto_videowritercommand(
                                                        @@videoframeswriter,
                                                preset: :h264preset_hd,
                                             framesize: @@video_size,
                                         frameduration: @@frame_duration)
    commands.add_command(addInputCommand)
    @@cleanup_commands.add_tocleanupcommands_closeobject(@@videoframeswriter)
  end

  def self.preroll()
    commands = SmigCommands.new
    self.make_window(commands)
    self.make_bitmapcontext(commands)
    self.make_videoframeswriter(commands)
    Smig.perform_commands(commands)
  end
  
  def self.cleanup()
    Smig.perform_commands(@@cleanup_commands)
  end

  # Returns a new darkened color. Doesn't modify original.
  def self.color_darkener(color: nil, darken: 1.0)
    darken = 0.0 if darken < 0.0
    darken = 1.0 if darken > 1.0
    
    newColor = color.dup
    newColor[:red] *= darken
    newColor[:green] *= darken
    newColor[:blue] *= darken
    newColor
  end

  # Returns a new lightener color. Doesn't modify original.
  def self.color_lightener(color: nil, lighten: 1.0)
    lighten = 1.0 if lighten < 1.0
    
    newColor = color.dup
    newColor[:red] *= lighten
    newColor[:green] *= lighten
    newColor[:blue] *= lighten
    newColor
  end

  def self.make_radialgradient(size: nil, color:  nil)
    radialGradientFill = MIRadialGradientFillElement.new()
    centerPoint1 = MIShapes.make_point(0, 0)
    centerPoint2 = MIShapes.make_point(size * 0.2, size * 0.3)
    radialGradientFill.center1 = centerPoint1
    radialGradientFill.radius1 = size * 0.5
    radialGradientFill.center2 = centerPoint2
    radialGradientFill.radius2 = size * 0.02
    locations = [ 0.0, 1.0 ]
    color1 = self.color_darkener(color: color, darken: 0.6)
    color2 = self.color_lightener(color: color, lighten: 4.0)
    colors = [ color1, color2 ]
    # colors = [ color, color2 ]
    radialGradientFill.set_arrayoflocations_andarrayofcolors(locations, colors)
    radialGradientFill.add_drawgradient_option(:kCGGradientDrawsAfterEndLocation)
    radialGradientFill
  end

  def self.make_clearscreen()
    clearScreen = MIDrawElement.new(:fillrectangle)
    clearScreen.fillcolor = MIColor.make_rgbacolor(1,1,1)
    clearScreen.rectangle = MIShapes.make_rectangle(width: @@video_width,
                                                   height: @@video_height)
    clearScreen
  end

  def self.make_drawradialdict(size: nil,
                              color: nil,
                       radialcenter: nil,
                       radialradius: nil,
                        speedfactor: 1.0)
    {
      radialcenter: radialcenter,
      radialradius: radialradius,
              size: size,
             color: color,
       speedfactor: speedfactor,
        startangle: SecureRandom.random_number * 2.0 * Math::PI - Math::PI
    }
  end

  def self.make_drawradial(drawradialdict: nil, angle: angle)
    radialGradientFill = self.make_radialgradient(
                            size: drawradialdict[:size],
                           color: drawradialdict[:color])
    radialCenter = drawradialdict[:radialcenter]
    radius = drawradialdict[:radialradius]
    radialGradientCenter = MIShapes.make_point(
      radialCenter[:x] + Math.cos(angle) * radius,
      radialCenter[:y] + Math.sin(angle) * radius)
    centerOffset = MITransformations.make_contexttransformation
    MITransformations.add_translatetransform(centerOffset, radialGradientCenter)
    radialGradientFill.contexttransformations = centerOffset
    radialGradientFill
  end

  def self.make_randompoint()
    randomPoint = MIShapes.make_point(
                      @@video_width * (0.25 + 0.5 * SecureRandom.random_number),
                      @@video_height * (0.2  + 0.5 * SecureRandom.random_number))
    randomPoint
  end

  def self.do_stuff()
    numSteps = 628
    startSize = 750
    shrinkAmount = 22
    
    color = MIColor.make_rgbacolor(0.8, 0.2, 0.1)
    drawRadialDict = self.make_drawradialdict(size: startSize,
                                             color: color,
                                      radialcenter: self.make_randompoint(),
                                      radialradius: startSize - 100,
                                       speedfactor: 1)
    drawRadialDicts = [drawRadialDict]

    startSize -= shrinkAmount
    color2 = MIColor.make_rgbacolor(0.6, 0.6, 0.1)
    drawRadialDict2 = self.make_drawradialdict(size: startSize,
                                              color: color2,
                                       radialcenter: self.make_randompoint(),
                                       radialradius: startSize - 100,
                                        speedfactor: -1.5)
    drawRadialDicts.push(drawRadialDict2)

    startSize -= shrinkAmount
    color3 = MIColor.make_rgbacolor(0.2, 0.8, 0.1)
    drawRadialDict3 = self.make_drawradialdict(size: startSize,
                                              color: color3,
                                       radialcenter: self.make_randompoint(),
                                       radialradius: startSize - 100,
                                        speedfactor: 2.0)
    drawRadialDicts.push(drawRadialDict3)

    startSize -= shrinkAmount
    color4 = MIColor.make_rgbacolor(0.0, 0.6, 0.6)
    drawRadialDict4 = self.make_drawradialdict(size: startSize,
                                              color: color4,
                                       radialcenter: self.make_randompoint(),
                                       radialradius: startSize - 100,
                                        speedfactor: -2.5)
    drawRadialDicts.push(drawRadialDict4)

    startSize -= shrinkAmount
    centerPoint5 = MIShapes.make_point(
                      @@video_width * (0.2 + 0.6 * SecureRandom.random_number),
                      @@video_height * (0.2  + 0.6 * SecureRandom.random_number))
    color5 = MIColor.make_rgbacolor(0.0, 0.2, 0.8)
    drawRadialDict5 = self.make_drawradialdict(size: startSize,
                                              color: color5,
                                       radialcenter: self.make_randompoint(),
                                       radialradius: startSize - 100,
                                        speedfactor: 3.0)
    drawRadialDicts.push(drawRadialDict5)

    startSize -= shrinkAmount
    color6 = MIColor.make_rgbacolor(0.6, 0.0, 0.6)
    drawRadialDict6 = self.make_drawradialdict(size: startSize,
                                              color: color6,
                                       radialcenter: self.make_randompoint(),
                                       radialradius: startSize - 100,
                                        speedfactor: -3.5)
    drawRadialDicts.push(drawRadialDict6)

    startSize -= shrinkAmount
    color7 = MIColor.make_rgbacolor(0.8, 0.2, 0.0)
    drawRadialDict7 = self.make_drawradialdict(size: startSize,
                                              color: color7,
                                       radialcenter: self.make_randompoint(),
                                       radialradius: startSize - 100,
                                        speedfactor: 4)
    drawRadialDicts.push(drawRadialDict7)

    startSize -= shrinkAmount
    color8 = MIColor.make_rgbacolor(0.6, 0.6, 0.0)
    drawRadialDict8 = self.make_drawradialdict(size: startSize,
                                              color: color8,
                                       radialcenter: self.make_randompoint(),
                                       radialradius: startSize - 100,
                                        speedfactor: -4.5)
    drawRadialDicts.push(drawRadialDict8)

    startSize -= shrinkAmount
    color9 = MIColor.make_rgbacolor(0.0, 0.8, 0.1)
    drawRadialDict9 = self.make_drawradialdict(size: startSize,
                                              color: color9,
                                       radialcenter: self.make_randompoint(),
                                       radialradius: startSize - 100,
                                        speedfactor: 5)
    drawRadialDicts.push(drawRadialDict9)

    startSize -= shrinkAmount
    color10 = MIColor.make_rgbacolor(0.0, 0.6, 0.6)
    drawRadialDict10 = self.make_drawradialdict(size: startSize,
                                              color: color10,
                                       radialcenter: self.make_randompoint(),
                                       radialradius: startSize - 100,
                                        speedfactor: -5.5)
    drawRadialDicts.push(drawRadialDict10)

    startSize -= shrinkAmount
    color11 = MIColor.make_rgbacolor(0.2, 0.0, 0.8)
    drawRadialDict11 = self.make_drawradialdict(size: startSize,
                                              color: color11,
                                       radialcenter: self.make_randompoint(),
                                       radialradius: startSize - 100,
                                        speedfactor: 6)
    drawRadialDicts.push(drawRadialDict11)

    startSize -= shrinkAmount
    color12 = MIColor.make_rgbacolor(0.6, 0.0, 0.6)
    drawRadialDict12 = self.make_drawradialdict(size: startSize,
                                              color: color12,
                                       radialcenter: self.make_randompoint(),
                                       radialradius: startSize - 100,
                                        speedfactor: -6.5)
    drawRadialDicts.push(drawRadialDict12)

    startSize -= shrinkAmount
    color13 = MIColor.make_rgbacolor(0.8, 0.0, 0.2)
    drawRadialDict13 = self.make_drawradialdict(size: startSize,
                                              color: color13,
                                       radialcenter: self.make_randompoint(),
                                       radialradius: startSize - 100,
                                        speedfactor: 7)
    drawRadialDicts.push(drawRadialDict13)

    startSize -= shrinkAmount
    color14 = MIColor.make_rgbacolor(0.4, 0.7, 0.2)
    drawRadialDict14 = self.make_drawradialdict(size: startSize,
                                              color: color14,
                                       radialcenter: self.make_randompoint(),
                                       radialradius: startSize - 100,
                                        speedfactor: -7.5)
    drawRadialDicts.push(drawRadialDict14)

    startSize -= shrinkAmount
    color15 = MIColor.make_rgbacolor(0.0, 0.9, 0.0)
    drawRadialDict15 = self.make_drawradialdict(size: startSize,
                                              color: color15,
                                       radialcenter: self.make_randompoint(),
                                       radialradius: startSize - 50,
                                        speedfactor: 8)
    drawRadialDicts.push(drawRadialDict15)

    startSize -= shrinkAmount
    color16 = MIColor.make_rgbacolor(0.3, 0.5, 0.7)
    drawRadialDict16 = self.make_drawradialdict(size: startSize,
                                              color: color16,
                                       radialcenter: self.make_randompoint(),
                                       radialradius: startSize - 50,
                                        speedfactor: -8.5)
    drawRadialDicts.push(drawRadialDict16)

    startSize -= shrinkAmount
    color17 = MIColor.make_rgbacolor(0.0, 0.1, 0.9)
    drawRadialDict17 = self.make_drawradialdict(size: startSize,
                                              color: color17,
                                       radialcenter: self.make_randompoint(),
                                       radialradius: startSize,
                                        speedfactor: 9)
    drawRadialDicts.push(drawRadialDict17)

    startSize -= shrinkAmount
    color18 = MIColor.make_rgbacolor(0.8, 0.0, 0.5)
    drawRadialDict18 = self.make_drawradialdict(size: startSize,
                                              color: color18,
                                       radialcenter: self.make_randompoint(),
                                       radialradius: startSize,
                                        speedfactor: -9.5)
    drawRadialDicts.push(drawRadialDict18)

    startSize -= shrinkAmount
    color19 = MIColor.make_rgbacolor(0.6, 0.6, 0.6)
    drawRadialDict19 = self.make_drawradialdict(size: startSize,
                                              color: color19,
                                       radialcenter: self.make_randompoint(),
                                       radialradius: startSize,
                                        speedfactor: 10)
    drawRadialDicts.push(drawRadialDict19)

    startSize -= shrinkAmount
    color20 = MIColor.make_rgbacolor(0.0, 0.9, 0.9)
    drawRadialDict20 = self.make_drawradialdict(size: startSize,
                                              color: color20,
                                       radialcenter: self.make_randompoint(),
                                       radialradius: startSize,
                                        speedfactor: -10.5)
    drawRadialDicts.push(drawRadialDict20)

    # Ths structures for all the radial gradient fills is done.
    destRect = MIShapes.make_rectangle(width: @@video_width, height: @@video_height)
    clearScreen = self.make_clearscreen()
    stepSizeInRadians = Math::PI * 2.0 / (numSteps - 1.0)
    (numSteps * 2).times do |step|
      drawElements = MIDrawElement.new(:arrayofelements)
      drawElements.add_drawelement_toarrayofelements(clearScreen)
      angle = step * stepSizeInRadians
      
      drawRadialDicts.each do |radialDict|
        thisAngle = angle * radialDict[:speedfactor] + radialDict[:startangle]
        drawRadialGradient = self.make_drawradial(drawradialdict: radialDict,
                                                           angle: thisAngle)
        drawElements.add_drawelement_toarrayofelements(drawRadialGradient)
      end
      drawRadialGradientsCommand = CommandModule.make_drawelement(@@bitmapcontext,
        drawinstructions: drawElements, createimage: true)
      commands = SmigCommands.new
      commands.add_command(drawRadialGradientsCommand)
      addImageCommand = CommandModule.make_addimageto_videoinputwriter(
                                                          @@videoframeswriter,
                                            sourceobject: @@bitmapcontext)
      commands.add_command(addImageCommand)
      if (step % 10).eql?(0)  && !@@window.nil?
        drawImageElement = MIDrawImageElement.new
        drawImageElement.set_bitmap_imagesource(source_object: @@bitmapcontext)
        drawImageElement.destinationrectangle = destRect
        drawImageCommand = CommandModule.make_drawelement(@@window,
                                        drawinstructions: drawImageElement)
        commands.add_command(drawImageCommand)
      end
      Smig.perform_commands(commands)
    end
    finishWritingCommand = CommandModule.make_finishwritingframescommand(
                                                          @@videoframeswriter)
  end

  def self.run()
    begin
      self.preroll()
      self.do_stuff()
    ensure
      self.cleanup()
    end
  end
end

SpinningBalls.run()
