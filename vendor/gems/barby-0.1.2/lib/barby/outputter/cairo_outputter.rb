require 'cairo'
require 'stringio'

module Barby
  class CairoOutputter < Outputter

    register :render_to_cairo_context
    register :to_png

    if Cairo.const_defined?(:PSSurface)
      register :to_ps
      register :to_eps if Cairo::PSSurface.method_defined?(:eps=)
    end

    register :to_pdf if Cairo.const_defined?(:PDFSurface)
    register :to_svg if Cairo.const_defined?(:SVGSurface)

    attr_writer :x, :y, :xdim, :height, :margin


    def render_to_cairo_context(context, options={})
      if context.respond_to?(:have_current_point?) and
          context.have_current_point?
        current_x, current_y = context.current_point
      else
        current_x = x(options) || margin(options)
        current_y = y(options) || margin(options)
      end

      _xdim = xdim(options)
      _height = height(options)
      context.save do
        context.set_source_color(:black)
        context.fill do
          barcode.encoding.scan(/(?:0+|1+)/).each do |codes|
            current_width = _xdim * codes.size
            if codes[0] == ?1
              context.rectangle(current_x, current_y, current_width, _height)
            end
            current_x += current_width
          end
        end
      end

      context
    end


    def to_png(options={})
      output_to_string_io do |io|
        Cairo::ImageSurface.new(options[:format],
                                full_width(options),
                                full_height(options)) do |surface|
          render(surface, options)
          surface.write_to_png(io)
        end
      end
    end


    def to_ps(options={})
      output_to_string_io do |io|
        Cairo::PSSurface.new(io,
                             full_width(options),
                             full_height(options)) do |surface|
          surface.eps = options[:eps] if surface.respond_to?(:eps=)
          render(surface, options)
        end
      end
    end


    def to_eps(options={})
      to_ps(options.merge(:eps => true))
    end


    def to_pdf(options={})
      output_to_string_io do |io|
        Cairo::PDFSurface.new(io,
                              full_width(options),
                              full_height(options)) do |surface|
          render(surface, options)
        end
      end
    end


    def to_svg(options={})
      output_to_string_io do |io|
        Cairo::SVGSurface.new(io,
                              full_width(options),
                              full_height(options)) do |surface|
          render(surface, options)
        end
      end
    end


    def x(options={})
      @x || options[:x]
    end

    def y(options={})
      @y || options[:y]
    end

    def width(options={})
      barcode.encoding.length * xdim(options)
    end

    def height(options={})
      @height || options[:height] || 50
    end

    def full_width(options={})
      width(options) + (margin(options) * 2)
    end

    def full_height(options={})
      height(options) + (margin(options) * 2)
    end

    def xdim(options={})
      @xdim || options[:xdim] || 1
    end

    def margin(options={})
      @margin || options[:margin] || 10
    end


  private

    def output_to_string_io
      io = StringIO.new
      yield(io)
      io.rewind
      io.read
    end


    def render(surface, options)
      context = Cairo::Context.new(surface)
      yield(context) if block_given?
      context.set_source_color(options[:background] || :white)
      context.paint
      render_to_cairo_context(context, options)
      context
    end


  end
end
