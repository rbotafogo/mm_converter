##########################################################################################
# This is a simple state machine to only read the root node of an MM and use its
# attribute to configure the rest of the map's convertion
##########################################################################################

module BaseMMMachine

  #----------------------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------------------

  def tag_start(name, value)

    case name
    when "node"
      new_node(value)
    when "richcontent"
      rich_content
    when "attribute"
      new_attribute(value)
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

end

require_relative 'mm_machine'
