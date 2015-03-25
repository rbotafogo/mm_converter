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

require 'base_mm_machine'
require_relative 'richtext_machine'

##########################################################################################
#
##########################################################################################

class MMMachine
  include BaseMMMachine
  
  attr_reader :filename
  attr_reader :extension
  attr_reader :base_dir
  attr_reader :output_dir

  attr_reader :level
  attr_reader :head
  attr_reader :attributes

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def initialize(input_file, output_dir, parser, extension = nil)

    @base_dir = File.expand_path File.dirname(input_file)
    @filename = File.basename(input_file, '.*')
    @extension = extension

    output = output_dir + "/" + File.basename(input_file, '.*') + extension
    @out = File.open(output, 'w:UTF-8')
    @parser = parser

    @level = 0
    @attributes = Hash.new

    super()

  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def header(head)
    @head = head
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  state_machine :state, initial: :awaiting_node do

    #####################################################################################
    # What to do when we get a new_node event
    #####################################################################################
    # We start the machine by awaiting on a node. Freemind is a tree structure and parsing
    # will move from node to node.  When receiving event :new_node, we move to state
    # :in_node.  If we were already on state :in_node, receiving a :new_node, keeps us in
    # state :in_noode.
    event :new_node do
      transition :awaiting_node => :down_node
      transition [:down_node, :up_node, :leveled_node] => :down_node
      transition [:attributes, :still_more_attributes] => :down_node
      transition :supplement => :awaiting_node
    end

    event :supplement do
      transition :awaiting_node => :supplement
    end

    # When starting a machine through a link, the first node of the map is not
    # processed, so we need to down a level, for when a :new_node event is received
    # this will be the first node processed with level = 0
    after_transition :on => :supplement, :do => :down_level

    # When receiving event :new_node, we need to move add one level in the tree.
    after_transition :on => :new_node, :do => :up_level

    # Only process a node the first time we get to it, i.e., when we are going down
    # the tree.
    after_transition :to => :down_node, :do => :process_node

    #####################################################################################
    # What to do when we get an exit_node event
    #####################################################################################

    event :exit_node do
      transition [:down_node, :up_node, :leveled_node, :attribute, 
        :still_more_attributes] => :up_node, if: :pos_level?
      transition [:down_node, :up_node, :leveled_node, :attribute,
        :still_more_attributes] => :awaiting_node, if: :zero_level?
    end

    # When we exit a node, we reduce it's level on the tree
    after_transition :on => :exit_node, :do => :down_level
    before_transition :on => :exit_node, :do => :process_exit_node
    after_transition :to => :awaiting_node, :do => :close_machine

    #####################################################################################
    # What to do when receiving a new_attribute
    #####################################################################################
    # Receiving a new_attribute
    event :new_attribute do
      transition [:down_node, :up_node, :leveled_node] => :attributes
      transition :attributes => :attributes
      transition :still_more_attributes => :attributes
    end

    after_transition :to => :attributes, :do => :process_attribute

    event :end_attribute do
      transition :attributes => :still_more_attributes
    end

    #####################################################################################
    # Processing rich text
    #####################################################################################
    # Entering rich_content
    event :rich_content do
    end

  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def new_node(value)
    @node_text = value["TEXT"]
    @node_value = value
    # @level += 1
    super
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def exit_node
    # p "event exit_node"
    # @level -= 1
    super
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def new_attribute(value)
    @attribute_value = value
    # @out.write("\n")
    # @out.write("#{attrs['NAME']}, #{attrs['VALUE']}")
    super
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def end_attribute
    # p "event end_attribute"
    super
  end
  
  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def rich_content
    p "richcontent"
    super
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def close_machine
    p "Finished doing convertion"
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def pos_level?
    @level > 0
  end
 
  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def zero_level?
    @level == 0
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def up_level
    @level += 1
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def down_level
    @level -= 1
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------
  
  def process_attribute
    # p @attribute_value
    @attributes[@attribute_value['NAME']] = @attribute_value['VALUE']
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def process_node
    # p @node_value
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def process_exit_node
    # p "geting out of node"
  end

end

require_relative 'taskjuggler/taskjuggler_machine'
require_relative 'latex/latex_machine'
