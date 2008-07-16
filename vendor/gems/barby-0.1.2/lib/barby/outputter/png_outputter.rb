require 'png'

module Barby

  class PngOutputter < Outputter

    register :to_png, :to_canvas

    attr_accessor :xdim, :width, :height, :margin


    def to_canvas(opts={})
      orig_opts = opts.inject({}){|h,p| send("#{p.first}=", p.last) if respond_to?("#{p.first}="); h.update(p.first => p.last) }
      canvas = PNG::Canvas.new(full_width, full_height, PNG::Color::White)

      x, y = margin, margin
      booleans.each do |bar|
        if bar
          x.upto(x+(xdim-1)) do |xx|
            y.upto y+(height-1) do |yy|
              canvas[xx,yy] = PNG::Color::Black
            end
          end
        end
        x += xdim
      end

      orig_opts.each{|k,v| send("#{k}=", v) if respond_to?("#{k}=") }
      canvas
    end


    def to_png(*a)
      PNG.new(to_canvas(*a)).to_blob
    end


    def width
      barcode.encoding.length * xdim
    end

    def height
      @height || 100
    end

    def full_width
      width + (margin * 2)
    end

    def full_height
      height + (margin * 2)
    end

    def xdim
      @xdim || 1
    end

    def margin
      @margin || 10
    end


  end

end
