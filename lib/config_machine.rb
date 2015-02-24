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

require_relative 'base_mm_machine'
require_relative 'mm_machine'

##########################################################################################
#
##########################################################################################

class ConfigMachine
  include BaseMMMachine

  attr_reader :first_attributes

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def initialize(input_file, output_dir, parser)
    @input_file = input_file
    @output_dir = output_dir
    @parser = parser
    @first_attributes = Hash.new
    super()
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
      transition :awaiting_node => :first_node
      transition [:first_node, :first_node_attributes, 
        :still_more_first_node_attributes] => :end_config
    end

    # When entering on state :first_mode, :header will print the header if there is one
    after_transition :to => :first_node, :do => :process_first_node
    after_transition :to => :first_node, :do => :get_header
    after_transition :to => :end_config, :do => :config_parameters

    #####################################################################################
    # What to do when receiving a new_attribute
    #####################################################################################
    # Receiving a new_attribute
    event :new_attribute do
      transition :first_node => :first_node_attributes
      transition :first_node_attributes => :first_node_attributes
      transition :still_more_first_node_attributes => :first_node_attributes
    end

    after_transition :to => :first_node_attributes, :do => :process_first_node_attribute

    event :end_attribute do
      transition :first_node_attributes => :still_more_first_node_attributes
    end

    #####################################################################################
    # Processing rich text
    #####################################################################################
    # Entering rich_content
    event :rich_content do
    end

    event :end_rich_content do
    end

    # Entering rich_content
    event :new_body do
    end

    event :end_body do
    end

  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def process_first_node
    # p @node_text
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------
  
  def process_first_node_attribute
    @first_attributes[@attribute_value['NAME']] ||= Array.new
    @first_attributes[@attribute_value['NAME']].push(@attribute_value['VALUE'])
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def get_header
    @head_node = @node_value
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def config_parameters
    # p @first_attributes
    convert_to = @first_attributes.delete('convert_to')
    raise "Convertion not specified" if convert_to == nil
    case convert_to[0]
    when "taskjuggler"
      machine = TaskjugglerMachine.new(@input_file, @output_dir, @parser)
      machine.header([@head_node, @node_value, @first_attributes])
      machine.new_node(@node_value)
      @parser.delete_observer(self)
      @parser.add_new_observer(machine)
    when "markdown"
      p "markdown"
    else
      p "latex"
    end

  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def new_node(value)
    @node_value = value
    @node_text = value["TEXT"]
    super
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def exit_node
    # p "event exit_node"
    super
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def new_attribute(value)
    @attribute_value = value
    super
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def end_attribute
    # p "event end_attribute"
    super
  end

end

