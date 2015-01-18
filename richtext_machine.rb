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

##########################################################################################
#
##########################################################################################

class RichtextMachine

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def set_output(out)
    @out = out
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  state_machine :state, initial: :awaiting_richcontent do

    event :rich_content do
      transition :awaiting_richcontent => :richcontent
    end

    event :end_rich_content do
      transition :richcontent => :awaiting_richcontent
    end

    event :new_body do
      transition :richcontent => :in_body
    end

    event :end_body do
      transition :in_body => :richcontent
    end

    event :text do
      transition :in_body => same
      transition :in_item => same
    end

    after_transition :on => :text, :do => :print_text

    event :new_itemize do
      transition :in_body => :itemize
    end

    after_transition :on => :new_itemize, :do => :print_begin_itemize

    event :end_itemize do
      transition :itemize => :in_body
    end

    after_transition :on => :end_itemize, :do => :print_end_itemize

    event :new_item do
      transition :itemize => :in_item
    end

    after_transition :on => :new_item, :do => :print_item

    event :end_item do
      transition :in_item => :itemize
    end

  end

  def print_text
    @out.write(@text)
    @out.write("\n")
    @text = nil
  end

  # Passing argument to an event
  def text(text)
    @text = text.strip
    super
  end

  def print_begin_itemize
    @out.write("\\begin{itemize}")
    @out.write("\n")
  end

  def print_end_itemize
    @out.write("\\end{itemize}")
    @out.write("\n")
  end

  def print_item
    @out.write("\\item ")
  end

end

##########################################################################################
#
##########################################################################################

class ParseRichtext

  attr_reader :input
  attr_reader :output

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def initialize(input_file, output_file)

    @input_file = input_file
    @output_file = output_file

    @source = File.new(input_file)
    @out = File.open(output_file, 'w')

    @rt_machine = RichtextMachine.new
    @rt_machine.set_output(@out)

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
    when "richcontent"
      @rt_machine.rich_content
    when "body"
      @rt_machine.new_body
    when "ul"
      @rt_machine.new_itemize
    when "li"
      @rt_machine.new_item
    end
    
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def tag_end(name)

    case name
    when "richcontent"
      @rt_machine.end_rich_content
    when "body"
      @rt_machine.end_body
    when "ul"
      @rt_machine.end_itemize
    when "li"
      @rt_machine.end_item
    end

  end
  
  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def text(text)
    @rt_machine.text(text)
  end 

end

ParseRichtext.new("example/equipe.mm", "example/equipe_rich.tex")
