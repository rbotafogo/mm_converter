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

require_relative 'richtext_machine'

##########################################################################################
#
##########################################################################################

class MindMapMachine
  
  attr_reader :level

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def initialize
    @level = 0
    super
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def set_output(out)
    @out = out
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  state_machine :state, initial: :awaiting_node do

    # We start the machine by awaiting on a node. Freemind is a tree structure and parsing
    # will move from node to node.  When receiving event :new_node, we move to state
    # :in_node.  If we were already on state :in_node, receiving a :new_node, keeps us in
    # state :in_noode.
    event :new_node do
      transition :awaiting_node => :in_node
      transition :in_node => :in_node
    end

    # When receiving event :new_node, we need to move up one level in the tree.
    after_transition :on => :new_node, :do => :up_level
    
    event :exit_node do
      transition :in_node => :in_node, if: :pos_level?
      transition :in_node => :awaiting_node, if: :zero_level?
    end

    after_transition :on => :exit_node, :do => :down_level

    event :new_attribute do
      transition :in_node => :attribute
    end

    event :end_attribute do
      transition :attribute => :in_node
    end

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

  def new_node(attrs)
    new_section(attrs["TEXT"])
    super
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def new_attribute(attrs)
    @out.write("\n")
    @out.write("#{attrs['NAME']}, #{attrs['VALUE']}")
    super
  end
  
  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def new_section(text)
    case @level
    when 0
      @out.write("\\del{")
    when 1
      @out.write("\n")
      @out.write("\\chapter{#{text}}")
      @out.write("\n")
    when 2
      @out.write("\\section{#{text}}")
      @out.write("\n")
    when 3
      @out.write("\\subsection{#{text}}")
      @out.write("\n")
    when 4
      @out.write("\\subsubsection{#{text}}")
      @out.write("\n")
    when 5
      @out.write("\\paragraph{#{text}}")
      @out.write("\n")
    when 6
      @out.write("\\subparagraph{#{text}}")
      @out.write("\n")
    end
  end

end

##########################################################################################
#
##########################################################################################

class ParseMM

  attr_reader :input
  attr_reader :output
  attr_reader :language

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def initialize(input_file, output_file)

    @input_file = input_file
    @output_file = output_file

    @source = File.new(input_file)
    @out = File.open(output_file, 'w')

    @mm_machine = MindMapMachine.new
    @rt_machine = RichtextMachine.new
    @mm_machine.set_output(@out)
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

  def attribute(text)
    @out.write(text)
    @out.write("\n")
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
      @out.write(text)
      @out.write("\n")
    end
  end 

end

##########################################################################################
#
##########################################################################################

class Converter

  attr_reader :input
  attr_reader :output
  attr_reader :template
  
  #----------------------------------------------------------------------------------------
  # input is a .mm file
  # template is a tex template to use
  # output is the output file.  If not given the output is the same as input with 
  # extension .tex.
  #----------------------------------------------------------------------------------------

  def initialize(input, template, output = nil)
    
    @input = input
    @template = template
    output_dir = File.dirname(input)
    @output = output_dir + "/" + ((output)? output : File.basename(input, '.*') + ".tex")

  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def header
    FileUtils.copy_file(@template, @output)
    @dest = File.open(@output, 'a')
    @dest.write("\n\n\\title{Planejamento}")
    @dest.write("\n\\author{Rodrigo Botafogo}")
    @dest.write("\n %\\date{} % Activate to display a given date or no date (if empty),")
    @dest.write("\n % otherwise the current date is printe")
    @dest.write("\n\\begin{document}")
    @dest.write("\n\\maketitle")

    @dest.write("\n\\end{document}")
    ParseMM.new(@input, @output)
  end

end

conv = Converter.new("../example/EBS.mm", "../latex_templates/portugues.tex")
conv.header

# ParseFreemind.new("EBS.mm", "ebs.tex")
