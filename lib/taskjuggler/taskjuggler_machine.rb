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

  attr_reader :ids
  attr_reader :mm_id_path
  attr_reader :flags

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def initialize(input_file, output_dir, parser, extension = ".tjp", mm_id_path = Array.new)

    @final_includes = Array.new
    @ids = Hash.new
    @mm_id_path = mm_id_path

    # array for storing all flags (icons) added to a node
    @flags = Array.new

    super(input_file, output_dir, parser, extension)

  end

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

  def new_icon(value)
    # @out.print("flags #{value['BUILTIN'].gsub('-', '_')}\n")
    @flags[@level] ||= Array.new
    @flags[@level] << value['BUILTIN'].gsub('-', '_')
    super
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def supplement(node_id)

    @out.print("supplement task #{node_id} {\n")
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
    
    includes = ["#{MMConverter.taskjuggler_includes}/flags.tji"]
    includes.concat(attrs['include'])

    attrs.delete('include')

    # store all include directives that need to go to the end of the file
    @final_includes = attrs['final_include']
    attrs.delete('final_include')

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
    
    id = make_id(head[0]['TEXT'])
    # @mm_id_path << id
    @out.print("task #{id} \"#{head[0]['TEXT']}\" {\n")

  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def process_node

    text = @node_value['TEXT']
    @node_id = make_id(text)
    @out.print("task #{@node_id} \"#{text}\"{\n")

    # If node has a LINK attribute, then follow the link and parse the file
    link = @node_value['LINK']
    if link
      link.gsub!('%20', ' ')
      new_file = @base_dir + "/#{link}"
      output_dir = File.expand_path File.dirname(new_file)
      parser = ParseMM.new(new_file)
      machine = TaskjugglerMachine.new(new_file, output_dir, parser, ".tji", @mm_id_path.clone)
      @final_includes.insert(0, "#{machine.filename}#{machine.extension}")
      p "supplementing #{@mm_id_path.join(".")}"
      machine.supplement(@mm_id_path.join("."))
      parser.add_new_observer(machine)
      parser.start
    end
  
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def process_exit_node

    # p "geting out of node"

    # add flags to the end of the task specification, so that it only applies to the 
    # task and not to the subtasks
    @flags[@level].each do |flag|
      @out.print("flags #{flag}\n")
    end if @flags[@level]
    @flags[@level].clear if @flags[@level]

    @out.print("}\n")
    @mm_id_path.pop

    # when the @level == 0 if reach the end of processing
    close_machine if @level == 0

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
    when "ct_sign"
      sign_date
    when "ct_date"
      contract_date
    when "project_end"
      project_end
    else
      attr_name = @attribute_value['NAME']
      if (attr_name[0] == '!')
        # remove the first character, i.e, the '!'.
        attr_name = attr_name[1..-1]
        @out.print("purge #{attr_name}\n")
      end
      @out.print("#{attr_name} #{@attribute_value['VALUE']}\n")
    end
    super

  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def close_machine
    
    # Include files in the include directive
    @final_includes.each do |include_file|
      @out.print("include \"#{include_file}\"\n")
    end if @final_includes

    p "Successfully converted Mind Map in '#{@filename}#{@extension}'"

    @out.flush

  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  private

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def make_id(text)

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

    @mm_id_path << id
    id

  end

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
  # When the contract was signed
  #----------------------------------------------------------------------------------------

  def sign_date

    @out.print("task ct_sign \"Dt. de assinatura do contrato\"{\n")
    @out.print("milestone\n")
    @out.print("start #{@attribute_value['VALUE']}\n")
    @out.print("}\n")

  end

  #----------------------------------------------------------------------------------------
  # When the project should be delivered according to contract
  #----------------------------------------------------------------------------------------

  def contract_date

    @out.print("task ct_date \"Dt. limite conforme contrato\"{\n")
    @out.print("milestone\n")
    @out.print("start #{@attribute_value['VALUE']}\n")
    @out.print("}\n")

  end

  #----------------------------------------------------------------------------------------
  # When the project should be delivered according to contract
  #----------------------------------------------------------------------------------------

  def project_end

    @out.print("task project_end \"Final do projeto - apto para faturamento\"{\n")
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
