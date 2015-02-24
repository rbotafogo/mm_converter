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


##########################################################################################
#
##########################################################################################

class JournalmodeMachine
  include BaseMMMachine
  
  attr_reader :level

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

  state_machine :state, initial: :journal_entry do

    #####################################################################################
    # What to do when we get a new_node event
    #####################################################################################

    event :new_node do
      transition [:journal_entry, :new_entry] => :journal_entry
      transition :attributes => :journal_entry
    end

    # Only process a node the first time we get to it, i.e., when we are going down
    # the tree.
    after_transition :to => :journal_entry, :do => :process_journalentry

    #####################################################################################
    # What to do when we get an exit_node event
    #####################################################################################

    event :exit_node do
      transition [:journal_entry, :attributes, :still_more_attributes] => 
        :journal_finish, if: :journal_ended?
      transition [:journal_entry, :attributes, :still_more_attributes] => 
        :new_entry, if: :journal?
    end

    after_transition :to => :new_entry, :do => :process_end_entry
    after_transition :to => :journal_finish, :do => :process_end_journal

    #####################################################################################
    # What to do when receiving a new_attribute
    #####################################################################################
    # Receiving a new_attribute
    event :new_attribute do
      transition :journal_entry => :attributes
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

  def new_node(value)
    @node_text = value['TEXT']
    @node_value = value
    @level += 1
    super
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def exit_node
    # p "event exit_node"
    @level -= 1
    p @level
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

  def journal?
    # p "checking journal at level: #{@level}"
    @level > 0
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def journal_ended?
    # p "checking journal ended at level: #{@level}"
    @level == 0
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def process_journalentry
    journal_header = @node_value['TEXT'].split
    date = journal_header[0]
    journal_header.shift
    headline = journal_header.join(" ")
    @out.print("journalentry #{date} #{headline}{\n")
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def process_end_entry
    @out.print("}\n")
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def process_attribute
    @out.print("#{@attribute_value['NAME']} #{@attribute_value['VALUE']}\n")
  end

  #----------------------------------------------------------------------------------------
  # End the processing of journal entries and return the processing to the original 
  # machine, whatever it was.
  #----------------------------------------------------------------------------------------

  def process_end_journal
    @parser.delete_observer(self)
    @parser.add_new_observer(@return_machine)
  end

end

