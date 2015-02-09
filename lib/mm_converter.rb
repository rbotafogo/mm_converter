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
require 'state_machine'

require 'config'

require_relative 'mm_machine'
require_relative 'richtext_machine'

##########################################################################################
#
##########################################################################################

class ParseMM

  #----------------------------------------------------------------------------------------
  # Parse the input_file and send parsed events to the given state machine.  Results should
  # be stored in the output_dir
  #----------------------------------------------------------------------------------------

  def initialize(input_file, output_dir)

    @input_file = input_file
    @output_dir = (output_dir)? output_dir : File.dirname(input_file)
    @source = File.new(input_file)

    # maybe, based on an input, we can chose different processing machines
    @machine = MMMachine.new
    @machine.set_output(@input_file, @output_dir)

    # start parsing the file.  This class will receive the events and redirect them to 
    # the proper machine
    REXML::Document.parse_stream(@source, self)

  end

  #----------------------------------------------------------------------------------------
  # This method is necessary do ignore parsing events that are of no interest to our
  # parsing.
  #----------------------------------------------------------------------------------------

  def method_missing(*arg)
  end
  
  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def tag_start(name, attrs)

    case name
    when "node"
      @machine.new_node(attrs)
    when "richcontent"
      @machine.rich_content
    when "attribute"
      @machine.new_attribute(attrs)
    when "body"
      @machine.new_body
    end
    
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def tag_end(name)

    case name
    when "node"
      @machine.exit_node
    when "richcontent"
      @machine.end_rich_content
    when "attribute"
      @machine.end_attribute
    when "body"
      @machine.end_body
    end

  end
  
  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def text(text)
    if (@machine.state == "in_body" && text.strip! != '')
      # @out.write(text)
      # @out.write("\n")
    end
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

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def initialize(input_file, output_dir = nil)

    @input_file = input_file
    @output_dir = File.dirname(input_file)
    ParseMM.new(input_file, output_dir)

=begin
    @rt_machine = RichtextMachine.new
    @mm_machine.set_output(@out)
    @rt_machine.set_output(@out)
=end

  end

end

conv = MMConverter.new("../examples/projetos.mm")
