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

require_relative 'journalmode_machine'

class TaskjugglerMachine < MMMachine

  #----------------------------------------------------------------------------------------
  # Event generated when the node title is "Journal" or "journal"
  #----------------------------------------------------------------------------------------

  def journalmode(value)

    compose
    machine = JournalmodeMachine.new(@out, @parser, self)
    # machine.header([@head_node, @node_value, @first_attributes])
    # machine.new_node(@node_value)
    @parser.delete_observer(self)
    @parser.add_new_observer(machine)

  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def new_node(value)
    @node_text = value["TEXT"].strip
    if (@node_text == "Journal" || @node_text == "journal")
      journalmode(value)
    else
      @node_value = value
    end
    super
  end


  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def header(head)

    attrs = head[2]

    # Use the start and period parameters to create the project start date and duration
    # attributes are stored in arrays, one can have a same attribute many times as is the
    # case with the 'include' directive.
    @out.print("project \"#{head[0]['TEXT']}\" #{attrs['start'][0]} +#{attrs['period'][0]} {\n")
    attrs.delete('start')
    attrs.delete('period')

    includes = attrs['include']
    attrs.delete('include')

    # add all attributes "as is" onto the project
    attrs.each do |attr|
      @out.print("#{attr[0]} #{attr[1][0]}")
      @out.print("\n")
    end

    @out.print("scenario plan \"Planned Scenario\" {\n")
    @out.print("scenario actual \"Actual Scenario\" {\n")
    @out.print("}\n}\n}\n")

    # Include files in the include directive
    includes.each do |include_file|
      @out.print("include \"#{include_file}\"\n")
    end
    
    @out.print("task #{head[0]['ID']} \"#{head[0]['TEXT']}\" {\n")

  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def process_node
    @node_id = @node_value['ID']
    @out.print("task #{@node_value['ID']} \"#{@node_value['TEXT']}\"{\n")
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def process_exit_node
    @out.print("}\n") unless journal_start?
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def process_attribute
    case @attribute_value['NAME']
    when "id"
      @ids[@attribute_value['VALUE']] = @node_id 
    when "depends"
      val = @attribute_value['VALUE']
      count = val.scan(/!/).count
      val.delete!("!")
      @out.print("depends #{'!' * count}#{@ids[val]}\n")
    when "dailymin"
      @out.print("limits {dailymin #{@attribute_value['VALUE']}}\n")
    when "dailymax"
      @out.print("limits {dailymax #{@attribute_value['VALUE']}}\n")
    else
      @out.print("#{@attribute_value['NAME']} #{@attribute_value['VALUE']}\n")
    end
  end

end

