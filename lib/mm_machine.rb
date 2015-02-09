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

class MMMachine
  
  attr_reader :level
  
  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def initialize
    @level = 0
    @rt_machine = RichtextMachine.new
    super
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def set_output(input_file, output_dir)
    # creating a single file, but later this should not be done here
    output = output_dir + "/" + (File.basename(input_file, '.*') + ".txt")
    @out = File.open(output, 'w')
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def start
    ParseMM.new(input_file, output_dir, self)
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def print_node

    if (first_node?)
      # FileUtils.copy_file(@template, @output)
      # @out = File.open(@output, 'a')
      @out.write("\n\n\\title{Planejamento}")
      @out.write("\n\\author{Rodrigo Botafogo}")
      @out.write("\n %\\date{} % Activate to display a given date or no date (if empty),")
      @out.write("\n % otherwise the current date is printe")
      @out.write("\n\\begin{document}")
      @out.write("\n\\maketitle")
      @out.write("\n\\end{document}")
    end

    new_section(@node_text)

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
      transition :awaiting_node => :first_node
      transition :first_node => :in_node
      transition :in_node => :in_node
    end

    # When entering on state :first_mode, :header will print the header if there is one
    before_transition :on => :new_node, :do => :print_node

    # When receiving event :new_node, we need to move up one level in the tree.
    after_transition :on => :new_node, :do => :up_level
    
    event :exit_node do
      transition :in_node => :in_node, if: :pos_level?
      transition :in_node => :awaiting_node, if: :zero_level?
    end

    after_transition :on => :exit_node, :do => :down_level

    # Receiving a new_attribute
    event :new_attribute do
      transition :in_node => :attribute
    end

    event :end_attribute do
      transition :attribute => :in_node
    end

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
    @node_text = attrs["TEXT"]
    # new_section(attrs["TEXT"])
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

