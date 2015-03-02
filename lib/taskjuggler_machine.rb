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

    machine = JournalmodeMachine.new(@out, @parser, self)
    # machine.header([@head_node, @node_value, @first_attributes])
    # machine.new_node(@node_value)
    @parser.delete_observer(self)
    @parser.add_new_observer(machine)

  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def rich_content

    # New note on the node
    @out.print("note ")
    machine = RTMarkdownMachine.new(@out, @parser, self)
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
      super # (1)
    end
  end

  # (1) Note that when going into journalmode there is no call to super.  The original
  # machine is left in its current state and the new machine is triggered by a call to 
  # method journalmode

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

    text = @node_value['TEXT']

    # make an id for the task.  Use the task text as base and concatenate each word with
    # _ and remove any non-ascii character.
    id = String.new
    tokens = text.split(" ")
    tokens.each_with_index do |token, i|
      id << "_" if (i > 0)
      id << token.downcase
        .encode('us-ascii', :invalid => :replace, :replace => "")
        .encode('us-ascii')
      id.gsub!(/\W+/, '')
    end

    @node_id = id
    @out.print("task #{id} \"#{text}\"{\n")

  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def process_attribute

    # special treatment for some attributes, the others are left as is
    case @attribute_value['NAME']
    when "id"
      @ids[@attribute_value['VALUE']] = @node_id 
    when "depends"
      @out.print("#{make_dependencies(@attribute_value['VALUE'])}")
    when "dailymin"
      @out.print("limits {dailymin #{@attribute_value['VALUE']}}\n")
    when "dailymax"
      @out.print("limits {dailymax #{@attribute_value['VALUE']}}\n")
    when "ct_date"
      contract_date
    else
      attr_name = @attribute_value['NAME']
      if (attr_name[0] == '!')
        # remove the first character, i.e, the '!'.
        attr_name = attr_name[1..-1]
        @out.print("purge #{attr_name}\n")
      end
      @out.print("#{attr_name} #{@attribute_value['VALUE']}\n")
    end

  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  private

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def make_dependencies(val)
    new_dep = ""
    # remove '!' from the string to be tokenize and count them, as they will have to be
    # added again when the depends directive is build
    count = val.scan(/!/).count
    val.delete!("!")
    # split the string on white spaces as the depend directive can have parameters
    tokens = val.split(" ")
    # split the dependency on dots
    deps = tokens[0].split(".")
    deps.each_with_index do |dep, i|
      begin
        new_dep << "." if i > 0 
        new_dep << @ids[dep]
      rescue
        raise "There is no task with id: #{dep} in the project"
      end
    end
    tokens.shift
    new_dep = "depends " + "!" * count + new_dep + " " + tokens.join(" ") + "\n"
  end

  #----------------------------------------------------------------------------------------
  # Title needs to be changed according to language
  #----------------------------------------------------------------------------------------

  def contract_date

    @out.print("task ct_date \"Dt. limite conforme contrato\"{\n")
    @out.print("milestone\n")
    @out.print("start #{@attribute_value['VALUE']}\n")
    @out.print("}\n")

  end

end

=begin
          === Headline 2 ===
          ----
          * Bullet 1
          ** Bullet 2
          *** Bullet 3
          # Enumeration 1
          ## Enumeration 2
          ### Enumeration 3
          This is an ''italic'' word.
          This is a '''bold''' word.
          This is a ''''monospaced'''' word.
          This is a '''''italic and bold''''' word.

          [http://www.taskjuggler.org]
          [http://www.taskjuggler.org The TaskJuggler Web Site]

          [[item]]
          [[item|An item]]
=end
