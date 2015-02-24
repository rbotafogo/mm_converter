# -*- coding: utf-8 -*-

##########################################################################################
# @author Rodrigo Botafogo
#
# Copyright © 2015 Rodrigo Botafogo. All Rights Reserved. Permission to use, copy, modify, 
# and distribute this software and its documentation, without fee and without a signed 
# licensing agreement, is hereby granted, provided that the above copyright notice, this 
# paragraph and the following two paragraphs appear in all copies, modifications, and 
# distributions.
#
# IN NO EVENT SHALL RODRIGO BOTAFOGO BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, 
# INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF 
# THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF RODRIGO BOTAFOGO HAS BEEN ADVISED OF THE 
# POSSIBILITY OF SUCH DAMAGE.
#
# RODRIGO BOTAFOGO SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, 
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE 
# SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED HEREUNDER IS PROVIDED "AS IS". 
# RODRIGO BOTAFOGO HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, 
# ENHANCEMENTS, OR MODIFICATIONS.
##########################################################################################

require 'fileutils'
require 'rexml/document'
require 'observer'

require 'config'
require_relative 'config_machine'

##########################################################################################
#
##########################################################################################

module MergeObservable
  include Observable

  alias_method :old_notify, :notify_observers

  def add_new_observer(observer)
    @new_observers ||= Array.new
    @new_observers << observer
  end

  def merge_observers
    @new_observers ||= Array.new
    @new_observers.each do |obs|
      self.add_observer(obs)
    end
    @new_observers = nil 
  end

  def notify_observers(*args)
    merge_observers
    old_notify(*args)
  end

end

##########################################################################################
#
##########################################################################################

class ParseMM
  include MergeObservable

  #----------------------------------------------------------------------------------------
  # Parse the input_file and send parsed events to the given state machine.  Results should
  # be stored in the output_dir
  #----------------------------------------------------------------------------------------

  def initialize(input_file)
    @input_file = input_file
    @source = File.new(input_file)
  end

  #----------------------------------------------------------------------------------------
  # start parsing the file.  This class will receive the events and redirect them to 
  # listeners
  #----------------------------------------------------------------------------------------

  def start
    REXML::Document.parse_stream(@source, self)
  end

  #----------------------------------------------------------------------------------------
  # This method is necessary do ignore parsing events that are of no interest to our
  # parsing.
  #----------------------------------------------------------------------------------------

  def method_missing(*args)
    # p args
  end
  
  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def tag_start(name, attrs)
    changed
    notify_observers(:tag_start, name, attrs)
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def tag_end(name)
    changed
    notify_observers(:tag_end, name, nil)
  end
  
end

##########################################################################################
#
##########################################################################################

class MMConverter

  #----------------------------------------------------------------------------------------
  # input is a .mm file
  # output_dir is the directory for output of the converted MM
  #----------------------------------------------------------------------------------------

  attr_reader :input
  attr_reader :output_dir
  attr_reader :parser

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def initialize(input_file, output_dir = nil)

    @input_file = input_file
    @output_dir = File.dirname(input_file)
    @parser = ParseMM.new(input_file)
    # creating a single file, but later this should not be done here

    # Use config machine to read the root node of the Map and do the proper convertion
    # of the map.
    @machine = ConfigMachine.new(@input_file, @output_dir, @parser)
    @parser.add_observer(@machine)
    @parser.start

  end

end

conv = MMConverter.new("../examples/projetos.mm")
# conv = MMConverter.new("../../../../Embratel/Projetos/Business Security - Planejamento.mm")
