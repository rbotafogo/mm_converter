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
