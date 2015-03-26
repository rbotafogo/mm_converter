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

require "state_machine"

##########################################################################################
#
##########################################################################################

class RichtextMachine

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def initialize(out, parser, return_machine)
    @out = out
    @parser = parser
    @return_machine = return_machine

    @level = 1
    @attributes = Hash.new
    @ids = Hash.new # this might be wrong!!! Might require a singe ids hash for the whole system
    super()
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def tag_start(name, value)

    case name
    when "richcontent"
      rich_content
    when "body"
      new_body
    when "ul"
      new_itemize
    when "li"
      new_item
    end
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def tag_end(name)

    case name
    when "richcontent"
      end_rich_content
    when "body"
      end_body
    when "ul"
      end_itemize
    when "li"
      end_item
    end
    
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def update(type, name, attrs)

    case type
    when :tag_start
      tag_start(name, attrs)
    when :tag_end
      tag_end(name)
    when :new_text
      new_text(name)
    else
      p "ooops error"
    end

  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  state_machine :state, initial: :richcontent do

    event :new_body do
      transition :richcontent => :in_body
    end

    event :end_body do
      transition :in_body => :richcontent
    end

    event :new_text do
      transition :in_body => same
      transition :in_item => same
    end

    after_transition :on => :new_text, :do => :print_text

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

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def new_body
    # p "new_body"
    super
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def new_itemize
    # p "itemize"
    super
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def new_item
    # p "item"
    super
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def new_text(text)
    @text = text.strip
    super
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def end_rich_content
    @parser.delete_observer(self)
    @parser.add_new_observer(@return_machine)
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def end_body
    # p "end_body"
    super
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def end_itemize
    # p "end_itemize"
    super
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def end_item
    # p "end_item"
    super
  end

end


require_relative 'taskjuggler/rtmarkdown_machine'
require_relative 'latex/rtlatex_machine'
