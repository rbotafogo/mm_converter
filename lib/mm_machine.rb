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
  attr_reader :first_attributes
  
  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def initialize(input_file, output_dir, parser)

    @level = -1
    @parser = parser
    # creating a single file, but later this should not be done here
    output = output_dir + "/" + (File.basename(input_file, '.*') + ".txt")
    @out = File.open(output, 'w')
    parser.add_observer(self)
    @first_attributes = Array.new
    super()

  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def tag_start(name, attrs)

    case name
    when "node"
      new_node(attrs)
    when "richcontent"
      rich_content
    when "attribute"
      new_attribute(attrs)
    when "body"
      new_body
    end
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def tag_end(name)

    case name
    when "node"
      exit_node
    when "richcontent"
      end_rich_content
    when "attribute"
      end_attribute
    when "body"
      end_body
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
    else
      p "ooops error"
    end

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
      
      transition :still_more_first_node_attributes => :first_node
      transition :attributes => :in_node
      transition :still_more_attributes => :in_node
    end

    # When entering on state :first_mode, :header will print the header if there is one
    after_transition :to => :first_node, :do => :process_first_node
    after_transition :to => :in_node, :do => :config_parameters, if: :one_level?

    # When receiving event :new_node, we need to move up one level in the tree.
    after_transition :on => :new_node, :do => :up_level

    # Process node
    after_transition :to => :in_node, :do => :process_node

    event :exit_node do
      # transition :first_node_attributes => :in_node
      # transition :attributes => :in_node
      # transition :still_more_attributes => :in_node
      transition :in_node => :in_node, if: :pos_level?
      transition :in_node => :awaiting_node, if: :zero_level?
    end

    after_transition :on => :exit_node, :do => :down_level

    # Receiving a new_attribute
    event :new_attribute do
      transition :first_node => :first_node_attributes
      transition :first_node_attributes => :first_node_attributes
      transition :still_more_first_node_attributes => :first_node_attributes
      transition :in_node => :attributes
      transition :attributes => :attributes
      transition :still_more_attributes => :attributes
    end

    after_transition :to => :attributes, :do => :process_attribute
    after_transition :to => :first_node_attributes, :do => :process_first_node_attribute

    event :end_attribute do
      transition :first_node_attributes => :still_more_first_node_attributes
      transition :attributes => :still_more_attributes
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

  def one_level?
    @level == 1
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def new_node(attrs)
    @node_text = attrs["TEXT"]
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

  def new_attribute(attrs)
    @new_attribute = attrs
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
  
  def process_first_node_attribute
    p "process_first_node_attribute"
    @first_attributes << @new_attribute
    p @new_attribute
  end

  def config_parameters
    p "config_parameters called"
    p @first_attributes
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------
  
  def process_attribute
    p @new_attribute
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def process_first_node
    p @node_text
  end

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def process_node
    p @node_text
  end

end


class LatexMachine < MMMachine

  
  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def process_first_node

    # FileUtils.copy_file(@template, @output)
    # @out = File.open(@output, 'a')
    @out.write("\n\n\\title{Planejamento}")
    @out.write("\n\\author{Rodrigo Botafogo}")
    @out.write("\n %\\date{} % Activate to display a given date or no date (if empty),")
    @out.write("\n % otherwise the current date is printe")
    @out.write("\n\\begin{document}")
    @out.write("\n\\maketitle")
    @out.write("\n\\end{document}")
    
    new_section(@node_text)

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
