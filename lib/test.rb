
require 'oga'
require 'config'

class Handler
  
  attr_reader :names

  def initialize
    @names = []
  end

  def on_document(*arg)
    p arg
  end

  def on_doctype(*arg)
    p arg
  end

  def on_cdata(*arg)
    p arg
  end

  def on_comment(*arg)
    p arg
  end

  def on_proc_ins(*arg)
    p arg
  end

  def on_xml_decl(*arg)
    p arg
  end

  def on_text(*arg)
    p arg
  end

  def on_element(*arg)
    p arg
  end

  def on_element_children(*arg)
    p arg
  end

  def after_element(*arg)
    p arg
  end

  def text(*arg)
    p *arg
  end

end

handler = Handler.new


file_h = File.open("EBS.mm")

Oga.sax_parse_xml(handler, file_h)

=begin
doc = Oga.parse_xml(handle)
doc.each_node do |node|
  p node
end
=end
