#!/usr/bin/env ruby -w
# encoding: UTF-8
#
# = HTMLDocument.rb -- The TaskJuggler III Project Management Software
#
# Copyright (c) 2006, 2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014
#               by Chris Schlaeger <cs@taskjuggler.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of version 2 of the GNU General Public License as
# published by the Free Software Foundation.
#

require 'taskjuggler/XMLDocument'
require 'taskjuggler/HTMLElements'

class TaskJuggler

  # HTMLDocument objects are a specialized form of XMLDocument objects. All
  # mandatory elements of a proper HTML document will be added automatically
  # upon object creation.
  class HTMLDocument < XMLDocument

    include HTMLElements

    attr_reader :html

    # When creating a HTMLDocument the caller can specify the type of HTML that
    # will be used. The constructor then generates the proper XML declaration
    # for it. :strict, :transitional and :frameset are supported for _docType_.
    def initialize(docType = :html5, &block)
      super(&block)

      unless docType == :html5
        @elements << XMLBlob.new('<?xml version="1.0" encoding="UTF-8"?>')
        case docType
        when :strict
          dtdRef = 'Strict'
          url = 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd'
        when :transitional
          dtdRef = 'Transitional'
          url = 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'
        when :frameset
          dtdRef = 'Frameset'
          url = 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd'
        else
          raise "Unsupported docType"
        end
        @elements << XMLBlob.new(
          '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 ' +
          "#{dtdRef}//EN\" \"#{url}\">")
      else
        @elements << XMLBlob.new('<!DOCTYPE html>')
      end
      @elements << XMLComment.new('This file has been generated by ' +
                                  "#{AppConfig.appName} v#{AppConfig.version}")
      attrs = { 'xml:lang' => 'en', 'lang' => 'en' }
      attrs['xmlns'] ='http://www.w3.org/1999/xhtml' unless docType == :html5
      @elements << (@html = HTML.new(attrs))
    end

    # Generate the 'head' section of an HTML page.
    def generateHead(title, metaTags = {}, blob = nil)
      @html << HEAD.new {
        e = [
          TITLE.new { title },
          META.new({ 'http-equiv' => 'Content-Type',
                     'content' => 'text/html; charset=utf-8' }),
          # Ugly hack to force IE into IE-9 mode.
          META.new({ 'http-equiv' => 'X-UA-Compatible', 'content' => 'IE=9' })
        ]
        # Include optional meta tags.
        metaTags.each do |name, content|
          e << META.new({ 'name' => name, 'content' => content })
        end
        # Add a raw HTML blob into the header if provided.
        e << XMLBlob.new(blob) if blob

        e
      }
    end

  end

end
