#!/usr/bin/env ruby
require 'moving_images'

include MovingImages
include MIMovie

module GettingStarted
  # Returns the window object we can access later.
  def self.create_window()
    windowName = SecureRandom.uuid
    window = SmigIDHash.make_objectid(objectname: windowName,
                                      objecttype: :nsgraphicscontext)
    createWindowCommand = CommandModule.make_createwindowcontext(name: windowName)
    puts JSON.pretty_generate(createWindowCommand.commandhash)
    Smig.perform_command(createWindowCommand)
    window
  end

  def self.run()
    theWindow = self.create_window()
    sleep 2
    Smig.close_object_nothrow(theWindow)
  end

  
end

GettingStarted.run