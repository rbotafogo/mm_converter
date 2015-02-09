require 'rexml/document'
require 'config'

class Handler
  
  def attlistdecl(element_name, attributes, raw_content)
    p "ATTLISTDECL"
    p "element_name: #{element_name}"
    p "attributes: #{attributes}"
    p "raw_content: #{raw_content}"
  end

  def cdata(content)
    p "CDATA"
    p "content: #{content}"
  end 

  def comment(comment)
    p "COMMENT"
    p comment
  end

  def doctype(name, pub_sys, long_name, uri)
    p "DOCTYPE"
    p name
    p pub_sys
    p long_name
    p uri
  end

  def doctype_end
    p "DOCTYPE_END"
  end

  def elementdecl(content)
    p "ELEMENTDECL"
    p content
  end

  def entity(content)
    p "ENTITY"
    p content
  end

  def entitydecl(content)
    p "ENTITYDECL"
    p arg
  end

  def instruction(name, instruction)
    p "INSTRUCTION"
    p name
    p instruction
  end

  def notationdecl(content)
    p "NOTATIONDECL"
    p content
  end

  def tag_end(name)
    p "TAG_END"
    p name
  end

  def tag_start(name, attrs)
    p "TAG_START"
    p name
    p attrs
  end

  def text(text)
    p "TEXT"
    p text
  end 

  def xmldecl(version, encoding, standalone)
    p "XMLDECL"
    p version
    p encoding
    p standalone
  end
  
end

handler = Handler.new
source = File.new("EBS.mm")

REXML::Document.parse_stream(source, handler)

